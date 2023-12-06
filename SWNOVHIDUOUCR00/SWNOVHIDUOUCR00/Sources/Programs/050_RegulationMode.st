USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
USING Libs.Timer;



PROGRAM RegulationMode 
    VAR
        (**Intended stage unit wants to transition to*)
        GoToState               : USINT;
        (**DHW transition timer*)
        TON_DHWTimer            : TON_s;
        (**DHW switch due to timer*)
        DHWFrcSwitch            : BOOL;
        (**DHW switch complete*)
        DHWFrcSwitchDone        : BOOL;
        (**Disable regular state transition during DHW switch*)
        Dis_OpStateSwitch       : BOOL;
        (**Iteration value*)
        i                       : INT;
        (**Iteration value*)
        j                       : INT;
        (**Outside temperature sample timer*)
        TON_OutDoorTemp         : TON_S;
        (**First 10 temperature samples taken*)
        OutDoorTempAvgReady     : BOOL;
        (**SG status byte*)
        SG_Status_Byte          : BYTE;
        (**Energybalance offset*)
        Offset_EBHP             : REAL;
        (**Energy balance timer*)
        TON_Energybalance       : TON_S;
        (**Disable automode*)
        Dis_AutoMode            : BOOL;
        (**FirstCycle*)
        FirstCycle              : BOOL := 1;

        
    END_VAR
    
    
    //Jump logic during startup to avoid incorrect I/O value sampling
    IF RestoreDefault OR UnitStatus = UNIT_STATUS#Wait THEN
        RETURN;
    END_IF;
    
    {REGION SMARTGRID INPUT MANAGEMENT}
        SG_Status_Byte.0 := Din_Data.Fct.SG1;
        SG_Status_Byte.1 := Din_Data.Fct.SG2;
        SG_Status := TO_USINT(SG_Status_Byte);        
    {ENDREGION}
    
    {REGION OUTDOOR TEMPERATURE FILTER CALCULATION}
    
        //Pass filtered request to outdoor unit

       
        IF(OutDoorTempSel = OutSideTemp#OUTSIDETEMP)THEN
            OutDoorTemp                     :=  Ain_Data.Fct.OutDoorTemp;
        ELSIF(OutDoorTempSel = OutSideTemp#OUTDOORUNIT)THEN
            OutDoorTemp                     :=  OU_OutsideTemp;
        ELSIF(OutDoorTempSel = OutSideTemp#CONNECTIVITYCARD)THEN
            OutDoorTemp                     :=  Conn_OutDoorTemp;
        END_IF;    
        //Update temperature value every hour or at first available cycle
        TON_OutDoorTemp(
            IN := OutDoorTempSel <= 2 AND NOT(TON_OutDoorTemp.Q),
            PT := 3600
        );
 
    
        //Selection of outdoor temperature value
        IF(TON_OutDoorTemp.Q OR FirstCycle)THEN
            OutDoorTempFilter_PreCalc[i]    :=  OutDoorTemp;
                        
            i := i+1;
            
            //Indicate if temperatures has been sampled for 5 minutes
            IF(i >= OutDoorTemp_FiltHrs) THEN
                IF(NOT(OutDoorTempAvgReady))THEN
                    OutDoorTempAvgReady := TRUE;
                END_IF;
                i := 0;
            END_IF;    
            
            //Calculate temperature average
            IF(OutDoorTempAvgReady)THEN
                OutDoorTempFilter := 0;
                FOR j := 0 TO OutDoorTemp_FiltHrs DO
                    OutDoorTempFilter := OutDoorTempFilter + OutDoorTempFilter_PreCalc[j];
                END_FOR;
                    OutDoorTempFilter := OutDoorTempFilter / TO_REAL(OutDoorTemp_FiltHrs);
            ELSE
                //Calculate only sampled temperatures if not all required samples are collected
                FOR j := 0 TO OutDoorTemp_FiltHrs DO
                    OutDoorTempFilter := OutDoorTempFilter + OutDoorTempFilter_PreCalc[j];
                END_FOR;
                    OutDoorTempFilter := OutDoorTempFilter / TO_REAL(i);
            END_IF;
                
            IF(FirstCycle)THEN
                FirstCycle := FALSE;
            END_IF;
            
        END_IF;
    
    {ENDREGION}
    
    {REGION ECT CALCULATION}
    //Select correct ECT depending on which operation mode is active, default to DHW value
        IF(GoToState = OpStage_Status#DHW)THEN
            ECT := Ain_Data.Fct.DHWBottomTemp + ECT_DHW_Offset;
        ELSIF(GoToState = OpStage_Status#HEATING)THEN
            ECT := OU_Unit.CondInTemp + ECT_Heat_Offset;
        ELSIF(GoToState = OpStage_Status#COOLING)THEN
            ECT := OU_Unit.OutDoorTemp + ECT_Cool_Offset;
        ELSE
            ECT := Ain_Data.Fct.DHWBottomTemp + ECT_DHW_Offset;
        END_IF;
        OU_Unit.ECT := ECT;
    {ENDREGION}
        
    {REGION DHW TIMING MANAGEMENT}
       
        /* 
        If DHW regulation is required at the same time as cooling/heating, the actual regulation mode will alternate
        with a set time. 
        */
        Dis_OpStateSwitch := (DHWNeed AND (OpModeAllowHeat OR OpModeAllowCool)); 
    
        TON_DHWTimer(
            IN := Dis_OpStateSwitch AND DHWFrcSwitchDone,
            PT := DhwTimerStop
        );
        DHWFrcSwitch := TON_DHWTimer.Q;
        DHWFrcSwitchDone  := FALSE;
    
        IF(DHWFrcSwitch)THEN //Select which mode that the application will transition to
            IF(HeatReq OR CoolReq) THEN     //transition to DHW
                GoToState := OpStage_Status#DHW;
            ELSE
                IF(DHWReq)THEN
                    IF(OpModeAllowHeat)THEN     //transition to heating
                        GoToState := OpStage_Status#HEATING;
                    ELSE                        //transition to cooling
                        GoToState := OpStage_Status#COOLING;
                    END_IF;
                END_IF;
            END_IF;
        END_IF;
        DHWFrcSwitchDone := (OpState = GoToState);
    {ENDREGION}
 
    {REGION STATE TRANSITION CHECK}
    //Only allow transition between active states if compressor temperature above ECT
    IF(OpState <> 0 AND GoToState = 0) THEN
        OpState := 0;
    ELSE
        //Only require compressor temperature when the compressor is running
        IF(OU_CompOn)THEN
            IF(GoToState <> OpState AND OU_CompTemp < ECT) THEN
                OU_CompHeat := TRUE;
            ELSIF(GoToState <> OpState) THEN
                OpState := GoToState;
                OU_CompHeat := FALSE;
            END_IF;
        ELSE
            OpState := GoToState;
        END_IF;
    END_IF;
    {ENDREGION}
    
    
    {REGION AUTO MODE}
    Dis_AutoMode := ManMode_Cool OR ManMode_Heat;
    
    IF(UnitOn)THEN
        IF(En_AutoMode AND NOT(Dis_OpStateSwitch) AND NOT(Dis_AutoMode)) OR DHWFrcSwitch THEN                      
            CASE OpState OF
                /*
                Change operation state depending on outside temperature
                 0: Decision phase
                 1: Heating
                 2: Cooling
                 3: DHW
                */
                
                0: //Decision phase              
                    IF(OpModeAllowHeat)THEN
                        GoToState := OpStage_Status#HEATING;
                    ELSIF(OpModeAllowCool)THEN
                        GoToState := OpStage_Status#COOLING;
                    ELSIF(DHWNeed) THEN
                        GoToState := OpStage_Status#DHW;
                    END_IF;
                    
                    //If no transition to another state is required, stop regulation
                    IF(GoToState = OpStage_Status#DECISION_PHASE)THEN
                        HeatReq := FALSE;
                        CoolReq := FALSE;
                        ImmHeatReq := FALSE;
                        DHWReq := FALSE;
                    END_IF;
                
                1: //Heating state
                    HeatReq := TRUE;
                    CoolReq := FALSE;
                    ImmHeatReq := FALSE;
                    DHWReq := FALSE;
                    IF(NOT(Dis_OpStateSwitch))THEN
                        IF(NOT(OpModeAllowHeat)) THEN // Return to decision phase
                            GoToState := OpStage_Status#DECISION_PHASE;
                        ELSIF(DHWNeed) THEN
                            GoToState := OpStage_Status#DHW;
                        END_IF;
                    END_IF;
                
                2: //Cooling state
                    HeatReq := FALSE;
                    CoolReq := TRUE;
                    ImmHeatReq := FALSE;
                    DHWReq := FALSE;
                
                    IF(NOT(OpModeAllowCool)) THEN // Return to decision phase
                        GoToState := OpStage_Status#DECISION_PHASE;
                    ELSIF(DHWNeed) THEN
                        GoToState := OpStage_Status#DHW;
                    END_IF;
                
                3: //DHW
                    HeatReq := FALSE;
                    CoolReq := FALSE;
                    ImmHeatReq := FALSE;
                    DHWReq := TRUE;
                    
                    IF(NOT(DHWNeed))THEN //Insert DHW max timer logic for heat/DHW switch
                        GoToState := OpStage_Status#DECISION_PHASE;
                    END_IF;
            END_CASE;       
        ELSIF(Dis_AutoMode)THEN
            //Manual regulation mode
            HeatReq := ManMode_Heat;
            CoolReq := ManMode_Cool;
            ImmHeatReq := FALSE;
        ELSE //Unit off or auto mode is disabled
            HeatReq := FALSE;
            CoolReq := FALSE;
            ImmHeatReq := FALSE;
            DHWReq := FALSE;
        END_IF;
    ELSE
        HeatReq := FALSE;
        CoolReq := FALSE;
        ImmHeatReq := FALSE;
        OpState := 0;
        GoToState := 0;
    END_IF;
    
    {ENDREGION}    
    
    {REGION ENERGY BALANCE CALCULATION}

    //Calculate energybalance every minute while unit is running
    IF(UnitOFF)THEN
        EBHP := 0;       
    ELSIF(OpModeAllowHeat)THEN
        TON_Energybalance(
            IN := NOT(TON_Energybalance.Q),
            PT := 60
        );
    
        Offset_EBHP := -0.01 * (SupplyTempCalc - HeatReg_Temp);
        
        IF(TON_Energybalance.Q)THEN
            EBHP := LIMIT(EBHPMin, ((EBHP - (SupplyTempCalc - HeatReg_Temp))) + Offset_EBHP, EBHPMax);
        END_IF;
    ELSIF(NOT(OpModeAllowHeat))THEN
        EBHP := 0;
    END_IF;   
    {ENDREGION}
    
END_PROGRAM