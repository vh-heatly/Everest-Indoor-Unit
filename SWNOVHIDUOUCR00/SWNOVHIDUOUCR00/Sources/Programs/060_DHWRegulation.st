USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
USING Libs.Timer;
USING Libs.ExpFilt;

PROGRAM DHWRegulation
    VAR
        (**Allow DHW*)
        AllowDHW          : BOOL;
        (**DHW top fill procent*)
        DHWTopProc        : USINT;
        (**DHW middle fill procent*)
        DHWMiddleProc     : USINT;
        (**DHW bottom fill procent*)
        DHWBottomProc     : USINT;
        (**Set/Reset DHW need*)
        SR_DHWNeed        : SR;        
        (**Circulation pump 1 timer*)
        TON_CircPump1     : TON_s;
        (**Charge regulation PID*)
        DHWChrgRegPID : PID_Incr;
        (**Temperature regulation PID*)
        DHWTempRegPID : PID_Incr;
        (**DHW block from smart grid*)
        SG_DHWBlock         : BOOL;
        (**DHW charging period timer*)
        TON_DHWChrg       : TON_s;
        (**Actual Pump start setpoint*)
        ActPmpStrtSetP    : REAL;
        (**Actual Pump stop setpoint*)
        ActPmpStopSetP    : REAL;
        (**Actual Pump start temperature*)
        ActPmpStrtTemp    : REAL;
        (**Actual Pump stop temperature*)
        ActPmpStopTemp    : REAL;
        (**Index variable*)
        i                 : INT;
        (**Heating regulation output filter*)
        DHWReg_Filt         : ExpFilt;
    END_VAR
    
    (*All the Programs are skipped while the default valeus are being installed*)
    IF RestoreDefault THEN
        RETURN;
    END_IF;
    
    SG_DHWBlock := SG_Status = SGStatus#BLOCKING_MODE
                    OR NOT(SystemCfg_AllowDHW);
    
    {REGION START/STOP TEMPERATURES}
    //Select DHW Start/stop temperatures
    IF(DhwMode = DHWMode#ECONOMY)THEN
        DHWStartTemp := DhwEcoStartTemp;
        DHWStopTemp := DhwEcoStopTemp;
    ELSIF(DhwMode = DHWMode#COMFORT)THEN
        DHWStartTemp := DhwComfStartTemp;
        DHWStopTemp := DhwComfStopTemp;
    ELSE
        DHWStartTemp := DhwNormStartTemp;
        DHWStopTemp := DhwNormStopTemp;
    END_IF;
    {ENDREGION}
    
    {REGION DHWProc calculation} //TBD
    /*  DHWTopProc := (((TO_USINT(Ain_Data.Fct.DHWTopTemp) - DhwRefTop) / TO_USINT(DhwPumpSetP) - DhwRefTop))*100;
        DHWMiddleProc := ((TO_USINT(Ain_Data.Fct.DHWMiddleTemp) - DhwRefMiddle) / TO_USINT(DhwPumpSetP) - DhwRefMiddle);
        DHWBottomProc := ((TO_USINT(Ain_Data.Fct.DHWBottomTemp) - DhwRefBottom) / TO_USINT(DhwPumpSetP) - DhwRefBottom);
        DHWProc := (DHWTopProc + DHWMiddleProc + DHWBottomProc) / 3; */
    {ENDREGION}
    
    {REGION ENABLE CHARGE}
    AllowDHW := NOT(SG_DHWBlock) AND NOT(OpModeAllowImm);  //Allow DHW as long as there is no blocking from smart grid
        
    //Determine need of DHW
    SR_DHWNeed(                                                                                          (**DHW START CONDITIONS*)
        S1 := ((Ain_Data.Fct.DHWBottomTemp < DHWStartTemp                                                //Low bottom temp.
                    OR (Ain_Data.Fct.DHWBottomTemp<ExtHotWatrStopTemp-ExtHotWatrDiff AND En_ExtHotWatr)) //Low bottom temp.(Extra hot water)
                    AND AllowDHW                                                                         //DHW is allowed
                    AND NOT(DHWNeed OR SG_DHWBlock))                                                     //Only trigger "DHW need" once
                    OR (TON_CircPump1.Q AND Ain_Data.Fct.DHWTopTemp < 45.0)                              //Pump active and low top temp.
                    AND UnitOn, 
                    //OR DHWProc < DHWStrtProc                                                           (**DHW STOP CONDITIONS*)
        R  := (Ain_Data.Fct.DHWBottomTemp >= DHWStopTemp AND NOT(En_ExtHotWatr)                          //Bottom temp. reached
                    OR (Ain_Data.Fct.DHWBottomTemp>=ExtHotWatrStopTemp AND En_ExtHotWatr)                //Bottom temp. reached(Extra hot water)
                    OR NOT(AllowDHW OR SG_DHWBlock)                                                      //DHW blocked
                    OR UnitOff)
                    //OR DHWProc >= DHWStrtProc
    );
    DHWNeed := SR_DHWNeed.Q1;
    
    //Circulation pump enable from flow
    TON_CircPump1(
        IN := Din_Data.Fct.FlowSw AND Uniton, 
        PT := TO_UINT(DhwFlowSwitchOnDel)
    );
    
    
    {ENDREGION}
    
    {REGION CHARGE MANAGEMENT}
        //DHW charging timer
        TON_DHWChrg(
            IN := DHWNeed AND OpState = OpStage_Status#DHW,
            PT := DhwTimerStop
        );
        
        //Boost compressor towards end of DHW charge
        DHWBoost := (DhwTimerStop - TON_DHWChrg.ET < DhwTimerIncComp) 
                    OR (DhwTimerStop - TON_DHWChrg.ET < DhwTimerIncComp/2 AND En_ExtHotWatr);
        
        /*    
        //Calculate current setpoint
        DHWReg_SetP := LIMIT(0, ((DHWCurve_K[Sel_HeatCurve_SetP]*OutDoorTempFilter) + DHWCurve_M[Sel_HeatCurve_SetP]), 80);
     
        //DHW charge request
        DHWChrgRegPID(
            RegVar_PID_Incr       := Ain_Data.Fct.DHWMiddleTemp,
            SetP_PID_Incr         := DHWReg_SetP,
            DeadBand_PID_Incr     := 0.0,
            Kp_PID_Incr           := DHWregPGain,
            Ti_PID_Incr           := TO_UINT(DHWRegIGain),
            Td_PID_Incr           := TO_UINT(DHWRegDGain),
            LowLim_PID_Incr       := 0.0,
            HighLim_PID_Incr      := 100.0,
            Period_PID_Incr       := 100,
            CoolHeatMode_PID_Incr := ENUM_COOL_HEAT#Heat,
            RevMode_PID_Incr      := ENUM_REV_MODE#Direct,
            ManModeVal_PID_Incr   := 0.0,
            En_PrePos_PID_Incr    := FALSE,
            En_ManMode_PID_Incr   := FALSE,
            En_PID_Incr           := DHWNeed
        );
        
        //Charge request filter
        DHWReg_Filt(
            In    := DHWChrgRegPID.Req_PID_Incr,
            Tau   := 5,
            En_FB := DHWChrgRegPID.En_PID_Incr,
            Out   => PID_DHWReq
        );
        */
    {ENDREGION}
    
    {REGION PUMP REGULATION}
    
    //Parameter selection for setpoint calculation
    IF(DhwMode = DHWMode#ECONOMY)THEN
        ActPmpStrtSetP := DhwSetPointStrtEco;
        ActPmpStopSetP := DhwSetPointStpEco;
        ActPmpStrtTemp := DhwBT3StrtEco;
        ActPmpStopTemp := DhwBT3StopEco;
    ELSIF(DhwMode = DHWMode#COMFORT) THEN
        ActPmpStrtSetP := DhwSetPointStrtCom;
        ActPmpStopSetP := DhwSetPointStpCom;
        ActPmpStrtTemp := DhwBT3StrtCom;
        ActPmpStopTemp := DhwBT3StopCom;
    ELSE
        ActPmpStrtSetP := DhwSetPointStrtNor;
        ActPmpStopSetP := DhwSetPointStpNor;
        ActPmpStrtTemp := DhwBT3StrtNor;
        ActPmpStopTemp := DhwBT3StopNor;
    END_IF;
    
    //Calculate pump regulation setpoint
    DhwPumpSetP := ScalerLimited(Ain_Data.Fct.DHWTopTemp, ActPmpStrtTemp, ActPmpStopTemp, ActPmpStrtSetP, ActPmpStopSetP);
    
    (*Temperature regulation PID*)
    DHWTempRegPID(
        RegVar_PID_Incr       := Ain_Data.Fct.DHWSupplyTemp,
        SetP_PID_Incr         := DhwPumpSetP,
        DeadBand_PID_Incr     := 0.0,
        Kp_PID_Incr           := TO_REAL(DhwPumpPGain),
        Ti_PID_Incr           := TO_UINT(DhwPumpIGain),
        Td_PID_Incr           := TO_UINT(DhwPumpDGain),
        LowLim_PID_Incr       := TO_REAL(DhwPumpMin),
        HighLim_PID_Incr      := TO_REAL(DhwPumpMax),
        Period_PID_Incr       := 100,
        CoolHeatMode_PID_Incr := ENUM_COOL_HEAT#Heat,
        RevMode_PID_Incr      := ENUM_REV_MODE#Direct,
        ManModeVal_PID_Incr   := 0.0,
        En_PrePos_PID_Incr    := FALSE,
        En_ManMode_PID_Incr   := FALSE,
        En_PID_Incr           := TON_CircPump1.Q
    );
    

    
    IF UnitOff THEN
        //Unit off
        DhwCircPumpReq := 0.0;
    ELSE
        //Pump regulation
        DhwCircPumpReq := DHWTempRegPID.Req_PID_Incr; 
    END_IF;
    
    {ENDREGION}
    
END_PROGRAM