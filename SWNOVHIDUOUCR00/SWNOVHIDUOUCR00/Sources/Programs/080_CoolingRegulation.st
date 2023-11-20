USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
USING Libs.Timer;

PROGRAM CoolingRegulation
    VAR
        (**SR mode selector*)
        SR_AutoMode          : SR;
        (**TON cooling delay*)
        TON_Cooling          : TON_s;
    END_VAR
    
    IF RestoreDefault THEN
        RETURN;
    END_IF;
    
        TON_Cooling( //Cooling mode
            IN := OutDoorTempFilter > CoolModeTemp,
            PT := OpModeSwitchDelay*60
            );
        SR_AutoMode(
                s1 := TON_Cooling.Q,
                R := OutDoorTempFilter < CoolModeTemp - CoolModeTempHyst
                );
        OpModeAllowCool := SR_AutoMode.Q1;    
    
END_PROGRAM