USING System.IO;
USING System;
USING Libs.Math;
USING Libs.IOMng_Basic;

(*
    NOTE:
    In order to ADD a new additional function Analog/Digital Output:
        1. INCREASE THE VALUE OF MAXIMUM NUMBER OF IN/OUT CONSTANT DEFINITON (MAX_DO_NO and MAX_AO_NO)
        2. ADD THE NAME AND UOM IN THE RELATIVE UNION STRUCTURE: AoutStruct and DoutStruct
        3. FROM GLOBAL VARIABLE VIEW FLAG THE NEW PROBE AS PARAMETER AND NFC
*)
VAR_GLOBAL CONSTANT
    (* It's not the number of channels available! *)
    (** Max number of possible Digital Outputs *)
    MAX_DO_NO   : USINT := 7;
    (* It's not the number of channels available! *)
    (** Max number of possible Analog Outputs *)
    MAX_AO_NO   : USINT := 2;
END_VAR

TYPE 
    {REGION ANALOGIC OUTPUT CONFIGURATION}
        AoutInfoUnion: UNION
            Fct : AoutInfoStruct;
            Arr : ARRAY[1..MAX_AO_NO] OF ErrConfig;
        END_UNION;
        
        AoutInfoStruct: STRUCT
            (**Circulation pump 1*)
            CircPump1    :   ErrConfig;   
            (**Circulation pump 2*)
            CircPump2    :   ErrConfig;
        END_STRUCT;
    
        AoutCfgUnion: UNION
            Fct : AoutCfgStruct;
            Arr : ARRAY[1..MAX_AO_NO] OF AoutConfig;
        END_UNION;
        
        AoutCfgStruct: STRUCT
            (**Circulation pump 1*)
            CircPump1    :   AoutConfig;   
            (**Circulation pump 2*)
            CircPump2    :   AoutConfig;
        END_STRUCT;
        
        AoutData: UNION
            Fct : AoutStruct;
            Arr : ARRAY[1..MAX_AO_NO] OF REAL;
        END_UNION;
        
        AoutStruct: STRUCT
            (**Circulation pump 1*)
            {ATTRIBUTE UOM PERCENT}
            CircPump1    :   REAL;
            {ATTRIBUTE UOM PERCENT}
            (**Circulation pump 2*)
            CircPump2    :   REAL;
        END_STRUCT;
    {ENDREGION}
    
    {REGION DIGITAL OUTPUT CONFIGURATION}
        DoutInfoUnion: UNION
            Fct : DoutInfoStruct;
            Arr : ARRAY [1..MAX_DO_NO] OF ErrConfig;
        END_UNION;
    
        DoutInfoStruct: STRUCT
            (**General alarm *)
            GlbAl          :   ErrConfig;
            (**Shunt valve*)
            ShuntVlvDout          :   ErrConfig;
            (**Immersion heater step 1*)
            ImmheatStep1   : ErrConfig;
            (**Immersion heater step 2*)
            ImmheatStep2   : ErrConfig;
            (**Immersion heater step 3*)
            ShuntVlvOffDout   : ErrConfig;
            (**Reversing valve*)
            RevVlv         : ErrConfig;
            (**Shut off valve*)
            ShutOffVlv     : ErrConfig;
        END_STRUCT;
    
        DoutCfgUnion: UNION
            Fct : DoutCfgStruct;
            Arr : ARRAY [1..MAX_DO_NO] OF DoutConfig;
        END_UNION;
        
        DoutCfgStruct: STRUCT
            (**General alarm *)
            GlbAl          :    DoutConfig;
            (**Shunt valve*)
            ShuntVlvDout          :   DoutConfig;
            (**Immersion heater step 1*)
            ImmheatStep1   : DoutConfig;
            (**Immersion heater step 2*)
            ImmheatStep2   : DoutConfig;
            (**Immersion heater step 3*)
            ShuntVlvOffDout   : DoutConfig;
            (**Reversing valve*)
            RevVlv         : DoutConfig;
            (**Shut off valve*)
            ShutOffVlv     : DoutConfig;
        END_STRUCT;
        
        DoutData: UNION
            Fct : DoutStruct;
            Arr : ARRAY[1..MAX_DO_NO] OF BOOL;
        END_UNION;
        
        DoutStruct: STRUCT
            (**General alarm *)
            GlbAl               :   BOOL;
            (**Shunt valve*)
            ShuntVlvDout            :   BOOL;
            (**Immersion heater step 1*)
            ImmheatStep1   : BOOL;
            (**Immersion heater step 2*)
            ImmheatStep2   : BOOL;
            (**Immersion heater step 3*)
            ShuntVlvOffDout   : BOOL;
            (**Reversing valve*)
            RevVlv         : BOOL;
            (**Shut off valve*)
            ShutOffVlv     : BOOL;
        END_STRUCT;
    {ENDREGION}

END_TYPE

VAR_GLOBAL PERSISTENT
    Dout_Cfg        : DoutCfgUnion  := (Fct := (
        (**General alarm *)
        GlbAl               := (Ch := 0),
        (**Shunt valve*)
        ShuntVlvDout        := (Ch := 8),
        (**Immersion heater step 1*)
        ImmheatStep1        := (Ch := 4),
        (**Immersion heater step 2*)
        ImmheatStep2        := (Ch := 5),
        (**Immersion heater step 3*)
        ShuntVlvOffDout     := (Ch := 9),
        (**Reversing valve*)
        RevVlv              := (Ch := 1),
        (**Shut off valve*)
        ShutOffVlv          := (Ch := 7)
    ));

    Aout_Cfg        : AoutCfgUnion := (Fct := (
        (**Circulation pump 1*)
        CircPump1      := (Ch := 3,  ModeType := MODE_TYPE_AOUT#LIB_IO_PWM_2_KHZ),  
        (**Circulation pump 2*)
        CircPump2      := (Ch := 4,  ModeType := MODE_TYPE_AOUT#LIB_IO_PWM_2_KHZ)

    ));
    
    Aout_Min : AoutData :=(Fct := (CircPump1 :=0, CircPump2 := 0));
    Aout_Max : AoutData :=(Fct := (CircPump1 :=100, CircPump2 := 100));
END_VAR

PROGRAM OutputMng
    VAR_TEMP
        i : DINT;
    END_VAR
    (*Enabling Analog outputs*)
    {REGION Analog Output Enable}
        Aout_Cfg.Fct.CircPump1.Enable := TRUE;
        Aout_Cfg.Fct.CircPump2.Enable := TRUE;
    {ENDREGION}

    (*Enabling Digital outputs*)
    {REGION Digital Output Enable}
        Dout_Cfg.Fct.GlbAl.Enable := TRUE;
        Dout_Cfg.Fct.ShuntVlvDout.Enable := TRUE;
        Dout_Cfg.Fct.ImmheatStep1.Enable := ImmHeatStage >= 1;
        Dout_Cfg.Fct.ImmheatStep2.Enable := ImmHeatStage >= 2;
        Dout_Cfg.Fct.ShuntVlvOffDout.Enable := TRUE;
        Dout_Cfg.Fct.RevVlv.Enable := TRUE;
        Dout_Cfg.Fct.ShutOffVlv.Enable  := TRUE;
    {ENDREGION}
	
	{REGION Analog Output value}
    Aout_Data.Fct.CircPump1 := Circ1Act_Req;
    Aout_Data.Fct.CircPump2 := Circ2Act_Req;
	{ENDREGION}
	
	{REGION Digital Output Value}
	Dout_Data.Fct.GlbAl := GblAlarm;
    Dout_Data.Fct.ShuntVlvDout := ShuntVlv_On;
    Dout_Data.Fct.ImmheatStep1 := ActImmStep_Out.0;
    Dout_Data.Fct.ImmheatStep2 := ActImmStep_Out.1;
    Dout_Data.Fct.ShuntVlvOffDout := ShuntVlv_Off;
    Dout_Data.Fct.RevVlv       := (DHWReq AND OU_CompOn) OR SWValveManA;
    Dout_Data.Fct.ShutOffVlv   := CoolReq OR ShutOffMan;
	{ENDREGION}
    FOR i := 1 TO UPPER_BOUND(Aout_Data.Arr, 1) DO
        Aout_Data.Arr[i] := ScalerLimited(Aout_Data.Arr[i], 0.0, 100.0, Aout_Min.Arr[i], Aout_Max.Arr[i]);
    END_FOR;
    
    IO_Mng.Write(
        BOARD_TYPE#PCO,
        Dout_Cfg.Arr,
        Dout_Data.Arr,  
        Aout_Cfg.Arr,
        Aout_Data.Arr,
        Dout_Info.Arr,
        Aout_Info.Arr,
        NO,
        noConfig,
        Y,
        yConfig,
        uConfig,
        Uout
    );
    
END_PROGRAM