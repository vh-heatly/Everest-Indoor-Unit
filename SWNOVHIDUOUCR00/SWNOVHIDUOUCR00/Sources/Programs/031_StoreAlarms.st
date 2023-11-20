USING System;
USING System.Alarm;
USING System.Timer;
USING System.Math;

USING Libs.Logics;
USING Libs.Alarm_Mng;

TYPE
    (**This structure manages all unit's alarms*)
    AlarmUnion : UNION
        (**Array of FBs Alarm_Req*)
        Arr   : ARRAY [1..noAlrms] OF Alarm_Req;
        (**Table of all alarms and them property*)
        Table : AlarmsStruct;
    END_UNION;

    (**List all alarms and them property (Code, Category, Reset type, ...)*)
    AlarmsStruct : STRUCT     
        (**Error in number of permanent memory writes*)
        Al_RetainMemNo : Alarm_Req           	 :=	 (StrCode := 'A01', Info := (Code := 001, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Manual));
        (**DHW bottom temperature*)
        Al_DHWBottomTemp : Alarm_Req             :=  (StrCode := 'A02', Info := (Code := 002, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
        (**DHW middle temperature*)
        Al_DHWMiddleTemp : Alarm_Req             :=  (StrCode := 'A03', Info := (Code := 003, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
        (**DHW top temperature*)
        Al_DHWTopTemp : Alarm_Req                :=  (StrCode := 'A04', Info := (Code := 004, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
        (**DHW supply temperature*)
        Al_DHWSupplyTemp : Alarm_Req             :=  (StrCode := 'A05', Info := (Code := 005, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
        (**Outdoor temperature*)
        Al_OutDoorTemp    :   Alarm_Req          :=  (StrCode := 'A06', Info := (Code := 006, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
        (**Climate system supply temperature*)
        Al_ClimSupplyTemp    :   Alarm_Req       :=  (StrCode := 'A07', Info := (Code := 007, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
        (**System pressure*)
        Al_SysPress    :   Alarm_Req             :=  (StrCode := 'A08', Info := (Code := 008, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
        (**Outdoor unit offline*)
        Al_OUOffline   : Alarm_Req               :=  (StrCode := 'A09', Info := (Code := 009, Category := CAT_AL_SRS_UNIT, Reset := AlarmResetType#Auto));
    END_STRUCT;
END_TYPE

VAR_GLOBAL CONSTANT
    {REGION UPDATE EVERY TIME AN ALARM IS ADDEDD!}    
        (**Number of alarm saved inside ALARM table. 
         *NOTE: update every time an alarm is addedd!
        *)
        noAlrms : UINT := 27;
    {ENDREGION}

    {REGION ALARM LOG CONFIGURATION}
        (**Number of logs of alarms saved inside ALARM-LOG table*)
        noAlrmsLog     : UINT := 20; 
        (**
         *Size of the array VARs_TO_LOG.
         *Number of additionals variables saved inside ALARM-LOG table,
         *when an alarm is triggered (NOTE: used inside System.Alarm library)
        *)
        MaxAlarmValues : UINT := 0;
    {ENDREGION}

    {REGION CONFIGURE HERE YOUR ALARMs CATEGORY (max 16). YOU NEED TO USE "ActAlr_ForCategory".}
    (**Alarm category associate to ActAlr_ForCategory BIT_0 *) CAT_AL_SRS_UNIT          : UINT := 1;
    (**Alarm category associate to ActAlr_ForCategory BIT_1 *) CAT_AL_SRS_CIRC1         : UINT := 2; 
    (**Alarm category associate to ActAlr_ForCategory BIT_2 *) CAT_WARN_CIRC1           : UINT := 4; 
    (**Alarm category associate to ActAlr_ForCategory BIT_3 *) SENSOR                   : UINT := 8;     
    (**Alarm category associate to ActAlr_ForCategory BIT_4 *) HEATPUMP                 : UINT := 16; 
    (**Alarm category associate to ActAlr_ForCategory BIT_5 *) FREE_0                   : UINT := 32; 
    (**Alarm category associate to ActAlr_ForCategory BIT_6 *) FREE_1                   : UINT := 64; 
    (**Alarm category associate to ActAlr_ForCategory BIT_7 *) FREE_2                   : UINT := 128; 
    (**Alarm category associate to ActAlr_ForCategory BIT_8 *) FREE_3                   : UINT := 256; 
    (**Alarm category associate to ActAlr_ForCategory BIT_9 *) FREE_4                   : UINT := 512; 
    (**Alarm category associate to ActAlr_ForCategory BIT_10*) FREE_5                   : UINT := 1024;
    (**Alarm category associate to ActAlr_ForCategory BIT_11*) FREE_6                   : UINT := 2048;
    (**Alarm category associate to ActAlr_ForCategory BIT_12*) FREE_7                   : UINT := 4096;
    (**Alarm category associate to ActAlr_ForCategory BIT_13*) FREE_8                   : UINT := 8192;
    (**Alarm category associate to ActAlr_ForCategory BIT_14*) FREE_9                   : UINT := 16384;
    (**Alarm category associate to ActAlr_ForCategory BIT_15*) FREE_10                  : UINT := 32768;
    {ENDREGION} 
END_VAR

VAR_GLOBAL PERSISTENT
    (**Log alarm array*)
    Log_Alarm  : ARRAY[1..noAlrmsLog] OF AlarmLog;
    (**Index of Log_Alarm *)
    LogAlrmIdx : UINT;
END_VAR

VAR_GLOBAL
    {REGION ALARMS MANAGEMENT}
        (**Container of Alarms table*)
        Alarms              : AlarmUnion;        
        (**Array of active alarms*)
        Active_Alrm         : ARRAY[1..noAlrms] OF UINT;        
        (**Active alarm status for each category, max 16 differents category (Bit15..Bit0)*)
        ActAlr_ForCategory  : WORD;   
    {ENDREGION}

    {REGION ALARMS LOG}
        (**Array of variables to store inside LOG_ALARM array, when an alarm happen*)
        VARs_TO_LOG : ARRAY[0..MaxAlarmValues] OF AlarmValue; 
        (**Empty structured used to clean LOG_ALARM array*)
        CleanLog    : AlarmLog;
    {ENDREGION}
END_VAR

VAR_GLOBAL INTERNAL
    (*Used by Modbus files transfer protocol*)
    AlrmInfoArr : ARRAY [1..noAlrms] OF AlarmInfo;
END_VAR

(**This program manages alarm categories and detects the alarms*) 
PROGRAM StoreAlarms
    VAR_TEMP
        (**Numeber of alarm active*)
        TotActAlm : UINT;
    END_VAR

    VAR
        (**Array index*)
        idx             : DINT;
        (**Numeber of alarm active in previous cycle*)
        TotActAlm_Old   : UINT;
        TP_ResAlrmByBMS : TP;
        
        {REGION USED BY LOG-ALARM TO STORE THE "ADDITIONAL VARIABLES"} 
        (**A42 trigger used to store additional values*)
        RFtrg_Alr1          : RF_TRIG;
        (**A48 trigger used to store additional values*)
        RFtrg_Alr2          : RF_TRIG;
        (**A46 trigger used to store additional values*)
        RFtrg_Alr3          : RF_TRIG;
        (**A43 trigger used to store additional values*)
        RFtrg_Alr4          : RF_TRIG;
        (**A01 trigger used to store additional values*)
        RFtrg_Alr5          : RF_TRIG;
        (**A35 trigger used to store additional values*)
        RFtrg_Alr6          : RF_TRIG;
        (**A32 trigger used to store additional values*)
        RFtrg_Alr7          : RF_TRIG;
        (**A33 trigger used to store additional values*)
        RFtrg_Alr8          : RF_TRIG;
        (**A37 trigger used to store additional values*)
        RFtrg_Alr9          : RF_TRIG;
        (**A34 trigger used to store additional values*)
        RFtrg_Alr10         : RF_TRIG;
        {ENDREGION} 
    END_VAR
        
    (*Alarm management is be skipped while the default valeus are being installed OR at startup while I/O are being read*)
    IF RestoreDefault OR UnitStatus = UNIT_STATUS#Wait THEN
        RETURN;
    END_IF;  

    {REGION RESET ALARM ARRAY}
    TP_ResAlrmByBMS(IN := ResAlrmByBMS, PT := T#5s);        (*Request of reset by BMS*)                 
    ResAlrmByBMS := TP_ResAlrmByBMS.Q;
    
    AlrmRes := ResAlrmByBMS OR ResAlrmByHMI;
    {ENDREGION}

    {REGION CLEAN THE LOG ARRAY}
    IF LogAlrmRes THEN 
        LogAlrmRes       := FALSE;
        (*RESTART LOG*)
        LogAlrmIdx := 0;
            
        (*CLEAR LOG LIST*)
        FOR idx := 1 TO TO_DINT(UPPER_BOUND(Log_Alarm, 1)) DO
            Log_Alarm[idx] := CleanLog;
        END_FOR;
    END_IF; 
    {ENDREGION}

    {REGION SET DYNAMIQUE CATEGORY}

    {ENDREGION}
	
    {REGION GET ACTIVE ALARMS}
    FOR idx := 1 TO UPPER_BOUND(Alarms.Arr, 1) DO
        (*Copy the alarm info into a dedicated array*)
        AlrmInfoArr[idx] := Alarms.Arr[idx].Info;
        
        {REGION "ADDITIONAL VARIABLES" stored inside LOG_ALARM array, when an alarm happen} 
		/*IF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_Envelope_Circ1.Info.Code THEN
			RFtrg_Alr1(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr1.Q THEN
                VARs_TO_LOG[0].UINT := TO_UINT(0);
            END_IF;*/
		/*ELSIF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_Inv_Circ1.Info.Code THEN
			RFtrg_Alr2(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr2.Q THEN
                    VARs_TO_LOG[0].UINT := PWRP_ErrCode_Circ1;
            END_IF;*/
		/*ELSIF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_HiDscgTempComp1_Circ1.Info.Code THEN
        	RFtrg_Alr3(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr3.Q THEN
                VARs_TO_LOG[0].UINT := TO_UINT(DscgT_Zone_Circ1);
            END_IF;*/
		/*ELSIF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_DisStartDp_Circ1.Info.Code THEN
			RFtrg_Alr4(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr4.Q THEN
                VARs_TO_LOG[0].REAL := DeltaP_Circ1;
            END_IF;*/
		/*ELSIF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_RetainMemNo.Info.Code THEN
			RFtrg_Alr5(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr5.Q THEN
                VARs_TO_LOG[0].UDINT := TO_UDINT(RetainMemWrites);
            END_IF;*/
		/*ELSIF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_EEV_Circ1.Info.Code THEN
			RFtrg_Alr6(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr6.Q THEN
                VARs_TO_LOG[0].UINT := TO_UINT(EEV_AlrmCode_Circ1);
            END_IF;*/
		/*ELSIF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_WkrHrsComp1_Circ1.Info.Code THEN
			RFtrg_Alr7(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr7.Q THEN
                VARs_TO_LOG[0].UINT := TO_UINT(Comp1Circ1_HrsRetain);
            END_IF;*/
		/*ELSIF Alarms.Arr[idx].Info.Code = Alarms.Table.Al_WkrHrsSrc_Circ1.Info.Code THEN
			RFtrg_Alr10(CLK := Alarms.Arr[idx].Info.Trigger);
            IF RFtrg_Alr10.Q THEN
                VARs_TO_LOG[0].UINT := TO_UINT(Source1Circ1_HrsRetain);
            END_IF;*/
		//END_IF;
        {ENDREGION}
    
        Alarms.Arr[idx]
                        (    
                            DataVal         := VARs_TO_LOG, (* Remember to define ALARM_VALUES *)
                            AlrmRes         := AlrmRes,
                            Lst_ActAlrm     := Active_Alrm,
                            Lst_LogAlrm     := Log_Alarm,
                            Lst_LogAlrm_Idx := LogAlrmIdx
                        );
    END_FOR;
    {ENDREGION}

    {REGION GET ALARM CATEGORIES}
    ActAlr_ForCategory := Alarm_Mng(Active_Alrm);
    Al_SrsUnit            := ActAlr_ForCategory.0;  									// BIT n.0  -> CAT_AL_SRS_UNIT     
    Al_SrsCirc1           := ActAlr_ForCategory.1 OR Al_SrsUnit;// BIT n.1  -> Al_SRS_CIRC1  
    Wrg_Regul             := ActAlr_ForCategory.4;                      				// BIT n.4  -> CAT_WRG_REGUL      
    Wrg_Circ1             := ActAlr_ForCategory.5;                      				// BIT n.7  -> CAT_WRG_CIRC1     
    Wrg_HrsCounters       := ActAlr_ForCategory.7;                      				// BIT n.10 -> CAT_WRG_HRSCOUNTER
    {ENDREGION}

    {REGION MANAGEMENT OF ALARM RELAY AND GROUPED ALARMS}
    (*Depending on alarm relay configuration, the alarm relay is activated by serious alarms only or by all alarms (including devices maintenance, retain memory,...) *)
    Al_RegulationAlrms :=    Al_SrsUnit
                          OR Al_SrsCirc1
                          OR Wrg_Regul;
    
    Al_MiscAlrms :=    Wrg_Circ1
                    OR Wrg_HrsCounters;
        
    RelayAlrm := Al_RegulationAlrms OR Al_MiscAlrms;
    {ENDREGION}

    {REGION COUNT OF TOTAL ALARMs AND WARNINGs ACTIVE}
    FOR idx := 1 TO TO_DINT(UPPER_BOUND(Active_Alrm,1)) DO
        IF Active_Alrm[idx] >= 1 THEN 
            TotActAlm := TotActAlm + 1;
        END_IF;
    END_FOR;
    
    GblAlarm := UINT_TO_BOOL(TotActAlm);
    
    (*LED-ALARM and BUZZER*)
    IF TotActAlm > TotActAlm_Old THEN
        Req_FixLED_Alarm   := FALSE;    // LED-ALARM on
        Req_BlinkLED_Alarm := TRUE;     // LED-ALARM is blinking
        BuzzerSilenced     := FALSE;    // Buzzer is buzzing
    END_IF;

    TotActAlm_Old := TotActAlm;
    {ENDREGION}
END_PROGRAM