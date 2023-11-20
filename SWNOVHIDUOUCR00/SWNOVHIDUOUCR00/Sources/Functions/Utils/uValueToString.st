USING System;
USING System.Math;

FUNCTION uValueToString : STRING
    
    VAR_INPUT
        value       : uValue;
        dataType    : DataType;
        precision   : DINT;
    END_VAR
    
    // Note: if a datatype not present below is needed, it's enough to add a new case with the proper conversion to string
    CASE dataType OF
        DataType#BOOL   : uValueToString := SEL(value.bool, 'FALSE', 'TRUE');
        DataType#SINT   : uValueToString := TO_STRING(value.sint);
        DataType#USINT  : uValueToString := TO_STRING(value.usint);
        DataType#INT    : uValueToString := TO_STRING(value.int);
        DataType#UINT   : uValueToString := TO_STRING(value.uint);
        DataType#DINT   : uValueToString := TO_STRING(value.dint);
        DataType#UDINT  : uValueToString := TO_STRING(value.udint);
        DataType#LINT   : uValueToString := TO_STRING(value.lint);
        DataType#ULINT  : uValueToString := TO_STRING(value.ulint);
        DataType#BYTE   : uValueToString := TO_STRING(value.byte);
        DataType#WORD   : uValueToString := TO_STRING(value.word);
        DataType#DWORD  : uValueToString := TO_STRING(value.dword);
        DataType#LWORD  : uValueToString := TO_STRING(value.lword);
        DataType#REAL   : uValueToString := truncRealString(TO_STRING(value.real), precision);
        DataType#STRING : uValueToString := value.string;
    ELSE
        uValueToString  := 'UNDEFINED';
    END_CASE;

END_FUNCTION