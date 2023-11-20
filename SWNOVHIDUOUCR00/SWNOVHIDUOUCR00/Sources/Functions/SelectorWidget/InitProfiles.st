USING System.Serial;
USING System.UI;
USING System.FileSystem;
USING System.Text;
USING System;

(**Function to set profiles*)
FUNCTION InitProfiles : BOOL

    VAR
        i : DINT;
        Profile : STRING;
    END_VAR
    
    FOR i := 0 TO 32 DO
        GetProfileByIndex(TO_USINT(i), Profile);
        IF Profile <> '' THEN
            NrProfile := NrProfile + 1;
            ProfileList[NrProfile].Name := Profile;
            ProfileList[NrProfile].MskIndex := i;
            Profile := '';
        END_IF;
    END_FOR;
    InitProfiles := NrProfile > 0;
END_FUNCTION