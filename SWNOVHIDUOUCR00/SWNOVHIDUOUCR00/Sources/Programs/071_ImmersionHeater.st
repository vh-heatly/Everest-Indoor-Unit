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
        (**SR Opmode selector*)
        SR_OpMode_Immheat  : SR;
        (**Heating blocked from smart grid*)
        SG_HeatBlock         : BOOL;

    END_VAR
    
    SG_HeatBlock := SG_Status = SGStatus#BLOCKING_MODE
                        OR NOT(SystemCfg_AllowHeat);   
    
    
    {REGION DETERMINE NEED/ALLOW}
    
    IF(((En_AutoMode AND UnitOn) AND NOT ImmHeatOnly)AND SystemCfg_AllowImm)AND ImmHeatStage > 0 THEN            

        SR_OpMode_Immheat( 
                    s1 := OutDoorTempFilter < ImmModeTemp - ImmModeTempHyst
                    AND NOT(SG_HeatBlock) AND UnitON AND NOT(HeatingBlock),
                    R := OutDoorTempFilter > ImmModeTemp OR SG_HeatBlock OR UnitOff
                    );
                
        OpModeAllowImm := SR_OpMode_Immheat.Q1 OR SG_Status = SGStatus#OVERCAPACITY_MODE;
    ELSIF (ImmHeatOnly) THEN
        OpModeAllowImm := TRUE;
    ELSIF (CompBlock AND CS_FreezeProtAct) THEN
        OpModeAllowImm := TRUE;
    ELSE
        OpModeAllowImm := FALSE;
    END_IF;
    
    {ENDREGION}

        //Immersion heater - EB counter 
        //When the immersion heater has been active due to EB and EB have deactivated the immersion heater there is a high probability
        //that the immersion heater will be needed again in a short while. Because of this the system shall focus on using the outdoor unit for heating and not switching to DHW. 
        TOF_ImmHeatEB( 
            IN := EBHP > ((EBStepImm - EBHPCompStrt) + EBHPStepOut) AND ImmersionHeatAllow,             // Triggered when immersion heater stepsOut activated
            PT := DHWCompBlockTime*3600
            );
        SR_EB_StepOut(
                s1 := EBHP > ((EBStepImm - EBHPCompStrt) + EBHPStepOut) AND ImmersionHeatAllow AND NOT TOF_ImmHeatEB.Q,   // Triggered when immersion heater stepsOut activated
                R :=  TOF_ImmHeatEB.Q
            );
            DHWCompBlock := SR_EB_StepOut.Q1;                                                                            // Block compressor when immersion heater activated from Energy balance               
        //Allow immersion heater
        SR_AutoMode_Immheat( 
                s1 :=   (EBHP < (EBHPCompStrt + EBStepImm)) AND OpmodeAllowImm                                            // EB triggers immersion heater
                        
                        OR (OU_EnvZone > 1),                                                                            // Out of ennvelope triggers immersion heater
                R := NOT SR_EB_StepOut.Q1 AND OU_EnvZone = 1 OR UnitOff OR NOT OpModeAllowImm
                );
        ImmersionHeatAllow := SR_AutoMode_Immheat.Q1 OR SG_Status = SGStatus#OVERCAPACITY_MODE OR ImmHeatOnly;    
    
    
    {REGION STEP IN/OUT IMMERSION HEATER}
        //Select start/stop temperature depending if SG is in overcapacity mode or not
        ImmheatStepInTemp := SEL(SG_Status = SGStatus#OVERCAPACITY_MODE, 
                            MAX(DHWStartTemp, SupplyTempCalc+3), 
                            MAX(MAX(DHWStartTemp, SupplyTempCalc+3), ExtHotWatrStopTemp-ExtHotWatrDiff)); 
    
        ImmheatStepOutTemp := SEL(SG_Status = SGStatus#OVERCAPACITY_MODE, 
                            MAX(DHWStopTemp, SupplyTempCalc+6), 
                            MAX(MAX(DHWStopTemp, SupplyTempCalc+6), ExtHotWatrStopTemp));
        
        //Manual mode
        IF(ImmHeatManMode > 0 AND MaxTankTempOk)THEN
            ActImmStep := ImmHeatManMode;
        ELSIF(ImmersionHeatAllow)THEN
                
            //Allow in/out step with a set time intervall
            TON_ImmHeatStep(
                IN := ImmersionHeatAllow AND NOT(ImmheatStepDone),
                PT := ImmHeatStepDelay
            );
            
            //Reset to allow timer to start over
            IF(ImmheatStepDone)THEN
                ImmheatStepDone := FALSE;
            END_IF;
                
            //Only step in when we have additional steps to use
            IF(TON_ImmHeatStep.Q AND Ain_Data.Fct.DHWMiddleTemp < ImmheatStepInTemp AND ActImmStep < TO_UINT(ImmHeatStage)) THEN  // Protection against to high temperature
                ImmheatStepDone := TRUE;
                ActImmStep := ActImmStep + 1;
            //Only step out when any immersion heating steps are active
            ELSIF(TON_ImmHeatStep.Q AND Ain_Data.Fct.DHWBottomTemp > ImmheatStepOutTemp AND ActImmStep >= 1)THEN
                ImmheatStepDone := TRUE;
                ActImmStep := ActImmStep - 1;
            END_IF;
        ELSE            
            //Turn off immersion heaters
            ActImmStep := 0;
        
        END_IF;
    {ENDREGION}
    IF NOT MaxTankTempOk THEN
        //To high temp Turn off immersion heaters
        ActImmStep := 0;
    ELSE
        ActImmStep_Out := LIMIT(0, TO_BYTE(ActImmStep), 3);
    END_IF;
    
END_PROGRAM