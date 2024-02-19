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
    (**DHW charging period timer*)
    TON_DHWChrg       : TON_s;
    (**Extra hotwater timer*)
    TOF_ExtHotWatr     : TOF_s;  
    (**Extra hotwater pulse*)
    R_Edge_tmp          : system.timer.R_Edge;
   
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
        SR_DHWNeed        : RS;        
        (**Circulation pump 1 timer*)
        TON_CircPump1     : TON_s;
//        (**Charge regulation PID*)
//        DHWChrgRegPID : PID_Incr;
        (**Temperature regulation PID*)
        DHWTempRegPID : PID_Incr;
        (**DHW block from smart grid*)
        SG_DHWBlock         : BOOL;
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
//        (**Heating regulation output filter*)
//        DHWReg_Filt         : ExpFilt;
        (**Circulation pump 1 low speed timer*)
        TON_GP1_LowSpd      : TON_s;
    END_VAR
    
    (*All the Programs are skipped while the default valeus are being installed*)
    IF RestoreDefault THEN
        RETURN;
    END_IF;
    
    SG_DHWBlock := SG_Status = SGStatus#BLOCKING_MODE
                    OR NOT(SystemCfg_AllowDHW);
    
    {REGION Extra Hot Water}
    (*Creates pulse on rising edge of ExtHotwatrEnbl**)
    R_Edge_tmp(
        In := ExtHotWatrEnbl,
        Reset := R_Edge_tmp.Out
        );
    (*Off delay to turn of after set time**)
    TOF_ExtHotWatr(
        IN := R_Edge_tmp.Out,
        PT := ExtHotWatrTime * 60
    );
    (**Disable ExtHotWatr when timer is done*)
    IF ExtHotWatrEnbl AND NOT TOF_ExtHotWatr.Q THEN
        ExtHotWatrEnbl := FALSE;
    END_IF;
   

    (*The extra hotwter enabled from input signal with timer or from SmartGrid [1:1]**)
    En_ExtHotWatr := ExtHotWatrEnbl OR SG_Status = SGStatus#OVERCAPACITY_MODE;
    
    {ENDREGION}
    
    {REGION START/STOP TEMPERATURES}
    //Select DHW Start/stop temperatures
    IF(DhwMode = DHWMode#ECONOMY)THEN
        DHWStartTemp := DhwEcoStartTemp;
        DHWStopTemp := DhwEcoStopTemp;
    ELSIF(DhwMode = DHWMode#COMFORT) OR (SG_Status = SGStatus#LOW_PRICE_MODE) THEN
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
    AllowDHW := NOT(SG_DHWBlock) AND NOT(ImmersionHeatAllow) AND (MaxTankTempOk) AND NOT (DHWCompBlock) AND NOT DHWFrcSwitch;  //Allow DHW as long as there is no blocking from smart grid -> DHW blocked if immersion heater activated by energy balance
        
    //Determine need of DHW
    SR_DHWNeed(                                                                                          (**DHW START CONDITIONS*)
        S := ((Ain_Data.Fct.DHWMiddleTemp < DHWStartTemp                                                   //Low middle temp.
                    OR (Ain_Data.Fct.DHWMiddleTemp<ExtHotWatrStopTemp-ExtHotWatrDiff AND En_ExtHotWatr))   //Low middle temp.(Extra hot water)
                    AND AllowDHW AND NOT TON_CircPump1.Q)                                                  //DHW is allowed
                                                                         
                    OR ((TON_CircPump1.Q AND Ain_Data.Fct.DHWTopTemp < 45.0)                               //Pump active and low top temp.
                    AND UnitOn AND AllowDHW), 
                    //OR DHWProc < DHWStrtProc                                                           (**DHW STOP CONDITIONS*)
        R1  := (Ain_Data.Fct.DHWBottomTemp >= DHWStopTemp AND NOT(En_ExtHotWatr)                           //Bottom temp. reached
                    OR (Ain_Data.Fct.DHWBottomTemp>=ExtHotWatrStopTemp AND En_ExtHotWatr)                  //Bottom temp. reached(Extra hot water)
                    OR NOT(AllowDHW) OR SG_DHWBlock                                                        //DHW blocked
                    OR UnitOff)                                                          
                    //OR DHWProc >= DHWStrtProc
    );
    DHWNeed := SR_DHWNeed.Q1;
    
    //Calculation of waterflow
    
    
    //Circulation pump enable from flow
    TON_CircPump1(
        IN := WaterFlow_DHW > 1.5 AND Uniton, 
        PT := TO_UINT(DhwFlowSwitchOnDel)
    );
    
    
    {ENDREGION}
    
    {REGION CHARGE MANAGEMENT}
        //DHW charging timer
//        TON_DHWChrg(
//            IN := DHWNeed AND OpState = OpStage_Status#DHW,
//            PT := DhwTimerStop*60
//        );
        
   
        //Boost compressor towards end of DHW charge
        IF En_ExtHotWatr THEN
            DHWBoost := (To_Real(TON_DHWTimer.ET) > To_Real(DhwTimerStop) * 60 * DhwBoostPercExtHotWatr * 0.01);
        ELSE
            DHWBoost := (TO_REAL(TON_DHWTimer.ET) > To_REAL(DhwTimerStop) * 60 * DhwBoostPerc * 0.01);
        END_IF;
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
        DHWPumpEstimate := Limit(0,(7.69 * ((WaterFlow_DHW * 1.257) - 0.85) -84.5) ,100);                         //low Delta T formula BF2 vs GP2 flow y = 1.257 x - 0.85
    ELSIF Ain_Data.Fct.DHWTopTemp - DhwPumpSetP > 7.5 AND Ain_Data.Fct.DHWTopTemp - DhwPumpSetP <=15 THEN
        DHWPumpEstimate := Limit(0,(7.69 * ((WaterFlow_DHW * 0.8621) - 0.2994)- 84.5) ,100);                      //Medium Delta T formula BF2 vs GP2 flow y = 0.8621 x - 0.2994
    ELSE        
        DHWPumpEstimate := Limit(0,(7.69 * ((WaterFlow_DHW * 0.696) - 0.1418) - 84.5 ),100);                      //High Delta T formula BF2 vs GP2 flow y = 0.696 x - 0.1418
    END_IF;
            
    //DHWPumpEstimate :=0;
    DhwPumpMin1 := Limit(0, DHWPumpEstimate - 40, 100);   //Calculated pumpflow vs pump pwm 0-100% y= 7.69 x -84.5 
    DhwPumpMax1 := Limit(0, DHWPumpEstimate + 10, 100);
    
    (*Temperature regulation PID*)
    DHWTempRegPID(
        RegVar_PID_Incr       := Ain_Data.Fct.DHWSupplyTemp,
        SetP_PID_Incr         := DhwPumpSetP,
        DeadBand_PID_Incr     := 0.0,
        Kp_PID_Incr           := TO_REAL(DhwPumpPGain),
        Ti_PID_Incr           := TO_UINT(DhwPumpIGain),
        Td_PID_Incr           := TO_UINT(DhwPumpDGain),
        LowLim_PID_Incr       := TO_REAL(DhwPumpMin),//DhwPumpMin1,//
        HighLim_PID_Incr      := TO_REAL(DhwPumpMax),//DhwPumpMax1,//
        Period_PID_Incr       := 100,
        CoolHeatMode_PID_Incr := ENUM_COOL_HEAT#Heat,
        RevMode_PID_Incr      := ENUM_REV_MODE#Direct,
        ManModeVal_PID_Incr   := TO_REAL(PumpSpdGP2Man),
        En_PrePos_PID_Incr    := FALSE,
        En_ManMode_PID_Incr   := PumpSpdGP2Man > 0,
        En_PID_Incr           := TON_CircPump1.Q
    );
    
    DHWPumpReg := DHWTempRegPID.Req_PID_Incr;
    
    TON_GP1_LowSpd(
        IN := TON_CircPump1.Q AND NOT(TON_GP1_LowSpd.Q),
        PT := 1
        );
    
    IF UnitOff OR NOT TON_CircPump1.Q  THEN // OLD: OR (DHWTempRegPID.Req_PID_Incr = 0)
        //Unit off or PID reg 0 then pump shall be set to off
        DhwCircPumpReq :=97;
    ELSIF (DHWTempRegPID.Req_PID_Incr = 0) AND TON_CircPump1.Q THEN
        IF TON_GP1_LowSpd.Q THEN
            DhwCircPumpReq := 85;
        ELSE
            DhwCircPumpReq := 97;
        END_IF;
    ELSE
        //Pump regulation
        DhwCircPumpReq := Scaler(DHWTempRegPID.Req_PID_Incr, 0, 100, 84, 10); //0-100 input is reversed and pump PWM input is scaled to fit the correct PWM curve.
    END_IF;
    
    Circ2Act_Req := DhwCircPumpReq;
    
    {ENDREGION}
    
END_PROGRAM