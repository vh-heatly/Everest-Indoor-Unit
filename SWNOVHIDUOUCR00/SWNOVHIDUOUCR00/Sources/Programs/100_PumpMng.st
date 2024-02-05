USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
USING Libs.Timer;
USING Libs.ExpFilt;

VAR_GLOBAL
    (**Actual PWM request heat medium pump*)
     Circ1Act_Req : REAL;
END_VAR

PROGRAM PumpMng

        
    IF(PumpSpdGP1Man > 0)THEN    //Manual mode
        CircPmp_Req := TO_REAL(PumpSpdGP1Man);
    ELSIF(UnitOn) THEN    //Fixed pump speed for GP1 depending on current operating mode
        IF(OpState = OpStage_Status#DEFROST)THEN
            CircPmp_Req := PumpSpdDefrost;
        ELSIF(OpState = OpStage_Status#DHW)THEN
            CircPmp_Req := PumpSpdDhwFix;
        ELSIF(OpState = OpStage_Status#HEATING) THEN
            CircPmp_Req := PumpspdHeatAuto;
        ELSIF(OpState = OpStage_Status#COOLING)THEN
            CircPmp_Req := PumpSpdCoolAuto;
        ELSE
            CircPmp_Req := 00.0;
        END_IF;
    ELSE
        CircPmp_Req := 0;
    END_IF;
    
    IF CircPmp_Req = 0 THEN // If pump shall be off the output shall be 97%
        Circ1Act_Req := 97;
    ELSE
    //Pump regulation
//    Circ1op_mode = CircPmp_Req;
    Circ1Act_Req := Scaler(CircPmp_Req, 1, 100, 84, 10); //1-100 input is reversed and pump PWM input is scaled to fit the correct PWM curve.
    END_IF;

END_PROGRAM