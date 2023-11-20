CLASS ScrollableTextMng
	USING System;
	USING System.Text;
	USING System.Timer;
	
    VAR PRIVATE
		IdxScrollText : DINT := 1;
		TON_StartScrollText : TON := (IN := TRUE);
		TON_StopScrollText : TON;
    END_VAR
	
METHOD PUBLIC ScrollText : STRING
        VAR_INPUT
            Text : STRING;
            IdxStart : DINT;
            StartTime : TIME;
            StopTime : TIME;
        END_VAR
        
        IF LEN(Text) > (22 - IdxStart) THEN
            THIS.TON_StartScrollText(PT := StartTime);
            THIS.TON_StopScrollText(PT := StopTime);
            
            IF THIS.TON_StopScrollText.Q THEN
                THIS.IdxScrollText := 1;
                THIS.TON_StartScrollText.IN := TRUE;
                THIS.TON_StopScrollText.IN := FALSE;
            END_IF;
            
            IF THIS.TON_StartScrollText.Q THEN
                THIS.IdxScrollText := THIS.IdxScrollText + 1;
            END_IF;
            
            IF THIS.IdxScrollText + 1 > LEN(Text) - (21 - IdxStart) THEN
                TON_StartScrollText.IN := FALSE;
                TON_StopScrollText.IN := TRUE;
            END_IF;
               
            ScrollText := MID(Text, 22 - IdxStart, THIS.IdxScrollText);
        ELSE
            ScrollText := Text;
        END_IF;
    END_METHOD
	
	METHOD PUBLIC Reset
	    THIS.TON_StartScrollText(IN := FALSE);
		THIS.TON_StopScrollText(IN := FALSE);
	    THIS.IdxScrollText := 1;
		THIS.TON_StartScrollText.IN := TRUE;
	END_METHOD	
END_CLASS