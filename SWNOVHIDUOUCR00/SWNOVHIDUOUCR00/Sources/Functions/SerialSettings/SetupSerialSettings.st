USING System;
USING System.Text;
USING System.Timer;
USING System.Serial;
USING System.Math;

(** Allow to setup settings for a serial line. *)
FUNCTION SetupSerialSettings
    VAR_IN_OUT
        (** Serial settings *)
        Settings : SerialSettings;
    END_VAR
    VAR_INPUT
        (** Serial speed (Baudrate) *)
        Speed    : Serial_Speed;
        (** Serial parity stop bits *)
        ParityStopBit  : Serial_ParityStopBits;
		(** Serial port configuration *)
        Port  : Serial_Channel;
    END_VAR
    
    // Change of serial baudrate
    CASE Speed OF
        Serial_Speed#Baud_1200:   Settings.Speed := 1200;
        Serial_Speed#Baud_2400:   Settings.Speed := 2400;
        Serial_Speed#Baud_4800:   Settings.Speed := 4800;
        Serial_Speed#Baud_9600:   Settings.Speed := 9600;
        Serial_Speed#Baud_19200:  Settings.Speed := 19200;
        Serial_Speed#Baud_38400:  Settings.Speed := 38400;
        Serial_Speed#Baud_57600:  Settings.Speed := 57600;
        Serial_Speed#Baud_115200: Settings.Speed := 115200;
        Serial_Speed#Baud_375000: Settings.Speed := 375000; 
    END_CASE;
    
    // Change of serial settings
    CASE ParityStopBit OF
        // 8-NONE-1
        Serial_ParityStopBits#NONE_1:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#None;
            Settings.Stops  := SERIAL_STOP_1;                
        
        // 8-NONE-2
        Serial_ParityStopBits#NONE_2:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#None;
            Settings.Stops  := SERIAL_STOP_2;                
        
        // 8-EVEN-1
        Serial_ParityStopBits#EVEN_1:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Even;
            Settings.Stops  := SERIAL_STOP_1;                
        
        // 8-EVEN-2
        Serial_ParityStopBits#EVEN_2:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Even;
            Settings.Stops  := SERIAL_STOP_2;                
        
        // 8-ODD-1
        Serial_ParityStopBits#ODD_1:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Odd;
            Settings.Stops  := SERIAL_STOP_1;                
        
        // 8-ODD-2
        Serial_ParityStopBits#ODD_2:  
            Settings.Bits   := SERIAL_BITS_8;
            Settings.Parity := Serial_Parity#Odd;
            Settings.Stops  := SERIAL_STOP_2;                
    END_CASE;
	
	Settings.Channel := Port;
END_FUNCTION
