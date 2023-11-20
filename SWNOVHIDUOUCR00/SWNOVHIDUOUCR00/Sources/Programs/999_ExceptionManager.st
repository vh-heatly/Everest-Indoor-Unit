USING System;
USING System.TEXT;

VAR_GLOBAL RETAIN INTERNAL
    (**Enable automatic test mode*)
    (*Allow to avoid the machine to stop in case of NFC/retain memory error.*)
    En_ATMode : BOOL;
END_VAR

PROGRAM ExceptionManager
    VAR_TEMP
        (**Event to read the error *)
        event           : Event;
        (**ID of task in error*)
        taskId          : INT;
        (**Error code*)
        error           : DINT;
        (**Erasures in case of retain/NFC written too often *)
        eraseures       : UDINT;
        (**Offset of erasure, in case of retain written too often *)
        eraseuresOffset : UDINT;
        (** Resume value: result of division by zero, square of negative, log of negative*)
        data            : UDINT := 0;
        (** Error string*)
        ErrorString     : STRING;
        (**Skip break of NFC/retain memory*)
        SkipRetainBreak : BOOL;
    END_VAR
    VAR_OUTPUT 
        ExceptionError : DINT;
    END_VAR
    
    (*Get the event*)
    GetCurrentEvent(event);

    (*Check for a system error*)
    IF event.EventType = VMSystemEvent AND event.Mask = TO_DWORD(EVENT_EXCEPTION) THEN
        
        taskId := TO_INT(event.Data);
        GetLastTaskErrorCodeError(taskId, error);
        ExceptionError := error;
        
        ErrorString := FORMAT('Error 0x%08X ', error) + GetErrorDescription(error);
        
        (*Cause of error*)
        CASE error OF
            ERR_NFC_SAVE_TOO_OFTEN, ERR_RETAIN_SAVE_TOO_OFTEN :
                IF error = ERR_RETAIN_SAVE_TOO_OFTEN THEN
                    GetRetainInfo(eraseures, eraseuresOffset);
                ELSE
                    GetNfcInfo(eraseures, eraseuresOffset);
                END_IF;
                ErrorString := ErrorString + FORMAT(' Erasures for minute %d', eraseures);
                ErrorString := ErrorString + FORMAT(' Erasures offset %d', eraseuresOffset);
			
				SkipRetainBreak := En_ATMode;
        END_CASE;
        
        (*Write log*)
        WriteLog(LogLevel#Error_Level, ErrorString);
        
        (*Break in case of connection with STone*)
        IF IsDebuggerPresent() AND NOT(SkipRetainBreak) THEN
            SYSBREAK();
        END_IF;
        
        (*Resume the task, reset the task error*)
        ResumeTask(taskId, error, data);
        
        (** To reset after 30 seconds, enable the following define: *)
        {IF FALSE}
        HardwareReset(30, 0);
        {ENDIF}
	END_IF;

END_PROGRAM