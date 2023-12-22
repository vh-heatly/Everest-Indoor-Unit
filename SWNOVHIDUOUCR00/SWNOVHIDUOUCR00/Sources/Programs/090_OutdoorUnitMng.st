USING System;
USING System.Math;
USING Libs.Math;
USING Libs.Timer;

PROGRAM OutdoorUnitMng
    VAR
        (**Allow/block OU from energybalance*)
        SR_Energybalance        : SR;
        (**Start/stop outdoor unit*)
        OU_OnOff                : BOOL;
        (**Compressor speed when starting DHW*)
        DHW_InitRPS             : REAL;
        (**First DHW cycle*)
        DHW_FirstCycle          : BOOL;
    END_VAR
    
    IF RestoreDefault THEN
        RETURN;
    END_IF;
    
    {REGION ALLOW START/STOP OF OUTDOOR UNIT}
        SR_Energybalance(
            S1 := EBHP <= EBHPCompStrt AND UnitOn,
            R := (EBHP >= EBHPStopComp AND OU_Unit.CondInTemp >= SupplyTempCalc + 2) OR UnitOff
        );
    {ENDREGION}
    
    OU_Unit.Info.Enabled := NOT(NoOutdoorUnit);   
    
    IF(OU_Unit.Info.Enabled)THEN
        
        //Read OU values
        OU_OutsideTemp := OU_Unit.OutDoorTemp;
        OU_DscgP := OU_Unit.DscgP;
        OU_SuctP := OU_Unit.SuctP;
        OU_DscgTemp := OU_Unit.DscgTemp;
        OU_SuctTemp := OU_Unit.SuctTemp;
        OU_EnvZone := OU_Unit.EnvZone;
        OU_CompTemp := OU_Unit.CompTemp;
        OU_CurrSH := OU_Unit.CurrSH;
        OU_CurrSpd := OU_Unit.CurrSpd_RPS;
        OU_SHSetP := OU_Unit.CurrSHSetP;
        OU_CompOn := OU_Unit.CompOn;
        
        {REGION DHW SWITCH MANAGEMENT}
        
        //Store current compressor speed when going into DHW
        IF(OpState = OpStage_Status#DHW AND DHW_FirstCycle)THEN
            DHW_InitRPS := OU_Unit.CurrSpd_RPS;
            DHW_FirstCycle := FALSE;
        ELSIF(NOT (OpState = OpStage_Status#DHW))THEN
            DHW_FirstCycle := TRUE;
        END_IF;
        
        {ENDREGION}
        
        {REGION REQUEST MANAGER}
        //Manual mode
        IF(CompSpdMan > 0)THEN
            OU_OnOff := TRUE;
            OU_Req := MIN(CompSpdMan, OU_Unit.MaxRPS);
        ELSIF(UnitOff OR NoOutdoorUnit OR CompBlock)THEN //Unit off or outdoor unit not required
            OU_Req := 0;
            OU_OnOff := FALSE;
        ELSIF(OpState = OpStage_Status#DHW)THEN //DHW charge request
            IF(OU_Unit.CompOn AND DHW_InitRPS > 50.0)THEN //Keep compressor at steady speed if running at 50+ rps
                OU_OnOff := OU_Unit.CompOn;
                
                IF(DHWBoost)THEN // Boost compressor speed during end of DHW
                    OU_Req := MIN(DHW_InitRPS + 30.0, OU_Unit.MaxRPS);
                ELSE
                    OU_Req := DHW_InitRPS;
                END_IF;
            ELSE //DHW charge request locked at 50 rps
                OU_OnOff := TRUE;
                
                IF(DHWBoost)THEN // Boost compressor speed during end of DHW
                    OU_Req := ScalerLimited(50.0+30.0, 0.0, 100.0, 0.0, OU_Unit.MaxRPS);
                ELSE
                    OU_Req := ScalerLimited(50.0, 0.0, 100.0, 0.0, OU_Unit.MaxRPS);
                END_IF;
            END_IF;
        ELSIF(OpState = OpStage_Status#HEATING AND SR_Energybalance.Q1)THEN //Heating request
            OU_Req := ScalerLimited(PID_HeatReq, 0.0, 100.0, OU_Unit.MinRPS, OU_Unit.MaxRPS);
            OU_OnOff := TRUE;
        ELSE 
            OU_Req := 0; 
            OU_OnOff := FALSE;
        END_IF;
        {ENDREGION}
               
        //Write OU values
        OU_Unit.EEV_CompHeat := OU_CompHeat;
        OU_Unit.CompReq := OU_Req;
        OU_Unit.AlrmReset := AlrmRes;
        OU_Unit.OnOff := OU_OnOff;
    END_IF;
        
END_PROGRAM