USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
USING Libs.Timer;
USING Libs.ExpFilt;

VAR_GLOBAL
    (**Actual PWM request DHW Pump*)
    Circ2Act_Req : REAL;
    DhwPumpMin1 : REAL;
    DhwPumpMax1 : REAL;
    DHWPumpEstimate : REAL;
    DHWPumpReg : REAL;
END_VAR

PROGRAM DHWRegulation
    VAR
        (**Allow DHW*)
        AllowDHW          : BOOL;
        (**DHW top fill procent*)
        DHWTopProc        : REAL;
        (**DHW middle fill procent*)
        DHWMiddleProc     : REAL;
        (**DHW bottom fill procent*)
        DHWBottomProc     : REAL;
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
    
    {REGION DHWProc calculation}
        DHWTopProc := Limit(0,((Ain_Data.Fct.DHWTopTemp - DhwRefTop) / (DhwRefTopN - DhwRefTop))*100,200);
        DHWMiddleProc := Limit(0,((Ain_Data.Fct.DHWMiddleTemp - DhwRefMiddle) / (DhwRefMiddleN - DhwRefMiddle))*100,200);
        DHWBottomProc := Limit(0,((Ain_Data.Fct.DHWBottomTemp - DhwRefBottom) / (DhwRefBottomN - DhwRefBottom))*100,200);
        
        IF DHWTopProc = 0 THEN
            DHWProc := 0.0;
        ELSE
            DHWProc := ((DHWTopProc + DHWMiddleProc + DHWBottomProc) / 3); 
        END_IF;
    {ENDREGION}
    
    {REGION ENABLE CHARGE}
    (**Add logic to block DHW here*)
    AllowDHW := NOT(SG_DHWBlock) AND NOT(OpModeAllowImm) AND NOT (MaxTankTempOk) AND NOT (DHWCompBlock);  //Allow DHW as long as there is no blocking from smart grid -> DHW blocked if immersion heater activated by energy balance
        
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
    
    //Calculation of waterflow
    
    
    //Circulation pump enable from flow
    TON_CircPump1(
        IN := WaterFlowD1 > 1.5 AND Uniton, 
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
    IF  Ain_Data.Fct.DHWTopTemp - DhwPumpSetP <= 7.5 THEN
        DHWPumpEstimate := Limit(0,(7.69 * ((WaterFlowD1 * 1.257) - 0.85) -84.5) ,100);                         //low Delta T formula BF2 vs GP2 flow y = 1.257 x - 0.85
    ELSIF Ain_Data.Fct.DHWTopTemp - DhwPumpSetP > 7.5 AND Ain_Data.Fct.DHWTopTemp - DhwPumpSetP <=15 THEN
        DHWPumpEstimate := Limit(0,(7.69 * ((WaterFlowD1 * 0.8621) - 0.2994)- 84.5) ,100);                      //Medium Delta T formula BF2 vs GP2 flow y = 0.8621 x - 0.2994
    ELSE        
        DHWPumpEstimate := Limit(0,(7.69 * ((WaterFlowD1 * 0.696) - 0.1418) - 84.5 ),100);                      //High Delta T formula BF2 vs GP2 flow y = 0.696 x - 0.1418
    END_IF;
            
    //DHWPumpEstimate :=0;
    DhwPumpMin1 := Limit(0, DHWPumpEstimate - 20, 100);   //Calculated pumpflow vs pump pwm 0-100% y= 7.69 x -84.5 
    DhwPumpMax1 := Limit(0, DHWPumpEstimate + 20, 100);
    
    (*Temperature regulation PID*)
    DHWTempRegPID(
        RegVar_PID_Incr       := Ain_Data.Fct.DHWSupplyTemp,
        SetP_PID_Incr         := DhwPumpSetP,
        DeadBand_PID_Incr     := 0.0,
        Kp_PID_Incr           := TO_REAL(DhwPumpPGain),
        Ti_PID_Incr           := TO_UINT(DhwPumpIGain),
        Td_PID_Incr           := TO_UINT(DhwPumpDGain),
        LowLim_PID_Incr       := DhwPumpMin1,//TO_REAL(DhwPumpMin),
        HighLim_PID_Incr      := DhwPumpMax1,//TO_REAL(DhwPumpMax),
        Period_PID_Incr       := 100,
        CoolHeatMode_PID_Incr := ENUM_COOL_HEAT#Heat,
        RevMode_PID_Incr      := ENUM_REV_MODE#Direct,
        ManModeVal_PID_Incr   := 0.0,
        En_PrePos_PID_Incr    := FALSE,
        En_ManMode_PID_Incr   := FALSE,
        En_PID_Incr           := TON_CircPump1.Q
    );
    
    DHWPumpReg := DHWTempRegPID.Req_PID_Incr;
    
    IF UnitOff OR NOT TON_CircPump1.Q OR (DHWTempRegPID.Req_PID_Incr = 0) THEN // OLD: OR (DHWTempRegPID.Req_PID_Incr = 0)
        //Unit off or PID reg 0 then pump shall be set to off
        DhwCircPumpReq :=95;
    ELSE
        //Pump regulation
//        DhwCircPumpReq := DHWTempRegPID.Req_PID_Incr;
        DhwCircPumpReq := Scaler(DHWTempRegPID.Req_PID_Incr, 0, 100, 85, 10); //1-100 input is reversed and pump PWM input is scaled to fit the correct PWM curve.
    END_IF;
    
    Circ2Act_Req := DhwCircPumpReq;
    
    {ENDREGION}
    
END_PROGRAM