{INCLUDE 'LibVer.g.st'}

NAMESPACE LibraryNamespaceAndVersion

USING System;
USING System.IO;
USING System.Math;
    
VAR_GLOBAL CONSTANT    
    (**Delta for remap Universal channel as ID, NO or Y
      Note: [1..20]=Normal channel for ID or NO or Y, [21..xx]=U chennel used as ID or NO or Y.
    *)
    DELTA_UNIV_CH : SINT  := 20;
    (**Max n° groups of Analog inputs *)
    AIN_GR_NO     : SINT  := 10;
END_VAR
    
VAR_GLOBAL INTERNAL CONSTANT    
    (**Not used*)
    NOTUSED       : USINT := 99;
END_VAR
    
VAR_GLOBAL INTERNAL    
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

    (** Array specifies the belonging relation between Channel and Group.
      * The array index identifies the Ain channel.
      * The array value, for each Ain channel, specifies the Group to which the channel belongs.
      * In case Channel doesn't have a Group, will be assigned to him the first free group.
    *)
    RelationChGroup : ARRAY [1..LIB_IO_MAX_U_CH] OF SINT;
END_VAR

     
(**Converts the 'probe mode type' in the one of 'System.IO' library.*)
FUNCTION PUBLIC PrbModeType_TO_LibSystemIO : USINT
    VAR_INPUT
        (**Probe mode type*)
        PrbModeTyp : MODE_TYPE_AIN;
    END_VAR
    
    CASE PrbModeTyp OF
        
        (* 
            MODE_TYPE_AIN#LIB_IO_PROBE_NTC              : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_NTC;
            MODE_TYPE_AIN#LIB_IO_PROBE_PT1000           : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_PT1000;
            MODE_TYPE_AIN#LIB_IO_PROBE_0_1V             : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_0_1V;
            MODE_TYPE_AIN#LIB_IO_PROBE_0_10V            : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_0_10V;
            MODE_TYPE_AIN#LIB_IO_PROBE_4_20MA           : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_4_20MA;
            MODE_TYPE_AIN#LIB_IO_PROBE_ONOFF            : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_ONOFF;
            MODE_TYPE_AIN#LIB_IO_PROBE_0_5V             : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_0_5V;
            MODE_TYPE_AIN#LIB_IO_PROBE_NTC_0_150        : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_NTC_0_150;
            MODE_TYPE_AIN#LIB_IO_PROBE_CUSTOM_n50T90    : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_CUSTOM_n50T90;
            MODE_TYPE_AIN#LIB_IO_PROBE_CUSTOM_10T170    : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_CUSTOM_10T170;
            MODE_TYPE_AIN#LIB_IO_PROBE_CUSTOM_1         : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_CUSTOM_1;
            MODE_TYPE_AIN#LIB_IO_PROBE_CUSTOM_SENSATA   : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_CUSTOM_SENSATA;
            MODE_TYPE_AIN#LIB_IO_PROBE_CUSTOM_2         : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_CUSTOM_2;
            MODE_TYPE_AIN#LIB_IO_PROBE_CUSTOM_3         : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_CUSTOM_3;
            MODE_TYPE_AIN#LIB_IO_PROBE_OHM_05           : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_OHM_05;
            MODE_TYPE_AIN#LIB_IO_PROBE_OHM_10           : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_OHM_10;
            MODE_TYPE_AIN#LIB_IO_PROBE_80MINUS          : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_80MINUS;
        *)
        MODE_TYPE_AIN#LIB_IO_PROBE_NTC .. MODE_TYPE_AIN#LIB_IO_PROBE_80MINUS: PrbModeType_TO_LibSystemIO := PrbModeTyp;    // 0..16 => Same value            
        
        (*
            MODE_TYPE_AIN#LIB_IO_PROBE_OHM              : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_OHM;
            MODE_TYPE_AIN#LIB_IO_PROBE_PT500            : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_PT500;
            MODE_TYPE_AIN#LIB_IO_PROBE_PT100            : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_PT100;
            MODE_TYPE_AIN#LIB_IO_PROBE_DIFF             : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_DIFF;
            MODE_TYPE_AIN#LIB_IO_PROBE_0_5V_ASS         : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_0_5V_ASS;
            MODE_TYPE_AIN#LIB_IO_PROBE_DIG_OPTO         : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_DIG_OPTO;
            MODE_TYPE_AIN#LIB_IO_PROBE_U_CNT            : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_U_CNT;
            MODE_TYPE_AIN#LIB_IO_PROBE_U_FREQ           : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_U_FREQ;
            MODE_TYPE_AIN#LIB_IO_PROBE_0_20MA           : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_0_20MA;
            MODE_TYPE_AIN#LIB_IO_PROBE_05_45V           : PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_05_45V;
        *)
        MODE_TYPE_AIN#LIB_IO_PROBE_OHM .. MODE_TYPE_AIN#LIB_IO_PROBE_NO_CONN-1: PrbModeType_TO_LibSystemIO := PrbModeTyp + 17;  // 17..30 => Value + 17          
    ELSE
        PrbModeType_TO_LibSystemIO := LIB_IO_PROBE_NO_CONN;
    END_CASE;    
END_FUNCTION
       
(**Converts 'System.IO' error code (STone library) to ERROR.*)
FUNCTION PUBLIC LibSystemIO_TO_Error : ERROR
    VAR_INPUT
        (**Error code of 'System.IO' library*)
        ErrLibSystemIO : SINT;
    END_VAR
    
    (* Code optimization: 
        - Error number is sequential but negative
        - Starts from: -1=LIB_IO_ERR_NOT_IN_USE to -10=LIB_IO_ERR_INTERNAL_FULL
     *)
    IF ErrLibSystemIO >= LIB_IO_ERR_INTERNAL_FULL AND  ErrLibSystemIO <= 0 THEN 
        LibSystemIO_TO_Error := TO_USINT(TO_SINT(ERROR#ProbeNotInUse) - ErrLibSystemIO);
    ELSIF ErrLibSystemIO = LIB_IO_ERR_CHIPIO_CONFIG_COMM THEN 
        LibSystemIO_TO_Error := ERROR#ChipIOConfigComm;
    ELSE
        LibSystemIO_TO_Error := ERROR#NoError;                                                  //included LIB_IO_NO_ERR
    END_IF;            
END_FUNCTION

(**Sets some information for the Local board:
  *  MAX_AIN_CH, MAX_DIN_CH, MAX_DOUT_CH, MAX_AOUT_CH variables
  *  RelationChGroup array
*)
FUNCTION INTERNAL SetEnvironment

        // Set first time Enviroument
    IF (MAX_AIN_CH=0 AND MAX_DIN_CH=0 AND MAX_DOUT_CH=0 AND MAX_AOUT_CH=0) THEN
        GetHardwareDescription(HwDesc_1);
        
        // Fetch the number of Ain&Din from hardware description --------------------------
        MAX_AIN_CH   := TO_USINT(LIB_IO_MAX_U_CH);    //        MAX_AIN_CH   := 8;
        MAX_DIN_CH   := TO_USINT(LIB_IO_MAX_ID_CH);   //        MAX_DIN_CH   := 5;
        MAX_DOUT_CH  := TO_USINT(LIB_IO_MAX_NO_CH);   //        MAX_DOUT_CH  := 5;
        MAX_AOUT_CH  := TO_USINT(LIB_IO_MAX_Y_CH);    //        MAX_AOUT_CH  := 2;
        // --------------------------------------------------------------------------------
{IF NOT DEF (IO_MNG_CORE0)}          
        Populate_RelationChGroup();
{ENDIF}         
    END_IF;
END_FUNCTION
    
{IF NOT DEF (IO_MNG_CORE0)} 
(**Populates the 'RelationChGroup'array.*)    
FUNCTION INTERNAL Populate_RelationChGroup
    VAR
        i           : INT;
        lastFGrUsed : SINT;
    END_VAR
    
    (* Populate array -> 'RelationChGroup' *)
    FOR i := 1 TO TO_INT(LIB_IO_MAX_U_CH) DO
        IF IOGetProbeGroup(TO_USINT(i)) > 0 THEN 
            (* Channel belongs at a Group *)
            RelationChGroup[i] := TO_SINT(IOGetProbeGroup(TO_USINT(i)));
            lastFGrUsed        := RelationChGroup[i];            
            
        ELSIF IOGetProbeGroup(TO_USINT(i)) = 0 THEN 
            (* Chennel doesn't belong at a Group -> I assign it a new 'Virtual Group' *)
            lastFGrUsed        := lastFGrUsed + 1;
            RelationChGroup[i] := lastFGrUsed;
            
        ELSIF IOGetProbeGroup(TO_USINT(i)) < 0 THEN 
            (* Channel is out of range -> The channel doens't exist inside the board*)
            RelationChGroup[i] := - 1;
        END_IF;
    END_FOR;
END_FUNCTION

(**Returns the Group to which the Channel belongs (0=Channel without group, -1=Out of range).*)    
FUNCTION PUBLIC Ch_TO_Group : SINT
    VAR_INPUT
        (**Ain Channel*)
        Ch : SINT;
    END_VAR
    
    IF Ch >= DELTA_UNIV_CH THEN
        (*In this case Ch is used as Universal channel for Ain*)
        Ch := Ch - DELTA_UNIV_CH;
    END_IF;
    IF (TO_DINT(Ch) >= LOWER_BOUND(RelationChGroup, 1)) AND (TO_DINT(Ch) <= UPPER_BOUND(RelationChGroup, 1)) THEN
        Ch_TO_Group := RelationChGroup[TO_SINT(Ch)];
    ELSE
        Ch_TO_Group := - 1;
    END_IF;
END_FUNCTION

(**Returns the list of all Channels belonging to the Group specified.*)
FUNCTION PUBLIC ChsSameGroup : ARRAY[0..LIB_IO_MAX_U_CH] OF SINT
    VAR_INPUT
        (**Gruop*)
        Group : SINT;
    END_VAR
    VAR
        i,k : INT;
    END_VAR
    
    FOR i := 1 TO TO_INT(LIB_IO_MAX_U_CH) DO
        IF Group = Ch_TO_Group(TO_SINT(i)) THEN 
            ChsSameGroup[k] := TO_SINT(i);
            k := k + 1;
        END_IF;
    END_FOR;
END_FUNCTION
   
(**Checks if Ain setting is compatible with setting admitted by HW's Channel (FALSE=Not Compatible, TRUE=Compatible).*)
FUNCTION PUBLIC AinCompatibilityHW: BOOL
    VAR_IN_OUT CONSTANT
        (**↓ AinCfg to test HW compatibility*)
        AinCfg : AinConfig;
    END_VAR
    VAR_IN_OUT    
        (**↑ Ain configuration error*)
        AinErr      : ErrConfig;
    END_VAR
    VAR
        (**List of all Channels belonging same to Group*)
        LstChsSameGrp : ARRAY [0..LIB_IO_MAX_U_CH] OF SINT;  
    END_VAR     
    
    // find all channel in same group
    LstChsSameGrp := ChsSameGroup(Ch_TO_Group(AinCfg.Ch));
    
    IF LstChsSameGrp[0] = 0 THEN
        AinErr.Trigger := TRUE;
        AinErr.Error   := ERROR#ChannelOutOfRange;
        
            // API checks compatibility
    ELSIF IOCheckUniversalIOConfiguration(TO_USINT(LstChsSameGrp[0]), LIB_IO_AIN, PrbModeType_TO_LibSystemIO(AinCfg.ModeType)) THEN
        AinCompatibilityHW := TRUE;
        AinErr.Trigger     := FALSE;
        AinErr.Error       := ERROR#NoError;
        
    ELSE
        AinErr.Trigger := TRUE;
        AinErr.Error   := ERROR#ChannelNotCompatible;        
    END_IF;      
END_FUNCTION
      
(**Checks if Ain setting is compatible with the Probes-Group belonging to the same Channels-Group (TRUE=Compatible, FALSE=Not Compatible).
  *NOTE: The correct name of this function must be 'AinCompatibilityHWProbesGroup' 
*)
FUNCTION PUBLIC AinSubGroupCompatibilityHW: BOOL
    VAR_IN_OUT CONSTANT
        (**↓ AinCfg to test HW compatibility*)
        AinCfg  : AinConfig;
        (**↓ uConfig*)
        uConfig : ARRAY[*] OF uChannelConfig;
    END_VAR   
    VAR_IN_OUT    
        (**↑ Ain configuration error*)
        AinErr  : ErrConfig;
    END_VAR
    VAR                                                                                                                                                                                                           
        (**The matrix specifies all the "probe types" that can be set for the analog inputs of the selected HW.
        * - Row: identifies the "Probes-Group", it contains only the probe types supported simultaneously by the HW.
        * - Column: given a row, the column allows you to identify the probe types supported by the "probe group". *)
        MtrxPrbType : ARRAY [1..6, 1..8] OF USINT := 
            [
            LIB_IO_PROBE_NTC,    LIB_IO_PROBE_NTC_0_150, NOTUSED, NOTUSED, NOTUSED, NOTUSED, NOTUSED, NOTUSED, //LIB_IO_PROBE_NTC_80_MINUS,
            LIB_IO_PROBE_PT1000, LIB_IO_PROBE_PT100,     LIB_IO_PROBE_PT500,         NOTUSED,                    NOTUSED,               NOTUSED,                     NOTUSED,               NOTUSED,            
            LIB_IO_PROBE_0_5V,   LIB_IO_PROBE_05_45V,    NOTUSED,                    NOTUSED,                    NOTUSED,               NOTUSED,                     NOTUSED,               NOTUSED,            
            LIB_IO_PROBE_4_20MA, LIB_IO_PROBE_0_20MA,    NOTUSED,                    NOTUSED,                    NOTUSED,               NOTUSED,                     NOTUSED,               NOTUSED,            
//          LIB_IO_PROBE_HLVP,   NOTUSED,                NOTUSED,                    NOTUSED,                    NOTUSED,               NOTUSED,                     NOTUSED,               NOTUSED,            
            LIB_IO_PROBE_U_CNT,  LIB_IO_PROBE_U_FREQ,    NOTUSED,                    NOTUSED,                    NOTUSED,               NOTUSED,                     NOTUSED,               NOTUSED,            
            LIB_IO_PROBE_0_10V,  NOTUSED,                NOTUSED,                    NOTUSED,                    NOTUSED,               NOTUSED,                     NOTUSED,               NOTUSED
            ];
        
        (**List of all Channels belonging same to Group*)
        LstChsSameGrp : ARRAY [0..LIB_IO_MAX_U_CH] OF SINT;
        (**Identifies the Probes-Group (Row of MtrxPrbType) of Channel to test HW compatibility*)
        PrbGrp_Ch     : USINT := NOTUSED;
        (**Identifies the Probes-Group (Row of MtrxPrbType) of LstChsSameGrp[Idx] *)
        PrbGrp_Ch1    : USINT := NOTUSED;        
        
        i, j : DINT;
        (**Index of 1st channel set as "configured" inside array LstChsSameGrp*)
        Idx  : DINT;
    END_VAR
    
    AinSubGroupCompatibilityHW := TRUE;    
    
    LstChsSameGrp := ChsSameGroup(Ch_TO_Group(AinCfg.Ch));  // Finds all channels belonging at the same group.    
    
    IF uConfig[LstChsSameGrp[0]].mode_sel = LIB_IO_PIN_NOT_CONFIGURED THEN
        //All channels are set as "not configured" -> It is the 1st cycle: so i can set this channel.
        {REGION Seeks the Index of 1st channel set as "configured" inside array LstChsSameGrp}
        FOR i := LOWER_BOUND(LstChsSameGrp, 1) TO UPPER_BOUND(LstChsSameGrp ,1) DO
            IF LstChsSameGrp[i] = AinCfg.Ch THEN
               Idx := i; 
            END_IF;
            IF LstChsSameGrp[i] = 0 THEN
               EXIT;                                        //NOTE: 0= end of Array.
            ELSE    
                IF uConfig[LstChsSameGrp[i]].mode_sel <> LIB_IO_PIN_NOT_CONFIGURED THEN
                    Idx := i;
                    EXIT;                                   // Found a channel configurated
                END_IF;
            END_IF;
        END_FOR;
        {ENDREGION}
    END_IF;
    
    IF AinCfg.Ch <> LstChsSameGrp[Idx] THEN
        {REGION Seek inside the MtrxPrbType}
            FOR i := 1 TO 6 DO
                FOR j := 1 TO 8 DO
                    (*Seeks the Probe-Group of AinCfg of which to test HW compatibility*)
                    IF PrbModeType_TO_LibSystemIO(AinCfg.ModeType) = MtrxPrbType[i,j] THEN
                        PrbGrp_Ch := TO_USINT(i);
                    END_IF;
                    
                    (*Seeks the Probe-Group of LstChsSameGrp[Idx]*)
                    IF uConfig[LstChsSameGrp[Idx]].mode_type = MtrxPrbType[i,j] THEN
                        PrbGrp_Ch1 := TO_USINT(i);
                    END_IF;
                END_FOR;
            END_FOR
        {ENDREGION};
        
        (*Are Probe-Group differents inside the same Channel-Group?*)
        IF  PrbGrp_Ch1 <> PrbGrp_Ch THEN
            AinSubGroupCompatibilityHW := FALSE;
            AinErr.Trigger                := TRUE;
            AinErr.Error                  := ERROR#ChannelNotCompatibleSubGroup;
        ELSE            
            AinErr.Trigger := FALSE;
            AinErr.Error   := ERROR#NoError;
        END_IF;
    ELSE        
        AinErr.Trigger := FALSE;
        AinErr.Error   := ERROR#NoError;
    END_IF;    
END_FUNCTION    

(**Checks if Aout setting is compatible with by HW's Channel (FALSE=Not Compatible, TRUE=Compatible).*)
FUNCTION PUBLIC AoutCompatibilityHW: BOOL
    VAR_IN_OUT CONSTANT
        (**↓ AoutCfg in test*)
        AoutCfg_test : AoutConfig;
    END_VAR
    VAR_IN_OUT
        (**↑ Aout configuration erroe*)
        AoutErr      : ErrConfig;
    END_VAR
    
    // Use API
    IF  IOCheckAnalogOutputConfiguration(TO_USINT(AoutCfg_test.Ch), AoutCfg_test.ModeType) THEN
        AoutCompatibilityHW := TRUE;
        AoutErr.Trigger     := FALSE;
        AoutErr.Error       := ERROR#NoError;
    ELSE
        AoutErr.Trigger := TRUE;
        AoutErr.Error   := ERROR#ChannelNotCompatible;
    END_IF;
END_FUNCTION

(**Checks if Dout setting is compatible with by HW's Channel (FALSE=Not Compatible, TRUE=Compatible).*)    
FUNCTION PUBLIC DoutCompatibilityHW: BOOL
    VAR_IN_OUT CONSTANT
        (**↓ DoutCfg in test*)
        DoutCfg_test : DoutConfig;
    END_VAR
    VAR_IN_OUT
        (**↑ Dout configuration erroe*)
        DoutErr      : ErrConfig;
    END_VAR 
    
    // Use API
    IF IOCheckDigitalOutputConfiguration(TO_USINT(DoutCfg_test.Ch), DoutCfg_test.ModeType) THEN
        DoutCompatibilityHW := TRUE;
        DoutErr.Trigger     := FALSE;
        DoutErr.Error       := ERROR#NoError;
    ELSE
        DoutErr.Trigger := TRUE;
        DoutErr.Error   := ERROR#ChannelNotCompatible;
    END_IF;    
END_FUNCTION  

{ENDIF}
    
END_NAMESPACE
