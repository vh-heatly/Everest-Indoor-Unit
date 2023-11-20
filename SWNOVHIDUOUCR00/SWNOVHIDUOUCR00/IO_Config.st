USING System.IO;

VAR_GLOBAL
	U    AT%IB1.0       : ARRAY[1..LIB_IO_MAX_U_CH]  OF uChannel;
	Uout AT%QB1.0       : ARRAY[1..LIB_IO_MAX_U_CH]  OF UINT;
	Y    AT%QW21.0      : ARRAY[1..LIB_IO_MAX_Y_CH]  OF UINT;
	NO   AT%QB31.0      : ARRAY[1..LIB_IO_MAX_NO_CH] OF BOOL;
	ID   AT%IB31.0      : ARRAY[1..LIB_IO_MAX_ID_CH] OF BOOL;

	uConfig  AT%MB1.0   : ARRAY[1..LIB_IO_MAX_U_CH]  OF uChannelConfig;
	yConfig  AT%MB21.0  : ARRAY[1..LIB_IO_MAX_Y_CH]  OF yChannelConfig;
	noConfig AT%MB31.0  : ARRAY[1..LIB_IO_MAX_NO_CH] OF noChannelConfig;

	virtU  AT%M61.0     : ARRAY[1..LIB_IO_MAX_U_CH]  OF BOOL;
	virtID AT%M71.0     : ARRAY[1..LIB_IO_MAX_ID_CH] OF BOOL;
END_VAR
