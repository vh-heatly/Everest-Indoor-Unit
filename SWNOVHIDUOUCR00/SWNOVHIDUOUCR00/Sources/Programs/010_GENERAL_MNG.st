USING System;
USING System.NVRAM;
USING System.Timer;
USING System.Serial;
USING System.Globalization;
USING Libs.GetTime;


PROGRAM Main
    VAR
        (**After restoring the memory to default, it waits 6s before restarting the PLC*)
        TON_WaitRestartPlc  : TON;
        (**R_TRIG Restore Default Settings*) 
        Rtrg_RestoreDefault  : R_TRIG;
        (**First cycle done used by NVRAM management*)
        FirstCycleDone_NVRAM : BOOL;
        (**Istance of SoftwareSafeUpload manage the system call GetFullDownloadRequest()*)
        SwSafeUpload         : SoftwareSafeUpload;
        i                    : DINT;
    END_VAR

    VAR_TEMP
        NVRAM_BOOL_Tmp : BYTE;
        TmpTimezone : STRING;
    END_VAR
    
    RetainMemWrites := GetRetainWritingsNumber();

    TaskMainCurrT   := GetTaskStartTimeAdv();
    TaskMainLiveCnt := GetTaskLiveCounter();
    RetainWrN       := TO_UDINT(GetRetainWritingsNumber());
    TaskMainExeT    := TaskMainCurrT - MemTime;
    MemTime         := TaskMainCurrT;
    
    {REGION RESTORE MEMORY}
    Rtrg_RestoreDefault(CLK := RestoreDefault);
    (*Saving BMS before restoring memory*)
    IF Rtrg_RestoreDefault.Q THEN                                         
        SPV_Addr_SavedRAM := SPV_Addr;
        SPV_Baud_SavedRAM := SPV_Baud; 
        SPV_Conf_SavedRAM := SPV_Conf;  
    END_IF;
    
    IF RestoreDefault AND NOT RetainRestored THEN
        RetainRestoreDefault(); (*NOTE: This request will be executed at END of MAIN task.*)
        RetainRestored := TRUE;
    END_IF;

    //------------------------------------------------------------------------------------
    //------------ WARM SOFTWARE RESET----------------------------------------------------
    //------------------------------------------------------------------------------------ 
    TON_WaitRestartPlc(IN := RetainRestored, PT := T#6s);

    IF TON_WaitRestartPlc.Q THEN 
        // Wait 6s because Retain will be write every 5s   
        // 0 - WARM start;
        SoftwareReset(0);
    END_IF;
    {ENDREGION}
   
    {REGION DATE AND TIME}        
    GetLocalTime(LocTime);
    Day_Week := DAY_OF_WEEK(LocTime);
    
    {REGION SET CLOCK TIME BY APPLICA}
    IF AppSetDateTime THEN 
        AppSetDateTime := FALSE; //CS: da provare senza il reset
        //Necessary and in this order
        SetTimeZone(AppTimeZone);                
        SetTime(AppDateTime); //APPLICA give UTC Times
        TimezoneIdx := FindTimezoneIndex(TimeZonePOSIX, AppTimeZone);
    END_IF;
    {ENDREGION}    
            
    {REGION SET CLOCK TIME BY USER INTERFACE}
    IF SetClockByDisp THEN
        SetClockByDisp := FALSE;
        //Necessary and in this order
        SetTimeZone(TimeZonePOSIX[TimezoneIdx]);            
        SetLocalTime(CONCAT_DT(
		    TO_UINT(YearIn) + 2000, 
		    TO_UINT(MonthIn),
		    TO_UINT(DayIn),
		    TO_UINT(HourIn),
		    TO_UINT(MinuteIn),
		    TO_UINT(SecondIn),
		    0
		));
    END_IF;
    {ENDREGION} 
    {ENDREGION}
    
    {REGION RETAIN WRITING SETTINGS}
    (*This FB manage the "retain writing error" as bios specification. *)
    RetainSetErasureWindowSize(ErasureWindowSize);
    RetainSetErasureWindowsNumber(ErasureWindowsNumber);
    RetainSetMaxErasure(MaxErasure);
    {ENDREGION}
    
    {REGION SYSTEM INFORMATION}
    IF NOT FirstCycleDone THEN
        MemTime        := TaskMainCurrT;
        GetSystemInfo(SysInfo);
        GetHardwareDescription(HardwareInfo);
        GetModel(DeviceType, BoardType, MachineType, HwCode);
        GetProjectInfo(InfoProject);
        GetProductInfo(InfoProduct);
        GUID := SplitPrjGUID(InfoProject.ProjectID);
        SwVersion := (TO_UINT(InfoProject.VersionMajor) * 10000) + (TO_UINT(InfoProject.VersionMinor) * 1000) + TO_UINT(InfoProject.VersionBuild);
		OS_Version := TO_UINT(SysInfo.FirmwareVersion);
		BootVersion := TO_UINT(SysInfo.BootloaderVersion);
        
        {REGION COMUNICATION IS STOPPED DURING INITIALIZATION OF INTERNAL PROTOCOLs STRUCTUREs.}
        (*BMS*)
        Supervisor.Init(FALSE);
        (*Fieldbus*)
        MBM_Line.Init(FALSE);
        (*Display*)
        Display.Init();
        {ENDREGION}
        
        {REGION IoT Third Parts Integration: Alarms retrieved via "Modbus File Transfer"}
        (*Following APIs calls are needed*)
        System.Alarm.AlarmInfoManagement(AlrmInfoArr);
        System.Alarm.AlarmLogManagement(LOG_ALARM);
        {ENDREGION}
        
        {REGION SAVING OF TIMEZONE WHEN RTC SET BY APPs}
		GetTimeZone(TmpTimezone);
        TimezoneIdx := FindTimezoneIndex(TimeZonePOSIX, TmpTimezone);
        {ENDREGION}
        FirstCycleDone := TRUE;
    END_IF;
    {ENDREGION}
    
    {REGION SYSTEM CONFIGURAITON}
        //System configuration selection
        //None selected
        // 1: Heating system 1 + DHW
        // 2: Heating system 1 + Heating system 2 + DHW
        // 3: Heating system 1 + Cooling + DHW
        // 4: Heating system 1 + Heating system 2 + DHW
    
        IF(SystemCfg > 0)THEN
            SystemCfg_AllowDHW := SystemCfg >= 1 AND SystemCfg <= 3; 
            SystemCfg_AllowHeat := SystemCfg >= 1;                   
            SystemCfg_AllowImm := SystemCfg >= 1;                    
            SystemCfg_AllowCool := SystemCfg = 4;                    
            SystemCfg_NoCfgSel := FALSE;
        ELSE
            SystemCfg_AllowDHW := FALSE;
            SystemCfg_AllowHeat := FALSE;          
            SystemCfg_AllowImm := FALSE;    
            SystemCfg_AllowCool := FALSE;                
            SystemCfg_NoCfgSel := TRUE;
        END_IF;
    {ENDREGION}
    
    {REGION PROTOCOLS}

    {REGION BMS/FIELDBUS SERIAL PORTs CONFIGURATION}
    CASE UoMZoneHMI OF            
        UOM_ZONE#SI:
            Supervisor.Info.Zone := SI;
            // Server BMS uses only SI to communicate (Client FielBus <-> Server BMS)
            // NOTE: In a net CLIENT+SERVER set NoConverion =0 beetwen: Client FielBus <-> Server BMS to increase pCO speed
            // i.e.: FBnet.Info.Zone=0 and BMSnet.Info.Zone=0
            Display.Info.Zone := SI;
        UOM_ZONE#Imperial:
            Supervisor.Info.Zone := Imperial;
            Display.Info.Zone := Imperial;
    ELSE
        Supervisor.Info.Zone := NONE;
        Display.Info.Zone := NONE;
    END_CASE; 
    
    {REGION CHANGE BMS2 SETTINGS}
    (*Memory after deleting command is immediately ready the next cycles*)
    IF RetainRestored THEN
        // Restore BMS2 settings                    
        SPV_Addr := SPV_Addr_SavedRAM;
        SPV_Baud := SPV_Baud_SavedRAM; 
        SPV_Conf := SPV_Conf_SavedRAM;
        
        // Force update BMS2 settings
        SPV_ChangeSet := TRUE;
    END_IF;
      
    IF SPV_ChangeSet THEN
		Supervisor.Info.TimeOut := TO_UDINT(SPV_OfflineTimeout)*1000;
        SetupSerialSettings(Supervisor.SerialSettings, SPV_Baud, SPV_Conf, getServerPort(SPV_Port));
        Supervisor.ChangeIdent(SPV_Addr);
        // Change setting of BMS supervisor port
        Supervisor.ChangeSettings();
        // Set the same settings for BMS port on Default app (NOTE: In case of FW ugrade the device will be reachable with the previous settings)
        SaveIdePortSettings(Supervisor.SerialSettings.Channel, Supervisor.SerialSettings.Speed, Supervisor.SerialSettings.Bits, Supervisor.SerialSettings.Parity, Supervisor.SerialSettings.Stops, SPV_Addr);  

        SPV_ChangeSet := FALSE;
    END_IF;
    
    SPV_Online := Supervisor.Info.Online;
    {ENDREGION}    
    
    {REGION CHANGE FIELDBUS2 SETTINGS}
    IF FB2_ChangeSet THEN
        SetupSerialSettings(MBM_Line.SerialSettings, FB2_Baud, FB2_Conf, getClientPort(MBM_Line_Port));
        // Change setting of FB supervisor port
        MBM_Line.ChangeSettings();
        
        FB2_ChangeSet := FALSE;
    END_IF;            
    {ENDREGION}
    {ENDREGION}
                
    {REGION READ BUFFER OF EACH SERIAL PORT}
    // NOTE: when the protocols are in START the read() method obtain the variables
    //       from each buffer -> so the variables can be used inside STone.
    
    // BMS
    Supervisor.Read();
    // Fieldbus
    MBM_Line.Read();
    Display.Read();
	{IF DEF (PGD)}
    	TerminalDetector.Run(Display);
	{ENDIF}
    {ENDREGION}
	{ENDREGION}
    
    {REGION NVRAM management}
    IF NOT FirstCycleDone_NVRAM THEN
        
        /*NVRAM_ReadVar(1, NVRAM_BOOL_Tmp);
        Dout_FourWVlv_NVRAM := TO_BOOL(NVRAM_BOOL_Tmp);
        
        FirstCycleDone_NVRAM := TRUE;
    ELSE
        NVRAM_WriteVar(1, TO_BYTE(Dout_FourWVlv_NVRAM));*/
    END_IF;
    {ENDREGION}
    
    //Outdoor unit status management
    OU_Online := OU_Unit.Info.isOnline;
    
    (*Call of SoftwareSafeUpload manage the system call GetFullDownloadRequest()*)
    SwSafeUpload(
        KeybOffOn := BmsOnOff, 
        StartUpload := UnitOff
    );
END_PROGRAM