USING System;
USING System.math;
USING Libs.Hysteresis;

VAR_GLOBAL
    (**MaxTankTemp within limits*)
    MaxTankTempOk : BOOL;
    
END_VAR  
PROGRAM Protection
    VAR
        (**Hyster MaxTankTemp*)
        HysterAdv_MaxTempTank : HysterAdv;
        (**SR latch for Climate System freeze protection*)
        RS_CS_FreezeProt : RS;
        (**SR latch for Outdoor Unit freeze protection*)
        RS_OU_FreezeProt : RS;
    END_VAR
{REGION MaxTankTemp}   
    HysterAdv_MaxTempTank(  
        In:= Ain_Data.Fct.DHWMiddleTemp , 
        SetP := MaxTankTemp, 
        DiffLeft := 3.0, 
        DiffRight := 0.0, 
        Reverse := TRUE
    );        
        
MaxTankTempOk := HysterAdv_MaxTempTank.Out;
    
{ENDREGION}
    
{REGION FREEZE PROTECTION CLIMATE SYTEM}
    RS_CS_FreezeProt(      
        S := OutDoorTemp < 3.5 AND NOT OpModeAllowHeat AND Ain_Data.Fct.ClimSupplyTemp < TO_REAL(SupplyTempHeatMin) AND NOT RS_CS_FreezeProt.Q1,
        R1 := (CS_FreezeProtReset OR OutDoorTemp > 5) 
    );
    CS_FreezeProtAct := RS_CS_FreezeProt.Q1;
{ENDREGION} 
    
{REGION FREEZE PROTECTION OUTDOOR UNIT}
    RS_OU_FreezeProt(      
        S := MIN(OutDoorTemp, OU_OutsideTemp)  < 5 AND OU_CondInTemp < 5 AND OU_CondOutTemp < 5  AND NOT RS_OU_FreezeProt.Q1,
        R1 := (MIN(OutDoorTemp, OU_OutsideTemp)  < 7 AND OU_CondInTemp > 20 AND OU_CondOutTemp > 20) 
    );
    //OU_FreezeProtAct := RS_OU_FreezeProt.Q1;
{ENDREGION}
END_PROGRAM