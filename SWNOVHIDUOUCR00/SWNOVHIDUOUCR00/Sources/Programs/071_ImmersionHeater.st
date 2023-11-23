USING System;
USING System.Math;
USING Libs.Math;
USING Libs.Timer;
USING Libs.Counters;

PROGRAM ImmersionRegulation
    VAR
        (**Highest DHW start temperature*)
        ImmheatStepOutTemp   : REAL;
        (**Highest DHW stop temperature*)
        ImmheatStepInTemp    : REAL;
        (**Immersion heater step in/out timer*)
        TON_ImmHeatStep      : TON_s;
        (**Immersion heater setp in/out performed*)
        ImmheatStepDone      : BOOL := TRUE;
        (**TON imm.heater delay*)
        TON_Immheat          : TON_s;
        (**SR mode selector*)
        SR_AutoMode_Immheat  : SR;
        (**Heating blocked from smart grid*)
        SG_HeatBlock         : BOOL;
        (**Allow immersion heater*)
        ImmersionHeatAllow   : BOOL;
    END_VAR
    
    SG_HeatBlock := SG_Status = SGStatus#BLOCKING_MODE
                        OR NOT(SystemCfg_AllowHeat);   
    
    ImmersionHeatAllow := SG_Status = SGStatus#OVERCAPACITY_MODE
                        OR OU_EnvZone > 1
                        OR ImmHeatOnly;
    
    {REGION DETERMINE NEED/ALLOW}
    
    IF((En_AutoMode AND UnitOn) AND NOT ImmHeatOnly) THEN            
        //Immersion heater - outdoor temperature timer
        TON_ImmHeat( 
            IN := OutDoorTempFilter < ImmModeTemp - ImmModeTempHyst
                AND NOT(SG_HeatBlock) AND UnitON AND ImmHeatStage > 0
                AND OpModeAllowHeat,
             PT := OpModeSwitchDelay*60
            );
        //Allow immersion heater
        SR_AutoMode_Immheat( 
                s1 := (TON_Immheat.Q AND 
                        (SG_Status = SGStatus#OVERCAPACITY_MODE 
                        OR EBHP < EBHPCompStrt - EBtepImm))
                        OR NoOutdoorUnit OR NOT(OpModeAllowHeat)
                        AND UnitON AND NOT(ImmHeatBlock),
                R := OutDoorTempFilter > ImmModeTemp OR SG_HeatBlock OR UnitOff
                );
        OpModeAllowImm := SR_AutoMode_Immheat.Q1;
    ELSIF (ImmHeatOnly) THEN
            OpModeAllowImm := TRUE;
    ELSE
        OpModeAllowImm := FALSE;
    END_IF;
    
    {ENDREGION}
    
    {REGION STEP IN/OUT IMMERSION HEATER}
        //Select start/stop temperature depending if SG is in overcapacity mode or not
        ImmheatStepInTemp := SEL(SG_Status = SGStatus#OVERCAPACITY_MODE, 
                            MAX(DHWStartTemp, SupplyTempCalc+3), 
                            MAX(MAX(DHWStartTemp, SupplyTempCalc+3), ExtHotWatrStopTemp-ExtHotWatrDiff)); 
    
        ImmheatStepOutTemp := SEL(SG_Status = SGStatus#OVERCAPACITY_MODE, 
                            MAX(DHWStopTemp, SupplyTempCalc+6), 
                            MAX(MAX(DHWStopTemp, SupplyTempCalc+6), ExtHotWatrStopTemp));
        
        //Manual mode
        IF(ImmHeatManMode > 0)THEN
            ActImmStep := ImmHeatManMode;
        ELSIF(ImmHeatOnly AND ImmersionHeatAllow)THEN
                
            //Allow in/out step with a set time intervall
            TON_ImmHeatStep(
                IN := OpModeAllowImm AND ImmHeatOnly AND NOT(ImmheatStepDone),
                PT := ImmHeatStepDelay
            );
            
            //Reset to allow timer to start over
            IF(ImmheatStepDone)THEN
                ImmheatStepDone := FALSE;
            END_IF;
                
            //Only step in when we have additional steps to use
            IF(TON_ImmHeatStep.Q AND Ain_Data.Fct.DHWMiddleTemp < ImmheatStepInTemp AND ActImmStep < TO_UINT(ImmHeatStage)) THEN
                ImmheatStepDone := TRUE;
                ActImmStep := ActImmStep + 1;
            //Only step out when any immersion heating steps are active
            ELSIF(TON_ImmHeatStep.Q AND Ain_Data.Fct.DHWBottomTemp > ImmheatStepOutTemp AND ActImmStep >= 1)THEN
                ImmheatStepDone := TRUE;
                ActImmStep := ActImmStep - 1;
            END_IF;
        ELSIF(OpModeAllowImm)THEN
            //Allow in/out step with a set time intervall
            TON_ImmHeatStep(
                IN := NOT(ImmheatStepDone),
                PT := ImmHeatStepDelay
            );
            
            //Reset to allow timer to start over
            IF(ImmheatStepDone)THEN
                ImmheatStepDone := FALSE;
            END_IF;
            
            //Step in when energybalance is low
            IF(EBHP <= EBHPCompStrt - EBtepImm AND TON_ImmHeatStep.Q AND ActImmStep < TO_UINT(ImmHeatStage))THEN
                ImmheatStepDone := TRUE;
                ActImmStep := ActImmStep + 1;
            //Step out when energybalance is high
            ELSIF(EBHP >= EBHPCompStrt + EBHPStepOut AND TON_ImmHeatStep.Q AND ActImmStep >= 1)THEN
                ImmheatStepDone := TRUE;
                ActImmStep := ActImmStep - 1;
            END_IF;
        ELSE            
            //Turn off immersion heaters
            ActImmStep := 0;
        END_IF;
    {ENDREGION}
    
    ActImmStep_Out := LIMIT(0, TO_BYTE(ActImmStep), 3);
    
END_PROGRAM