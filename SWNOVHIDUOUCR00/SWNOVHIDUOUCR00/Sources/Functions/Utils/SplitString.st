(**Split the given string in multiple rows*)
FUNCTION SplitString
	USING System;
	USING System.Text;
	
    VAR_INPUT
        Str : STRING;
		MaxStrLength : UDINT;
    END_VAR
	VAR_IN_OUT
	    StrArr : ARRAY[*] OF STRING;
	END_VAR
	VAR
	    i : UDINT;
		j : DINT;
		idx : DINT;
		TmpStr : STRING;
		StrLen : UDINT;
	END_VAR
	
	//Start index from the lower array index
	idx := LOWER_BOUND(StrArr, 1);
	
	StrLen := TO_UDINT(LEN(Str));
	
	WHILE i < StrLen DO
		//Avoid array out of bound
		IF idx > UPPER_BOUND(StrArr, 1) THEN
			EXIT;
		END_IF;
		
		//Pick 22 character from the string
		TmpStr := MID(Str, MaxStrLength, i + 1);
		
		//Check if the partial string starts with whitespace, if yes remove it.
		IF LEFT(TmpStr, 1) = ' ' THEN
			i := i + 1;
		    //Pick the new 22 character from the string
			TmpStr := MID(Str, MaxStrLength, i + 1);
		END_IF;
		
		(* 
		1. Be sure we are NOT splitting the last 22 chars of the string otherwise it could split these chars in more lines...
		2. Check if the partial string is ending with a word
		*)
		IF i + MaxStrLength < StrLen AND MID(Str, 1, i + MaxStrLength + 1) <> ' ' THEN
		    //Find the latest word, we don't want to split the word in more lines
			FOR j := TO_DINT(MaxStrLength) TO 1 BY -1 DO
			    IF MID(TmpStr, 1, j) = ' ' THEN
					TmpStr := LEFT(TmpStr, j);
					EXIT;
				END_IF;
			END_FOR;
			
			//If "j" is 0 it means that the string is a long word, so the next iteration needs to increase by 22
			IF j = 0 THEN
				j := TO_DINT(MaxStrLength);
			END_IF;
		ELSE
			j := TO_DINT(MaxStrLength);
		END_IF;
		StrArr[idx] := TmpStr;
		i := i + TO_UDINT(j);
		idx := idx + 1;
	END_WHILE;
END_FUNCTION