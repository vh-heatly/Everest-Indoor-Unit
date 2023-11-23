

PROGRAM PumpMng
    IF(PumpSpdGP1Man > 0)THEN    //Manual mode
        CircPmp_Req := PumpSpdGP1Man;
    ELSIF(UnitOn) THEN    //Fixed pump speed for GP1 depending on current operating mode
        IF(OU_Unit.DefrostStatus)THEN
                CircPmp_Req := PumpSpdDefrost;
            ELSIF(OpState = OpStage_Status#DHW)THEN
                CircPmp_Req := PumpSpdDhwFix;
            ELSIF(OpState = OpStage_Status#HEATING) THEN
                CircPmp_Req := PumpspdHeatAuto;
            ELSIF(OpState = OpStage_Status#COOLING)THEN
                CircPmp_Req := PumpSpdCoolAuto;
            ELSE
                CircPmp_Req := 50.0;
        END_IF;
    ELSE
        CircPmp_Req := 0;
    END_IF;
    
END_PROGRAM