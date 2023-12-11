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
        TOF_ImmheatEB        : TON_s;
        (** EB counter step out immersion heater*)
        SR_EB_StepOut        : SR;
        (**SR mode selector*)
        SR_AutoMode_Immheat  : SR;
        (**Heating blocked from smart grid*)
        SG_HeatBlock         : BOOL;
//        (**Allow immersion heater*)
//        ImmersionHeatAllow   : BOOL;
    END_VAR
    
    SG_HeatBlock := SG_Status = SGStatus#BLOCKING_MODE
                        OR NOT(SystemCfg_AllowHeat);   
    
//    ImmersionHeatAllow := SG_Status = SGStatus#OVERCAPACITY_MODE
//                        OR OU_EnvZone > 1
//                        OR ImmHeatOnly;
    
    {REGION DETERMINE NEED/ALLOW}
    
    IF(((En_AutoMode AND UnitOn) AND NOT ImmHeatOnly)AND SystemCfg_AllowImm)AND ImmHeatStage > 0 THEN            
        //Immersion heater - EB counter 
        //When the immersion heater has been active due to EB and EB have deactivated the immersion heater there is a high probability
        //that the immersion heater will be needed again in a short while. Because of this the system shall focus on using the outdoor unit for heating and not switching to DHW. 
        TOF_ImmHeatEB( 
            IN := (EBHP > (EBHPCompStrt + EBtepImm)) AND OpModeAllowHeat,
            PT := DHWCompBlockTime*3600
            );
        SR_EB_StepOut(
                s1 := (EBHP > (EBHPCompStrt + EBtepImm)) AND OpModeAllowHeat,
                R :=  TOF_ImmHeatEB.Q
            );
        //Allow immersion heater
        SR_AutoMode_Immheat( 
                s1 :=   (EBHP < (EBHPCompStrt + EBtepImm))                                           // EB triggers immersion heater
                        
                        OR (OU_EnvZone > 1),
                R := SR_EB_StepOut.Q1 AND OU_EnvZone = 1 OR UnitOff
                );
        OpModeAllowImm := SR_AutoMode_Immheat.Q1 OR SG_Status = SGStatus#OVERCAPACITY_MODE OR NoOutdoorUnit;
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
        ELSIF(ImmHeatOnly OR OpModeAllowImm)THEN
                
            //Allow in/out step with a set time intervall
            TON_ImmHeatStep(
                IN := OpModeAllowImm AND NOT(ImmheatStepDone),
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
//        ELSIF(OpModeAllowImm)THEN
//            //Allow in/out step with a set time intervall
//            TON_ImmHeatStep(
//                IN := NOT(ImmheatStepDone),
//                PT := ImmHeatStepDelay
//            );
            
//            //Reset to allow timer to start over
//            IF(ImmheatStepDone)THEN
//                ImmheatStepDone := FALSE;
//            END_IF;
            
//            //Step in when energybalance is low
//            IF(EBHP <= EBHPCompStrt - EBtepImm AND TON_ImmHeatStep.Q AND ActImmStep < TO_UINT(ImmHeatStage))THEN
//                ImmheatStepDone := TRUE;
//                ActImmStep := ActImmStep + 1;
//            //Step out when energybalance is high
//            ELSIF(EBHP >= EBHPCompStrt + EBHPStepOut AND TON_ImmHeatStep.Q AND ActImmStep >= 1)THEN
//                ImmheatStepDone := TRUE;
//                ActImmStep := ActImmStep - 1;
//            END_IF;
//        ELSE            
//            //Turn off immersion heaters
//            ActImmStep := 0;
        END_IF;
    {ENDREGION}
    
    ActImmStep_Out := LIMIT(0, TO_BYTE(ActImmStep), 3);
    
END_PROGRAM