USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
USING Libs.Timer;
USING Libs.ExpFilt;

PROGRAM HeatingRegulation
    VAR
        (**SR mode selector*)
        SR_AutoMode_Heating  : SR;
        (**Heating PID regulator*)
        PID_HeatReg          : PID_Incr;
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
        SG_HeatBlock := SG_Status = SGStatus#BLOCKING_MODE
                        OR NOT(SystemCfg_AllowHeat);
    
        IF(En_AutoMode AND UnitOn)THEN
            SR_AutoMode_Heating(
                    s1 := OutDoorTempFilter < HeatModeTemp - HeatModeTempHyst
                    AND NOT(SG_HeatBlock) AND UnitON AND NOT(HeatingBlock),
                    R := OutDoorTempFilter > HeatModeTemp OR SG_HeatBlock OR UnitOff
                    );
            OpModeAllowHeat := SR_AutoMode_Heating.Q1;
            CS_FreezeProtReset := SR_AutoMode_Heating.Q1;
        ELSIF CS_FreezeProtAct THEN // Freeze protection active override logic for OpModeAllowHeat
            OpModeAllowHeat := TRUE;
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
        ELSE
            SG_Offset := 0;
        END_IF;
    
        //Determine total setpoint offset
        SetP_Offset := SetP_ExtAdj + SG_Offset + Offset_EBHP + HeatCurve_Offset;
        
        //Calculate current supply temperature setpoint
        SupplyTempCalc := LIMIT(TO_REAL(SupplyTempHeatMin), ((HeatCurve_K[Sel_HeatCurve_SetP]*OutDoorTemp) + HeatCurve_M[Sel_HeatCurve_SetP]) + SetP_Offset, TO_REAL(SupplyTempHeatMax));
    

    {ENDREGION}                 
   
    
    {REGION OU HEATING PID REGULATOR}
    
    HeatReg_Temp := Ain_Data.Fct.ClimSupplyTemp;    
    
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
        ManModeVal_PID_Incr   := 0.0,
        En_PrePos_PID_Incr    := FALSE,
        En_ManMode_PID_Incr   := FALSE,
        En_PID_Incr           := OpModeAllowHeat
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
    
        IF(ShuntManMode)THEN
            ShuntVlv_Off := ShuntManClose AND NOT(ShuntManOpen);
            ShuntVlv_On := ShuntManOpen AND NOT(ShuntManClose);
        ELSIF OpModeAllowHeat AND (((Ain_Data.Fct.DHWMiddleTemp+2) > Ain_Data.Fct.ClimSupplyTemp) AND ImmersionHeatAllow) 
            OR (OpModeAllowHeat AND ImmHeatOnly) AND NOT(ShuntVlvBlock) THEN
            
            //Invert factor calculation if supply temp is higher than setpoint
            ShuntVlvFactor_PT := SEL((SupplyTempCalc - Ain_Data.Fct.ClimSupplyTemp) < 0,
                                    TO_UINT((SupplyTempCalc - Ain_Data.Fct.ClimSupplyTemp) * ShuntVlvPFactor),
                                    TO_UINT((Ain_Data.Fct.ClimSupplyTemp - SupplyTempCalc) * ShuntVlvPFactor));
            
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
                        S1 := (SupplyTempCalc < Ain_Data.Fct.ClimSupplyTemp AND TOF_ShuntFactor.Q) AND ImmersionHeatAllow,
                        R := NOT(TOF_ShuntFactor.Q) OR SR_ShuntOpen.Q1
                );
            ShuntVlv_Off := SR_ShuntClose.Q1;
            
            //Shunt opening management
            SR_ShuntOpen(
                        S1 := (SupplyTempCalc > Ain_Data.Fct.ClimSupplyTemp AND TOF_ShuntFactor.Q) AND ImmersionHeatAllow,
                        R := NOT(TOF_ShuntFactor.Q) OR SR_ShuntClose.Q1
                );
            
            ShuntVlv_On := SR_ShuntOpen.Q1;
            
        ELSIF(ShuntVlvBlock OR NOT ImmersionHeatAllow OR NOT OpModeAllowHeat)THEN //Block shunt valve
            ShuntVlv_On := FALSE;
            
            //After blocking shunt valve, force closing for X seconds
            TON_ShuntBlock(
                IN := ShuntVlvBlock,
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