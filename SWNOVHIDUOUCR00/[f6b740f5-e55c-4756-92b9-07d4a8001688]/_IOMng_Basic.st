{INCLUDE 'LibVer.g.st'}

NAMESPACE LibraryNamespaceAndVersion

USING System;
USING System.IO;
USING System.Math;
USING System.Alarm;
USING System.Globalization;
  
USING Libs.AinMng_v2_0_2;
USING Libs.GetTime_v1_0_0;
    
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------   
//---------------------------------------------------------------------------- 

(**Reads the value from Din, specified its configuration. 
  *Returns an error in case of Din is incompatible with HW's channel (FALSE=No error, TRUE=Error).*)
FUNCTION INTERNAL DinRead : BOOL
    VAR_IN_OUT CONSTANT
        (**↓ ID is the array of channel with values read*)
        ID      : ARRAY[*] OF BOOL;      
        (**↓ Configuration of a single Din channel*)
        DinCfg  : DinConfig;
        (**↓ U is the system array of channels with values read. NOTE: used if Universal Channel configured as Din*)
        U       : ARRAY[*] OF uChannel;
    END_VAR    
    VAR_IN_OUT
        (**↑ Digital input value to read*)
        DinData : BOOL;       
        (**↑ Configuration error of a single Din channel*)
        DinErr  : ErrConfig;
        (**↑ uConfig is the array with configuration of channels (U). NOTE: used if Universal Channel configured as Din*)
        uConfig : ARRAY [*] OF uChannelConfig;
    END_VAR
    
    ResetError(DinErr);
    
    IF DinCfg.Ch >0 AND DinCfg.Ch <= TO_SINT(MAX_DIN_CH) THEN                                           //Standard DIN
        DinData := ID[DinCfg.Ch] XOR DinCfg.Logic;
        
    ELSIF DinCfg.Ch > DELTA_UNIV_CH AND DinCfg.Ch <= (TO_SINT(MAX_AIN_CH) + DELTA_UNIV_CH) THEN         // Universal Channel (U) used as DIN             
                            
        CASE DinCfg.ModeType OF
            MODE_TYPE_DIN#LIB_IO_DIN       : uConfig[DinCfg.Ch - DELTA_UNIV_CH].mode_sel  := LIB_IO_DIN;
            MODE_TYPE_DIN#LIB_IO_DIN_COUNT : uConfig[DinCfg.Ch - DELTA_UNIV_CH].mode_sel  := LIB_IO_DIN_COUNT;
            MODE_TYPE_DIN#LIB_IO_DIN_FREQ  : uConfig[DinCfg.Ch - DELTA_UNIV_CH].mode_sel  := LIB_IO_DIN_FREQ;
        END_CASE;
        uConfig[DinCfg.Ch - DELTA_UNIV_CH].mode_type := LIB_IO_PROBE_ONOFF;
        
        DinData      := U[DinCfg.Ch - DELTA_UNIV_CH].b XOR DinCfg.Logic;
        DinErr.Error := LibSystemIO_TO_Error(uConfig[DinCfg.Ch - DELTA_UNIV_CH].error);
        
    ELSE                 
        DinErr.Error := ERROR#ChannelOutOfRange;                                                    //The Channel doesn't exist inside the HW board
    END_IF;
    
    IF DinErr.Error <> ERROR#NoError THEN
        DinRead        := TRUE;
        DinErr.Trigger := TRUE;
    END_IF;
END_FUNCTION
   
(**Reads the value from Ain, specified its configuration. 
  *Returns an error in case of Ain setting is incompatible with HW's channel (FALSE=No error, TRUE=Error).*)
FUNCTION INTERNAL AinRead : BOOL
    VAR_IN_OUT CONSTANT
        (**↓ U is the system array of channels with values read*)
        U            : ARRAY[*] OF uChannel;      
        (**↓ Configuration of a single Ain channel*)
        AinCfg       : AinConfig;
        (**↓ Max limit for Ain_Value (Active probe only)*)
        AinCfgMax    : REAL;
        (**↓ Min limit for Ain_Value (Active probe only)*)
        AinCfgMin    : REAL;
        (**↓ Offset for Ain_Value*)
        AinCfgOffset : REAL;
    END_VAR
    VAR_IN_OUT    
        (**↑ Analog input value to read*)
        AinData      : REAL;
        (**↑ Configuration error of a single Ain channel*)
        AinErr       : ErrConfig;         
        (**↑ uConfig is the system array with configuration of channels (U)*)
        uConfig      : ARRAY[*] OF uChannelConfig;
        (**↑ Store the time when Ain alram is triggerd*)
        TimeAinAlr   : ARRAY[*] OF UDINT;
    END_VAR
    VAR      
        (**Save System time*)
        {ATTRIBUTE UOM MILLISECOND}
        MemSysTime  : UDINT;
        (**)
        OnOffVal    : BOOL;
        (**Probe error filtered by AinMngCore*)
        PrbErr      : SINT;
    END_VAR
    
    ResetError(AinErr);
    
    IF AinCfg.Ch > 0 AND AinCfg.Ch <= TO_SINT(MAX_AIN_CH) THEN                      // Universal channel (U) used as Analog Input
        MemSysTime := GetSystemTimeAdv();
{IF NOT DEF (IO_MNG_CORE0)}         
        IF  AinCompatibilityHW(AinCfg, AinErr)  AND
            AinSubGroupCompatibilityHW(AinCfg, uConfig, AinErr) THEN           // Checks compatibility of Channels-Group and Probes-Group, and set error code in AinCfg.Error
{ENDIF}                               
            IF AinCfg.ModeType < MODE_TYPE_AIN#LIB_IO_PROBE_NO_CONN THEN            // Sets uConfig
                uConfig[AinCfg.Ch].mode_sel  := LIB_IO_AIN;
                uConfig[AinCfg.Ch].mode_type := PrbModeType_TO_LibSystemIO(AinCfg.ModeType);
                uConfig[AinCfg.Ch].filter    := AinCfg.Filter;
            ELSE  
                uConfig[AinCfg.Ch].mode_sel  := LIB_IO_PIN_NOT_CONFIGURED;
                uConfig[AinCfg.Ch].mode_type := LIB_IO_PROBE_NO_CONN;
            END_IF;
                                                    
            {REGION Manegement as Ain_Mng FB} 
                PrbErr := uConfig[AinCfg.Ch].error;
                IF  AinMngCore2(
                                U[AinCfg.Ch].r,
                                PrbModeType_TO_LibSystemIO(AinCfg.ModeType),
                                AinCfgOffset,
                                AinCfgMin,
                                AinCfgMax,
                    
                                AinData,
                                OnOffVal,
                                PrbErr
                                )
                OR PrbErr <> LIB_IO_NO_ERR
                
                THEN                    // Cheks if there is a configuration error report by O.S.

                    IF TimeAinAlr[AinCfg.Ch] = 0 THEN                                //Alarm not saved?
                        TimeAinAlr[AinCfg.Ch] := MemSysTime;                         //Store time
                    END_IF;
                    
                    IF MemSysTime - TimeAinAlr[AinCfg.Ch] >= LIMIT(0, AinCfg.AlrmDT, 9999)*1000 THEN         //the cheching is in [ms]
                        AinErr.Error := LibSystemIO_TO_Error(PrbErr);
                    END_IF;
                ELSE
                    TimeAinAlr[AinCfg.Ch] := 0;
                END_IF;
            {ENDREGION}
                
{IF NOT DEF (IO_MNG_CORE0)}                
        END_IF;
{ENDIF}           
    ELSE               
        AinErr.Error := ERROR#ChannelOutOfRange;            //The Channel doesn't exist inside the HW board
    END_IF;   
                    
    IF AinErr.Error <> ERROR#NoError THEN
        AinRead        := TRUE;
        AinErr.Trigger := TRUE;
    END_IF;  
END_FUNCTION
    
(**Writes the value on the Dout, specified its configuration. 
  *Returns an error in case of Dout is incompatible with HW's channel (FALSE=No error, TRUE=Error).*)
FUNCTION INTERNAL DoutWrite : BOOL
    VAR_IN_OUT CONSTANT
        (**↓ Dout values value to write*)
        DoutData : BOOL;
        (**↓ Configuration of a single Dout channel*)
        DoutCfg  : DoutConfig;
    END_VAR    
    VAR_IN_OUT    
        (**↑ Configuration error of a single Dout channel*)
        DoutErr  : ErrConfig;
        (**↑ NO is the array of channel with values to write*)
        NO       : ARRAY[*] OF BOOL;
        (**↑ noConfig is the array with configuration of channels (NO)*)
        noConfig : ARRAY[*] OF noChannelConfig;
    END_VAR
    
     ResetError(DoutErr);
    
    IF DoutCfg.Ch > 0 AND DoutCfg.Ch <= TO_SINT(MAX_DOUT_CH) THEN           //Standard DOUT --------------------------------
{IF NOT DEF (IO_MNG_CORE0)}                
        IF DoutCompatibilityHW(DoutCfg, DoutErr ) THEN                      //Check compatibility error
{ENDIF}            
            noConfig[DoutCfg.Ch].mode_type := DoutCfg.ModeType;
                
            IF noConfig[DoutCfg.Ch].error = LIB_IO_NO_ERR THEN              // Chek if there are config error (reported also run time)                            
                NO[DoutCfg.Ch] := DoutData XOR DoutCfg.Logic;               // WRITE!
            ELSE
                DoutErr.Error:= LibSystemIO_TO_Error(noConfig[DoutCfg.Ch].error); 
            END_IF;
{IF NOT DEF (IO_MNG_CORE0)}                
        END_IF;
{ENDIF}        
        
    ELSE
        DoutErr.Error := ERROR#ChannelOutOfRange;
    END_IF;        
    
    IF DoutErr.Error <> ERROR#NoError THEN
        DoutWrite       := TRUE;
        DoutErr.Trigger := TRUE;
    END_IF;
END_FUNCTION

(**Writes the value on the Aout, specified its configuration. 
  *Returns an error in case of Aout is incompatible with HW's channel (FALSE=No error, TRUE=Error).*)
FUNCTION INTERNAL AoutWrite : BOOL
    VAR_IN_OUT CONSTANT
        (**↓ Analog output value to write*)
        AoutData : REAL;
        (**↓ Configuration of a single Aout channel*)
        AoutCfg  : AoutConfig;        
    END_VAR    
    VAR_IN_OUT    
        (**↑ Configuration error of a single Aout channel*)
        AoutErr    : ErrConfig;
        (**↑ Y is the array of channels with values to write*)
        Y          : ARRAY[*] OF UINT;        
        (**↑ yConfig is the array with configuration of channels (Y)*)
        yConfig    : ARRAY[*] OF yChannelConfig;
        (**↑ uConfig is the array with configuration of channels (U). NOTE: used if Universal Channel configured as Aout*)
        uConfig    : ARRAY[*] OF uChannelConfig;
        (**↑ Uout is the array with values to apply at Univeral channel U. NOTE: used if Universal Channel configured as Aout*)
        Uout       : ARRAY[*] OF UINT;
    END_VAR      
    
    ResetError(AoutErr);
    
    IF AoutCfg.Ch > 0 AND AoutCfg.Ch <= TO_SINT(MAX_AOUT_CH) THEN                                   //Standard Y --------------------------------                  
{IF NOT DEF (IO_MNG_CORE0)}                
        IF AoutCompatibilityHW(AoutCfg, AoutErr) THEN                                               // CHECK COMPATIBILITY error code set in AoutCfg.error structure
{ENDIF}            
            yConfig[AoutCfg.Ch].Mode_Type := AoutCfg.ModeType;
            yConfig[AoutCfg.Ch].Param0    := AoutCfg.Param0;
            yConfig[AoutCfg.Ch].Param1    := AoutCfg.Param1;
            yConfig[AoutCfg.Ch].Param2    := AoutCfg.Param2;
            
            IF AoutErr.Error <> ERROR#ChannelAlreadyUsed THEN
                AoutErr.Error := LibSystemIO_TO_Error(yConfig[AoutCfg.Ch].error);                    // put possible config error raised by system.IO in Alarm Structure 
            END_IF;
                
            IF yConfig[AoutCfg.Ch].error = LIB_IO_NO_ERR THEN                                        // Chek if there are config error (reported also run time)                            
                Y[AoutCfg.Ch] := TO_UINT(AoutData*10);                                               // WRITE!
            ELSE
                AoutErr.Error := LibSystemIO_TO_Error(yConfig[AoutCfg.Ch].error); 
            END_IF; 
{IF NOT DEF (IO_MNG_CORE0)}                
        END_IF;
{ENDIF}        

    ELSIF AoutCfg.Ch > DELTA_UNIV_CH AND AoutCfg.Ch <= (TO_SINT(MAX_AOUT_CH) + DELTA_UNIV_CH) THEN      // Universal Channel (U) used as Aout             
    
        uConfig[AoutCfg.Ch - DELTA_UNIV_CH].mode_sel := LIB_IO_AOUT;
        Uout[AoutCfg.Ch - DELTA_UNIV_CH]             := TO_UINT(AoutData*10);
        AoutErr.Error                                := LibSystemIO_TO_Error(uConfig[AoutCfg.Ch - DELTA_UNIV_CH].error);
        
    ELSE 
        AoutErr.Error := ERROR#ChannelOutOfRange;
    END_IF;
        
    IF AoutErr.Error <> ERROR#NoError THEN
        AoutWrite       := TRUE;
        AoutErr.Trigger := TRUE;
    END_IF;    
END_FUNCTION

(**Returns TRUE if channel of element 'i' is alredy used, otherwise FALSE*)
FUNCTION INTERNAL CheckChannelAlreadyUsed : BOOL
    VAR_IN_OUT CONSTANT
        (**↓ Channel of element i*)
        iCh     : SINT;
        (**↓ Channel of element j*)
        jCh     : SINT;
    END_VAR
    VAR_IN_OUT
        (**↑ Information of I/O channel*)
        iErr    : ErrConfig;
    END_VAR
    
    //IF i<>j AND (iEnable AND iCh <> 0) AND (jEnable AND iCh = jCh) THEN
    IF iCh = jCh THEN
        CheckChannelAlreadyUsed := TRUE;
        
        (*Set error inside i element*)
        iErr.Trigger := TRUE;
        iErr.Error   := ERROR#ChannelAlreadyUsed;        
    END_IF;
END_FUNCTION    

(**Returns TRUE, and set uConfig.mode_sel=LIB_IO_PIN_NOT_CONFIGURED.*)    
FUNCTION INTERNAL Reset_Uconfig_ModeSel : BOOL
    VAR_IN_OUT
        (**U channels configuration (Physical channels)*)
        uConfig: ARRAY[*] OF uChannelConfig;
    END_VAR
    VAR
        i : DINT;
    END_VAR
    
    FOR i := LOWER_BOUND(uConfig, 1) TO UPPER_BOUND(uConfig, 1) DO
        uConfig[i].mode_sel := LIB_IO_PIN_NOT_CONFIGURED;
    END_FOR;
    
    Reset_Uconfig_ModeSel := TRUE;
END_FUNCTION 

(**Resets only the error saved inside STRUCT ErrConfig.*)    
FUNCTION INTERNAL ResetError
    VAR_IN_OUT
        (**↑ Information of I/O channel*)
        Err : ErrConfig;
    END_VAR
    Err.Error   := ERROR#NoError;
    Err.Trigger := FALSE;    
END_FUNCTION
    
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------   
//----------------------------------------------------------------------------    

(**This class manages the I/O operation of a Local board*)    
CLASS Class_IOMng_Basic
    VAR PRIVATE
        (**Reset status flag of uConfig.mode_sel filed (TRUE=Reset done)*)
        ResetDone_UconfigModeSel : BOOL;
        (**Store the time when Ain alram is triggerd*)
        TimeAinAlr : ARRAY [1..LIB_IO_MAX_U_CH] OF UDINT;
    END_VAR
    
    (**Resets only the TimeAinAlr array element of channels not used.*)
    METHOD PRIVATE Reset_TimeAinAlr
        VAR_IN_OUT CONSTANT
            (**↓ Ain's configuration*)
            AinCfg : ARRAY[*] OF AinConfig;
        END_VAR

        VAR
            i      : DINT;
            ChUsed : ARRAY [1..LIB_IO_MAX_U_CH] OF BOOL;
        END_VAR
        
        FOR i := LOWER_BOUND(AinCfg, 1) TO UPPER_BOUND(AinCfg, 1) DO
            IF      AinCfg[i].Enable 
                AND (AinCfg[i].Ch > 0 AND AinCfg[i].Ch <= TO_SINT(MAX_AIN_CH)) THEN
                ChUsed[AinCfg[i].Ch] := TRUE;                                           //Channel used
            END_IF;
        END_FOR;
        
        FOR i := LOWER_BOUND(ChUsed, 1) TO UPPER_BOUND(ChUsed, 1) DO
            IF NOT ChUsed[i] THEN
                THIS.TimeAinAlr[i] := 0;                                                //Reset time of Ain alarm
            END_IF;
        END_FOR;
    END_METHOD
    
    (**Reads the board inputs: Ain and Din. 
      *Returns the number of errors (0=No error).*)
    METHOD Read : UINT
        VAR_INPUT
            (**↓ Identifier expected of the HW board used*)
            Board : USINT;
        END_VAR
        VAR_IN_OUT CONSTANT
            (**↓ ID values (Physical channels)*)
            ID           : ARRAY[*] OF BOOL;
            (**↓ U values (Physical channels)*)
            U            : ARRAY[*] OF uChannel;         
            (**↓ Din's configuration*)
            DinCfg       : ARRAY[*] OF DinConfig;
            (**↓ Ain's configuration*)
            AinCfg       : ARRAY[*] OF AinConfig;
            (**↓ Max limits to use in the convertion of value read (Active probe only)*)
            AinCfgMax    : ARRAY[*] OF REAL;
            (**↓ Min limits to use in the convertion of value read (Active probe only)*)
            AinCfgMin    : ARRAY[*] OF REAL;
            (**↓ Offset's to sum at the values read *)
            AinCfgOffset : ARRAY[*] OF REAL;
        END_VAR    
        VAR_IN_OUT    
            (**↑ Reading of Din values*)
            DinData : ARRAY[*] OF BOOL;
            (**↑ Din configuration errors*)
            DinErr  : ARRAY[*] OF ErrConfig;
            (**↑ Reading of Ain values*)
            AinData : ARRAY[*] OF REAL;
            (**↑ Ain configuration errors*)
            AinErr  : ARRAY[*] OF ErrConfig;
            (**↑ U channels configuration (Physical channels)*)
            uConfig : ARRAY[*] OF uChannelConfig;
        END_VAR            
        VAR            
            i,j : INT;
        END_VAR
        
        SetEnvironment();                                                                                                                                            //Set number of phisical ch
                            
        {REGION AIn READ}
        THIS.ResetDone_UconfigModeSel := Reset_Uconfig_ModeSel(uConfig);                        //Reset the filed Uconfig.Mode_Sel
        
        (*Reset of TimeAinAlr*)
        Reset_TimeAinAlr(AinCfg);
        
        FOR i := TO_INT(LOWER_BOUND(AinCfg,1)) TO TO_INT(UPPER_BOUND(AinCfg,1)) DO
            AinErr[i].Configured := AinCfg[i].Enable AND AinCfg[i].Ch <> 0;
            
            IF AinErr[i].Configured THEN            
                IF AinCfg[i].Board = Board THEN
                    Read := Read + TO_UINT(AinRead(U, AinCfg[i], AinCfgMax[i], AinCfgMin[i], AinCfgOffset[i], AinData[i], AinErr[i], uConfig, THIS.TimeAinAlr));      //Reading failed: Increment the number of errors
{IF NOT DEF (IO_MNG_CORE0)}                     
                    FOR j := i-1 TO TO_INT(LOWER_BOUND(AinCfg,1)) BY -1  DO                                                       //Checks if the channel was already previously used. If yes an alarm is triggered!                    
                        IF AinCfg[j].Board = Board AND AinErr[j].Configured THEN
                            Read := Read + TO_UINT(CheckChannelAlreadyUsed(AinCfg[i].Ch, AinCfg[j].Ch, AinErr[i]));             //If used: Increment the number of errors
                        END_IF;
                    END_FOR;
{ENDIF}                    
                END_IF;
            ELSE
                ResetError(AinErr[i]);
                AinData[i] := 0;
            END_IF;
        END_FOR;
        {ENDREGION}
        
        {REGION Din READ}
        FOR i := TO_INT(LOWER_BOUND(DinCfg,1)) TO TO_INT(UPPER_BOUND(DinCfg,1)) DO
            DinErr[i].Configured := DinCfg[i].Enable AND DinCfg[i].Ch <> 0;
            
            IF DinErr[i].Configured THEN
                IF DinCfg[i].Board = Board THEN
                    Read := Read + TO_UINT(DinRead(ID, DinCfg[i], U, DinData[i], DinErr[i], uConfig));                          //Reading failed: Increment the number of errors
{IF NOT DEF (IO_MNG_CORE0)}                      
                    FOR j := i-1 TO TO_INT(LOWER_BOUND(DinCfg,1)) BY -1  DO                                                       //Checks if the channel was already previously used. If yes an alarm is triggered!                 
                       IF DinCfg[j].Board = Board AND DinErr[j].Configured THEN
                            Read := Read + TO_UINT(CheckChannelAlreadyUsed(DinCfg[i].Ch, DinCfg[j].Ch, DinErr[i]));             //If used: Increment the number of errors    
                        END_IF;                        
                    END_FOR;
{ENDIF}                    
                END_IF;
            ELSE
                ResetError(DinErr[i]);
                DinData[i] := FALSE;
            END_IF;
        END_FOR;
        {ENDREGION}        
    END_METHOD
        
    (**Writes board outputs: Aout and Dout.
      *Returns the number of errors (0=No error).*)
    METHOD Write : UINT
        VAR_INPUT
            (**↓ Identifier expected of the HW board used*)
            Board : USINT;        
        END_VAR
        
        VAR_IN_OUT CONSTANT
            (**↓ Dout's configuration*)
            DoutCfg  : ARRAY[*] OF DoutConfig; 
            (**↓ Dout values to write*)
            DoutData : ARRAY[*] OF BOOL;
            (**↓ Aout's configuration*)
            AoutCfg  : ARRAY[*] OF AoutConfig;
            (**↓ Aout values to write*)
            AoutData : ARRAY[*] OF REAL;
        END_VAR        
                
        VAR_IN_OUT
            (**↑ Dout configuration errors*)
            DoutErr  : ARRAY[*] OF ErrConfig;
            (**↑ Aout configuration errors*)
            AoutErr  : ARRAY[*] OF ErrConfig;
            (**↑ NO values (Physical channels)*)
            NO       : ARRAY[*] OF BOOL;
            (**↑ NO channels configuration (Physical channels)*)
            noConfig : ARRAY[*] OF noChannelConfig;
            (**↑ Y values (Physical channels)*)
            Y        : ARRAY[*] OF UINT;
            (**↑ Y channels configuration (Physical channels)*)
            yConfig  : ARRAY[*] OF yChannelConfig;
            (**↑ U channels configuration (Physical channels)*)
            uConfig  : ARRAY[*] OF uChannelConfig;
            (**↑ Aout values to write when Universal Channel (U) used as Aout*)
            Uout     : ARRAY[*] OF UINT;
        END_VAR
        VAR
            i,j : INT;
        END_VAR
        
        SetEnvironment();                                                                       //set number of phisical Ch
        
        {REGION Reset of: NO, noConfig, Y, yConfig, Uout, uConfig}                              // team STone suggest to use do this method.
            IF NOT THIS.ResetDone_UconfigModeSel THEN
                Reset_Uconfig_ModeSel(uConfig);
            END_IF;
        
            FOR i := TO_INT(LOWER_BOUND(NO, 1)) TO TO_INT(UPPER_BOUND(NO, 1)) DO                //Same lenght: NO[] and noConfig[]
                noConfig[i].mode_type := LIB_IO_STANDARD_RELE;                                  //Configuration of physical ADigital Output
                NO[i] := FALSE;                                                                 //Physical Digital Output
            END_FOR;
        
            FOR i := TO_INT(LOWER_BOUND(yConfig, 1)) TO TO_INT(UPPER_BOUND(yConfig, 1)) DO      //Same lenght: Y[] and yConfig[]
//              yConfig[i].mode_type := LIB_IO_PIN_NOT_CONFIGURED;                              //Configuration of physical Analog Output (Line commented for #23)
                Y[i] := 0;                                                                      //Physical Analog Output
            END_FOR;
        
            FOR i := TO_INT(LOWER_BOUND(Uout, 1)) TO TO_INT(UPPER_BOUND(Uout, 1)) DO
                Uout[i] := 0;                                                                   //Physical Universal channel (U) used Analog Output
            END_FOR;                        
        {ENDREGION}        
        
        {REGION Aout write}
        FOR i := TO_INT(LOWER_BOUND(AoutCfg,1)) TO TO_INT(UPPER_BOUND(AoutCfg,1)) DO
            AoutErr[i].Configured := AoutCfg[i].Enable AND AoutCfg[i].Ch <> 0;
            
            IF AoutErr[i].Configured THEN 
                IF AoutCfg[i].Board = Board THEN
                    Write := Write + TO_UINT(AoutWrite(AoutData[i], AoutCfg[i], AoutErr[i], Y, yConfig, uConfig, Uout));            //Writing failed:  Increment the number of errors
{IF NOT DEF (IO_MNG_CORE0)}                     
                    FOR j := i-1 TO TO_INT(LOWER_BOUND(AoutCfg,1)) BY -1  DO                                                          //Checks if the channel was already previously used. If yes an alarm is triggered! 
                        IF AoutCfg[j].Board = Board AND AoutErr[j].Configured THEN
                            Write := Write + TO_UINT(CheckChannelAlreadyUsed(AoutCfg[i].Ch, AoutCfg[j].Ch, AoutErr[i]));            //If used: Increment the number of errors
                        END_IF;
                    END_FOR;
{ENDIF}                    
                END_IF;
            ELSE
                ResetError(AoutErr[i]);
            END_IF;
        END_FOR;
        {ENDREGION}
                
        {REGION Dout write}
        FOR i := TO_INT(LOWER_BOUND(DoutCfg,1)) TO TO_INT(UPPER_BOUND(DoutCfg,1)) DO
            DoutErr[i].Configured := DoutCfg[i].Enable AND DoutCfg[i].Ch <> 0;                
            
            IF DoutErr[i].Configured THEN            
                IF DoutCfg[i].Board = Board THEN                
                    Write := Write + TO_UINT(DoutWrite(DoutData[i], DoutCfg[i], DoutErr[i], NO, noConfig));                         //Writing failed: Increment the number of errors
{IF NOT DEF (IO_MNG_CORE0)}                     
                    FOR j := i-1 TO TO_INT(LOWER_BOUND(DoutCfg,1)) BY -1  DO                                                          //Checks if the channel was already previously used. If yes an alarm is triggered!
                        IF DoutCfg[j].Board = Board AND DoutErr[j].Configured THEN
                            Write := Write + TO_UINT(CheckChannelAlreadyUsed(DoutCfg[i].Ch, DoutCfg[j].Ch, DoutErr[i]));            //If used: Increment the number of errors
                        END_IF;
                    END_FOR;
{ENDIF}                    
                END_IF;
            ELSE
                ResetError(DoutErr[i]);
            END_IF;    
        END_FOR;
        {ENDREGION}
    END_METHOD   
    
END_CLASS


    
END_NAMESPACE



