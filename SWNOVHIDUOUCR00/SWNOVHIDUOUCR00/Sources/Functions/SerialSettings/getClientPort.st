USING System.Serial;

(**Function to get the system serial channel*)
FUNCTION getClientPort : Serial_Channel
    VAR_INPUT
        Port : Serial_Channel_Server;
    END_VAR
	CASE Port OF
	    Serial_Channel_Client#FBUS2:
			getClientPort := Serial_Channel#FBUS2;
	    Serial_Channel_Client#FBUS1:
			getClientPort := Serial_Channel#FBUS1;
	ELSE
		getClientPort := Serial_Channel#FBUS2;
	END_CASE;
END_FUNCTION