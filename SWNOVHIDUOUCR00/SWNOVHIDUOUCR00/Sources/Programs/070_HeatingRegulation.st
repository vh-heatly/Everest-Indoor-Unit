USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
//USING Libs.PID_ADV;
USING Libs.Timer;
USING Libs.ExpFilt;

PROGRAM HeatingRegulation
    VAR
        (**SR mode selector*)
        SR_AutoMode_Heating  : SR;
        (**Heating PID regulator*)
        PID_HeatReg          : PID_Incr;
//        (**Heating PID regulator*)
//        PID_HeatReg          : PID_Adv;
        (**Setpoint total offset*)
        SetP_Offset          : REAL;
        (**Heating blocked from smart grid*)
        SG_HeatBlock         : BOOL;
        (**Heating regulation output filter*)
        HeatReg_Filt         : ExpFilt;
        (**First Cycle done*)
        FirstCycle           : BOOL := TRUE;
        (**Shunt valve block timer*)
        TON_ShuntBlock       : TON_s;
        (**Shunt valve block pulse timer*)
        TON_ShuntBlockPulse  : TON_s;
        (**Shunt valve regulation timer*)
        TON_ShuntTimerDone   : TON_s;
        (**Shunt valve regulation factor timer*)
        TOF_ShuntFactor      : TOF_s;
        (**Shunt factor PT*)
        ShuntVlvFactor_PT    : UINT;
        (**SR shunt close*)
        SR_ShuntClose        : SR;
        (**SR shunt open*)
        SR_ShuntOpen        : SR;
        (**PID Heat Manual Value*)
        ManModeVal : REAL;
        (**Freeze time after DHW charge timer*)
        TOF_RPSBlock       : TOF_s;
        (**Setpoint calculation for Shunt control*)
        ShuntTempCalc       : REAL;
    END_VAR
    
    IF RestoreDefault THEN
        RETURN;
    END_IF;
    
    //Skip first cycle in order to avoid operating mode conflict
    IF(FirstCycle AND UnitOn)THEN
        FirstCycle := FALSE;
        RETURN;
    ELSIF(UnitOff)THEN
        FirstCycle := TRUE;
    END_IF;
    
    {REGION AUTOMODE}
        //Block heating/immersion heating from smart grid
        SG_HeatBlock := NOT(SystemCfg_AllowHeat);
    
        IF(En_AutoMode AND UnitOn)THEN
            SR_AutoMode_Heating(
                    s1 := OutDoorTempFilter < HeatModeTemp - HeatModeTempHyst
                    AND NOT(SG_HeatBlock) AND UnitON AND NOT(HeatingBlock),
                    R := OutDoorTempFilter > HeatModeTemp OR SG_HeatBlock OR UnitOff
                    );
            OpModeAllowHeat := SR_AutoMode_Heating.Q1 OR CS_FreezeProtAct;
            CS_FreezeProtReset := SR_AutoMode_Heating.Q1;
        ELSE
            OpModeAllowHeat := FALSE;
        END_IF;

        
    {ENDREGION}
    
    {REGION SETPOINT CALCULATION}
   
        //Add setpoint offset depending on smartgrid status
        IF(SG_Status = SGStatus#LOW_PRICE_MODE)THEN
            SG_Offset := TempSG1;
        ELSIF(SG_Status = SGStatus#OVERCAPACITY_MODE)THEN
            SG_Offset := TempSG2;
        ELSIF (SG_Status = SGStatus#BLOCKING_MODE)THEN
            SG_Offset := TempSG3;
        ELSE
            SG_Offset := 0;
        END_IF;
    
        //Determine total setpoint offset
        SetP_Offset := SetP_ExtAdj + SG_Offset + Offset_EBHP + HeatCurve_Offset;
        
        //Calculate current supply temperature setpoint
        SupplyTempCalc := LIMIT(TO_REAL(SupplyTempHeatMin), ((HeatCurve_K[Sel_HeatCurve_SetP]*OutDoorTemp) + HeatCurve_M[Sel_HeatCurve_SetP]) + SetP_Offset, TO_REAL(SupplyTempHeatMax));
    

    {ENDREGION}                 
   
    
    {REGION OU HEATING PID REGULATOR}
    //Timer to go back and freeze regulator/compressor rps after DHW charge -> test the timer and adjust
    TOF_RPSBlock(
                IN := OpState = OpStage_Status#DHW OR OpState = OpStage_Status#DEFROST,
                PT := 120
            );
    
    HeatReg_Temp := Ain_Data.Fct.ClimSupplyTemp;    
    IF OU_CompOn THEN
        IF OU_HP_Status = 2 OR OU_HP_Status = 8 OR DHW_InitRPS = 0 THEN
            ManModeVal := ScalerLimited(OU_Unit.CurrSpd_RPS, OU_Unit.MinRPS, OU_CompMaxRps, 0.0, 100.0); 
        ELSE
            ManModeVal := ScalerLimited(DHW_InitRPS, OU_Unit.MinRPS, OU_CompMaxRps, 0.0, 100.0);    
        END_IF;
    ELSE
        ManModeVal := 50.0;
    END_IF;
    
    PID_HeatReg(        
        RegVar_PID_Incr       := HeatReg_Temp,
        SetP_PID_Incr         := SupplyTempCalc,
        DeadBand_PID_Incr     := 0.0,
        Kp_PID_Incr           := TO_REAL(HeatRegPGain),
        Ti_PID_Incr           := TO_UINT(HeatRegIGain),
        Td_PID_Incr           := TO_UINT(HeatRegDGain),
        LowLim_PID_Incr       := 0.0,
        HighLim_PID_Incr      := 100.0,
        Period_PID_Incr       := 100,
        CoolHeatMode_PID_Incr := ENUM_COOL_HEAT#Heat,
        RevMode_PID_Incr      := ENUM_REV_MODE#Direct,
        ManModeVal_PID_Incr   := ManModeVal,
        En_PrePos_PID_Incr    := FALSE,
        En_ManMode_PID_Incr   := NOT OU_CompOn OR OU_HP_Status = 2 OR OU_HP_Status = 8 OR TOF_RPSBlock.Q,
        En_PID_Incr           := OpState = OpStage_Status#HEATING AND SR_Energybalance.Q1
    );
 

    
    //Pass filtered request to outdoor unit
    HeatReg_Filt(
        In    := PID_HeatReg.Req_PID_Incr,
        Tau   := 50,
        En_FB := PID_HeatReg.En_PID_Incr,
        Out   => PID_HeatReq
    );
    
    {ENDREGION}
    
    
        
    {REGION SHUNT VALVE}
        //Shunt valve management
        ShuntTempCalc := Sel(ImmHeatOnly, (SupplyTempCalc - 4),SupplyTempCalc);   
    
        IF(ShuntManMode)THEN
            ShuntVlv_Off := ShuntManClose AND NOT(ShuntManOpen);
            ShuntVlv_On := ShuntManOpen AND NOT(ShuntManClose);
        ELSIF (OpModeAllowHeat AND ((Ain_Data.Fct.DHWMiddleTemp+2) > Ain_Data.Fct.ClimSupplyTemp AND ImmersionHeatAllow AND HeatReq))
            OR (OpModeAllowHeat AND ImmHeatOnly) AND NOT(ShuntVlvBlock) THEN  //AND (((Ain_Data.Fct.DHWMiddleTemp+2) > Ain_Data.Fct.ClimSupplyTemp)
            
            //Invert factor calculation if supply temp is higher than setpoint
            ShuntVlvFactor_PT := SEL((ShuntTempCalc - Ain_Data.Fct.ClimSupplyTemp) < 0,
                                    TO_UINT((ShuntTempCalc - Ain_Data.Fct.ClimSupplyTemp) * ShuntVlvPFactor),
                                    TO_UINT((Ain_Data.Fct.ClimSupplyTemp - ShuntTempCalc) * ShuntVlvPFactor));
            
            //Calculate Shunt timer each ShuntTimeFactor minute while unit on
            TON_ShuntTimerDone(
                IN := NOT(TON_ShuntTimerDone.Q),
                PT := ShuntVlvTimeFactor
            );
            
            //Calculate Shunt factor -> how long steps shunt needs to take
            TOF_ShuntFactor(
                IN := TON_ShuntTimerDone.Q,
                PT := ShuntVlvFactor_PT
            );
            
            //Shunt closing management
            SR_ShuntClose(
                        S1 := (ShuntTempCalc < Ain_Data.Fct.ClimSupplyTemp AND TOF_ShuntFactor.Q) AND ImmersionHeatAllow,
                        R := NOT(TOF_ShuntFactor.Q) OR SR_ShuntOpen.Q1
                );
            ShuntVlv_Off := SR_ShuntClose.Q1;
            
            //Shunt opening management
            SR_ShuntOpen(
                        S1 := (ShuntTempCalc > Ain_Data.Fct.ClimSupplyTemp AND TOF_ShuntFactor.Q) AND ImmersionHeatAllow,
                        R := NOT(TOF_ShuntFactor.Q) OR SR_ShuntClose.Q1
                );
            
            ShuntVlv_On := SR_ShuntOpen.Q1;
            
        ELSIF(ShuntVlvBlock OR NOT ImmersionHeatAllow OR NOT OpModeAllowHeat) OR (Ain_Data.Fct.DHWMiddleTemp+2) <= Ain_Data.Fct.ClimSupplyTemp OR NOT HeatReq THEN //Block shunt valve
            ShuntVlv_On := FALSE;
            
            //After blocking shunt valve, force closing for X seconds
            TON_ShuntBlock(
                IN := (ShuntVlvBlock OR NOT ImmersionHeatAllow OR NOT OpModeAllowHeat) OR (Ain_Data.Fct.DHWMiddleTemp+2) <= Ain_Data.Fct.ClimSupplyTemp OR NOT HeatReq,
                PT := ShuntVlvBlock_Time
            );
            
            //Once inital closing procedur is complete, pulse valve closing
            IF(TON_ShuntBlock.Q)THEN
                TON_ShuntBlockPulse(
                    IN := NOT(TON_ShuntBlockPulse.Q),
                    PT := ShuntVlvBlock_PulseIntervall + ShuntVlvBlock_PulseTime
                );
            END_IF;
            
            ShuntVlv_Off := NOT(TON_ShuntBlock.Q)   //Initial close of valve
                            OR ((ShuntVlvBlock_PulseIntervall+ShuntVlvBlock_PulseTime) - TON_ShuntBlockPulse.ET) < ShuntVlvBlock_PulseTime; //Pulsing close command
        ELSE
            ShuntVlv_On := FALSE;
            ShuntVlv_Off := FALSE;
        END_IF;   
            
    {ENDREGION}   
    
    
END_PROGRAM