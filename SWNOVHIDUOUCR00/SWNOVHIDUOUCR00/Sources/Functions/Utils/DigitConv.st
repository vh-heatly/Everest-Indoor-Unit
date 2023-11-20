USING System;
USING System.Timer; 
USING System.Math;

FUNCTION_BLOCK DigitConv
    VAR_INPUT
        Input : INT;
    END_VAR
    VAR_OUTPUT

        Digit_0   : INT;
        Digit_1   : INT;
        Digit_2   : INT;
        Digit_3   : INT;
        Digit_4   : INT;
        Digit_Sign: BOOL;

    END_VAR
    
    VAR
        Input_Int : INT;
    END_VAR
    
    IF Input<=-1 THEN
	    Digit_Sign:=TRUE;
	    Input_Int:=(-1*Input);
    ELSE 
	    Digit_Sign:=FALSE;
	    Input_Int:=(Input);
    END_IF;

    Digit_4:=Input_Int/10000;
    Digit_3:=(Input_Int-Digit_4*10000)/1000;
    Digit_2:=(Input_Int-Digit_4*10000-Digit_3*1000)/100;
    Digit_1:=(Input_Int-Digit_4*10000-Digit_3*1000-Digit_2*100)/10;
    Digit_0:=(Input_Int-Digit_4*10000-Digit_3*1000-Digit_2*100-Digit_1*10)/1;
END_FUNCTION_BLOCK

