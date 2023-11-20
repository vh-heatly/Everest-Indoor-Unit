USING System;
USING System.Timer;

FUNCTION FindTimezoneIndex : UINT
    VAR_IN_OUT CONSTANT
		(**List of time zones available from the software*)
        TimeZonePosixList : ARRAY[*] OF STRING;
		(**The time zone posix to find*)
		TimeZonePosix : STRING;
	END_VAR
    VAR
        i : DINT;
    END_VAR
    
    FOR i := LOWER_BOUND(TimeZonePosixList, 1) TO UPPER_BOUND(TimeZonePosixList, 1) DO
        IF TimeZonePosix = TimeZonePosixList[i] THEN
            FindTimezoneIndex := TO_UINT(i);
            EXIT;
        END_IF;                    
    END_FOR;
END_FUNCTION