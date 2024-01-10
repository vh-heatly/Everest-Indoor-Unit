USING System;
USING System.Timer;
USING Libs.Timer;

PROGRAM AlarmsMng
	VAR
	    RTrig_RetainErr : R_TRIG;
	END_VAR

    (*Alarm management is skipped while the default valeus are being installed OR at startup while I/O are being read*)
    IF RestoreDefault OR UnitStatus = UNIT_STATUS#Wait THEN
        RETURN;
    END_IF;  
	
	RTrig_RetainErr(
		CLK := ExceptionInstance.ExceptionError = ERR_RETAIN_SAVE_TOO_OFTEN
	);
	Alarms.Table.Al_RetainMemNo.Info.Trigger := RTrig_RetainErr.Q;

    {REGION UNIT ALARMS BY DIN}
    {ENDREGION}

    {REGION PROBES ALARMS}
    Alarms.Table.Al_DHWBottomTemp.Info.Trigger := Ain_Info.Fct.DHWBottomTemp.Trigger;
    Alarms.Table.Al_DHWMiddleTemp.Info.Trigger := Ain_Info.Fct.DHWMiddleTemp.Trigger;
    Alarms.Table.Al_DHWTopTemp.Info.Trigger := Ain_Info.Fct.DHWTopTemp.Trigger;
    Alarms.Table.Al_DHWSupplyTemp.Info.Trigger := Ain_Info.Fct.DHWSupplyTemp.Trigger;
    Alarms.Table.Al_ClimSupplyTemp.Info.Trigger := Ain_Info.Fct.ClimSupplyTemp.Trigger;
    Alarms.Table.Al_OutDoorTemp.Info.Trigger := Ain_Info.Fct.OutDoorTemp.Trigger;
    Alarms.Table.Al_SysPress.Info.Trigger := Ain_Info.Fct.SysPress.Trigger;
    Alarms.Table.Al_OUOffline.Info.Trigger := (NOT (OU_Unit.Info.isOnline)) AND NOT(NoOutdoorUnit);
    {ENDREGION}
	
    {REGION OUTDOOR UNIT ALARMS}
    IF NOT NoOutdoorUnit THEN
    
        
        
    END_IF;
    
    {ENDREGION}
    
    {REGION LOGIC ALARMS}
    Alarms.Table.Al_FreezeProAct.Info.Trigger := CS_FreezeProtAct;
    {ENDREGION}
    
    
END_PROGRAM