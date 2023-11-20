USING System.Serial;

(**Function to get the system serial channel*)
FUNCTION getServerPort : Serial_Channel
    VAR_INPUT
        Port : Serial_Channel_Server;
    END_VAR
	CASE Port OF
	    Serial_Channel_Server#BMS2:
			getServerPort := Serial_Channel#BMS2;
	    Serial_Channel_Server#BMS1:
			getServerPort := Serial_Channel#BMS1;
	    Serial_Channel_Server#Serial0:
			getServerPort := Serial_Channel#Serial0;
	ELSE
		getServerPort := Serial_Channel#BMS1;
	END_CASE;
END_FUNCTION