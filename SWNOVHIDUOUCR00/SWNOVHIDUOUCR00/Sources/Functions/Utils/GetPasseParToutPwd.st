FUNCTION GetPasseParToutPwd : UINT
	USING System.Timer;
	
    VAR
		Date : DateTime;
	END_VAR

	GetLocalTime(Date);
    GetPasseParToutPwd := 9999 - ((Date.Day * Date.Month) + Date.Year);
END_FUNCTION