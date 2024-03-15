USING System;
USING System.IO;
USING Libs.IOMng_Basic;
USING Libs.Thermodynamic;
(*
    NOTE:
    In order to ADD a new additional function Analog/Digital Input:
        1. INCREASE THE VALUE OF MAXIMUM NUMBER OF IN/OUT CONSTANT DEFINITON (AIN_NO and DIN_NO)
        2. ADD THE NAME AND UOM IN THE RELATIVE UNION STRUCTURE: AinStruct, AinOffsetStruct and DinStruct.
        3. FROM GLOBAL VARIABLE VIEW FLAG THE NEW PROBE AS PARAMETER AND NFC
*)
VAR_GLOBAL CONSTANT
    (* It's not the number of channels available! *)
    (** Max number of possible Analog Inputs *)
    AIN_NO : USINT := 7;
    (* It's not the number of channels available! *)
    (** Max number of possible Digital Inputs *)
    DIN_NO : USINT := 4;
END_VAR

VAR_GLOBAL
    (**Max n° of Ain used by Local board*)
    MAX_AIN_CH  : USINT;
    (**Max n° of Din used by Local board*)
    MAX_DIN_CH  : USINT;
    (**Max n° of Dout used by Local board*)
    MAX_DOUT_CH : USINT;
    (**Max n° of Aout used by Local board*)
    MAX_AOUT_CH : USINT;
    (**Device parameteres (Number of I/O, type o Core...) *)
    HwDesc_1    : HardwareDescription;
    
    SystemPressure : REAL;
END_VAR

TYPE
    {REGION DIGITAL INPUT CONFIGURATION}
    DinInfoUnion: UNION
        Fct : DinInfoStruct;
        Arr : ARRAY[1..DIN_NO] OF ErrConfig;
    END_UNION;

    DinInfoStruct: STRUCT
        (**Start/Stop Command*)
        RemOnOff        : ErrConfig;
        (**Flow switch*)
        FlowSw          : ErrConfig;
        (**SG input 1*)
        SG1          : ErrConfig;
        (**SG input 2*)
        SG2          : ErrConfig;
    END_STRUCT;
    
    DinCfgUnion: UNION
        Fct : DinCfgStruct;
        Arr : ARRAY[1..DIN_NO] OF DinConfig;
    END_UNION;

    DinCfgStruct: STRUCT
        (**Start/Stop Command*)
        RemOnOff        : DinConfig;
        (**Flow switch*)
        FlowSw          : DinConfig;
        (**SG input 1*)
        SG1          : DinConfig;
        (**SG input 2*)
        SG2          : DinConfig;
    END_STRUCT;

    DinData: UNION
        Fct : DinStruct;
        Arr : ARRAY[1..DIN_NO] OF BOOL;
    END_UNION;

    DinStruct: STRUCT
        (**Start/Stop Command*)
        RemOnOff        : BOOL;
        (**Flow switch*)
        FlowSw          : BOOL;
        (**SG input 1*)
        SG1          : BOOL := FALSE;
        (**SG input 2*)
        SG2          : BOOL := FALSE;
    END_STRUCT;
    {ENDREGION}
    
    {REGION ANALOGIC INPUT CONFIGURATION}
    (*
            PAY ATTENTION!!!
            When you add a new AIN remember to also update the MAIN_UI_SEL and AUX_AIN_TYP enumerators.
        *)
    
    AinInfoUnion: UNION
        Fct : AinInfoStruct;
        Arr : ARRAY[1..AIN_NO] OF ErrConfig; 
    END_UNION;
    
    AinInfoStruct: STRUCT
        (**BT5 DHW bottom temperature*)
        DHWBottomTemp    :   ErrConfig;
        (**BT4 DHW middle temperature*)
        DHWMiddleTemp    :   ErrConfig;
        (**BT3 DHW top temperature*)
        DHWTopTemp       :   ErrConfig;
        (**BT7 DHW supply temperature*)
        DHWSupplyTemp    :   ErrConfig;
        (**BT1 Outdoor temperature*)
        OutDoorTemp    :   ErrConfig;
        (**BT6 Climate system supply temperature*)
        ClimSupplyTemp    :   ErrConfig;
        (**BP1 System pressure*)
        SysPress    :   ErrConfig;
    END_STRUCT;

    AinCfgUnion: UNION
        Fct : AinCfgStruct;
        Arr : ARRAY[1..AIN_NO] OF AinConfig; 
    END_UNION;

    AinCfgStruct: STRUCT
        (**BT5 DHW bottom temperature*)
        DHWBottomTemp     :  AinConfig;
        (**BT4 DHW middle temperature*)
        DHWMiddleTemp    :   AinConfig;
        (**BT3 DHW top temperature*)
        DHWTopTemp       :   AinConfig;
        (**BT7 DHW supply temperature*)
        DHWSupplyTemp    :   AinConfig;
        (**BT1 Outdoor temperature*)
        OutDoorTemp    :   AinConfig;
        (**BT7 Climate system supply temperature*)
        ClimSupplyTemp    :   AinConfig;
        (**BP1 System pressure*)
        SysPress    :   AinConfig;
    END_STRUCT;

    AinData: UNION
        Fct : AinDataStruct;
        Arr : ARRAY[1..AIN_NO] OF REAL;
    END_UNION;

    AinDataStruct: STRUCT
        {ATTRIBUTE UOM CELSIUS}
        {METADATA MAX_VAL 999.9}
        {METADATA MIN_VAL -99.9}
        (**BT5 DHW bottom temperature*)
        DHWBottomTemp       :   REAL;
        {ATTRIBUTE UOM CELSIUS}
        {METADATA MAX_VAL 999.9}
        {METADATA MIN_VAL -99.9}
        (**BT4 DHW middle temperature*)
        DHWMiddleTemp      :   REAL;
        {ATTRIBUTE UOM CELSIUS}
        {METADATA MAX_VAL 999.9}
        {METADATA MIN_VAL -99.9}
        (**BT3 DHW top temperature*)
        DHWTopTemp      :   REAL;
        {ATTRIBUTE UOM CELSIUS}
        {METADATA MAX_VAL 999.9}
        {METADATA MIN_VAL -99.9}
        (**BT7 DHW supply temperature*)
        DHWSupplyTemp      :   REAL;
        {ATTRIBUTE UOM CELSIUS}
        {METADATA MAX_VAL 999.9}
        {METADATA MIN_VAL -99.9}
        (**BT1 Outdoor temperature*)
        OutDoorTemp      :   REAL;
        {ATTRIBUTE UOM CELSIUS}
        {METADATA MAX_VAL 999.9}
        {METADATA MIN_VAL -99.9}
        (**BT6 Climate system supply temperature*)
        ClimSupplyTemp    :   REAL;
        {ATTRIBUTE UOM BAR}
        {METADATA MAX_VAL 7.0}
        {METADATA MIN_VAL -1.0}
        (**BP1 System pressure*)
        SysPress    :   REAL;
    END_STRUCT;

    AinOffset: UNION
        Fct : AinOffSetStruct;
        Arr : ARRAY[1..AIN_NO] OF REAL;
    END_UNION;

    AinOffSetStruct: STRUCT
        {ATTRIBUTE UOM DELTACELSIUS}
        (**BT5 DHW bottom temperature*)
        DHWBottomTemp      :   REAL;
        {ATTRIBUTE UOM DELTACELSIUS}
        (**BT4 DHW middle temperature*)
        DHWMiddleTemp      :   REAL;
        {ATTRIBUTE UOM DELTACELSIUS}
        (**BT3 DHW top temperature*)
        DHWTopTemp         :   REAL;
        {ATTRIBUTE UOM DELTACELSIUS}
        (**BT7 DHW supply temperature*)
        DHWSupplyTemp      :   REAL;
        {ATTRIBUTE UOM DELTACELSIUS}
        (**BT1 Outdoor temperature*)
        OutDoorTemp        :   REAL;
        {ATTRIBUTE UOM DELTACELSIUS}
        (**BT6 Climate system supply temperature*)
        ClimSupplyTemp     :   REAL;
        {ATTRIBUTE UOM BAR}
        (**BP1 System pressure*)
        SysPress           :   REAL;
    END_STRUCT;
    
    {ENDREGION}
END_TYPE

VAR_GLOBAL PERSISTENT
        ReservedIOCfg :BOOL := TRUE;
        Din_Cfg     : DinCfgUnion  := (Fct := (
            (**StartStop*)
            RemOnOff        := (Ch := 0, ModeType := MODE_TYPE_DIN#LIB_IO_DIN),
            (**Flow switch*)
            FlowSw          := (Ch := 0, ModeType := MODE_TYPE_DIN#LIB_IO_DIN),
            (**SG input 1*)
            SG1          := (Ch := 4, ModeType := MODE_TYPE_DIN#LIB_IO_DIN, logic := TRUE),
            (**SG input 2*)
            SG2          := (Ch := 5, ModeType := MODE_TYPE_DIN#LIB_IO_DIN, logic := TRUE)
        ));
    
        Ain_Cfg     : AinCfgUnion := (Fct := (
            (**DHW bottom temperature*)
            DHWBottomTemp       := (Ch := 5,  ModeType := MODE_TYPE_AIN#LIB_IO_PROBE_NTC),
            (**DHW middle temperature*)
            DHWMiddleTemp       := (Ch := 4,  ModeType := MODE_TYPE_AIN#LIB_IO_PROBE_NTC),
            (**DHW top temperature*)
            DHWTopTemp          := (Ch := 3,  ModeType := MODE_TYPE_AIN#LIB_IO_PROBE_NTC),
            (**DHW supply temperature*)
            DHWSupplyTemp       := (Ch := 6,  ModeType := MODE_TYPE_AIN#LIB_IO_PROBE_NTC),
            (**Outdoor temperature*)
            OutDoorTemp         := (Ch := 1,  ModeType := MODE_TYPE_AIN#LIB_IO_PROBE_NTC),
            (**Climate system supply temperature*)
            ClimSupplyTemp      := (Ch := 2,  ModeType := MODE_TYPE_AIN#LIB_IO_PROBE_NTC),
            (**System pressure*)
            SysPress            := (Ch := 10,  ModeType := MODE_TYPE_AIN#LIB_IO_PROBE_4_20MA)
        ));

    Ain_Min     : AinData := (Fct := (
        SysPress := 0
    ));

    Ain_Max     : AinData := (Fct := (
        SysPress := 6
    
    ));

    Ain_Offset  : AinOffset :=();

    (**Probe alarm delay*)
    {ATTRIBUTE UOM SECOND}
    PrbAlrm_DT : UINT(0..999) := 10;
END_VAR

PROGRAM InputMng
    VAR_TEMP
        i : DINT;
    END_VAR
    
    (*All the Programs are skipped while the default valeus are being installed*)
    IF RestoreDefault THEN
        RETURN;
    END_IF;

    {REGION Analog Input Enable}
        Ain_Cfg.Fct.DHWBottomTemp.Enable := TRUE;
        Ain_Cfg.Fct.DHWMiddleTemp.Enable := TRUE;
        Ain_Cfg.Fct.DHWTopTemp.Enable := TRUE;
        Ain_Cfg.Fct.DHWSupplyTemp.Enable := TRUE;
        Ain_Cfg.Fct.ClimSupplyTemp.Enable := TRUE;
        Ain_Cfg.Fct.OutDoorTemp.Enable := TRUE;
        Ain_Cfg.Fct.SysPress.Enable := TRUE;
    {ENDREGION}

    {REGION Digital Input Enable}
        Din_Cfg.Fct.RemOnOff.Enable := TRUE;
        Din_Cfg.Fct.FlowSw.Enable := TRUE;
        Din_Cfg.Fct.SG1.Enable := TRUE;
        Din_Cfg.Fct.SG2.Enable := TRUE;
    {ENDREGION}
    
    (*Initialization Probe Alarm Delay*)
    FOR i := LOWER_BOUND(Ain_Cfg.Arr, 1) TO UPPER_BOUND(Ain_Cfg.Arr, 1) DO  
        Ain_Cfg.Arr[i].AlrmDT := TO_UDINT(PrbAlrm_DT);
    END_FOR;

    IO_Mng.Read(
        BOARD_TYPE#PCO,
        ID,
        U,
        Din_Cfg.Arr,
        Ain_Cfg.Arr,
        Ain_Max.Arr,
        Ain_Min.Arr,
        Ain_Offset.Arr,
        Din_Data.Arr,
        Din_Info.Arr,
        Ain_Data.Arr,
        Ain_Info.Arr,
        uConfig
    );
    
    HandleSpecialID(2, LIB_IO_PROBE_U_FREQ, 5, uID2);
    WaterFlow_DHW := (TO_REAL(uID2.ui) * 0.0106);    // 530 pulses per litre
    
    SystemPressure := To_Real(U[10].ud);
    SystemPressure := To_Real(U[10].ui);
    SystemPressure := To_Real(U[10].b);
    SystemPressure := To_Real(U[10].r);
END_PROGRAM
