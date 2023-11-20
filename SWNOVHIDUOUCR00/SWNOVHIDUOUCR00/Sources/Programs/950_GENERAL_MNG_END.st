USING System.UI;

PROGRAM MainEnd
    {REGION WRITE BUFFER OF EACH SERIAL PORT}
    IF RetainRestored THEN
        //Stop all protocols.
        Supervisor.Stop();
        MBM_Line.Stop();
        Display.Stop();
    ELSE
        //Modbus Server line
        Supervisor.Write();
        //START COMMUNICATION
        Supervisor.Start();

        //Modbus Client line
        MBM_Line.Write();
        //START COMMUNICATION
        MBM_Line.Start();

        Display.Write();
    END_IF;

    {ENDREGION}

	(* Refresh UI *)
    SendVirtualKey(NO_KEY, 1); 

END_PROGRAM