USING System;
USING System.math;
USING Libs.Hysteresis;
USING Libs.Timer;

VAR_GLOBAL
    (**MaxTankTemp within limits*)
    MaxTankTempOk : BOOL;
    (**Comp minimum running time in heat or cool mode*)    
    TON_MinTimer          : TON_s;
    (**Timer to increase flow*)    
    TON_ProtectTimer          : TON_s;
    (**FirstCycle*)
    FirstCycle              : BOOL := 1;
        (**SR latch for Outdoor Unit freeze protection*)
        SR_OU_FreezeProt : SR;
    
END_VAR  
PROGRAM Protection
    VAR
        (**Hyster MaxTankTemp*)
        HysterAdv_MaxTempTank : HysterAdv;
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
    TON_MinTimer(
        IN := SR_OU_FreezeProt.Q1,
        PT := 600
    );
            
    TON_ProtectTimer(
        IN := NOT TON_ProtectTimer.Q,
        PT := 10
    );        
    
    SR_OU_FreezeProt(      
        S1 := (((MIN(Ain_Data.Fct.OutDoorTemp, OU_OutsideTemp)  < 5) AND (Min(OU_CondInTemp,OU_CondOutTemp) < 5) OR OU_ComError)),
        R := (MIN(Ain_Data.Fct.OutDoorTemp, OU_OutsideTemp)  > 7 AND Min(OU_CondInTemp,OU_CondOutTemp) > 20 AND TON_MinTimer.Q) 
    );
    OU_FreezeProtAct := SR_OU_FreezeProt.Q1; 
    
    IF OU_FreezeProtAct THEN
        IF FirstCycle = 1 THEN
            PumpspdFreezeProt := PumpSpdDefrost;
            FirstCycle := 0;
        ELSIF OU_WaterFlow < OU_WaterFlowLimit AND TON_ProtectTimer.Q AND PumpspdFreezeProt < 100 THEN
            PumpspdFreezeProt := PumpspdFreezeProt + 5; 
        ELSE
            
        END_IF;
    END_IF;
    
{ENDREGION}
END_PROGRAM