USING System;
USING System.Math;
USING Libs.Math;
USING Libs.PID_Incr;
USING Libs.Timer;

VAR_GLOBAL
        (**DHW switch due to timer*)
        DHWFrcSwitch            : BOOL;
          (**DHW transition timer*)
        TON_DHWTimer            : TON_s;
END_VAR


PROGRAM RegulationMode 
    VAR
        (**Iteration value*)
        i                       : INT;
        (**Iteration value*)
        j                       : INT;
        (**Iteration value*)
        k                       : INT;
        (**Outside temperature sample timer*)
        TON_OutDoorTemp         : TON_S;
        (**First full FilterHrs temperature samples taken*)
        OutDoorTempAvgReady     : BOOL;
        
        OutDoorTempFilterTmp    : REAL;
        (**Outside temperature Sensor sample timer*)
        TON_OutDoorTempSnsr     : TON_S;
        (**Comp minimum running time in heat or cool mode*)    
        TON_MinRunTime          : TON_s;
        MinRunTime              : BOOL;
        (**DHW switch complete*)
        DHWFrcSwitchDone        : BOOL;
        (**Disable regular state transition during DHW switch*)
        Dis_OpStateSwitch       : BOOL;
        (**RS latch Comp minimum running time in heat or cool mode*)        
        RS_ChangeOfMode         : RS;
        (**SG status byte*)
        SG_Status_Byte          : BYTE;
        (**Energy balance timer*)
        TON_Energybalance       : TON_S;
        (**Disable automode*)
        Dis_AutoMode            : BOOL;
        (**FirstCycle*)
        FirstCycle              : BOOL := 1;
        (**Outdoor sensor average collected*)
        OutDoorTempSnsrAvgReady : BOOL;
        
        OutDoorTempSnsr_FiltSec : INT := 100;
        (**Outdoor temporary starage af collected values*)
        OutDoorTempSnsrFilter_PreCalc : ARRAY [0..300] OF REAL;
        
        
        
    END_VAR
    
    
    //Jump logic during startup to avoid incorrect I/O value sampling
    IF RestoreDefault OR UnitStatus = UNIT_STATUS#Wait THEN
        RETURN;
    END_IF;
    
    {REGION SMARTGRID INPUT MANAGEMENT}
        SG_Status_Byte.0 := Din_Data.Fct.SG1 AND SGActive;
        SG_Status_Byte.1 := Din_Data.Fct.SG2 AND SGActive;
        SG_Status := TO_USINT(SG_Status_Byte);        
    {ENDREGION}
    
    {REGION OUTDOOR TEMPERATURE FILTER CALCULATION}
    
    

       
    
        
        //Update temperature value every 5 minute or at first available cycle Not for Online sensor value
        TON_OutDoorTempSnsr(
            IN := OutDoorTempSel <=1 AND NOT(TON_OutDoorTempSnsr.Q),
            PT := 10
        );
 
    
        //Selection of outdoor temperature value
        IF(TON_OutDoorTempSnsr.Q OR FirstCycle)THEN
            IF(OutDoorTempSel = OutSideTemp#OUTSIDETEMP)THEN
                OutDoorTempSnsrFilter_PreCalc[k]                   :=  Ain_Data.Fct.OutDoorTemp;
            ELSIF(OutDoorTempSel = OutSideTemp#OUTDOORUNIT)THEN
                OutDoorTempSnsrFilter_PreCalc[k]                   :=  OU_OutsideTemp;
            END_IF;    
                        
            k := k+1;
            
            //Indicate if temperatures has been sampled
            IF(k >= (OutDoorTempSnsr_FiltSec/10)) THEN
                IF(NOT(OutDoorTempSnsrAvgReady))THEN
                    OutDoorTempSnsrAvgReady := TRUE;
                END_IF;
                k := 0;
            END_IF;    
            
            //Calculate temperature average
            IF(OutDoorTempSnsrAvgReady)THEN
                OutDoorTempFilterTmp := 0;
                FOR j := 0 TO (OutDoorTempSnsr_FiltSec/10) DO
                    OutDoorTempFilterTmp := OutDoorTempFilterTmp + OutDoorTempSnsrFilter_PreCalc[j];
                END_FOR;
                    OutDoorTemp := OutDoorTempFilterTmp / TO_REAL((OutDoorTempSnsr_FiltSec/10));
                    OutDoorTempFilterTmp := 0;
            ELSE
                //Calculate only sampled temperatures if not all required samples are collected
                FOR j := 0 TO (k-1) DO
                    OutDoorTempFilterTmp := OutDoorTempFilterTmp + OutDoorTempSnsrFilter_PreCalc[j];
                END_FOR;
                    OutDoorTemp := OutDoorTempFilterTmp / TO_REAL(j);
                    OutDoorTempFilterTmp := 0;
            END_IF;
        
            ELSIF(OutDoorTempSel = OutSideTemp#CONNECTIVITYCARD)THEN
                OutDoorTemp                     :=  Conn_OutDoorTemp;    
            
        END_IF;    
    
    
    
    
        //Update temperature value every hour or at first available cycle
        TON_OutDoorTemp(
            IN := NOT(TON_OutDoorTemp.Q),
            PT := 3600
        );
 
    
        //Selection of outdoor temperature value
        IF(TON_OutDoorTemp.Q OR FirstCycle)THEN
            OutDoorTempFilter_PreCalc[i]    :=  OutDoorTemp;
                        
            i := i+1;
            
            //Indicate if temperatures has been sampled for OutDoorTemp_FiltHrs
            IF(i >= OutDoorTemp_FiltHrs) THEN
                IF(NOT(OutDoorTempAvgReady))THEN
                    OutDoorTempAvgReady := TRUE;
                END_IF;
                i := 0;
            END_IF;    
            
            //Calculate temperature average
            IF(OutDoorTempAvgReady)THEN
                OutDoorTempFilterTmp := 0;
                FOR j := 0 TO OutDoorTemp_FiltHrs DO
                    OutDoorTempFilterTmp := OutDoorTempFilterTmp + OutDoorTempFilter_PreCalc[j];
                END_FOR;
                    OutDoorTempFilter := OutDoorTempFilterTmp / TO_REAL(OutDoorTemp_FiltHrs);
                    OutDoorTempFilterTmp := 0;
            ELSE
                //Calculate only sampled temperatures if not all required samples are collected
                FOR j := 0 TO (i-1) DO
                    OutDoorTempFilterTmp := OutDoorTempFilterTmp + OutDoorTempFilter_PreCalc[j];
                END_FOR;
                    OutDoorTempFilter := OutDoorTempFilterTmp / TO_REAL(j);
                    OutDoorTempFilterTmp := 0;
            END_IF;
            
        END_IF;
    
        IF(FirstCycle)THEN
            FirstCycle := FALSE;
        END_IF;
    
    {ENDREGION}
    
        
    {REGION DHW TIMING MANAGEMENT}
       
        /* 
        If DHW regulation is required at the same time as cooling/heating, the actual regulation mode will alternate
        with a set time. 
        */
        Dis_OpStateSwitch := (DHWNeed AND (OpModeAllowHeat OR OpModeAllowCool)); 
    
        TON_DHWTimer(
            IN := Dis_OpStateSwitch AND DHWFrcSwitchDone,
            PT := DhwTimerStop*60
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
    
    {REGION DEFROST}  
    IF OU_Unit.DefrostRun THEN
        GoToState := OpStage_Status#DEFROST;
    END_IF;    
    {ENDREGION}
    
    {REGION Minimum running time}
    TON_MinRunTime(
        IN := (OpState = OpStage_Status#HEATING) OR (OpState = OpStage_Status#COOLING),
        PT := CompRunTimerMin * 60
    );
    RS_ChangeOfMode(
        S  := (OpState = OpStage_Status#HEATING) OR (OpState = OpStage_Status#COOLING),
        R1 := TON_MinRunTime.Q
    );
    
    MinRunTime := RS_ChangeOfMode.S AND RS_ChangeOfMode.Q1;
    {ENDREGION}
 
    {REGION STATE TRANSITION CHECK}
    //Only allow transition between active states if compressor temperature above ECT and if mimimum compressor time is reached
    IF(OpState <> 0 AND GoToState = 0) THEN
        OpState := 0;
    ELSE
        //Only require compressor temperature when the compressor is running
        IF(OU_CompOn)THEN
            IF (GoToState = OpStage_Status#DEFROST) THEN
                OpState := GoToState;
            ELSIF(GoToState <> OpState AND OU_CompTemp < ECT) THEN
                OU_CompHeat := TRUE;
            ELSIF(GoToState <> OpState AND MinRunTime) THEN
                OU_CompHeat := FALSE;
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
    Dis_AutoMode := ManMode_Cool OR ManMode_Heat;// OR ImmHeatOnly;
    
    IF(UnitOn)THEN
        IF(En_AutoMode  AND NOT(Dis_AutoMode)) OR DHWFrcSwitch THEN           //AND NOT(Dis_OpStateSwitch)           
            CASE OpState OF
                /*
                Change operation state depending on system need
                 0: Decision phase
                 1: Heating
                 2: Cooling
                 3: DHW
                 4: Defrost
                
                */
                
                0: //Decision phase              
                    IF(DHWNeed)THEN
                        GoToState := OpStage_Status#DHW;
                    ELSIF(OpModeAllowHeat) THEN
                        GoToState := OpStage_Status#HEATING;
                    ELSIF(OpModeAllowCool)THEN
                        GoToState := OpStage_Status#COOLING;
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
                    
                    IF OU_Unit.DefrostRun THEN 
                        GoToState := OpStage_Status#DEFROST;
                    ELSIF(NOT(OpModeAllowHeat)) THEN // Return to decision phase
                        GoToState := OpStage_Status#DECISION_PHASE;
                    ELSIF(DHWNeed AND NOT DHWFrcSwitch) THEN
                        GoToState := OpStage_Status#DHW;
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
                    IF OU_Unit.DefrostRun THEN 
                        GoToState := OpStage_Status#DEFROST;
                     
                    ELSIF(NOT(DHWNeed))THEN // IF statements reflects priority of the modes
                        IF OpModeAllowHeat THEN
                            GoToState := OpStage_Status#HEATING;
                        ELSIF OpModeAllowCool THEN
                            GoToState := OpStage_Status#COOLING;
                        ELSE
                            GoToState := OpStage_Status#DECISION_PHASE;
                        END_IF;
                    END_IF;
                4: //Defrost
                    HeatReq := FALSE;
                    CoolReq := FALSE;
                    ImmHeatReq := FALSE;
                    DHWReq := FALSE;
                    IF NOT OU_Unit.DefrostRun THEN  // Leave defrost mode
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
            PT := 1
        );
        IF(TON_Energybalance.Q)THEN
            EBHP := LIMIT(EBHPMin, ((EBHP - (SupplyTempCalc - Offset_EBHP - HeatReg_Temp) / 60)), EBHPMax);
        END_IF;
        
        Offset_EBHP := LIMIT(0, -0.01 * EBHP, 4);
        

    ELSIF(NOT(OpModeAllowHeat))THEN
        EBHP := 0;
    END_IF;   
    {ENDREGION}
    
END_PROGRAM