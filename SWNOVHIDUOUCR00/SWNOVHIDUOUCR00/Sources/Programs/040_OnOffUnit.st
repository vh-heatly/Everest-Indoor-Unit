USING System.Timer;
USING Libs.Thermodynamic;

PROGRAM OnOffUnit
    VAR
        (**Instance TON to manage startup delay for I/O*)
        TON_StartUpDT : TON;
    END_VAR
    
    (*All the Programs are skipped while the default valeus are being installed*)
    IF RestoreDefault THEN
        RETURN;
    END_IF;
    
    (*This delay is used to give the time to other parts of the application to initialize (e.g. I/O to be configured)*)
    TON_StartUpDT(
        IN := TRUE,
        PT := T#5s
    );
    
    (*UNIT ON/OFF COMMAND*)
    UnitOn :=   KeybOnOff
                AND NOT Al_SrsUnit
                AND (BmsOnOff OR NOT En_SPV_OnOff)
                AND (Din_Data.Fct.RemOnOff OR NOT Din_Info.fct.RemOnOff.configured);

    UnitOff := NOT UnitOn;
    IF UnitOff THEN
        /*EEV_Circ1_Man_En := FALSE;
        Comp1_Circ1_ManModeEn := FALSE;
        Src_En_Man := FALSE;*/
    END_IF;
    
    //ManMode := EEV_Circ1_Man_En OR Comp1_Circ1_ManModeEn OR Src_En_Man;

    {REGION UNIT STATUS}
    IF NOT(TON_StartUpDT.Q) THEN
        (*Wait*)
        UnitStatus          := UNIT_STATUS#Wait;
    ELSIF Al_SrsUnit THEN
        (*Off By Alarm*)
        UnitStatus          := UNIT_STATUS#OffByAlarm;
    ELSIF NOT(BmsOnOff) AND En_SPV_OnOff THEN
        (*Off By BMS*)
        UnitStatus          := UNIT_STATUS#OffByBMS;
    ELSIF (NOT(Din_Data.Fct.RemOnOff) AND Din_Info.Fct.RemOnOff.configured) THEN
        (*Off By Digital Input*)
        UnitStatus          := UNIT_STATUS#OffByDI;
    ELSIF NOT(KeybOnOff) THEN
        (*Off By Keyboard*)
        UnitStatus          := UNIT_STATUS#OffByKeyboard;
    ELSIF ManMode THEN
        (*Unit manual mode active*)
        UnitStatus          := UNIT_STATUS#Manual;
    ELSIF UnitOn THEN
        (*Unit ON*)
        UnitStatus          := UNIT_STATUS#UnitON;
    END_IF;
    {ENDREGION}
    
END_PROGRAM