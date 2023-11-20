USING System;
USING System.Math;
USING System.Timer;
USING Libs.Counters;

PROGRAM HoursCounterMng
    VAR
        (**Used for debug: n° of seconds for hour (Set 0=3600s)*)
        HrsCntrAdjust  : UINT;
        (**Source circuit 1 HoursCounter FB*)
        HrsCntr_Source1Circ1 : HoursCounter;
    END_VAR    
    
    (*All the Programs are skipped while the default valeus are being installed*)
    IF RestoreDefault THEN
        RETURN;
    END_IF;
    
    (*--------------------------------
               HOURS COUNTER RESET
      --------------------------------*)
    IF ResTotCnt THEN
        ResTotCnt := FALSE;                                             (* Auto-Reset *) 
    END_IF;
END_PROGRAM