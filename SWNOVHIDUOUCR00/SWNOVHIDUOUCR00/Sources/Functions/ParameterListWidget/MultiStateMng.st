/*
AUTHOR      : Carel Industries S.p.A
VERSION     : 1.0.0
DATE        : 20/02/2022
DESCRIPTION : WidgetList.
*/

USING System;

VAR_GLOBAL

	{REGION LISTS DESCRIPTIONS AND ENUMERATORS}

	listKEY_PROBE_ERROR :  ARRAY[0..22] OF Multistate := [(Value := 0, Description :='NO ERROR'), (Value := 1, Description :='PROBE BROKEN'), (Value := 2, Description :='CHANNEL OUT OF LIMIT'), (Value := 3, Description :='CHANNEL NOT COMPATIBLE IN THE SUBGROUP'), (Value := 4, Description :='INCOMPATIBLE CHANNEL'), (Value := 5, Description :='CHANNEL ALREADY USED'), (Value := 6, Description :='RESERVED 0'), (Value := 7, Description :='RESERVED 1'), (Value := 8, Description :='RESERVED 2'), (Value := 9, Description :='RESERVED 3'), (Value := 10, Description :='RESERVED 4'), (Value := 11, Description :='IO CHIP COMM. CONFIG.'), (Value := 12, Description :='PROBE NOT USED'), (Value := 13, Description :='PROBE NOT CONNECTED'), (Value := 14, Description :='SHORT CIRCUIT'), (Value := 15, Description :='OVER THE LIMIT'), (Value := 16, Description :='BELOW THE LIMIT'), (Value := 17, Description :='INVALID PARAMETER'), (Value := 18, Description :='CHANNEL OCCUPIED'), (Value := 19, Description :='INVALID CHANNEL'), (Value := 20, Description :='INTERNAL TABLE ERROR'), (Value := 21, Description :='INVALID PROBE TYPE'), (Value := 22, Description :='INTERNAL STRUCTURE FULL')];
	listKEY_MODE_TYPE_AIN :  ARRAY[0..30] OF Multistate := [(Value := 0, Description :='NTC'), (Value := 1, Description :='PT1000'), (Value := 2, Description :='0..1 V'), (Value := 3, Description :='0..10 V'), (Value := 4, Description :='4..20 mA'), (Value := 5, Description :='ON OFF'), (Value := 6, Description :='0..5V'), (Value := 7, Description :='NTC 0..150'), (Value := 8, Description :='PROBE CUSTOM n50T90'), (Value := 9, Description :='PROBE CUSTOM 10T170'), (Value := 10, Description :='PROBE NOT USED'), (Value := 11, Description :='PROBE NOT USED'), (Value := 12, Description :='PROBE NOT USED'), (Value := 13, Description :='PROBE NOT USED'), (Value := 14, Description :='0..5 OHM'), (Value := 15, Description :='0..10 OHM'), (Value := 16, Description :='80 MINUS'), (Value := 17, Description :='OHM'), (Value := 18, Description :='PT500'), (Value := 19, Description :='PT100'), (Value := 20, Description :='DIFF'), (Value := 21, Description :='0..5V ASS'), (Value := 22, Description :='DIG OPTO'), (Value := 23, Description :='U COUNTER'), (Value := 24, Description :='U FREQ'), (Value := 25, Description :='0..20 mA'), (Value := 26, Description :='0.5..4.5 V'), (Value := 27, Description :='HLVP'), (Value := 28, Description :='PTC CAREL'), (Value := 29, Description :='SFL60'), (Value := 30, Description :='PROBE NO CONNECTION')];
	listKEY_MODE_TYPE_AOUT :  ARRAY[0..6] OF Multistate := [(Value := 0, Description :='0..10 V'), (Value := 1, Description :='PWM sync with freq'), (Value := 2, Description :='phase cutting'), (Value := 3, Description :='PWM 100 HZ 0..10 SR'), (Value := 4, Description :='0..10 V'), (Value := 5, Description :='PWM 2KHZ'), (Value := 6, Description :='PWM_VFC')];
	listKEY_DIN_LOGIC :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='NC'), (Value := 1, Description :='NO')];
	listKEY_DOUT_LOGIC :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='NO'), (Value := 1, Description :='NC')];
	listKEY_DIGITAL_STATUS :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='NOT ACTIVE'), (Value := 1, Description :='ACTIVE')];
	listKEY_DIN_CH :  ARRAY[0..32] OF Multistate := [(Value := 0, Description :='NOT USED'), (Value := 1, Description :='ID1'), (Value := 2, Description :='ID2'), (Value := 3, Description :='ID3'), (Value := 4, Description :='ID4'), (Value := 5, Description :='ID5'), (Value := 6, Description :='ID6'), (Value := 7, Description :='ID7'), (Value := 8, Description :='ID8'), (Value := 9, Description :='ID9'), (Value := 10, Description :='ID10'), (Value := 11, Description :='ID11'), (Value := 12, Description :='ID12'), (Value := 13, Description :='ID13'), (Value := 14, Description :='ID14'), (Value := 15, Description :='NOT USED'), (Value := 16, Description :='NOT USED'), (Value := 17, Description :='NOT USED'), (Value := 18, Description :='NOT USED'), (Value := 19, Description :='NOT USED'), (Value := 20, Description :='NOT USED'), (Value := 21, Description :='U1'), (Value := 22, Description :='U2'), (Value := 23, Description :='U3'), (Value := 24, Description :='U4'), (Value := 25, Description :='U5'), (Value := 26, Description :='U6'), (Value := 27, Description :='U7'), (Value := 28, Description :='U8'), (Value := 29, Description :='U9'), (Value := 30, Description :='U10'), (Value := 31, Description :='U11'), (Value := 32, Description :='U12')];
	listKEY_DOUT_CH :  ARRAY[0..29] OF Multistate := [(Value := 0, Description :='NOT USED'), (Value := 1, Description :='NO1'), (Value := 2, Description :='NO2'), (Value := 3, Description :='NO3'), (Value := 4, Description :='NO4'), (Value := 5, Description :='NO5'), (Value := 6, Description :='NO6'), (Value := 7, Description :='NO7'), (Value := 8, Description :='NO8'), (Value := 9, Description :='NO9'), (Value := 10, Description :='NO10'), (Value := 11, Description :='NO11'), (Value := 12, Description :='NO12'), (Value := 13, Description :='NO13'), (Value := 14, Description :='NO14'), (Value := 15, Description :='NO15'), (Value := 16, Description :='NO16'), (Value := 17, Description :='NO17'), (Value := 18, Description :='NO18'), (Value := 19, Description :='NO19'), (Value := 20, Description :='NO20'), (Value := 21, Description :='NO21'), (Value := 22, Description :='NO22'), (Value := 23, Description :='NO23'), (Value := 24, Description :='NO24'), (Value := 25, Description :='NO25'), (Value := 26, Description :='NO26'), (Value := 27, Description :='NO27'), (Value := 28, Description :='NO28'), (Value := 29, Description :='NO29')];
	listKEY_AIN_CH :  ARRAY[0..12] OF Multistate := [(Value := 0, Description :='NOT USED'), (Value := 1, Description :='U1'), (Value := 2, Description :='U2'), (Value := 3, Description :='U3'), (Value := 4, Description :='U4'), (Value := 5, Description :='U5'), (Value := 6, Description :='U6'), (Value := 7, Description :='U7'), (Value := 8, Description :='U8'), (Value := 9, Description :='U9'), (Value := 10, Description :='U10'), (Value := 11, Description :='U11'), (Value := 12, Description :='U12')];
	listKEY_AOUT_CH :  ARRAY[0..32] OF Multistate := [(Value := 0, Description :='NOT USED'), (Value := 1, Description :='Y1'), (Value := 2, Description :='Y2'), (Value := 3, Description :='Y3'), (Value := 4, Description :='Y4'), (Value := 5, Description :='Y5'), (Value := 6, Description :='Y6'), (Value := 7, Description :='NOT USED'), (Value := 8, Description :='NOT USED'), (Value := 9, Description :='NOT USED'), (Value := 10, Description :='NOT USED'), (Value := 11, Description :='NOT USED'), (Value := 12, Description :='NOT USED'), (Value := 13, Description :='NOT USED'), (Value := 14, Description :='NOT USED'), (Value := 15, Description :='NOT USED'), (Value := 16, Description :='NOT USED'), (Value := 17, Description :='NOT USED'), (Value := 18, Description :='NOT USED'), (Value := 19, Description :='NOT USED'), (Value := 20, Description :='NOT USED'), (Value := 21, Description :='U1'), (Value := 22, Description :='U2'), (Value := 23, Description :='U3'), (Value := 24, Description :='U4'), (Value := 25, Description :='U5'), (Value := 26, Description :='U6'), (Value := 27, Description :='U7'), (Value := 28, Description :='U8'), (Value := 29, Description :='U9'), (Value := 30, Description :='U10'), (Value := 31, Description :='U11'), (Value := 32, Description :='U12')];
	listKEY_EEV_REGMODE :  ARRAY[0..2] OF Multistate := [(Value := 1, Description :='SSH'), (Value := 2, Description :='SSH+DSH'), (Value := 3, Description :='SSH+DT')];
	listKEY_COMP_TYP :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='BLDC Only'), (Value := 1, Description :='BLDC + OnOff'), (Value := 2, Description :='BLDC + 2 OnOff')];
	listKEY_PWRP_SPEED_STATUS :  ARRAY[0..3] OF Multistate := [(Value := 0, Description :='NORMAL'), (Value := 1, Description :='TEMPERATURE DERATING'), (Value := 2, Description :='DC BUS DERATING'), (Value := 3, Description :='TORQUE DERATING')];
	listKEY_PWRP_STATUS :  ARRAY[0..4] OF Multistate := [(Value := 0, Description :='STOP'), (Value := 1, Description :='RUN'), (Value := 2, Description :='ALARM'), (Value := 3, Description :='CRANKCASE HEATING'), (Value := 4, Description :='DC BUS READY')];
	listKEY_UNIT_STATUS :  ARRAY[0..28] OF Multistate := [(Value := 0, Description :='Wait'), (Value := 1, Description :='Unit On'), (Value := 2, Description :='Off by Alarm'), (Value := 3, Description :='Off by Network'), (Value := 4, Description :='Off by BMS'), (Value := 5, Description :='Off by Scheduler'), (Value := 6, Description :='Off by DI'), (Value := 7, Description :='Off by Keyboard'), (Value := 8, Description :='Manual mode'), (Value := 9, Description :='Changeover'), (Value := 10, Description :='Switch On'), (Value := 11, Description :='Shutdown'), (Value := 12, Description :='PreConditioning'), (Value := 13, Description :='Dehumidification'), (Value := 14, Description :='Antifreeze'), (Value := 15, Description :='Defrost'), (Value := 16, Description :='Air Pressure/Flow'), (Value := 17, Description :='Air Quality'), (Value := 18, Description :='Cooling'), (Value := 19, Description :='Heating'), (Value := 20, Description :='Free Cooling'), (Value := 21, Description :='Free Heating'), (Value := 22, Description :='Low Temp. control'), (Value := 23, Description :='High Temp. control'), (Value := 24, Description :='Test I/O'), (Value := 25, Description :='DHW'), (Value := 26, Description :='Inactivity start'), (Value := 27, Description :='High saturation humidity'), (Value := 28, Description :='Purging')];
	listKEY_EEV_STATUS :  ARRAY[0..18] OF Multistate := [(Value := 1, Description :='Close'), (Value := 2, Description :='Close'), (Value := 3, Description :='Off'), (Value := 4, Description :='Pos'), (Value := 5, Description :='Pos'), (Value := 6, Description :='Wait'), (Value := 7, Description :='On'), (Value := 8, Description :='On'), (Value := 9, Description :='On'), (Value := 11, Description :='On'), (Value := 12, Description :='On'), (Value := 13, Description :='Pos'), (Value := 14, Description :='Init'), (Value := 16, Description :='Pos'), (Value := 22, Description :='LowSH'), (Value := 23, Description :='LOP'), (Value := 24, Description :='MOP'), (Value := 25, Description :='HiTc'), (Value := 26, Description :='Man')];
	listKEY_BLDC_COMP_MODEL :  ARRAY[0..180] OF Multistate := [(Value := 0, Description :='SIAM ANB33FBEMT 400V'), (Value := 1, Description :='SIAM ANB42FBEMT 400V'), (Value := 2, Description :='SIAM ANB52FKFMT 400V'), (Value := 3, Description :='SAMSUNG UG5T520FUBJX 400V'), (Value := 4, Description :='SIAM AEE33FPAMT 400V'), (Value := 5, Description :='SIAM AEB60FEQMT 400V'), (Value := 6, Description :='HITACHI E655DHD-65D2YG 400V'), (Value := 7, Description :='SIAM SNB130FGBMT2 400V'), (Value := 8, Description :='SIAM SNB172FEKMT2 400V'), (Value := 9, Description :='SIAM TNB220FLHMT2 400V'), (Value := 10, Description :='SIAM SNB130FGBMT2 230V'), (Value := 11, Description :='SIAM SNB172FEKMT2 230V'), (Value := 12, Description :='SIAM TNB220FLHMT2 230V'), (Value := 13, Description :='LG GPT425DBA 230V'), (Value := 14, Description :='TOSHIBA DA550A3F-11M 400V'), (Value := 15, Description :='TOSHIBA DA422A3F-27M 400V'), (Value := 16, Description :='TOSHIBA DA270A2F-20L 230V'), (Value := 17, Description :='SIAM ANB66FU2MT 400V'), (Value := 18, Description :='SANYO DALIAN-C-SDP205H02B 400V'), (Value := 19, Description :='TOSHIBA DA220A2F-23L 230V'), (Value := 20, Description :='HITACHI E405DHD-36D2G 400V'), (Value := 21, Description :='TOSHIBA DA330A2F-20M 230V'), (Value := 22, Description :='SIAM ANB66FBZMT 400V'), (Value := 23, Description :='TOSHIBA DA790A4F-11UC 400V'), (Value := 24, Description :='SAMSUNG UX5T250FNBJX 400V'), (Value := 25, Description :='TOSHIBA DA91A1FJH-10A2 230V'), (Value := 26, Description :='TOSHIBA DA130A1FJH-10A2 230V'), (Value := 27, Description :='TOSHIBA DA220A2FJH-10B2 230V'), (Value := 28, Description :='TOSHIBA DA330A3FJH-10C1 230V'), (Value := 29, Description :='TOSHIBA DA420A3FJH-10C1 230V'), (Value := 30, Description :='TOSHIBA DA150A1F-21F 230V'), (Value := 31, Description :='TOSHIBA DA111A1F-20F 230V'), (Value := 32, Description :='SIAM ANB78FVAMT 400V'), (Value := 33, Description :='TOSHIBA DA75F0F-11UA 230V'), (Value := 34, Description :='MITSUBISHI SBB172F 230V'), (Value := 35, Description :='HITACHI E705DHD-72D2YG 400V'), (Value := 36, Description :='SIAM TNB306FPNMT 400V'), (Value := 37, Description :='SIAM TNB306FPGMT 230V'), (Value := 38, Description :='PANASONIC 5KD240XCA21 230V'), (Value := 39, Description :='SANYO-DALIAN C-SDP330H02B 400V'), (Value := 40, Description :='HITACHI E405DHD-38D2G 400V'), (Value := 41, Description :='SAMSUNG UX5T250FNBJX 230V'), (Value := 42, Description :='TOSHIBA DY45N1F-10F3 230V'), (Value := 43, Description :='SAMSUNG UX8TH5140FJU 230V'), (Value := 44, Description :='SAMSUNG UG8T300FUBJU 230V'), (Value := 45, Description :='TOSHIBA DS130A1FJ-24F 230V'), (Value := 46, Description :='SIAM SNB110FGYMT 230V'), (Value := 47, Description :='LG APA026DAA 230V'), (Value := 48, Description :='LG ABA051DAA 230V'), (Value := 49, Description :='SIAM ADB66F1-MTS 400V'), (Value := 50, Description :='SIAM ADB78F1-MTS 400V'), (Value := 51, Description :='MITSUBISHI LNB53FCAMC 400V'), (Value := 52, Description :='SIAM ADB33F1-MTS 400V'), (Value := 53, Description :='SAMSUNG UG5T520FUBJX 230V'), (Value := 54, Description :='SIAM ANB66FVAMTS 400V'), (Value := 55, Description :='SIAM ANBANB87FVLMT 400V'), (Value := 56, Description :='LG GKT141MAD 230V'), (Value := 57, Description :='LG GPT442MBB 400V'), (Value := 58, Description :='PANASONIC 5JD420XAA22 230V'), (Value := 59, Description :='MITSUBISHI LNB42FSCMC 230V'), (Value := 60, Description :='SIAM ANB52FVEMT 400V'), (Value := 61, Description :='LG GJT240MBA 230V'), (Value := 62, Description :='HIGHLY WHP02930ASPMA6J 230V'), (Value := 63, Description :='SIAM APB52FAAMT 400V'), (Value := 64, Description :='TOSHIBA DA422A3F-26M 230V'), (Value := 65, Description :='TOSHIBA DA640A3F-20MD 400V'), (Value := 66, Description :='SIAM APB33FAAMT 400V'), (Value := 67, Description :='SIAM ANB33FEYMT 230V'), (Value := 68, Description :='SIAM SNB130FQYMT 230V'), (Value := 69, Description :='GMCC DSM180D19UDZ 230V'), (Value := 70, Description :='MITSUBISHI LNB53FCFMC 400V'), (Value := 71, Description :='SIAM ANB33FBSMT 230V'), (Value := 72, Description :='SIAM SNB172FQGMT 230V'), (Value := 73, Description :='HITACHI E856DHD-80D2YG 400V'), (Value := 74, Description :='MITSUBISHI MBB42F-1PH 230V'), (Value := 75, Description :='MITSUBISHI MBB42F-3PH 400V'), (Value := 76, Description :='SIAM SNB172FQGMT 230V'), (Value := 77, Description :='MITSUBISHI SNB140FUYMC 230V'), (Value := 78, Description :='AVIC C-8RZ420H1BAF 230V -GDP'), (Value := 79, Description :='SIAM TNB220FSNMT 400V'), (Value := 80, Description :='SAMSUNG UG4T150FUAJQ 230V'), (Value := 81, Description :='SIAM DNB28FAAMT 230V'), (Value := 82, Description :='TOSHIBA DA130A1F-25F3 230V'), (Value := 83, Description :='TOSHIBA DY30N1F-10F3 230V'), (Value := 84, Description :='TOSHIBA DY67L1F-10FU 230V'), (Value := 85, Description :='TOSHIBA RY100L1F-10FU 400V'), (Value := 86, Description :='SIAM ANB42FEYMT 230V (1PH)-'), (Value := 87, Description :='SIAM ANB42FEYMT 230V (3PH)-'), (Value := 88, Description :='SIAM ANB52FO1MT 230V (1PH)-'), (Value := 89, Description :='SIAM ANB52FO1MT 230V (3PH)-'), (Value := 90, Description :='SIAM APB52FA1MT 400V'), (Value := 91, Description :='SIAM ANB66FVCMT 230V (1PH)-'), (Value := 92, Description :='SIAM ANB66FVCMT 230V (3PH)-'), (Value := 93, Description :='SIAM ANB78FVCMT 230V (1PH)-'), (Value := 94, Description :='SIAM ANB78FVCMT 230V (3PH)-'), (Value := 95, Description :='SIAM DNB28FAGMT 230V (1PH)-'), (Value := 96, Description :='SIAM DNB28FAGMT 230V (3PH)-'), (Value := 97, Description :='PANASONIC 5VD330ZAA21 230V'), (Value := 98, Description :='PANASONIC 5VD420ZAA21 230V'), (Value := 99, Description :='TOSHIBA DA91A1FJH-10AU 230V'), (Value := 100, Description :='TOSHIBA DA420A3FJH-10CU 230V'), (Value := 101, Description :='SIAM SPB172F-MT 230V (1PH)-'), (Value := 102, Description :='SIAM APB52FA1MT 230V'), (Value := 103, Description :='SIAM ANB66FBZMT-24 400V'), (Value := 104, Description :='SIAM DNB36FAEMT 400V'), (Value := 105, Description :='SIAM DNB36FAGMT 230V (1PH)-'), (Value := 106, Description :='SIAM DNB36FAGMT 230V (3PH)-'), (Value := 107, Description :='SIAM DNB22FAHMT 230V (1PH)-'), (Value := 108, Description :='SIAM DNB22FAHMT 230V (3PH)-'), (Value := 109, Description :='SIAM ANB66FE1MTS 400V'), (Value := 110, Description :='TOSHIBA DA220A2FJH-10BU 230V'), (Value := 111, Description :='TOSHIBA DA130A1FJH-10AU 230V'), (Value := 112, Description :='TOSHIBA DA330A3FJH-10CU 230V'), (Value := 113, Description :='TOSHIBA NY30N1FH-10FU 230V'), (Value := 114, Description :='TOSHIBA NY45N1FH-10FU 230V'), (Value := 115, Description :='TOSHIBA NY67L1FH-10FU 230V'), (Value := 116, Description :='SIAM ANB33FE1MTS 400V'), (Value := 117, Description :='SIAM ANB66FD1MTS 400V'), (Value := 118, Description :='SIAM AGK66FDBMTS 400V'), (Value := 119, Description :='SIAM AGK33FDAMTS 400V'), (Value := 120, Description :='SIAM AGK87FDCMTS 400V'), (Value := 121, Description :='SIAM SVB110FNYMT 230V'), (Value := 122, Description :='SIAM ADB42FCAMTS 400V'), (Value := 123, Description :='SIAM ANB42FE1MTS 400V'), (Value := 124, Description :='SIAM AGB66FD1MTS 230V'), (Value := 125, Description :='AVIC C-8RZ420L4BAL 230V'), (Value := 126, Description :='AVIC C-8RZ420L4BAL 230V'), (Value := 127, Description :='TOSHIBA DA91A1FJH-10AU 230V'), (Value := 128, Description :='TOSHIBA DA130A1FJH-10AU 230V'), (Value := 129, Description :='TOSHIBA DA220A2FJH-10BU 230V'), (Value := 130, Description :='TOSHIBA DA330A3FJH-10CU 230V'), (Value := 131, Description :='TOSHIBA DA420A3FJH-10CU 230V'), (Value := 132, Description :='SIAM ANB87FVLMT-60 400V'), (Value := 133, Description :='MELCO SVB140FCAMC 230V'), (Value := 134, Description :='AVIC C9RZ700H1ABF 400V'), (Value := 135, Description :='SIAM ADB33FE1MTS 400V'), (Value := 136, Description :='MELCO HNB78FDYEHC 400V'), (Value := 137, Description :='SIAM ANB66FD1MTS 230V'), (Value := 138, Description :='AVIC C1RZ089H3BBF 230V'), (Value := 139, Description :='AVIC C7RZ233H1E 230V'), (Value := 140, Description :='PANASONIC H550D5VZAAC2 230V'), (Value := 141, Description :='HIGHLY WHP09100AUKPA8LT6 230V'), (Value := 142, Description :='SIAM DPW42FBDMTS 400V'), (Value := 143, Description :='SIAM DPW36FBCMTS 400V'), (Value := 144, Description :='SIAM DPW28FBBMTS 400V'), (Value := 145, Description :='SIAM DPW22FBAMTS 400V'), (Value := 146, Description :='SIAM AVB66FLAMT 400V'), (Value := 147, Description :='AVIC C8RZ420H3BBF 230V'), (Value := 148, Description :='SIAM AVB52FLAMT 400V'), (Value := 149, Description :='PANASONIC 5JD420XAA22 230V'), (Value := 150, Description :='AVIC C7RZ233H3CBF 230V'), (Value := 151, Description :='AVIC C1RZ089H3BBF 230V'), (Value := 152, Description :='SIAM DVB28FV5MT 400V'), (Value := 153, Description :='SIAM AGK87FDCMTS 400V'), (Value := 154, Description :='SIAM AGK78FDCMTS 400V'), (Value := 155, Description :='SIAM AGK78FDCMTS 400V'), (Value := 156, Description :='PANASONIC 5RD160ZAA21 230V'), (Value := 157, Description :='PANASONIC 9VD330XAB21 230V'), (Value := 158, Description :='HIGHLY ATH356SDPC9FQ 230V'), (Value := 159, Description :='SIAM DVB36FCPMT 400V'), (Value := 160, Description :='SIAM AGK66FDBMTS 400V'), (Value := 161, Description :='SIAM AGK33FDAMTS 400V'), (Value := 162, Description :='PANASONIC H650D5VZAAC2 230V'), (Value := 163, Description :='MELCO TBB306FPGMC 230V'), (Value := 164, Description :='SIAM SNB172FEKMT-PS2 230V'), (Value := 165, Description :='AVIC C7RZ320H1BAF 230V'), (Value := 166, Description :='TOSHIBA LY100L1FH-10FU 400V'), (Value := 167, Description :='TOSHIBA CRD220A2FJH-10BU 230V'), (Value := 168, Description :='TOSHIBA CRD130A1FJH-10A 230V'), (Value := 169, Description :='TOSHIBA CRD91A1FJH-10A 230V'), (Value := 170, Description :='GMCC ATF400D64UMT 400V'), (Value := 171, Description :='AVIC C-6RZ158H1CBF 230V'), (Value := 172, Description :='SIAM SVB172FCKMT 230V'), (Value := 173, Description :='SIAM SVB130FBBMT 230V'), (Value := 174, Description :='AVIC C-6RZ210H3AGF 230V'), (Value := 175, Description :='SIAM SVB220FBGMT 230V'), (Value := 176, Description :='SIAM SVB220FZAMT 400V'), (Value := 177, Description :='AVIC C6RZ132H3ABF 230V'), (Value := 178, Description :='AVIC C8RZ420H3ABF 400V'), (Value := 179, Description :='GMCC ATQ580D66UNT 400V'), (Value := 180, Description :='AVIC C7RZ320H3CAF 400V ')];
	listKEY_ALARM_RESET :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='Manual'), (Value := 1, Description :='Semiautomatic')];
	listKEY_DFR_START_STOP_TYP :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='By DIN'), (Value := 1, Description :='By Evap. Cond. Temp.'), (Value := 2, Description :='By BMS')];
	listKEY_COOL_HEAT :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='COOL'), (Value := 1, Description :='HEAT')];
	listKEY_TYP_EVD :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='DISABLED'), (Value := 1, Description :='EMBEDDED'), (Value := 2, Description :='EVD EVO')];
	listKEY_OFF_ON :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='OFF'), (Value := 1, Description :='ON')];
	listKEY_ALARM :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='No alarm'), (Value := 1, Description :='Alarm')];
	listKEY_ENVELOPE_ZONE :  ARRAY[0..10] OF Multistate := [(Value := 0, Description :='NONE'), (Value := 1, Description :='OPERATING POINT INSIDE THE ENVELOPE'), (Value := 2, Description :='MAX COMPRESSION RATIO'), (Value := 3, Description :='HIGH DISCHARGE PRESSURE'), (Value := 4, Description :='MAX CURRENT'), (Value := 5, Description :='HIGH SUCTION PRESSURE'), (Value := 6, Description :='MIN COMPRESSION RATIO'), (Value := 7, Description :='MIN DIFF. PRESSURE'), (Value := 8, Description :='LOW DISCHARGE PRESSURE'), (Value := 9, Description :='LOW SUCTION PRESSURE'), (Value := 10, Description :='HIGH DISCHARGE TEMPERATURE')];
	listKEY_DSCG_HT :  ARRAY[0..3] OF Multistate := [(Value := 0, Description :='OK'), (Value := 1, Description :='DECREASE ACCELERATION RATIO'), (Value := 2, Description :='DECREASE SPEED'), (Value := 3, Description :='ALARM ZONE')];
	listKEY_ALARM_CODE_PWRP :  ARRAY[0..54] OF Multistate := [(Value := 0, Description :='NO ALARM'), (Value := 1, Description :='OVERCURRENT'), (Value := 2, Description :='MOTOR OVERLOAD'), (Value := 3, Description :='OVERVOLTAGE'), (Value := 4, Description :='UNDERVOLTAGE'), (Value := 5, Description :='DRIVE OVERTEMPERATURE'), (Value := 6, Description :='DRIVE UNDERTEMPERATURE'), (Value := 7, Description :='OVERCURRENT HW'), (Value := 8, Description :='RESERVED'), (Value := 9, Description :='RESERVED'), (Value := 10, Description :='CPU ERROR'), (Value := 11, Description :='PARAMETER DEFAULT'), (Value := 12, Description :='DC BUS RIPPLE'), (Value := 13, Description :='DATA COMMUNICATION FAULT'), (Value := 14, Description :='DRIVE THERMISTOR FAULT'), (Value := 15, Description :='RESERVED'), (Value := 16, Description :='RESERVED'), (Value := 17, Description :='MOTOR PHASE FAULT (**)'), (Value := 18, Description :='RESERVED'), (Value := 19, Description :='SPEED FAULT'), (Value := 20, Description :='PFC MODULE ERROR'), (Value := 21, Description :='POWER SUPPLY OVERVOLTAGE'), (Value := 22, Description :='POWER SUPPLY UNDERVOLTAGE'), (Value := 23, Description :='RESERVED'), (Value := 24, Description :='RESERVED'), (Value := 25, Description :='GROUND FAULT'), (Value := 26, Description :='CPU SYNCHRONISATION ERROR 1'), (Value := 27, Description :='CPU SYNCHRONISATION ERROR 2'), (Value := 28, Description :='DRIVER OVERLOAD'), (Value := 29, Description :='SAFETY INTERVENTION'), (Value := 101, Description :='U/V/W CURRENTS MEASURE FAULT'), (Value := 102, Description :='UNBALANCED U/V/W CURRENTS'), (Value := 103, Description :='OVERCURRENT OR GROUND FAULT'), (Value := 104, Description :='STO INPUT OPEN'), (Value := 105, Description :='STO INTERNAL CIRCUIT FAULT'), (Value := 106, Description :='POWER SUPPLY LOSS'), (Value := 107, Description :='MOTOR DRIVERS ERROR'), (Value := 108, Description :='RESERVED'), (Value := 109, Description :='DATA COMMUNICATION FAULT'), (Value := 110, Description :='COMPRESSOR STALL'), (Value := 111, Description :='DCBUS OVERCURRENT'), (Value := 112, Description :='DCBUS CURRENT MEASURE ERROR'), (Value := 113, Description :='DCBUS VOLTAGE OUT OF RANGE'), (Value := 114, Description :='DCBUS VOLTAGE MEASURE ERROR'), (Value := 115, Description :='POWER SUPPLY UNDERVOLTAGE'), (Value := 116, Description :='POWER SUPPLY VOLTAGE MEASUREMENT'), (Value := 201, Description :='DCBUS OVERLOAD'), (Value := 202, Description :='DCBUS LOAD MEASURE ERROR'), (Value := 203, Description :='DRIVE OVERTEMPERATURE'), (Value := 204, Description :='DRIVE UNDERTEMPERATURE'), (Value := 205, Description :='TEMPERATURE PROBE FAULT'), (Value := 206, Description :='CPU SYNCHRONISATION ERROR'), (Value := 207, Description :='INVALID SAFETY DATA SET'), (Value := 208, Description :='RESERVED'), (Value := 209, Description :='CONTROL CIRCUIT ERROR')];
	listKEY_ALARM_CODE_EEV :  ARRAY[0..6] OF Multistate := [(Value := 0, Description :='None'), (Value := 1, Description :='MOP'), (Value := 2, Description :='LOP'), (Value := 3, Description :='LowSuct'), (Value := 4, Description :='LowSH'), (Value := 5, Description :='HiCondTemp'), (Value := 6, Description :='HighSH')];
	listKEY_SIGNAL_TYPE :  ARRAY[0..6] OF Multistate := [(Value := 0, Description :='FIXED SPEED'), (Value := 1, Description :='EXT.SIGNAL'), (Value := 2, Description :='BMS'), (Value := 3, Description :='PID'), (Value := 4, Description :='MIN SPEED'), (Value := 5, Description :='MID SPEED'), (Value := 6, Description :='MAX SPEED')];
	listKEY_SERVER_PORTS :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='BMS1'), (Value := 1, Description :='BMS2'), (Value := 2, Description :='Serial0')];
	listKEY_CLIENT_PORTS :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='FieldBus1'), (Value := 1, Description :='FieldBus2')];
	listKEY_SERIAL_SPEED :  ARRAY[0..8] OF Multistate := [(Value := 0, Description :='1200'), (Value := 1, Description :='2400'), (Value := 2, Description :='4800'), (Value := 3, Description :='9600'), (Value := 4, Description :='19200'), (Value := 5, Description :='38400'), (Value := 6, Description :='57600'), (Value := 7, Description :='115200'), (Value := 8, Description :='375000')];
	listKEY_SERIAL_CFG :  ARRAY[0..5] OF Multistate := [(Value := 0, Description :='8-NONE-1'), (Value := 1, Description :='8-NONE-2'), (Value := 2, Description :='8-EVEN-1'), (Value := 3, Description :='8-EVEN-2'), (Value := 4, Description :='8-ODD-1'), (Value := 5, Description :='8-ODD-2')];
	listKEY_SPV_OFFLINE_MNG :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='NONE'), (Value := 1, Description :='WARNING'), (Value := 2, Description :='ALARM')];
	listKEY_LANGUAGES :  ARRAY[0..1] OF Multistate := [(Value := 1, Description :='ENGLISH'), (Value := 2, Description :='ITALIANO')];
	listKEY_UOM :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='NONE'), (Value := 1, Description :='INTERNATIONAL SYSTEM'), (Value := 2, Description :='IMPERIAL')];
	listKEY_DATE_FORMAT :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='DD/MM/YYYY'), (Value := 1, Description :='MM/DD/YYYY'), (Value := 2, Description :='YYYY/MM/DD')];
	listKEY_TIME_ZONE :  ARRAY[0..135] OF Multistate := [(Value := 1, Description :='(UTC-12:00) International Date Line West'), (Value := 2, Description :='(UTC-11:00) Coordinated Universal Time-11'), (Value := 3, Description :='(UTC-10:00) Aleutian Islands'), (Value := 4, Description :='(UTC-10:00) Hawaii'), (Value := 5, Description :='(UTC-09:30) Marquesas Islands'), (Value := 6, Description :='(UTC-09:00) Alaska'), (Value := 7, Description :='(UTC-09:00) Coordinated Universal Time-09'), (Value := 8, Description :='(UTC-08:00) Baja California (+others equivalent)'), (Value := 9, Description :='(UTC-08:00) Coordinated Universal Time-08'), (Value := 10, Description :='(UTC-08:00) Pacific Time (US & Canada)'), (Value := 11, Description :='(UTC-07:00) Arizona'), (Value := 12, Description :='(UTC-07:00) Chihuahua - La Paz - Mazatlan'), (Value := 13, Description :='(UTC-07:00) Mountain Time (US & Canada)'), (Value := 14, Description :='(UTC-06:00) Central America (+others equivalent)'), (Value := 15, Description :='(UTC-06:00) Central Time (US & Canada)'), (Value := 16, Description :='(UTC-06:00) Easter Island'), (Value := 17, Description :='(UTC-06:00) Guadalajara - Mexico City - Monterrey'), (Value := 18, Description :='(UTC-06:00) Saskatchewan'), (Value := 19, Description :='(UTC-05:00) Bogota - Lima - Quito - Rio Branco'), (Value := 20, Description :='(UTC-05:00) Chetumal'), (Value := 21, Description :='(UTC-05:00) Eastern Time (US & Canada) (+others equivalent)'), (Value := 22, Description :='(UTC-05:00) Haiti'), (Value := 23, Description :='(UTC-05:00) Havana'), (Value := 24, Description :='(UTC-05:00) Indiana (East)'), (Value := 25, Description :='(UTC-04:00) Asuncion'), (Value := 26, Description :='(UTC-04:00) Atlantic Time (Canada)'), (Value := 27, Description :='(UTC-04:00) Caracas (+others equivalent)'), (Value := 28, Description :='(UTC-04:00) Cuiaba'), (Value := 29, Description :='(UTC-04:00) Georgetown - La Paz - Manaus - San Juan'), (Value := 30, Description :='(UTC-04:00) Santiago'), (Value := 31, Description :='(UTC-04:00) Turks and Caicos'), (Value := 32, Description :='(UTC-03:30) Newfoundland'), (Value := 33, Description :='(UTC-03:00) Araguaina (+others equivalent)'), (Value := 34, Description :='(UTC-03:00) Brasilia'), (Value := 35, Description :='(UTC-03:00) Cayenne - Fortaleza'), (Value := 36, Description :='(UTC-03:00) City of Buenos Aires'), (Value := 37, Description :='(UTC-03:00) Greenland'), (Value := 38, Description :='(UTC-03:00) Montevideo'), (Value := 39, Description :='(UTC-03:00) Punta Arenas'), (Value := 40, Description :='(UTC-03:00) Saint Pierre and Miquelon'), (Value := 41, Description :='(UTC-03:00) Salvador'), (Value := 42, Description :='(UTC-02:00) Coordinated Universal Time-02 (+others equivalent)'), (Value := 43, Description :='(UTC-02:00) Mid-Atlantic - Old'), (Value := 44, Description :='(UTC-01:00) Azores'), (Value := 45, Description :='(UTC-01:00) Cabo Verde Is.'), (Value := 46, Description :='(UTC) Coordinated Universal Time'), (Value := 47, Description :='(UTC+00:00) Casablanca'), (Value := 48, Description :='(UTC+00:00) Dublin - Edinburgh - Lisbon - London'), (Value := 49, Description :='(UTC+00:00) Monrovia - Reykjavik'), (Value := 50, Description :='(UTC+01:00) Amsterdam - Berlin - Bern - Rome - Stockholm - Vienna (+others equiv.)'), (Value := 51, Description :='(UTC+01:00) Belgrade - Bratislava - Budapest - Ljubljana - Prague'), (Value := 52, Description :='(UTC+01:00) Brussels - Copenhagen - Madrid - Paris'), (Value := 53, Description :='(UTC+01:00) Sarajevo - Skopje - Warsaw - Zagreb'), (Value := 54, Description :='(UTC+01:00) West Central Africa'), (Value := 55, Description :='(UTC+01:00) Windhoek (+others equivalent)'), (Value := 56, Description :='(UTC+02:00) Amman'), (Value := 57, Description :='(UTC+02:00) Athens - Bucharest (+others equivalent)'), (Value := 58, Description :='(UTC+02:00) Beirut'), (Value := 59, Description :='(UTC+02:00) Cairo (+others equivalent)'), (Value := 60, Description :='(UTC+02:00) Chisinau'), (Value := 61, Description :='(UTC+02:00) Damascus'), (Value := 62, Description :='(UTC+02:00) Gaza - Hebron'), (Value := 63, Description :='(UTC+02:00) Harare - Pretoria'), (Value := 64, Description :='(UTC+02:00) Helsinki - Kyiv - Riga - Sofia - Tallinn - Vilnius'), (Value := 65, Description :='(UTC+02:00) Jerusalem'), (Value := 66, Description :='(UTC+02:00) Kaliningrad'), (Value := 67, Description :='(UTC+02:00) Khartoum'), (Value := 68, Description :='(UTC+02:00) Tripoli'), (Value := 69, Description :='(UTC+03:00) Baghdad (+others equivalent)'), (Value := 70, Description :='(UTC+03:00) Istanbul'), (Value := 71, Description :='(UTC+03:00) Kuwait - Riyadh'), (Value := 72, Description :='(UTC+03:00) Minsk'), (Value := 73, Description :='(UTC+03:00) Moscow - St. Petersburg - Volgograd'), (Value := 74, Description :='(UTC+03:00) Nairobi'), (Value := 75, Description :='(UTC+03:30) Tehran'), (Value := 76, Description :='(UTC+04:00) Abu Dhabi - Muscat (+others equivalent)'), (Value := 77, Description :='(UTC+04:00) Astrakhan - Ulyanovsk'), (Value := 78, Description :='(UTC+04:00) Baku'), (Value := 79, Description :='(UTC+04:00) Izhevsk - Samara'), (Value := 80, Description :='(UTC+04:00) Port Louis'), (Value := 81, Description :='(UTC+04:00) Saratov'), (Value := 82, Description :='(UTC+04:00) Tbilisi'), (Value := 83, Description :='(UTC+04:00) Yerevan'), (Value := 84, Description :='(UTC+04:30) Kabul'), (Value := 85, Description :='(UTC+05:00) Ashgabat - Tashkent (+others equivalent)'), (Value := 86, Description :='(UTC+05:00) Ekaterinburg'), (Value := 87, Description :='(UTC+05:00) Islamabad - Karachi'), (Value := 88, Description :='(UTC+05:30) Chennai - Kolkata - Mumbai - New Delhi'), (Value := 89, Description :='(UTC+05:30) Sri Jayawardenepura'), (Value := 90, Description :='(UTC+05:45) Kathmandu'), (Value := 91, Description :='(UTC+06:00) Astana (+others equivalent)'), (Value := 92, Description :='(UTC+06:00) Dhaka'), (Value := 93, Description :='(UTC+06:00) Omsk'), (Value := 94, Description :='(UTC+06:30) Yangon (Rangoon)'), (Value := 95, Description :='(UTC+07:00) Bangkok - Hanoi - Jakarta (+others equivalent)'), (Value := 96, Description :='(UTC+07:00) Barnaul - Gorno - Altaysk'), (Value := 97, Description :='(UTC+07:00) Hovd'), (Value := 98, Description :='(UTC+07:00) Krasnoyarsk'), (Value := 99, Description :='(UTC+07:00) Novosibirsk'), (Value := 100, Description :='(UTC+07:00) Tomsk'), (Value := 101, Description :='(UTC+08:00) Beijing - Chongqing - Hong Kong - Urumqi (+others equivalent)'), (Value := 102, Description :='(UTC+08:00) Irkutsk (+others equivalent)'), (Value := 103, Description :='(UTC+08:00) Kuala Lumpur - Singapore'), (Value := 104, Description :='(UTC+08:00) Perth'), (Value := 105, Description :='(UTC+08:00) Taipei'), (Value := 106, Description :='(UTC+08:00) Ulaanbaatar'), (Value := 107, Description :='(UTC+08:30) Pyongyang (+others equivalent)'), (Value := 108, Description :='(UTC+08:45) Eucla'), (Value := 109, Description :='(UTC+09:00) Chita (+others equivalent)'), (Value := 110, Description :='(UTC+09:00) Osaka - Sapporo - Tokyo'), (Value := 111, Description :='(UTC+09:00) Seoul'), (Value := 112, Description :='(UTC+09:00) Yakutsk'), (Value := 113, Description :='(UTC+09:30) Adelaide'), (Value := 114, Description :='(UTC+09:30) Darwin'), (Value := 115, Description :='(UTC+10:00) Brisbane'), (Value := 116, Description :='(UTC+10:00) Canberra - Melbourne - Sydney (+others equivalent)'), (Value := 117, Description :='(UTC+10:00) Guam - Port Moresby (+others equivalent)'), (Value := 118, Description :='(UTC+10:00) Hobart'), (Value := 119, Description :='(UTC+10:00) Vladivostok'), (Value := 120, Description :='(UTC+10:30) Lord Howe Island'), (Value := 121, Description :='(UTC+11:00) Bougainville Island (+others equivalent)'), (Value := 122, Description :='(UTC+11:00) Chokurdakh'), (Value := 123, Description :='(UTC+11:00) Magadan'), (Value := 124, Description :='(UTC+11:00) Norfolk Island'), (Value := 125, Description :='(UTC+11:00) Sakhalin'), (Value := 126, Description :='(UTC+11:00) Solomon Is. - New Caledonia'), (Value := 127, Description :='(UTC+12:00) Anadyr - Petropavlovsk-Kamchatsky (+others equivalent)'), (Value := 128, Description :='(UTC+12:00) Auckland - Wellington'), (Value := 129, Description :='(UTC+12:00) Coordinated Universal Time+12'), (Value := 130, Description :='(UTC+12:00) Fiji'), (Value := 131, Description :='(UTC+12:00) Petropavlovsk-Kamchatsky - Old'), (Value := 132, Description :='(UTC+12:45) Chatham Islands'), (Value := 133, Description :='(UTC+13:00) Coordinated Universal Time+13 (+others equivalent)'), (Value := 134, Description :='(UTC+13:00) Nuku alofa'), (Value := 135, Description :='(UTC+13:00) Samoa'), (Value := 136, Description :='(UTC+14:00) Kiritimati Island')];
	listKEY_EN_DIS :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='DISABLED'), (Value := 1, Description :='ENABLED')];
	listKEY_AUTO_MANUAL :  ARRAY[0..1] OF Multistate := [(Value := 0, Description :='AUTO'), (Value := 1, Description :='MANUAL MODE')];
	listKEY_CRANCKCASEHEATER_MODE :  ARRAY[0..2] OF Multistate := [(Value := 0, Description :='MANAGED BY THE APPLICATION'), (Value := 1, Description :='FORCED ON'), (Value := 2, Description :='FORCED OFF')];
	listKEY_ALARM_CODE_PSDHEEZ :  ARRAY[0..29] OF Multistate := [(Value := 0, Description :='NO ALARM'), (Value := 1, Description :='STO OPEN'), (Value := 2, Description :='STO HARDWARE'), (Value := 3, Description :='OVERCURRENT'), (Value := 4, Description :='OVERCURRENT HARDWARE'), (Value := 5, Description :='OVERCURRENT RMS'), (Value := 6, Description :='CURRENT MEAS.HW FAULT'), (Value := 7, Description :='UNBALANCED MOTOR CURRENT'), (Value := 8, Description :='INVERTER MODULE FAULT'), (Value := 9, Description :='Vdc OVERVOLTAGE'), (Value := 10, Description :='Vdc UNDERVOLTAGE'), (Value := 12, Description :='Vdc OUT OF SAFETY RANGE'), (Value := 13, Description :='Vdc MEAS.HW FAULT'), (Value := 16, Description :='POWER OVERLOAD'), (Value := 18, Description :='Vac OUT OF RANGE'), (Value := 19, Description :='Vac MEAS.HW FAULT'), (Value := 20, Description :='Vac MISSING'), (Value := 21, Description :='MOTOR STALL'), (Value := 22, Description :='LOW COS PHI'), (Value := 28, Description :='PFC FAULT'), (Value := 29, Description :='CPU ERROR'), (Value := 30, Description :='INVALID SAFETY PARAMS.'), (Value := 31, Description :='INVALID DRIVE PARAMS.'), (Value := 32, Description :='Vref HW FAULT'), (Value := 33, Description :='OVERTEMPERATURE'), (Value := 34, Description :='UNDERTEMPERAUTRE'), (Value := 35, Description :='THERMISTOR FAULT'), (Value := 36, Description :='COMMUNICATION LOST'), (Value := 37, Description :='PARAMETER DEFAULT'), (Value := 38, Description :='DACs/COMPARATORS')];
    
	{ENDREGION}
END_VAR

TYPE
	MULTISTATE_KEY : (
		NONE,
		listKEY_PROBE_ERROR,
		listKEY_MODE_TYPE_AIN,
		listKEY_MODE_TYPE_AOUT,
		listKEY_DIN_LOGIC,
		listKEY_DOUT_LOGIC,
		listKEY_DIGITAL_STATUS,
		listKEY_DIN_CH,
		listKEY_DOUT_CH,
		listKEY_AIN_CH,
		listKEY_AOUT_CH,
		listKEY_EEV_REGMODE,
		listKEY_COMP_TYP,
		listKEY_PWRP_SPEED_STATUS,
		listKEY_PWRP_STATUS,
		listKEY_UNIT_STATUS,
		listKEY_EEV_STATUS,
		listKEY_BLDC_COMP_MODEL,
		listKEY_ALARM_RESET,
		listKEY_DFR_START_STOP_TYP,
		listKEY_COOL_HEAT,
		listKEY_TYP_EVD,
		listKEY_OFF_ON,
		listKEY_ALARM,
		listKEY_ENVELOPE_ZONE,
		listKEY_DSCG_HT,
		listKEY_ALARM_CODE_PWRP,
		listKEY_ALARM_CODE_EEV,
		listKEY_SIGNAL_TYPE,
		listKEY_SERVER_PORTS,
		listKEY_CLIENT_PORTS,
		listKEY_SERIAL_SPEED,
		listKEY_SERIAL_CFG,
		listKEY_SPV_OFFLINE_MNG,
		listKEY_LANGUAGES,
		listKEY_UOM,
		listKEY_DATE_FORMAT,
		listKEY_TIME_ZONE,
		listKEY_EN_DIS,
		listKEY_AUTO_MANUAL,
		listKEY_CRANCKCASEHEATER_MODE,
		listKEY_ALARM_CODE_PSDHEEZ);

END_TYPE


(*Return the description of paramter given the value and the list of descriptions*)
FUNCTION GetMultistateDescription : BOOL
	VAR_IN_OUT CONSTANT
		MultistateList : ARRAY[*] OF MULTISTATE;
	END_VAR
	VAR_IN_OUT
	    Description : STRING;
	END_VAR
	VAR_INPUT
	    Value : INT;
	END_VAR
	VAR
		i : DINT;
	END_VAR

	FOR i := LOWER_BOUND(MultistateList, 1) TO UPPER_BOUND(MultistateList, 1) DO
		IF MultistateList[i].Value = Value THEN
		    Description := MultistateList[i].Description;
			GetMultistateDescription := TRUE;
			EXIT;
		END_IF;
	END_FOR;
END_FUNCTION

(*Return the description of paramter*)
FUNCTION GetMultistateDescription : BOOL
	VAR_IN_OUT
	    Description : STRING;
	END_VAR
    VAR_INPUT
		Key : MULTISTATE_KEY;
		Value : INT;
    END_VAR
    (*Befor to call this function the multistate key are already setted by MultistateKey function*)

	CASE Key OF
		MULTISTATE_KEY#listKEY_PROBE_ERROR : GetMultistateDescription := GetMultistateDescription(listKEY_PROBE_ERROR, Description, Value);
		MULTISTATE_KEY#listKEY_MODE_TYPE_AIN : GetMultistateDescription := GetMultistateDescription(listKEY_MODE_TYPE_AIN, Description, Value);
		MULTISTATE_KEY#listKEY_MODE_TYPE_AOUT : GetMultistateDescription := GetMultistateDescription(listKEY_MODE_TYPE_AOUT, Description, Value);
		MULTISTATE_KEY#listKEY_DIN_LOGIC : GetMultistateDescription := GetMultistateDescription(listKEY_DIN_LOGIC, Description, Value);
		MULTISTATE_KEY#listKEY_DOUT_LOGIC : GetMultistateDescription := GetMultistateDescription(listKEY_DOUT_LOGIC, Description, Value);
		MULTISTATE_KEY#listKEY_DIGITAL_STATUS : GetMultistateDescription := GetMultistateDescription(listKEY_DIGITAL_STATUS, Description, Value);
		MULTISTATE_KEY#listKEY_DIN_CH : GetMultistateDescription := GetMultistateDescription(listKEY_DIN_CH, Description, Value);
		MULTISTATE_KEY#listKEY_DOUT_CH : GetMultistateDescription := GetMultistateDescription(listKEY_DOUT_CH, Description, Value);
		MULTISTATE_KEY#listKEY_AIN_CH : GetMultistateDescription := GetMultistateDescription(listKEY_AIN_CH, Description, Value);
		MULTISTATE_KEY#listKEY_AOUT_CH : GetMultistateDescription := GetMultistateDescription(listKEY_AOUT_CH, Description, Value);
		MULTISTATE_KEY#listKEY_EEV_REGMODE : GetMultistateDescription := GetMultistateDescription(listKEY_EEV_REGMODE, Description, Value);
		MULTISTATE_KEY#listKEY_COMP_TYP : GetMultistateDescription := GetMultistateDescription(listKEY_COMP_TYP, Description, Value);
		MULTISTATE_KEY#listKEY_PWRP_SPEED_STATUS : GetMultistateDescription := GetMultistateDescription(listKEY_PWRP_SPEED_STATUS, Description, Value);
		MULTISTATE_KEY#listKEY_PWRP_STATUS : GetMultistateDescription := GetMultistateDescription(listKEY_PWRP_STATUS, Description, Value);
		MULTISTATE_KEY#listKEY_UNIT_STATUS : GetMultistateDescription := GetMultistateDescription(listKEY_UNIT_STATUS, Description, Value);
		MULTISTATE_KEY#listKEY_EEV_STATUS : GetMultistateDescription := GetMultistateDescription(listKEY_EEV_STATUS, Description, Value);
		MULTISTATE_KEY#listKEY_BLDC_COMP_MODEL : GetMultistateDescription := GetMultistateDescription(listKEY_BLDC_COMP_MODEL, Description, Value);
		MULTISTATE_KEY#listKEY_ALARM_RESET : GetMultistateDescription := GetMultistateDescription(listKEY_ALARM_RESET, Description, Value);
		MULTISTATE_KEY#listKEY_DFR_START_STOP_TYP : GetMultistateDescription := GetMultistateDescription(listKEY_DFR_START_STOP_TYP, Description, Value);
		MULTISTATE_KEY#listKEY_COOL_HEAT : GetMultistateDescription := GetMultistateDescription(listKEY_COOL_HEAT, Description, Value);
		MULTISTATE_KEY#listKEY_TYP_EVD : GetMultistateDescription := GetMultistateDescription(listKEY_TYP_EVD, Description, Value);
		MULTISTATE_KEY#listKEY_OFF_ON : GetMultistateDescription := GetMultistateDescription(listKEY_OFF_ON, Description, Value);
		MULTISTATE_KEY#listKEY_ALARM : GetMultistateDescription := GetMultistateDescription(listKEY_ALARM, Description, Value);
		MULTISTATE_KEY#listKEY_ENVELOPE_ZONE : GetMultistateDescription := GetMultistateDescription(listKEY_ENVELOPE_ZONE, Description, Value);
		MULTISTATE_KEY#listKEY_DSCG_HT : GetMultistateDescription := GetMultistateDescription(listKEY_DSCG_HT, Description, Value);
		MULTISTATE_KEY#listKEY_ALARM_CODE_PWRP : GetMultistateDescription := GetMultistateDescription(listKEY_ALARM_CODE_PWRP, Description, Value);
		MULTISTATE_KEY#listKEY_ALARM_CODE_EEV : GetMultistateDescription := GetMultistateDescription(listKEY_ALARM_CODE_EEV, Description, Value);
		MULTISTATE_KEY#listKEY_SIGNAL_TYPE : GetMultistateDescription := GetMultistateDescription(listKEY_SIGNAL_TYPE, Description, Value);
		MULTISTATE_KEY#listKEY_SERVER_PORTS : GetMultistateDescription := GetMultistateDescription(listKEY_SERVER_PORTS, Description, Value);
		MULTISTATE_KEY#listKEY_CLIENT_PORTS : GetMultistateDescription := GetMultistateDescription(listKEY_CLIENT_PORTS, Description, Value);
		MULTISTATE_KEY#listKEY_SERIAL_SPEED : GetMultistateDescription := GetMultistateDescription(listKEY_SERIAL_SPEED, Description, Value);
		MULTISTATE_KEY#listKEY_SERIAL_CFG : GetMultistateDescription := GetMultistateDescription(listKEY_SERIAL_CFG, Description, Value);
		MULTISTATE_KEY#listKEY_SPV_OFFLINE_MNG : GetMultistateDescription := GetMultistateDescription(listKEY_SPV_OFFLINE_MNG, Description, Value);
		MULTISTATE_KEY#listKEY_LANGUAGES : GetMultistateDescription := GetMultistateDescription(listKEY_LANGUAGES, Description, Value);
		MULTISTATE_KEY#listKEY_UOM : GetMultistateDescription := GetMultistateDescription(listKEY_UOM, Description, Value);
		MULTISTATE_KEY#listKEY_DATE_FORMAT : GetMultistateDescription := GetMultistateDescription(listKEY_DATE_FORMAT, Description, Value);
		MULTISTATE_KEY#listKEY_TIME_ZONE : GetMultistateDescription := GetMultistateDescription(listKEY_TIME_ZONE, Description, Value);
		MULTISTATE_KEY#listKEY_EN_DIS : GetMultistateDescription := GetMultistateDescription(listKEY_EN_DIS, Description, Value);
		MULTISTATE_KEY#listKEY_AUTO_MANUAL : GetMultistateDescription := GetMultistateDescription(listKEY_AUTO_MANUAL, Description, Value);
		MULTISTATE_KEY#listKEY_CRANCKCASEHEATER_MODE : GetMultistateDescription := GetMultistateDescription(listKEY_CRANCKCASEHEATER_MODE, Description, Value);
		MULTISTATE_KEY#listKEY_ALARM_CODE_PSDHEEZ : GetMultistateDescription := GetMultistateDescription(listKEY_ALARM_CODE_PSDHEEZ, Description, Value);
	END_CASE;
END_FUNCTION


(*Return true if a parameter has a multistate*)
FUNCTION GetMultistateKey : MULTISTATE_KEY

	VAR_INPUT
		Acronym : STRING;
	END_VAR

	IF Acronym = 'L14-err' OR  Acronym = 'L44-err' OR  Acronym = 'L51-err' OR  Acronym = 'L52-err' OR  Acronym = 'L53-err' OR  Acronym = 'L54-err' OR  Acronym = 'L59-err' OR  Acronym = 'L60-err' OR  Acronym = 'L62-err' OR  Acronym = 'L63-err' OR  Acronym = 'L64-err' OR  Acronym = 'L66-err' OR  Acronym = 'L67-err' OR  Acronym = 'L68-err' OR  Acronym = 'L69-err' OR  Acronym = 'L73-err' OR  Acronym = 'L74-err' OR  Acronym = 'L75-err' OR  Acronym = 'L76-err' OR  Acronym = 'L77-err' OR  Acronym = 'L78-err' OR  Acronym = 'L82-err' OR  Acronym = 'L84-err' OR  Acronym = 'L88-err' OR  Acronym = 'L125-err' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_PROBE_ERROR;
	ELSIF Acronym = 'L51-T' OR  Acronym = 'L52-T' OR  Acronym = 'L53-T' OR  Acronym = 'L54-T' OR  Acronym = 'L59-T' OR  Acronym = 'L60-T' OR  Acronym = 'L62-T' OR  Acronym = 'L63-T' OR  Acronym = 'L64-T' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_MODE_TYPE_AIN;
	ELSIF Acronym = 'L88-T' OR  Acronym = 'L125-T' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_MODE_TYPE_AOUT;
	ELSIF Acronym = 'L14-L' OR  Acronym = 'L66-L' OR  Acronym = 'L67-L' OR  Acronym = 'L68-L' OR  Acronym = 'L69-L' OR  Acronym = 'L73-L' OR  Acronym = 'L74-L' OR  Acronym = 'L75-L' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DIN_LOGIC;
	ELSIF Acronym = 'L44-L' OR  Acronym = 'L76-L' OR  Acronym = 'L77-L' OR  Acronym = 'L78-L' OR  Acronym = 'L82-L' OR  Acronym = 'L84-L' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DOUT_LOGIC;
	ELSIF Acronym = 'I06' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DIGITAL_STATUS;
	ELSIF Acronym = 'L14-C' OR  Acronym = 'L66-C' OR  Acronym = 'L67-C' OR  Acronym = 'L68-C' OR  Acronym = 'L69-C' OR  Acronym = 'L73-C' OR  Acronym = 'L74-C' OR  Acronym = 'L75-C' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DIN_CH;
	ELSIF Acronym = 'L44-C' OR  Acronym = 'L76-C' OR  Acronym = 'L77-C' OR  Acronym = 'L78-C' OR  Acronym = 'L82-C' OR  Acronym = 'L84-C' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DOUT_CH;
	ELSIF Acronym = 'L51-C' OR  Acronym = 'L52-C' OR  Acronym = 'L53-C' OR  Acronym = 'L54-C' OR  Acronym = 'L59-C' OR  Acronym = 'L60-C' OR  Acronym = 'L62-C' OR  Acronym = 'L63-C' OR  Acronym = 'L64-C' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_AIN_CH;
	ELSIF Acronym = 'L88-C' OR  Acronym = 'L125-C' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_AOUT_CH;
	ELSIF Acronym = 'E62' OR  Acronym = 'I78' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_EEV_REGMODE;
	ELSIF Acronym = 'C47' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_COMP_TYP;
	ELSIF Acronym = 'I70' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_PWRP_SPEED_STATUS;
	ELSIF Acronym = 'I68' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_PWRP_STATUS;
	ELSIF Acronym = 'I00' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_UNIT_STATUS;
	ELSIF Acronym = 'I44' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_EEV_STATUS;
	ELSIF Acronym = 'P00' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_BLDC_COMP_MODEL;
	ELSIF Acronym = 'b63' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_ALARM_RESET;
	ELSIF Acronym = 'S86' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DFR_START_STOP_TYP;
	ELSIF Acronym = 'I19' OR  Acronym = 'I08' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_COOL_HEAT;
	ELSIF Acronym = 'E47' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_TYP_EVD;
	ELSIF Acronym = 'S55' OR  Acronym = 'C61' OR  Acronym = 'C63' OR  Acronym = 'C65' OR  Acronym = 'I10' OR  Acronym = 'I12' OR  Acronym = 'I14' OR  Acronym = 'I96' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_OFF_ON;
	ELSIF Acronym = 'L67' OR  Acronym = 'L68' OR  Acronym = 'L69' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_ALARM;
	ELSIF Acronym = 'I46' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_ENVELOPE_ZONE;
	ELSIF Acronym = 'I66' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DSCG_HT;
	ELSIF Acronym = 'I62' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_ALARM_CODE_PWRP;
	ELSIF Acronym = 'I80' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_ALARM_CODE_EEV;
	ELSIF Acronym = 'Y83' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_SIGNAL_TYPE;
	ELSIF Acronym = 'Y00' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_SERVER_PORTS;
	ELSIF Acronym = 'Y14' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_CLIENT_PORTS;
	ELSIF Acronym = 'Y02' OR  Acronym = 'Y15' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_SERIAL_SPEED;
	ELSIF Acronym = 'Y03' OR  Acronym = 'Y16' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_SERIAL_CFG;
	ELSIF Acronym = 'Y06' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_SPV_OFFLINE_MNG;
	ELSIF Acronym = 'Y07' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_LANGUAGES;
	ELSIF Acronym = 'Y08' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_UOM;
	ELSIF Acronym = 'Y42' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_DATE_FORMAT;
	ELSIF Acronym = 'Y50' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_TIME_ZONE;
	ELSIF Acronym = 'b17' OR  Acronym = 'b18' OR  Acronym = 'C44' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_EN_DIS;
	ELSIF Acronym = 'C60' OR  Acronym = 'C62' OR  Acronym = 'C64' OR  Acronym = 'E00' OR  Acronym = 'S10' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_AUTO_MANUAL;
	ELSIF Acronym = 'P34' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_CRANCKCASEHEATER_MODE;
	ELSIF Acronym = 'I76' THEN
		GetMultistateKey := MULTISTATE_KEY#listKEY_ALARM_CODE_PSDHEEZ;

	ELSE
		GetMultistateKey := MULTISTATE_KEY#NONE;
	END_IF;


END_FUNCTION
