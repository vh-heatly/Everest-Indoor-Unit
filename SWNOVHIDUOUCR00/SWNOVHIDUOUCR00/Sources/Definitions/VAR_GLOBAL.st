USING System;
USING System.Timer;
(*----------------------------------
         ADD HERE YOUR VARS!
----------------------------------*)
VAR_GLOBAL    
    {REGION SYSTEM INFO}
        (**Retain writings number*)
        RetainWrN       : UDINT;
        (**Task Main live counter*)
        TaskMainLiveCnt : UINT;
        (**Task Main execution time*)
        {ATTRIBUTE UOM MILLISECOND}
        TaskMainExeT    : UDINT;    
        (**Current System Time*)
        {ATTRIBUTE UOM MILLISECOND}
        CurrSysT        : UDINT;        
        (**Task Main current execution time*)
        {ATTRIBUTE UOM MILLISECOND}
        TaskMainCurrT   : UDINT;
    
        (**System Info structure*)
        SysInfo         : SystemInfo;
        (**Hardware Info structure*)
        HardwareInfo    : HardwareDescription;
        (**Project information*)
        InfoProject     : ProjectInfo;
        (**Product information read in OTP memory*)
        InfoProduct     : ProductInfo;
    
        (**Device model*)
		DeviceType      : UINT;
        (**Board type*)
        BoardType       : UINT;
        (**Target machine type*)
		MachineType     : UINT;
        (**Target hardware code*)
		HwCode          : UINT;
    
        RetainMemWrites : ULINT;
        
        (**Stone project GUID*)
        GUID : StonePrjGUID;
    {ENDREGION}  
    
    {REGION Used by APPLICA to manage clock and timeZONE}
        APPsCfgRTC : APPsConfigRTC;
    {ENDREGION}
    
    {REGION HMI}
        (**Logged in pGD1 display as Service*)
    	Access_Service : BOOL;
        (**Logged in pGD1 display as User*)
    	Access_User    : BOOL;
        (**Logged in pGD1 display as Manufacturer*)
    	Access_Manuf   : BOOL;
        (**Logged in pGD1 display as System Manager*)
    	Access_Sys     : BOOL;
        (**Switch to TRUE or FALSE every second*)
        Blink          : BOOL;
        (**Password used for Loging procedure (User, Service, Manufacturer, System)*) {METADATA MIN_VAL 0} {METADATA MAX_VAL 3}
        LoginPwdType   : USINT;
    
    	{REGION Management of "Date and Hour" displayed by pGD1 display}
            (**Current local time (read only)*)
            CurrLocTime    : DateTimeRTC;
            (**Local time based on current time zone*)
            LocTime        : DateTime;
            (**Current day of week*)
            Day_Week       : DayOfWeek(0..6);
        {ENDREGION}
    {ENDREGION}
    
    {REGION ALARMS MANAGEMENT BY HMI}
        (**Global alarm*)
	    GblAlarm            : BOOL;
        (**Buzzer status (FALSE=Active, TRUE=Silenced)*)
	    BuzzerSilenced      : BOOL := FALSE;
        (**Requet to make blink LED-Alarm*)
        Req_BlinkLED_Alarm  : BOOL;
        (**Requet to maintain LED-Alarm's light on and fixed)*)
        Req_FixLED_Alarm    : BOOL;
        (**Requet TO make blink LED-PRG*)
        Req_BlinkLED_PRG    : BOOL;
        (**Requet to maintain LED-PRG's light on and fixed)*)
        Req_FixLED_PRG      : BOOL;
    {ENDREGION}
    
    {REGION Management of HMI LEDs}
        (**Mng. of LED blinking Alarm*)
    	DisplayBlinkLED_Alarm      : BOOL;
        (**Mng. of LED Alarm*)
    	DisplayLED_Alarm           : BOOL;    
        (**Mng. of LED blinking PRG*)
    	DisplayBlinkLED_PRG        : BOOL;
        (**Mng. of LED PRG*)
    	DisplayLED_PRG             : BOOL;
        (**Mng. of LED blinking BACKGROUND*)
    	DisplayBlinkLED_BACKGROUND : BOOL;
        (**Mng. of LED BACKGROUND*)
        DisplayLED_BACKGROUND      : BOOL;
    {ENDREGION}
    
    {REGION Main Mask}  
    	//(**UnitStatus - Unit status*)
    	//UnitStatus      : UNIT_STATUS (UNIT_STATUS#NOT_Used..UNIT_STATUS#Purging);
        (**Index of the Quick Menu*)
        IdxQM           : QUICK_MENU (QUICK_MENU#OnOff..QUICK_MENU#Info);
        (**Index of the image displayed by Quick Menu*)
        IdxImgQM        : USINT (0..5);
    {ENDREGION}
    
    {REGION Managemnet of Password in pGD1 interface}
        (**Temporary password*)
    	TmpPwd      : UINT(0..9999) := 0;
    	(**Temporary password digit 1*)
    	TmpPwd_Dig1 : UINT(0..9) := 0;
    	(**Temporary password digit 2*)
    	TmpPwd_Dig2 : UINT(0..9) := 0;
    	(**Temporary password digit 3*)
    	TmpPwd_Dig3 : UINT(0..9) := 0;
    	(**Temporary password digit 4*)
    	TmpPwd_Dig4 : UINT(0..9) := 0;
    {ENDREGION}
    
    {REGION Unit On}
        (**Reset of all hours counter (FALSE=None, TRUE=Reset)*)
        ResTotCnt    : BOOL;
    {ENDREGION}
    
END_VAR