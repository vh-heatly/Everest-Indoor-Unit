USING System;
USING System.Math;
USING System.Text;

FUNCTION truncRealString : STRING

    VAR_INPUT
        string : STRING;
        precision : DINT;
    END_VAR
    IF precision <= 0 THEN 
        precision := - 1;
    END_IF;

    truncRealString := LEFT(string, FIND(string, '.') + precision);
    truncRealString := truncRealString;
END_FUNCTION