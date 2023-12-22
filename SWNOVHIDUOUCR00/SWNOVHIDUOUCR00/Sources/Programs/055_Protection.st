USING System;
USING Libs.Hysteresis;

    VAR_GLOBAL
        (**Hyster MaxTankTemp*)
        HysterAdv_MaxTempTank : HysterAdv;
        MaxTankTempOk : BOOL;
    END_VAR  
PROGRAM Protection
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
END_PROGRAM