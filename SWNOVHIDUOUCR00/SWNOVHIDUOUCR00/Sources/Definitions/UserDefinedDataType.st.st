(*----------------------------------
         ADD HERE YOUR TYPES!
----------------------------------*)
TYPE
    (**STone project GIUD*)
    StonePrjGUID:
        STRUCT
            Grp1 : STRING[8];
            Grp2 : STRING[4];
            Grp3 : STRING[4];
            Grp4 : STRING[4];
            Grp5 : STRING[12];        
        END_STRUCT;
    
    (**Date position range*)
    DatePosRange : USINT(0..99);
    
    (**Time Struct used to change RTC*)
    TimeRTC: STRUCT
        (**Hourh*)  {ATTRIBUTE UOM HOUR}
        Hour        : UINT(0..23);
        (**Minute*) {ATTRIBUTE UOM MINUTE}
        Minute      : UINT(0..59);
        (**Second*){ATTRIBUTE UOM SECOND}
        Second      : UINT(0..59);
        (**Millisecond*){ATTRIBUTE UOM MILLISECOND}
        Millisecond : UINT(0..999);
    END_STRUCT;
    
    (**Date Struct used to change RTC*)
    DateRTC: STRUCT
        (**Day*)    {ATTRIBUTE UOM DAY}
        Day         : UINT(1..31);
        (**Month*)  {ATTRIBUTE UOM MONTH}
        Month       : UINT(1..12);
        (**Year*)   {ATTRIBUTE UOM YEAR}
        Year        : UINT(2021..2200);
    END_STRUCT;
    
    (**Date and time Struct used to change RTC*)
    DateTimeRTC: STRUCT
        (**Day*)    {ATTRIBUTE UOM DAY}
        Day         : UINT(1..31);
        (**Month*)  {ATTRIBUTE UOM MONTH}
        Month       : UINT(1..12);
        (**Year*)   {ATTRIBUTE UOM YEAR}
        Year        : UINT(2021..2200);
        (**Hourh*)  {ATTRIBUTE UOM HOUR}
        Hour        : UINT(0..23);
        (**Minute*) {ATTRIBUTE UOM MINUTE}
        Minute      : UINT(0..59);
        (**Second*){ATTRIBUTE UOM SECOND}
        Second      : UINT(0..59);
        (**Millisecond*){ATTRIBUTE UOM MILLISECOND}
        Millisecond : UINT(0..999);
    END_STRUCT;
    
    HeatCurves_SetP: STRUCT
        test : ARRAY [1..2] OF REAL;
    END_STRUCT;
    
    (**Units measure zone*)
    UOM_ZONE :
        (
        (**No Zone*)
        NONE,
        (**International System Zone [°C/bar]*)
        SI,
        (**Imperial Zone [°F/psi]*)
        Imperial
        );

   (**Unit status type*)
    UNIT_STATUS:
    (
        (**Wait*)
        Wait,                
        (**Unit ON*)
        UnitON,
        (**Off By Alarm*)
        OffByAlarm,      
        (**Off By Network*)
        OffByNetwork,               
        (**Off By BMS*)
        OffByBMS,                   
        (**Off By Scheduler*)
        OffByScheduler,             
        (**Off By Digital Input*)
        OffByDI,             
        (**Off By Keyboard*)
        OffByKeyboard,              
        (**Unit manual mode active*)
        Manual,                     
        (**ChangeOver*)
        ChangeOver,                 
        (**Switch ON*)
        SwitchON,                   
        (**Shut Down*)
        ShutDown,                   
        (**Pre-Conditioning*)
        PreConditioning,            
        (**Dehumidification*)
        Dehumidification,           
        (**Antifreeze*)
        Antifreeze,                 
        (**Defrost*)
        Defrost,                    
        (**Air Pressure/Flow*)
        AirPressure_Flow,           
        (**Air Quality*)
        AirQuality,                 
        (**Cooling*)
        Cooling,                    
        (**Heating*)
        Heating,                    
        (**FreeCooling*)
        FreeCooling,                
        (**FreeHeating*)
        FreeHeating,                
        (**Low Temperature Control*)
        LowTemperatureControl,      
        (**High Temperature Control*)
        HighTemperatureControl,     
        (**Test I/O*)
        TestIO,                     
        (**Domestic Hot Water*)
        DHW,                        
        (**Inactivity Start*)
        InactivityStart,            
        (**High Saturation Humidity*)
        HighSaturationHumidity,     
        (**Purging*)
        Purging                     
    ); 
    
    (**List of Quick Menu position*)
    QUICK_MENU:
    (
        (**Selected Loop OnOff*)
        OnOff,
        (**Selcted Loop Set*)
        Set,
        (**Selected Loop Info*)
        Info
    );
    
    (**Current state of HMI - Used to manage LogoMask/LanguageMask/MainMask transition*)
    State_HMI:
    (
        (**Wait*)
        Wait,
        (**Display Logo Mask*)
        DisplayLogoMask,
        (**Display Language Mask*)
        DisplayLanguageMask,
        (**Display Main Mask*)
        DisplayMainMask
    );
    
    (**Serial port configuration (Parity and Stop bits)*)
    Serial_ParityStopBits :
    (
        (**NONE-1*)
        NONE_1,
        (**NONE-2*)
        NONE_2,    
        (**EVEN-1*)
        EVEN_1,
        (**EVEN-2*)
        EVEN_2,
        (**ODD-1*)
        ODD_1,
        (**ODD-2*)
        ODD_2
    );
    
    (**Serial port baud rate configuration*)
    Serial_Speed :
    (
        (**Baud rate 1200*)
        Baud_1200,
        (**Baud rate 2400*)
        Baud_2400,
        (**Baud rate 4800*)
        Baud_4800,
        (**Baud rate 9600*)
        Baud_9600,
        (**Baud rate 19200*)
        Baud_19200,
        (**Baud rate 38400*)
        Baud_38400,
        (**Baud rate 57600*)
        Baud_57600,
        (**Baud rate 115200*)
        Baud_115200,
        (**Baud rate 375000*)
        Baud_375000
    );
    
    (**Type of password used for Login procedure*)
    LOGIN_PASSWORD : 
    (
        (**User*)
        User,
        (**Service*)
        Service,
        (**Manufacturer*)
        Manufacturer,
        (**System*)
        System   
    );
    
    (**Used by APPLICA to manage clock and timezone*)
    APPsConfigRTC: 
        STRUCT            
        	(**Every time it's value change the PLC change it's RTC*)
        	SetRTC     : BOOL;
            (**New "Date and Time" used to update the RTC*)
        	DateTime   : DATE_AND_TIME;
        	(**New "Time Zone" used to update the RTC*)
        	TimeZone   : STRING;    
        END_STRUCT;
    
    BOARD_TYPE : (
        (**Current PCO*)
        PCO
    );
   
    Multistate: STRUCT
        (**Value of multistate*)
        Value        : INT;
        (**Description of multistate*)
        Description  : STRING;
    END_STRUCT;

    PROFILE_INFO : STRUCT
        (**Profile name*)
        Name : STRING;
        (**Profile mask name*)
        MskIndex : DINT;
    END_STRUCT;
	
    CAROUSEL_DATA : STRUCT
        (**Acronym*)
        Acronym : STRING;
        (**Enable*)
        Enable  : BOOL;
        (**Description*)
        Desc    : STRING;
    END_STRUCT;
    
    SIGNAL_TYPE : (
        (**Request by BMS*)
        BMS,
        (**Request by PID*)
        PID
    );
    
    (**EEV driver type*)
    EVD_TYPE :(
        (**EVD Disabled*)
        Disabled,
        (**EVD Embedded*)
        Embedded,
        (**EVD EVO*)
        External
    );
    
    (**Circuit compressors type*)
    COMP_TYPE :(
        (**BLDC Only*)
        BLDC_Only,
        (**Tandem - One BLDC and one on/off*)
        BLDC_Tandem,
        (**Trio - One BLDC and two on/off*)
        BLDC_Trio
    );
    
    (**Power+ Speed status*)
    SPEED_STATUS :(
        (**Normal regulation*)
        Normal,
        (**Temperature derating*)
        Temp,
        (**DC Bus derating*)
        Bus,
        (**Torque derating*)
        Torque
    );
    
	(**Supervisor offline management*)
    SPV_OFFLINE_MNG :(
		(**No visualization*)
		None,
		(**Warning, visualization only*)
		Warning,
		(**Alarm, switch off the unit*)
		Alarm
	);
	
	COMP_STATUS :(
        (**Compressor status - off*)
		Off,
        (**Compressor status - off timing*)
		OffTiming,
        (**Compressor status - on timing*)
		OnTiming,
        (**Compressor status - on running*)
		Running,
        (**Compressor status - manual mode*)
		ManualMode,
        (**Compressor status - defrost*)
		Defrost,        
        (**Compressor status - alarm*)
		Alarm
	);

    EEV_ALARM_CODE :(
		(**----*)
        None,
        (**EEV error : MOP*)
        MOP,
        (**EEV error : LOP*)
        LOP,
        (**EEV error : LowSuct*)
        LowSuct,
        (**EEV error : Low super heat*)
        LowSH,
        (**EEV error : High condention temperature*)
        HiCondTemp,
        (**EEV error : High super heat*)
        HighSH
    );

    DEFROST_STARTSTOP_TYP :(
        (**Defrost by DIN*)
        ByDIN,
        (**Defrost by Evaporate condensation temperature*)
        ByEvapCondTemp,
        (**Defrost by BMS*)
        ByBms
    );

	STAGE_CFG_ENUM:(
		(**1 stage = 100%*)
		ONOFF,
		(**2 stages = 50% - 100%*)
		TWO_STAGES,
		(**3 stages = 50% - 75% - 100%*)
		THREE_STAGES_50,
		(**4 stages = 25% - 50% - 75% - 100%*)
		FOUR_STAGES,
		(**3 stages = 33% - 66% - 100%*)
		THREE_STAGES_33,
		(**BLDC*)
		BLDC,
		(**1 stage = modulating*)
		INVERTER
	);

	ROT_TYPE:(
		(**----*)
		NONE,
		(**First In - First Out*)
		FIFO,
		(**Last In - First Out*)
		LIFO,
		(**device on/off request is based on device operating hours*)
		TIMED,
		(**device on/off request is based on custom parameters*)
		CUSTOM,
		(**device on/off request is based on custom parameters without circuit equalization*)
		CUSTOM2
	);
	EQUALIZATION:(
		(**Grouped*)
		GROUPED,
		(**Equalized*)
		EQUALIZED,
		(**Grouped at start and equalised at shutdown*)
		GRP_START_EQ_SHUTDWN
	);
	
	(**DevRot can have the following values :
            0 : Device Off, 
            1 : Device ON OR stage 1, 
            2 : Stage 2, 
            3 : Stage 3, 
            4 : Stage 4,
            5 : Device ON FOR pump-down AT power-ON, 
            6 : Device on for pump-down at power-off
    *)
	DEVROT_ENUM:(
		OFF,
		ON_STAGE1,
		STAGE2,
		STAGE3,
		STAGE4,
		PMPDWN_PWRON,
		PMPDWN_PWROFF
	);
	
	(** Serial channels list *)
	Serial_Channel_Server:
	(
	    (** BMS1 serial channel *)
	    BMS1,
	    (** BMS2 serial channel *)
	    BMS2,
	    (** Serial0 serial channel *)
	    Serial0
	);
	
	(** Serial channels list *)
	Serial_Channel_Client:
	(
	    (** FBUS1 serial channel *)
	    FBUS1,
	    (** FBUS2 serial channel *)
	    FBUS2
	);
	(** Superheat modification function status *)
	EEV_SSHSetP_Status:
	(
        (**"Standard" Superheat setpoint not affected*)
        NORMAL_OPERATION,
	    (** Low discharge superheat *)
	    LOW_DSH,
	    (** High discharge temperature *)
	    HIGH_DLT,
        (** Compressor heating active *)
        COMP_HEAT,
        (** MOP - Superheat prevention*)
        MOP_SHPREV
	);
    
    OpStage_Status:
    (
        (**Unit in decision phase*)
        DECISION_PHASE,
        (**Unit in heating mode*)
        HEATING,
        (**Unit in cooling mode*)
        COOLING,
        (**Unit in DHW mode*)
        DHW,
        (**Unit in Defrost mode*)
        DEFROST
    );
    
    SGStatus:
    (
        (**SG normal mode*)
        NORMAL_MODE,
        (**SG low price mode*)
        LOW_PRICE_MODE,
        (**SG blocking mode*)
        BLOCKING_MODE,
        (**SG overcapacity mode*)
        OVERCAPACITY_MODE
    );
    
    DHWMode:
    (
        (**Economy mode*)
        ECONOMY,
        (**Normal mode*)
        NORMAL,
        (**Comfort mode*)
        COMFORT
    );
    
    OutSideTemp:
    (
        (**Outside temperature probe*)
        OUTSIDETEMP,
        (**Ooutdoor unit temperature*)
        OUTDOORUNIT,
        (**Connectivity card*)
        CONNECTIVITYCARD
    );

    
END_TYPE