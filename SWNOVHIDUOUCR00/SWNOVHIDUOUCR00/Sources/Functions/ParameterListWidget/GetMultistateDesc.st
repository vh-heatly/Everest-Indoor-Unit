USING System;

(*Return the description of paramter given the value and the list of descriptions*)
FUNCTION GetMultistateDsc : STRING
  VAR_IN_OUT
		CurrArrMlt : ARRAY[*] OF Multistate;
        value : INT;
	END_VAR
	VAR
			i : DINT;
	END_VAR

	FOR i := LOWER_BOUND(CurrArrMlt, 1) TO UPPER_BOUND(CurrArrMlt, 1) DO
		IF CurrArrMlt[i].Value = value THEN
		    GetMultistateDsc := CurrArrMlt[i].Description;
			EXIT;
		ELSE
			GetMultistateDsc := 'FUNCTION_ERROR';
		END_IF;
	END_FOR;
END_FUNCTION