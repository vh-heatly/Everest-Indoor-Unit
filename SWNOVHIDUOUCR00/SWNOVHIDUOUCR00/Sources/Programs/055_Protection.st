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
        (**SR latch for Outdoor Unit freeze protection*)
        SR_OU_FreezeProt : SR;
        (**SR latch for Climate System freeze protection*)
        SR_CS_FreezeProt : SR;
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
    SR_CS_FreezeProt(      
        S1 := Ain_Data.Fct.OutDoorTemp < 3.5 AND NOT OpModeAllowHeat AND Ain_Data.Fct.ClimSupplyTemp < TO_REAL(SupplyTempHeatMin),
        R := (CS_FreezeProtReset OR Ain_Data.Fct.OutDoorTemp > 5) 
    );
    CS_FreezeProtAct := SR_CS_FreezeProt.Q1;
{ENDREGION} 
    
{REGION FREEZE PROTECTION OUTDOOR UNIT}
    
    
    SR_OU_FreezeProt(      
        S1 := (((MIN(Ain_Data.Fct.OutDoorTemp, OU_OutsideTemp)  < 5) AND (Min(OU_CondInTemp,OU_CondOutTemp) < 5) OR OU_ComError)),
        R := (MIN(Ain_Data.Fct.OutDoorTemp, OU_OutsideTemp)  > 7 AND Min(OU_CondInTemp,OU_CondOutTemp) > 20) 
    );
    //OU_FreezeProtAct := SR_OU_FreezeProt.Q1;   Add action for outdoor unit pump etc....
{ENDREGION}
END_PROGRAM