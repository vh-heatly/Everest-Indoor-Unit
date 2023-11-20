USING System.UI;
USING System;
{IF DEF (PGD)}
	USING Libs.TerminalDetector;
{ENDIF}

(* 0 highest priority, 10 lowest *)
CONFIGURATION __CONFIGURATION__
	RESOURCE __RESOURCE__ ON RUNTIMETARGET
		TASK ExceptionTask (SYSTEM := EVENT_EXCEPTION OR EVENT_ULTRACAP_POWER OR EVENT_STOP_ULTRACAP_POWER, PRIORITY := 0);
		    PROGRAM ExceptionInstance WITH ExceptionTask : ExceptionManager;

        TASK MainTask (INTERVAL := MAIN_TASK_INTERVAL, PRIORITY := 3);
            PROGRAM UIManagerInstance       WITH MainTask : UIManager;
        	PROGRAM MainInstance            WITH MainTask : Main;
            PROGRAM InputMngInstance        WITH MainTask : InputMng;
            PROGRAM AlarmsMngInstance       WITH MainTask : AlarmsMng;
            PROGRAM StoreAlarmsINstance     WITH MainTask : StoreAlarms;
            PROGRAM OnOffUnitInstance       WITH MainTask : OnOffUnit;
            PROGRAM RegulationModeInstance  WITH MainTask : RegulationMode;
            PROGRAM DHWRegulationInstance   WITH MainTask : DHWRegulation;
            PROGRAM HeatingRegulationInstance   WITH MainTask : HeatingRegulation;
            PROGRAM ImmersionRegulationInstance WITH MainTask : ImmersionRegulation;
            PROGRAM CoolingRegulationInstance   WITH MainTask : CoolingRegulation;
            PROGRAM OutDoorUnitInstance     WITH MainTask : OutdoorUnitMng;
            PROGRAM PumpMngInstance         WITH MainTask : PumpMng;
            PROGRAM HoursCounterMngInstance WITH MainTask : HoursCounterMng;
            PROGRAM OutputMngInstance       WITH MainTask : OutputMng;    
            PROGRAM MainEndInstance         WITH MainTask : MainEnd;
	END_RESOURCE
END_CONFIGURATION

{IF DEF (PGD)}
	VAR_GLOBAL
	    TerminalDetector : TerminalDetector;
	END_VAR
{ENDIF}

{METADATA NOT_AN_ACTION}
FUNCTION ManageKey : BOOL
    VAR_INPUT
        keyPressed : UINT;
        keyCounter : UINT;
    END_VAR
    pGD2.OnGui(keyPressed, keyCounter);
    ManageKey := TRUE;
END_FUNCTION