USING System;
USING System.Text;
USING System.Timer;
USING System.Serial;
USING System.Math;

(**Returns Stone project GUID splitted.*)
FUNCTION SplitPrjGUID : StonePrjGUID
    VAR_IN_OUT CONSTANT
        (**↓ Stone project GUID*)
        ProjectID : STRING;
    END_VAR
    SplitPrjGUID.Grp1 := MID(ProjectID,  8, 1);
    SplitPrjGUID.Grp2 := MID(ProjectID,  4, 1+8);
    SplitPrjGUID.Grp3 := MID(ProjectID,  4, 1+8+4);
    SplitPrjGUID.Grp4 := MID(ProjectID,  4, 1+8+4+4);
    SplitPrjGUID.Grp5 := MID(ProjectID, 12, 1+8+4+4+4);
END_FUNCTION