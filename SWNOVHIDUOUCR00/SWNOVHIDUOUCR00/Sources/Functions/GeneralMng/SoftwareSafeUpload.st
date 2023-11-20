USING System;
USING System.Timer;

(** 
 * Allow to upload the software safely.
 * When a full download request from the IDE starts, the variable "KeybOffOn" will be set to FALSE.
 * Then after 10s, if the StartUpload is TRUE the download will start.
 *)
FUNCTION_BLOCK SoftwareSafeUpload
    VAR_IN_OUT
        (**Keyboard On/Off*)
        KeybOffOn   : BOOL;
    END_VAR
    VAR_INPUT
        (**Upload start-up command*)
        StartUpload : BOOL;
    END_VAR
    VAR
        (**Wait before start software upload inside controller*)
        TON_WAIT_DOWNLOAD : TON := (PT := T#5s);
    END_VAR
    
    (* A write operation in RETAIN/PERSISTENT MEMORY (ie: KeybOnOff=FALSE) became effective after 5s -> Inside the POP-UP window -> 
           if you select button "BY-PASS" (... and NOT WAIT 10s) and the UNIT is ON -> at controller re-start probably KeybOnOff will be TRUE. *)
    TON_WAIT_DOWNLOAD(IN := NOT(KeybOffOn) AND StartUpload);
    
    IF GetFullDownloadRequest() THEN                    
        //Request to put in "safety status" the unit.
        KeybOffOn := FALSE;
        //When UNIT is in "safety status", the full download can be done.
        IF TON_WAIT_DOWNLOAD.Q THEN
            SetIDESema(TO_INT(IDESEMA_FULLDOWNLOAD), TO_INT(SEMA_STATUS_GO));
        END_IF;
    ELSE
        SetIDESema(TO_INT(IDESEMA_FULLDOWNLOAD), TO_INT(SEMA_STATUS_WAIT));
    END_IF;
END_FUNCTION_BLOCK