{INCLUDE 'LibVer.g.st'}

NAMESPACE LibraryNamespaceAndVersion   
    
    USING System.Alarm;
    USING System.IO;
    
    TYPE
        (**Specifies the behavior of Din (NOTE: LIB_IO_DIN_COUNT and LIB_IO_DIN_FREQ only for U channel used as Din) *)
        MODE_TYPE_DIN: (            
            (** Selection mode for digital input (U channel) *)    
        	LIB_IO_DIN,
            (** Selection mode for analog DIN counter (U channel) *)    
        	LIB_IO_DIN_COUNT,
            (** Selection mode for analog DIN freq (U channel) *)    
        	LIB_IO_DIN_FREQ
        ); 
        
        (**Specifies the U channel behavior (Ain, Din, Aout)*)
        MODE_SEL_AIN: (
            (** Selection mode for analog ouput (U channel) *) 
        	LIB_IO_AOUT,
            (** Selection mode for digital input (U channel) *)    
        	LIB_IO_DIN,
            (** Selection mode for analog DIN counter (U channel) *)    
        	LIB_IO_DIN_COUNT,
            (** Selection mode for analog DIN freq (U channel) *)    
        	LIB_IO_DIN_FREQ,  
            (** Selection mode not configured (U channel) *)
            LIB_IO_PIN_NOT_CONFIGURED
        );           
        
        (**Specifies the behavior of Ain (probe type) *)
        MODE_TYPE_AIN: (
            (** Selection type NTC for AIN (U channel) *)                          	
        	LIB_IO_PROBE_NTC,
            (** Selection type PT1000 for AIN (U channel) *)
        	LIB_IO_PROBE_PT1000,
            (** Selection type 0..1 V for AIN (U channel) *)
        	LIB_IO_PROBE_0_1V,
            (** Selection type 0..10 V for AIN (U channel) *)
        	LIB_IO_PROBE_0_10V,
            (** Selection type 4..20 mA for AIN (U channel) *)
        	LIB_IO_PROBE_4_20MA,
            (** Selection type ON OFF for AIN (U channel) *)
        	LIB_IO_PROBE_ONOFF,
            (** Selection type 0..5V for AIN (U channel) *)
        	LIB_IO_PROBE_0_5V,
            (** Selection type NTC 0..150 for AIN (U channel) *)
        	LIB_IO_PROBE_NTC_0_150,
            (** Selection type PROBE CUSTOM n50T90 for AIN (U channel) *)
        	LIB_IO_PROBE_CUSTOM_n50T90,
            (** Selection type PROBE CUSTOM 10T170 for AIN (U channel) *)
        	LIB_IO_PROBE_CUSTOM_10T170,
            (** Selection type PROBE CUSTOM 1 for AIN (U channel) *)
        	LIB_IO_PROBE_CUSTOM_1,
            (** Selection type CUSTOM SENSATA for AIN (U channel) *)
        	LIB_IO_PROBE_CUSTOM_SENSATA,
            (** Selection type PROBE CUSTOM 2 for AIN (U channel) *)
        	LIB_IO_PROBE_CUSTOM_2,
            (** Selection type PROBE CUSTOM 3 for AIN (U channel) *)
        	LIB_IO_PROBE_CUSTOM_3,
            (** Selection type 0..5 OHM for AIN (U channel) *)
        	LIB_IO_PROBE_OHM_05,
            (** Selection type 0..10 OHM  for AIN (U channel) *)
        	LIB_IO_PROBE_OHM_10,
            (** Selection type 80 MINUS for AIN (U channel) *)
        	LIB_IO_PROBE_80MINUS,
            (** Selection type OHM for AIN (U channel) *)
        	LIB_IO_PROBE_OHM,
            (** Selection type PT500 for AIN (U channel) *)
        	LIB_IO_PROBE_PT500,
            (** Selection type PT100 for AIN (U channel) *)
        	LIB_IO_PROBE_PT100,
            (** Selection type DIFF for AIN (U channel) *)
        	LIB_IO_PROBE_DIFF,
            (** Selection type 0..5V ASS for AIN (U channel) *)
        	LIB_IO_PROBE_0_5V_ASS,
            (** Selection type DIG OPTO for AIN (U channel) *)
        	LIB_IO_PROBE_DIG_OPTO,
            (** Selection type U COUNTER for AIN (U channel) *)
        	LIB_IO_PROBE_U_CNT,
            (** Selection type U FREQ for AIN (U channel) *)
        	LIB_IO_PROBE_U_FREQ,
            (** Selection type 0..20 mA for AIN (U channel) *)
        	LIB_IO_PROBE_0_20MA,
            (** Selection type 0.5..4.5 V for AIN (U channel) *)
        	LIB_IO_PROBE_05_45V,
            (** Selection type HLVP for AIN (U channel) *)
            LIB_IO_PROBE_HLVP,           
            (** Selection type PTC CAREL for AIN (U channel) *)
            LIB_IO_PROBE_PTC_CAREL,      
            (** Selection type SFL60 for AIN (U channel) *)
            LIB_IO_PROBE_SFL60,   		
            (** Selection type PROBE NO CONNECTION for AIN (U channel) *)
        	LIB_IO_PROBE_NO_CONN
        );         
        
        (**Specifies the behavior of Dout*)
        MODE_TYPE_DOUT: (
            (** Selection type normal mode for NO*)
        	LIB_IO_STANDARD_RELE,
            (** Selection type delayed mode for NO*)
        	LIB_IO_DELAYED_RELE,
            (** Selection type cycled mode for NO*)
        	LIB_IO_CYCLIC_RELE
        );
        
        (**Specifies the behavior of Aout*)
        MODE_TYPE_AOUT: (
            (** Selection type 0..10 V for AOUT (Y channel) *) 	
        	LIB_IO_OUT_0_10V,
            (** Selection type PWM synchronous with main frequency for AOUT (Y channel) *) 	
        	LIB_IO_PWM_SYNC_MAIN_FREQ,
            (** Selection type phase cutting for AOUT (Y channel) *) 	
        	LIB_IO_PHASE_CUTTING,
            (** Selection type PWM 100 HZ 0..10 SR for AOUT (Y channel) *) 	
        	LIB_IO_PWM100HZ0_10_SR,
            (** Selection type 0..10 V for AOUT (Y channel) *) 	
        	LIB_IO_OUT_0_10V_SRC,
            (** Selection type PWM 2KHZ for AOUT (Y channel) *) 	
        	LIB_IO_PWM_2_KHZ,
            (** Selection type PWM_VFC for AOUT (Y channel) *) 	
	        LIB_IO_PWM_VFC
        );     
        
        (**Error code*)
        ERROR: (
            (** No error *)
            NoError,
            (** Probe out of range / Probe broken*)
            BrokenProbe,
            (** Channel out of premissible range*)
            ChannelOutOfRange,
            (** Channel not compatible with specified Group Type*)
            ChannelNotCompatibleSubGroup,
            (** Channel not compatible with specified type*)
            ChannelNotCompatible,
            (** Channel already used by another function*)
            ChannelAlreadyUsed,
            (*--- keeps free for future new alamrs implemantation --- *)
            Reserved0,
            Reserved1,
            Reserved2,
            Reserved3,
            Reserved4,
            (*---------------------------------------------------------*)
                    //-----------  from bios (chip IO) transled with Uniform_error_code() Function
            (** Error during chip IO configuration (from chip IO)*)
            ChipIOConfigComm,
            (** Probe not in use (from chip IO)*)
            ProbeNotInUse,
            (** Probe not connected (from chip IO)*)
            ProbeNotConnected,
            (** Probe short circuited (from chip IO)*)
            ShortCircuit,
            (** Probe overflow (from chip IO)*)
            Overflow,
            (** Probe underflow (from chip IO)*)
            Underflow,
            (** Invalid param, range, direction and type may be out of range (from chip IO)*)
            InvalidParam,
            (** Channel busy, happens with the second channel of PT100 (from chip IO)*)
            ChannelNotFree,
            (** Channel not valid (from chip IO)*)
            InvalidChannel,
            (** Missing scaling values for probes (from chip IO)*)
            InternalTableError,
            (** Invalid probe type (from chip IO)*)
            InvalidProbeType,
            (** Internal structure full (from chip IO)*)
            InternalStructureFull
        );
    END_TYPE

    
    TYPE          
        (**Information of a I/O channel*)
        ErrConfig: STRUCT
            (**Channel configuration status (TRUE= Ch<>0 and Enable=TRUE)*)
            Configured : BOOL;
            (**Config alarm trigger*)
            Trigger    : BOOL;
            (**Error code*)
            Error      : ERROR;            
        END_STRUCT;
        
        (**Ain configuration (Channel U)*)
        AinConfig: STRUCT
                (**Identifier expected of the HW board used*)
                Board       : USINT;
                (**Configuration channel (0:Not used, 1..20:Universal channel (U)) *)
                Ch          : SINT;  
                (**Function is enabled*)
                Enable      : BOOL;       
                (** Probe type. NOTE: Cosidered if Universal channel (U) is used as Ain*)                                                                                    
                ModeType    : MODE_TYPE_AIN;
                (**Stability of the probe: P parameter of internal PID for noise reduction*)
                Filter      : USINT := 5;            
                (**Broken probe alarm delay (0..9999)*)
                {ATTRIBUTE UOM SECOND}
                AlrmDT      : UDINT;
            END_STRUCT; 
        
        (**Aout configuration*)
        AoutConfig: STRUCT
                (**Identifier expected of the HW board used*)
                Board       : USINT;
                (**Configuration channel (0:Not used, 1..DELTA_UNIV_CH:Analog Output (Y), > DELTA_UNIV_CH: Universal Channel (U) used as Analog Output*)
                Ch          : SINT; 
                (**Function is enabled*)
                Enable      : BOOL;              
        		(** Channel mode type*)
        		ModeType    : MODE_TYPE_AOUT;
        		(**Parameter configuration in accord with type *)
        		Param0      : UINT;
        		(**Parameter configuration in accord with type *)
        		Param1      : UINT;
        		(**Parameter configuration in accord with type *)
        		Param2      : UINT;  
            END_STRUCT;

        (**Din configuration*)
        DinConfig: STRUCT
                (**Identifier expected of the HW board used*)
                Board       : USINT;            
                (**Configuration channel (0:Not used, 1..DELTA_UNIV_CH:Digital Input (ID), >DELTA_UNIV_CH: Universal Channel (U) used as Digital Input*)
                Ch          : SINT;  
                (**Function is enabled*)
                Enable      : BOOL; 
                (**Channel mode type. NOTE: LIB_IO_DIN_COUNT and LIB_IO_DIN_FREQ only for Universal channel (U) used as Digital Input*)                                                                                    
                ModeType    : MODE_TYPE_DIN;            
                (**Invert the logic of Digital Input*)
                (*
                  *  DI  │  Logic │ Result (XOR)
                  *  ────┼────────┼───────
                  *  0   │    0   │   0
                  *  1   │    0   │   1
                  *  0   │    1   │   1
                  *  1   │    1   │   0    *)
                Logic       : BOOL;  
                (**Not used*)
                {ATTRIBUTE UOM SECOND}
                AlrmDT      : UDINT;
            END_STRUCT;

        (**Dout configuration*)
        DoutConfig: STRUCT
                (**Identifier expected of the HW board used*)
                Board       : USINT;            
                (**Configuration channel*)
                Ch          : SINT;  
                (**Function is enabled*)
                Enable      : BOOL;              
                (**Channel mode type*)   
                ModeType    : MODE_TYPE_DOUT;
                (**Invert the logic of Digital Output*)
                (*
                  *  DOUT│  Logic │ Result (XOR)
                  *  ────┼────────┼───────
                  *  0   │    0   │   0
                  *  1   │    0   │   1
                  *  0   │    1   │   1
                  *  1   │    1   │   0    *)
                Logic       : BOOL;    
                (**Used to obtain a: Delayed Relay, Cyclic Relay, Delayed Relay no sync (see doc.)*)
                tOn         : UINT;
                (**Used to obtain a: Delayed Relay, Cyclic Relay, Delayed Relay no sync (see doc.)*)
        		tOff        : UINT;
                (**Group the work of two or more relè by ID *)
        		GroupID     : USINT; 
                (**Not used*)
                {ATTRIBUTE UOM SECOND}
                AlrmDT      : UDINT;
        END_STRUCT;            
    END_TYPE    
END_NAMESPACE