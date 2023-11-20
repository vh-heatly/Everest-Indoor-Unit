USING System;

FUNCTION uValueToInt : INT
    
    VAR_INPUT
        value : uValue;
        dataType : DataType;
    END_VAR
    
    // Note: if a datatype not present below is needed, it's enough to add a new case with the proper conversion to string
    CASE dataType OF
        DataType#BOOL   : uValueToInt := TO_INT(value.bool);
        DataType#SINT   : uValueToInt := TO_INT(value.sint);
        DataType#USINT  : uValueToInt := TO_INT(value.usint);
        DataType#INT    : uValueToInt := TO_INT(value.int);
        DataType#UINT   : uValueToInt := TO_INT(value.uint);
        DataType#DINT   : uValueToInt := TO_INT(value.dint);
        DataType#UDINT  : uValueToInt := TO_INT(value.udint);
        DataType#LINT   : uValueToInt := TO_INT(value.lint);
        DataType#ULINT  : uValueToInt := TO_INT(value.ulint);
        DataType#REAL   : uValueToInt := TO_INT(value.real);
    ELSE
        uValueToInt := -999;
    END_CASE;    
END_FUNCTION