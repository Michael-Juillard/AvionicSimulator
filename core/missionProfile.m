classdef missionProfile < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        satellite 
        timeSimulation
        powerProfileFile
        profileAllPower
        sensorsList
        hardwareUsageProfileFile
        profileAllHW
        preProcessingUnitList
        OBC
        lineConnection
        dynamicSim
    end
    
    methods
        function obj = missionProfile(fileInfo)
            %missionProfile Construct an instance of this class
            %   Detailed explanation goes here

            DOMnode = xmlread(fileInfo);
            xRoot = DOMnode.getDocumentElement;
            if xRoot.getTagName ~= 'missionProfile'
                return;
            end

            % name
            nameChild = xRoot.getElementsByTagName('name');
            if nameChild.getLength ~= 0
                obj.name = char(nameChild.item(0).getTextContent);
            end
            
            % satellite
            satelliteChild = xRoot.getElementsByTagName('satellite');
            if satelliteChild.getLength ~= 0
                obj.satellite = char(satelliteChild.item(0).getTextContent);
            end
            
            %timeSimulation
%             timeSimulationChild = xRoot.getElementsByTagName('timeSimulation');
%             if timeSimulationChild.getLength ~= 0
%                 obj.timeSimulation = 1000.0*str2num(timeSimulationChild.item(0).getTextContent); % from [s] to [ms]
%             end

            % powerProfileFile
            powProfChild = xRoot.getElementsByTagName('powerProfile');
            if powProfChild.getLength ~= 0
                obj.powerProfileFile = char(powProfChild.item(0).getTextContent);
            end

            sensorsChild = xRoot.getElementsByTagName('sensors');
            if sensorsChild.getLength ~= 0
                oneChild = sensorsChild.item(0);
                nbChild = oneChild.getLength;
                obj.sensorsList = {};
                for i = 1:nbChild-1
                    oneSensor=oneChild.item(i);
                    if oneSensor.hasAttributes()
                        idSensor = str2double(oneSensor.getAttribute('id'));
                        nameSensor=char(oneSensor.item(0).getTextContent);
                        obj.sensorsList(idSensor) = {sensor(['component/sensor/' nameSensor '.xml'])};
                    end
                end
            end
            
            dynamicSimChild = xRoot.getElementsByTagName('dynamicSim');
            if dynamicSimChild.getLength ~= 0
                obj.dynamicSim = str2double(dynamicSimChild.item(0).getTextContent);
            else
                obj.dynamicSim = 0;
            end


            hardwareUsageProfileChild = xRoot.getElementsByTagName('hardwareUsageProfile');
            if hardwareUsageProfileChild.getLength ~= 0
                obj.hardwareUsageProfileFile = char(hardwareUsageProfileChild.item(0).getTextContent);
            end

            preProChild = xRoot.getElementsByTagName('preProcessingUnit');
            if preProChild.getLength ~= 0
                oneChild = preProChild.item(0);
                nbChild = oneChild.getLength;
                obj.preProcessingUnitList = {};
                for i = 1:nbChild-1
                    onePreProp=oneChild.item(i);
                    if onePreProp.hasAttributes()
                        idPreProp = str2double(onePreProp.getAttribute('id'));
                        namePreProp=char(onePreProp.item(0).getTextContent);
                        obj.preProcessingUnitList(idPreProp) = {preProcessing(['component/preProcessing/' namePreProp '.xml'])};
                    end
                end
            end

            OBCChild = xRoot.getElementsByTagName('OBC');
            if OBCChild.getLength ~= 0
                obj.OBC = OBC(['component/OBC/' char(OBCChild.item(0).getTextContent) '.xml']);
            end

            %Linking loading
            linkChild = xRoot.getElementsByTagName('linking');
            if linkChild.getLength ~= 0
                oneChild = linkChild.item(0);
                nbChild = oneChild.getLength;
                obj.lineConnection = {};
                for i = 1:nbChild-1
                    oneLine=oneChild.item(i);
                    if oneLine.hasAttributes()
                        idLine = str2double(oneLine.getAttribute('id'));
                        %line type
                        lineType = '';
                        lineTypeChild = oneLine.getElementsByTagName('lineType');
                        if lineTypeChild.getLength ~= 0
                            lineType = char(lineTypeChild.item(0).getTextContent);
                        end
                        %line length
                        length = -1;
                        lineLengthChild = oneLine.getElementsByTagName('length');
                        if lineLengthChild.getLength ~= 0
                            length = str2double(lineLengthChild.item(0).getTextContent);
                        end
                        %redundant
                        
                        lineRedundantChild = oneLine.getElementsByTagName('redundant');
                        if lineRedundantChild.getLength ~= 0
                            redundantTxt = char(lineRedundantChild.item(0).getTextContent);
                            if string(redundantTxt) == "true"
                                redundant = true;
                            end
                        end
                        %connectToOBC
                        connectToOBC = false;
                        lineConnectToOBCChild = oneLine.getElementsByTagName('connectToOBC');
                        if lineConnectToOBCChild.getLength ~= 0
                            connectToOBCTxt = char(lineConnectToOBCChild.item(0).getTextContent);
                            if string(connectToOBCTxt) == "true"
                                connectToOBC = true;
                            end
                        end
                        %idOBCMem
                        idOBCMem= 0;
                        lineIdOBCMemChild = oneLine.getElementsByTagName('idOBCMem');
                        if lineIdOBCMemChild.getLength ~= 0
                            idOBCMem = str2double(lineIdOBCMemChild.item(0).getTextContent);
                        end
                        %sensor connected
                        listSensorConnected = [];
                        lineListSensorConnectedChild = oneLine.getElementsByTagName('sensorConnected');
                        if lineListSensorConnectedChild.getLength ~= 0
                            listSensorIdChild = lineListSensorConnectedChild.item(0);
                            nbSensorId = listSensorIdChild.getLength;
                            listSensorConnected = zeros(1,nbSensorId-2);
                            for j = 1:nbSensorId-2
                                oneSensorId=listSensorIdChild.item(j);
                                listSensorConnected(j) = str2double(oneSensorId.getTextContent);
                            end
                        end
                        %preProcessingUnitID
                        idPreProcess = -1;
                        linePreProcessChild = oneLine.getElementsByTagName('preProcessingUnitID');
                        if linePreProcessChild.getLength ~= 0
                            idPreProcess = str2double(linePreProcessChild.item(0).getTextContent);
                            if idPreProcess > 0 %if preprocessing exist
                                setIdLineOut(getPreProcessingUnit(obj,idPreProcess),idLine);
                            end
                        end
                        
                        obj.lineConnection(idLine) = {lineConnection(['component/lineType/' lineType '.xml'],length,connectToOBC, idOBCMem,listSensorConnected,idPreProcess)};

                    end
                end
            end
            obj.profileAllPower = {};
            obj.profileAllHW ={};
            obj.timeSimulation = 0; % load later           
            
        end
        
        %% Generic info
        function [name, satellite] = getInfo(obj)
            name = obj.name;
            satellite = obj.satellite;
        end
        
        function getInfoReadable(obj)
            disp(['Profile name : ' obj.name ' & Stellite name : ' obj.satellite  ' & Total time sim :' num2str(obj.timeSimulation/(1000*60))  ' [min]']);
        end
        
        function timeSimulation = getTimeSimulation(obj)
            timeSimulation = obj.timeSimulation;
        end
        
        function dynamicSim = getDynamicSim(obj)
            dynamicSim = obj.dynamicSim;
        end
        
        %% Power profile
        function powerProfileFile = getPowerProfileFile(obj)
            powerProfileFile = obj.powerProfileFile;
        end
        
        function success = loadPowerProfile(obj,scenario)
            fullPathFile = ['profile/PowerProfile/Power_' scenario '_' obj.powerProfileFile '.csv'];
            if isfile(fullPathFile)
                %disp(fullPathFile)
                tabelPowerProf = readtable(fullPathFile);

                namePower = tabelPowerProf{1, 1}{1};
                initLevel  = tabelPowerProf{1, 2};
                data = tabelPowerProf{1, 3:end-1};
                data(isnan(data)) = [];
                profilePowerCycle = [data(1:2:end) ; 1000*data(2:2:end)]; % mode and timing (from [s] to [ms])

                obj.profileAllPower = { namePower,initLevel, profilePowerCycle };
                success = true;
            else
                success = false;
            end
        end
        
        function power =  getInitalAvailablePower(obj)
            power = obj.profileAllPower{1,2};
        end
        
        function power = getAvailablePower(obj, time)
            powerFromBeg = obj.profileAllPower{3};
            powerFromTime = powerFromBeg(1,powerFromBeg(2,:)<=time);
            if isempty(powerFromTime)
                power = obj.profileAllPower{1,2};
            else
                power = powerFromTime(end);
            end
        end
        
        %% Hardware profile
        function hardwareUsageProfileFile = getHardwareUsageProfileFile(obj)
            hardwareUsageProfileFile = obj.hardwareUsageProfileFile;
        end
        
        function success = loadHardwareProfile(obj,scenario)
            if obj.dynamicSim ~= 1 
                fullPathFile = ['profile/HWProfile/HW_' scenario '_' obj.hardwareUsageProfileFile '.csv'];
                if isfile(fullPathFile)
                    tabelHWProf = readtable(fullPathFile);
                    nbItem = size(tabelHWProf,1);
                    obj.profileAllHW ={};
                    for i = 1:(nbItem-1)
                        nameHW = tabelHWProf{i, 1}{1};
                        typeHW = tabelHWProf{i, 2};
                        id  = tabelHWProf{i, 3};
                        initMode = tabelHWProf{i, 4};
                        data = tabelHWProf{i, 5:end-1};
                        data(isnan(data)) = [];
                        profileOneHW = [[initMode data(1:2:end) 0] ; [0 1000*data(2:2:end) inf]]; % mode and timing (from [s] to [ms])

                        obj.profileAllHW{typeHW,id} = { nameHW,typeHW,id,initMode, profileOneHW };
                    end
                    endSim = tabelHWProf{nbItem, 5:end-1};
                    endSim(isnan(endSim)) = [];
                    obj.timeSimulation = 1000*endSim(1);% (from [s] to [ms])
                    success = true;
                else
                    success = false;
                end
            else
                success = true;
            end
        end
        
        
        function mode =  getInitalModeHW(obj, type, id)
            mode = 0;
            if obj.dynamicSim ~= 1
                oneHWProfile = obj.profileAllHW{type,id};
                if ~isempty(oneHWProfile)
                    mode = oneHWProfile{4};
                end
            else
                mode = 1; %default SHOULD NOT BE USED
            end
            
        end
        
        function mode = getActualModeHW(obj, type, id, time)
            mode = 0;
            if obj.dynamicSim ~= 1
                oneHWProfile = obj.profileAllHW{type,id};
                if ~isempty(oneHWProfile)
                    if oneHWProfile{5}(2,2) < time
                        oneHWProfile{5}(:,1) = [];
                    end
                    mode = oneHWProfile{5}(1,1);

                end
            else
                mode = 1; %default SHOULD NOT BE USED
            end
        end
        
        %% Sensor
        function listIdSensor = getListIdSensor(obj)
            listIdSensor = find(~cellfun(@isempty,obj.sensorsList));
        end
        
        function oneSensor = getSensor(obj,idSensor)
            oneSensor = obj.sensorsList{idSensor};
        end
        
        function [idMode, nameMode] = getActualModeSensor(obj,idSensor)
            [idMode, nameMode] = getActualMode(obj.sensorsList{idSensor});
        end
        
        function success = setModeIdSensor(obj,idSensor,idMode)
            success = setModeId(obj.sensorsList{idSensor},idMode);
        end
        
        function power = getPowerSensor(obj,idSensor)
            power = getPower(obj.sensorsList{idSensor});
        end
             
        function dataOutAverage = getDataOutAverageSensor(obj,idSensor)
            dataOutAverage = getDataOutAverage(obj.sensorsList{idSensor});
        end
        
        function [success, dataSend, newTransmission, endTransmission] = updateSensor(obj,idSensor,time, rateSending)
            [success, dataSend, newTransmission, endTransmission] = update(obj.sensorsList{idSensor},time, rateSending);
        end
        
        function [nbModeMax, allModePower, allModePackSize,allModeRatePacket, allModeAccuracySensor] = getAllModeParamSensor(obj)
            listIdSensor = getListIdSensor(obj);
            nbModeMax = 6;
            
            allModePower = {zeros(1+nbModeMax,+size(listIdSensor,2))};
            allModePower{1}(1,:) = listIdSensor;
            allModePackSize = {zeros(1+nbModeMax,+size(listIdSensor,2))};
            allModePackSize{1}(1,:) = listIdSensor;
            allModeRatePacket = {zeros(1+nbModeMax,+size(listIdSensor,2))};
            allModeRatePacket{1}(1,:) = listIdSensor;
            allModeAccuracySensor = {zeros(1+nbModeMax,+size(listIdSensor,2))};
            allModeAccuracySensor{1}(1,:) = listIdSensor;
            it = 1;
            
            for idSensor = listIdSensor
                [nbMode, modePower, modePackSize,modeRatePacket, modeAccuracySensor] = getParamPerMode(obj.sensorsList{idSensor});
                
                allModePower{1}(2:end,it) = [modePower  ones(1,nbModeMax-nbMode)*-1];
                allModePackSize{1}(2:end,it) = [modePackSize  ones(1,nbModeMax-nbMode)*-1];
                allModeRatePacket{1}(2:end,it) = [modeRatePacket  ones(1,nbModeMax-nbMode)*-1];
                allModeAccuracySensor{1}(2:end,it) = [modeAccuracySensor  ones(1,nbModeMax-nbMode)*-1];

                it = it +1;
            end
        end
        
        
        %% PreProcessingUnitList
        function listIdPreProcessingUnit = getListIdPreProcessingUnit(obj)
            listIdPreProcessingUnit = find(~cellfun(@isempty,obj.preProcessingUnitList));
        end
        
        function onePreProcessingUnit = getPreProcessingUnit(obj,idPreProcessingUnit)
            onePreProcessingUnit = obj.preProcessingUnitList{idPreProcessingUnit};
        end
        
        function [idMode, nameMode] = getActualModePrePro(obj,idPreProcessingUnit)
            [idMode, nameMode] = getActualMode(obj.preProcessingUnitList{idPreProcessingUnit});
        end
        
        function success = setModeIdPrePro(obj,idPreProcessingUnit,idMode)
            success = setModeId(obj.preProcessingUnitList{idPreProcessingUnit},idMode);
        end
        
        function power = getPowerPrePro(obj,idPreProcessingUnit)
            power = getPower(obj.preProcessingUnitList{idPreProcessingUnit});
        end
        
        function id = getIdLineOutPrePro(obj,idPreProcessingUnit)
            id = getIdLineOut(obj.preProcessingUnitList{idPreProcessingUnit});
        end
        
        function [memeFullStIn,successStIn, memeFullStOut, successStOut, dataOutStOut, endOutPacketStOut, newOutPacketStOut ]= updatePrePro(obj,idPreProcessingUnit,timeStep,dataIn,newInPacketLine, EndInPacketLine, outRate)
            [memeFullStIn,successStIn, memeFullStOut, successStOut, dataOutStOut, endOutPacketStOut, newOutPacketStOut ]= update(obj.preProcessingUnitList{idPreProcessingUnit},timeStep,dataIn,newInPacketLine, EndInPacketLine, outRate);
        end
        
        function [nbModeMax, allModeCompressionFactor, allModeCompressionRate,allModeCompressionLag,allModePower, allModeAccuaracyLoss] = getAllModeParamPrePro(obj)
            listIdPrePro = getListIdPreProcessingUnit(obj);
            nbModeMax = 6;
           
            allModeCompressionFactor = {zeros(1+nbModeMax,+size(listIdPrePro,2))};
            allModeCompressionFactor{1}(1,:) = listIdPrePro;
            allModeCompressionRate = {zeros(1+nbModeMax,+size(listIdPrePro,2))};
            allModeCompressionRate{1}(1,:) = listIdPrePro;
            allModeCompressionLag = {zeros(1+nbModeMax,+size(listIdPrePro,2))};
            allModeCompressionLag{1}(1,:) = listIdPrePro;
            allModePower = {zeros(1+nbModeMax,+size(listIdPrePro,2))};
            allModePower{1}(1,:) = listIdPrePro;
            allModeAccuaracyLoss = {zeros(1+nbModeMax,+size(listIdPrePro,2))};
            allModeAccuaracyLoss{1}(1,:) = listIdPrePro;
            
            it = 1;
            
            for idPrepPro = listIdPrePro
                [nbMode, modeCompressionFactor, modeCompressionRate,modeCompressionLag, modePower, modeAccuaracyLoss] = getParamPerMode(obj.preProcessingUnitList{idPrepPro});
                
                
                allModeCompressionFactor{1}(2:end,it) = [modeCompressionFactor  ones(1,nbModeMax-nbMode)*-1];
                allModeCompressionRate{1}(2:end,it) = [modeCompressionRate  ones(1,nbModeMax-nbMode)*-1];
                allModeCompressionLag{1}(2:end,it) = [modeCompressionLag  ones(1,nbModeMax-nbMode)*-1];
                allModePower{1}(2:end,it) = [modePower  ones(1,nbModeMax-nbMode)*-1];
                allModeAccuaracyLoss{1}(2:end,it) = [modeAccuaracyLoss  ones(1,nbModeMax-nbMode)*-1];

                it = it +1;
            end
        end
        
        %% OBC
        function OBC = getOBC(obj)
            OBC = obj.OBC;
        end
        
        function [memeFull, previsouNotDone] = addDataOBC(obj,idStorage, dataAmount,newPacket, endPacket)
            [memeFull, previsouNotDone] = addData(obj.OBC,idStorage,dataAmount,newPacket, endPacket);
        end
            
        function [success, data, endPacket, newPacket] = readPacketOBC(obj,idStorage,time,rate)
            [success, data, endPacket, newPacket] = readPacket(obj.OBC,idStorage,time,rate);
        end
        
        function percentage = utilisationStorageOBC(obj,idStorage)
            percentage = utilisationStorage(obj.OBC,idStorage);
        end
        
        function MIPS = getMIPSOBC(obj)
            MIPS = getMIPS(obj.OBC);
        end
        
        function power = getPowerOBC(obj)
            power = getPower(obj.OBC);
        end
        
        function listIdOBCMem = getListIdStorage(obj)
            listIdOBCMem = getListIdStorage(obj.OBC);
        end
        
        function listIdAlgo = getListIdAlgorithm(obj)
            listIdAlgo = getListIdAlgorithm(obj.OBC);
        end
            
        function listIdASIC = getListIdASIC(obj)
            listIdASIC = getListIdASIC(obj.OBC);
        end
                
        function listIdFPGA = getListIdFPGA(obj)
            listIdFPGA = getListIdFPGA(obj.OBC);
        end
        
        function success = setModeIdOBC(obj,idMode)
            success = setModeId(obj.OBC,idMode);
        end
            
        function [idMode, nameMode] = getActualModeOBC(obj)
            [idMode, nameMode] = getActualMode(obj.OBC);
        end
        
        function success = setModeIdAlgo(obj,idAlgorithm,idMode)
            success = setModeIdAlgo(obj.OBC,idAlgorithm,idMode);
        end
        
        function [idMode, nameMode] = getActualModeAlgo(obj,idAlgorithm)
            [idMode, nameMode] = getActualModeAlgo(obj.OBC,idAlgorithm);
        end
        
        function idMode = getActualModeAlgoId(obj,idAlgorithm)
            idMode = getActualModeAlgoId(obj.OBC,idAlgorithm);
        end
        
        function [nbMode, MIPSMode, powerMode] = getParamPerModeOBC(obj)
            [nbMode, MIPSMode, powerMode] = getParamPerMode(obj.OBC);
        end
        %asic
        function power= getPowerASIC(obj,idASIC)
            power= getPowerASIC(obj.OBC,idASIC);
        end
        
        function algorithmIdImpl = getAlgorithmIdImplASIC(obj,idASIC)
            algorithmIdImpl = getAlgorithmIdImplASIC(obj.OBC,idASIC);
        end
        
        function processingRate = getProcessingRateASIC(obj,idASIC)
            processingRate = getProcessingRateASIC(obj.OBC,idASIC);
        end
        %fpga
        function power= getPowerFPGA(obj,idFPGA)
            power= getPowerFPGA(obj.OBC,idFPGA);
        end
        
        function idAlgorithm = getIdsAlgorithmFPGA(obj,idFPGA)
            idAlgorithm = getIdsAlgorithmFPGA(obj.OBC,idFPGA);
        end
        %algo
        function idMemoryLinked = getIdMemoryLinkedAlgo(obj,idAlgorithm)
            idMemoryLinked = getIdMemoryLinkedAlgo(obj.OBC,idAlgorithm);
        end
        
        function  requested = requestDataInAlgo(obj,idAlgorithm,timeStep)
            requested = requestDataInAlgo(obj.OBC,idAlgorithm,timeStep);
        end
        
        function setPacketInFinishReadingAlgo(obj,idAlgorithm, finish)
            setPacketInFinishReadingAlgo(obj.OBC,idAlgorithm, finish);
        end
        
        function nbOperationPerS = getNbOperationPerSAlgo(obj,idAlgorithm)
            nbOperationPerS = getNbOperationPerSAlgo(obj.OBC,idAlgorithm);
        end
        
        function processingRate = getProcessingRateAlgo(obj,idAlgorithm)
            processingRate = getProcessingRateAlgo(obj.OBC,idAlgorithm);
        end
        
        function success = setOnFPGAAlgo(obj,idAlgorithm)
            success = setOnFPGAAlgo(obj.OBC,idAlgorithm);
        end
        
        
        function [nbModeMax, allModeNbOperationPerS, allModeProcessingSpeed,allModeProcessingRate,allModeFrequency,allModePeriode] = getAllModeParamAlgo(obj)
            [nbModeMax, allModeNbOperationPerS, allModeProcessingSpeed,allModeProcessingRate,allModeFrequency,allModePeriode] = getAllModeParamAlgo(obj.OBC);
        end
        
        %% LineConnection
        function listIdLineConnection = getListIdLineConnection(obj)
            listIdLineConnection = find(~cellfun(@isempty,obj.lineConnection));
        end
        
        function oneLineConnection = getLineConnection(obj,idLineConnection)
            oneLineConnection = obj.lineConnection{idLineConnection};
        end
        
        function success = hasSensorConnectedLine(obj,idLineConnection)
            success = hasSensorConnected(obj.lineConnection{idLineConnection});
        end
        
        function bool = isConnectToOBCLine(obj,idLineConnection)
            bool = isConnectToOBC(obj.lineConnection{idLineConnection});
        end
        
        function id = getIdOBCMemLine(obj,idLineConnection)
           id = getIdOBCMem(obj.lineConnection{idLineConnection});
        end
        
        function id = getSensorIdLine(obj,idLineConnection)
            id = getSensorId(obj.lineConnection{idLineConnection});
        end
        
        function id = getPreProcIdLine(obj,idLineConnection)
            id = getPreProcId(obj.lineConnection{idLineConnection});
        end
        
        function rate = getRateLine(obj,idLineConnection)
            rate = getRate(obj.lineConnection{idLineConnection});
        end
        
        function busynessLine=  getBusynessLine(obj,idLineConnection)
            busynessLine=  getBusynessLine(obj.lineConnection{idLineConnection});
        end
        
        
        function [dataOut, lineBusy,newOutPacket, EndOutPacket] = updateLine(obj,idLineConnection,time, dataIn,newInPacket, EndInPacket)
            [dataOut, lineBusy,newOutPacket, EndOutPacket] = update(obj.lineConnection{idLineConnection},time, dataIn,newInPacket, EndInPacket);
        end
    end
        
       
end

