classdef OBC < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        storageList
        FPGAList
        ASICList
        algorithmList
        nbMode
        actualMode
        listMode
        MIPSMode
        powerMode
    end
    
    methods
        function obj = OBC(fileInfo )
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here
            DOMnode = xmlread(fileInfo);
            xRoot = DOMnode.getDocumentElement;
            if xRoot.getTagName ~= 'OBC'
                return;
            end

            % name
            nameChild = xRoot.getElementsByTagName('name');
            if nameChild.getLength ~= 0
                obj.name = char(nameChild.item(0).getTextContent);
            end

            %storage
            storageChild = xRoot.getElementsByTagName('storage');
            if storageChild.getLength ~= 0
                unitsChild = storageChild.item(0);
                nbChild = unitsChild.getLength;
                obj.storageList = {};
                for i = 1:2:nbChild-1
                    oneUnit=unitsChild.item(i);
                    idUnit = str2double(oneUnit.getAttribute('id'));
                    %storageType
                    storageType='';
                    storageTypeChild = oneUnit.getElementsByTagName('type');
                    if storageTypeChild.getLength ~= 0
                        storageType = char(storageTypeChild.item(0).getTextContent);
                    end
                    %capacity 
                    capacity = 0;
                    storageCapacityChild = oneUnit.getElementsByTagName('capacity');
                    if storageCapacityChild.getLength ~= 0
                        capacity = str2double(storageCapacityChild.item(0).getTextContent);
                    end
                    %inputRate
                    inputRate = 0;
                    storageInputRateChild = oneUnit.getElementsByTagName('inputRate');
                    if storageInputRateChild.getLength ~= 0
                        inputRate = str2double(storageInputRateChild.item(0).getTextContent);
                    end
                    % outputRate
                    outputRate = 0;
                    storageOutputRateeChild = oneUnit.getElementsByTagName('outputRate');
                    if storageOutputRateeChild.getLength ~= 0
                        outputRate = str2double(storageOutputRateeChild.item(0).getTextContent);
                    end
                    % readWriteSimultanous
                    readWriteSimultanous = false;
                    storageReadWriteSimultanousChild = oneUnit.getElementsByTagName('readWriteSimultanous');
                    if storageReadWriteSimultanousChild.getLength ~= 0
                        readWriteSimultanousTxt = char(storageReadWriteSimultanousChild.item(0).getTextContent);
                        if string(readWriteSimultanousTxt) == "true"
                            readWriteSimultanous = true;
                        end
                    end
                    
                    obj.storageList(idUnit) = {storage(storageType, capacity, inputRate, outputRate, readWriteSimultanous)};
                end      
            end
            
            %HWaccelerometers
            HWaccelerometersChild = xRoot.getElementsByTagName('HWaccelerometers');
            if HWaccelerometersChild.getLength ~= 0
                HWoneChild = HWaccelerometersChild.item(0);
                %FPGA
                FPGAChild = HWoneChild.getElementsByTagName('FPGA');
                if FPGAChild.getLength ~= 0
                    unitsChild = FPGAChild.item(0);
                    nbChild = unitsChild.getLength;
                    obj.FPGAList ={};
                    for i = 1:2:nbChild-1
                        oneUnit=unitsChild.item(i);
                        idUnit = str2double(oneUnit.getAttribute('id'));
                        %nbGates
                        nbGates=0;
                        nbGatesChild = oneUnit.getElementsByTagName('nbGates');
                        if nbGatesChild.getLength ~= 0
                            nbGates = str2double(nbGatesChild.item(0).getTextContent);
                        end
                        %power 
                        power = 0;
                        powerChild = oneUnit.getElementsByTagName('power');
                        if powerChild.getLength ~= 0
                            power = str2double(powerChild.item(0).getTextContent);
                        end
                        %nbIO
                        nbIO = 0;
                        nbIOChild = oneUnit.getElementsByTagName('nbIO');
                        if nbIOChild.getLength ~= 0
                            nbIO = str2double(nbIOChild.item(0).getTextContent);
                        end
                        % reprogramable
                        reprogramable = false;
                        reprogramableChild = oneUnit.getElementsByTagName('reprogramable');
                        if reprogramableChild.getLength ~= 0
                            reprogramableTxt = char(reprogramableChild.item(0).getTextContent);
                            if string(reprogramableTxt) == "true"
                                reprogramable = true;
                            end
                        end
                        % reprogramTime
                        reprogramTime = 0;
                        reprogramTimeChild = oneUnit.getElementsByTagName('reprogramTime');
                        if reprogramTimeChild.getLength ~= 0
                            reprogramTime = str2double(reprogramTimeChild.item(0).getTextContent);
                        end
                        
                        % initalAlgo
                        initalAlgo = 0;
                        initalAlgoChild = oneUnit.getElementsByTagName('initalAlgoId');
                        if initalAlgoChild.getLength ~= 0
                            initalAlgo = str2double(initalAlgoChild.item(0).getTextContent);
                        end

                        obj.FPGAList(idUnit) = {FPGA(nbGates,power,nbIO,reprogramable,reprogramTime,initalAlgo)};
                    end      
                end
                
                %ASIC
                ASICChild = HWoneChild.getElementsByTagName('ASIC');
                if ASICChild.getLength ~= 0
                    unitsChild = ASICChild.item(0);
                    nbChild = unitsChild.getLength;
                    obj.ASICList ={};
                    for i = 1:2:nbChild-1
                        oneUnit=unitsChild.item(i);
                        idUnit = str2double(oneUnit.getAttribute('id'));
                        %algorithmIdImpl
                        algorithmIdImpl=0;
                        algorithmIdImplChild = oneUnit.getElementsByTagName('algorithmIdImpl');
                        if algorithmIdImplChild.getLength ~= 0
                            algorithmIdImpl = str2double(algorithmIdImplChild.item(0).getTextContent);
                        end
                        %power 
                        power = 0;
                        powerChild = oneUnit.getElementsByTagName('power');
                        if powerChild.getLength ~= 0
                            power = str2double(powerChild.item(0).getTextContent);
                        end
                        %nbIO
                        nbIO = 0;
                        nbIOChild = oneUnit.getElementsByTagName('nbIO');
                        if nbIOChild.getLength ~= 0
                            nbIO = str2double(nbIOChild.item(0).getTextContent);
                        end

                        % processingSpeed
                        processingSpeed = 0;
                        processingSpeedChild = oneUnit.getElementsByTagName('processingSpeed');
                        if processingSpeedChild.getLength ~= 0
                            processingSpeed = str2double(processingSpeedChild.item(0).getTextContent);
                        end
                        
                        % processingRate
                        processingRate = 0;
                        processingRateChild = oneUnit.getElementsByTagName('processingRate');
                        if processingRateChild.getLength ~= 0
                            processingRate = str2double(processingRateChild.item(0).getTextContent);
                        end

                        obj.ASICList(idUnit) = {ASIC(algorithmIdImpl,power,nbIO,processingSpeed,processingRate)};
                    end      
                end
            end
            
            %algorithms
            algorithmsChild = xRoot.getElementsByTagName('algorithms');
            if algorithmsChild.getLength ~= 0
                algoChild = algorithmsChild.item(0);
                nbChild = algoChild.getLength;
                obj.algorithmList = {};
                for i = 1:2:nbChild-1
                    oneAlgo=algoChild.item(i);
                    idAlgo = str2double(oneAlgo.getAttribute('id'));
                    %name
                    name='';
                    nameChild = oneAlgo.getElementsByTagName('name');
                    if nameChild.getLength ~= 0
                        name = char(nameChild.item(0).getTextContent);
                    end
                    % ASICimplemented
                    ASICimplemented = false;
                    ASICimplementedChild = oneAlgo.getElementsByTagName('ASICimplemented');
                    if ASICimplementedChild.getLength ~= 0
                        ASICimplementedTxt = char(ASICimplementedChild.item(0).getTextContent);
                        if string(ASICimplementedTxt) == "true"
                            ASICimplemented = true;
                        end
                    end
                    %FPGAoperationReductionFactor 
                    FPGAoperationReductionFactor = 0;
                    FPGAoperationReductionFactorChild = oneAlgo.getElementsByTagName('FPGAoperationReductionFactor');
                    if FPGAoperationReductionFactorChild.getLength ~= 0
                        FPGAoperationReductionFactor = str2double(FPGAoperationReductionFactorChild.item(0).getTextContent);
                    end
                    %idMemoryLinked
                    idMemoryLinked = 0;                    
                    idMemoryLinkedChild = oneAlgo.getElementsByTagName('idMemoryLinked');
                    if idMemoryLinkedChild.getLength ~= 0
                        idMemoryLinked = str2double(idMemoryLinkedChild.item(0).getTextContent);
                    end
                    
                    % modes to read for algo ---
                    modesAlgoChild = oneAlgo.getElementsByTagName('modes');
                        if modesAlgoChild.getLength ~= 0
                            oneModeAlgoChild = modesAlgoChild.item(0);
                            nbChild = oneModeAlgoChild.getLength;
                            maxNbItem = ceil((nbChild-1)/2);
                            listAlgoMode = cell(1,maxNbItem);
                            modeAlgoNbOperation = zeros(1,maxNbItem);
                            modeAlgoNbGateFPGA = zeros(1,maxNbItem);
                            modeAlgoFrequency = zeros(1,maxNbItem);
                            modeProcessingSpeed = zeros(1,maxNbItem);
                            modeProcessingRate = zeros(1,maxNbItem);
                            for j = 1:2:nbChild-1
                                oneALGOMode=oneModeAlgoChild.item(j);
                                %modeInfo = oneMode.getChildNodes;
                                idAlgoMode = str2double(oneALGOMode.getAttribute('id'));

                                nameAlgoModeNode = oneALGOMode.getElementsByTagName('name');
                                if nameAlgoModeNode.getLength ~= 0
                                    listAlgoMode{idAlgoMode}=char(nameAlgoModeNode.item(0).getTextContent);
                                end

                                nbOperationAlgoModeNode = oneALGOMode.getElementsByTagName('nbOperationPerS');
                                if nbOperationAlgoModeNode.getLength ~= 0
                                    modeAlgoNbOperation(idAlgoMode)=str2double(nbOperationAlgoModeNode.item(0).getTextContent);
                                end

                                nbGateFPGAAlgoModeNode = oneALGOMode.getElementsByTagName('nbGateFPGA');
                                if nbGateFPGAAlgoModeNode.getLength ~= 0
                                    modeAlgoNbGateFPGA(idAlgoMode)=str2double(nbGateFPGAAlgoModeNode.item(0).getTextContent);
                                end
                                
                                processingSpeedAlgoModeNode = oneALGOMode.getElementsByTagName('processingSpeed');
                                if processingSpeedAlgoModeNode.getLength ~= 0
                                    modeProcessingSpeed(idAlgoMode)=str2double(processingSpeedAlgoModeNode.item(0).getTextContent);
                                end
                                
                                processingRateAlgoModeNode = oneALGOMode.getElementsByTagName('processingRate');
                                if processingRateAlgoModeNode.getLength ~= 0
                                    modeProcessingRate(idAlgoMode)=str2double(processingRateAlgoModeNode.item(0).getTextContent);
                                end
                                
                                frequencyAlgoModeNode = oneALGOMode.getElementsByTagName('frequency');
                                if frequencyAlgoModeNode.getLength ~= 0
                                    modeAlgoFrequency(idAlgoMode)=str2double(frequencyAlgoModeNode.item(0).getTextContent);
                                end
                            end
                        end
                    
                    
                    obj.algorithmList(idAlgo) = {algorithm(name, ASICimplemented, FPGAoperationReductionFactor,idMemoryLinked, listAlgoMode, modeAlgoNbOperation, modeAlgoNbGateFPGA,modeProcessingSpeed,modeProcessingRate, modeAlgoFrequency )};
                end      
            end
            
            % initalMode
            initialModeChild = xRoot.getElementsByTagName('initalMode');
            if initialModeChild.getLength ~= 0
                obj.actualMode = str2double(initialModeChild.item(0).getTextContent);
            end

            modesChild = xRoot.getElementsByTagName('modesOBC');
            if modesChild.getLength ~= 0
                oneChild = modesChild.item(0);
                nbChild = oneChild.getLength;
                maxNbItem = ceil((nbChild-1)/2);
                listMode =cell(1,maxNbItem);
                MIPSMode = zeros(1,maxNbItem);
                powerMode=zeros(1,maxNbItem);
                for i = 1:2:nbChild-1
                    oneMode=oneChild.item(i);
                    %modeInfo = oneMode.getChildNodes;
                    idMode = str2double(oneMode.getAttribute('id'));

                    nameModeNode = oneMode.getElementsByTagName('name');
                    if nameModeNode.getLength ~= 0
                        listMode{idMode}=char(nameModeNode.item(0).getTextContent);
                    end

                    MIPSModeNode = oneMode.getElementsByTagName('MIPS');
                    if MIPSModeNode.getLength ~= 0
                        MIPSMode(idMode)=str2double(MIPSModeNode.item(0).getTextContent);
                    end

                    powerModeNode = oneMode.getElementsByTagName('power');
                    if powerModeNode.getLength ~= 0
                        powerMode(idMode)=str2double(powerModeNode.item(0).getTextContent);
                    end
                end
            end
        
            obj.listMode = listMode;
            obj.MIPSMode = MIPSMode;
            obj.powerMode = powerMode/(10^3);  % from [mW] to [W]
            obj.nbMode = size(listMode,2);
            
        end
        
        function [name, nbMode] = getInfo(obj)
            name = obj.name;
            nbMode = obj.nbMode;
        end
        
        function [nbMode, MIPSMode, powerMode] = getParamPerMode(obj)
            nbMode = obj.nbMode;
            MIPSMode= obj.MIPSMode;
            powerMode = obj.powerMode;
        end
        
        function getInfoReadable(obj)
            disp(['Name architecture : ' obj.name ' & number of mode ' num2str(obj.nbMode)]);
        end
        
        function success = setModeId(obj,idMode)
            if idMode >= 1 && idMode <= obj.nbMode
                obj.actualMode = idMode;
                success = true;
            else
                success = false;
            end
        end
            
                    
        function nameMode = getNameMode(obj, id)
            if id >= 1 && id <= obj.nbMode
                nameMode = obj.listMode{id};
            else
                nameMode = '';
            end
        end
        
        function getNameModeReadable(obj, id)
            if id >= 1 && id <= obj.nbMode
                disp(['Mode name : ' obj.listMode{id}]);
            else
                disp('Mode id not valid');
            end
        end
        
        function [idMode, nameMode] = getActualMode(obj)
            idMode = obj.actualMode;
            nameMode = obj.listMode{idMode};
        end
        
        function getActualModeReadable(obj)
            idMode = obj.actualMode;
            disp(['Mode id : ' num2str(idMode) ' & mode name : ' obj.listMode{idMode}]);               
        end
        
        %Storage
        function listIdStorage = getListIdStorage(obj)
            listIdStorage = find(~cellfun(@isempty,obj.storageList));
        end
        
        function oneStorage = getStorage(obj,idStorage)
            oneStorage = obj.storageList{idStorage};
        end
        
        function [memeFull, previsouNotDone] = addData(obj,idStorage, dataAmount,newPacket, endPacket)
            [memeFull, previsouNotDone] = addData(obj.storageList{idStorage},dataAmount,newPacket, endPacket);
        end
            
        function [success, data, endPacket, newPacket] = readPacket(obj,idStorage,time,rate)
            [success, data, endPacket, newPacket] = readPacket(obj.storageList{idStorage},time,rate);
        end
        
        function percentage = utilisationStorage(obj,idStorage)
            percentage = utilisationStorage(obj.storageList{idStorage});
        end
        
        %FPGA
        function listIdFPGA = getListIdFPGA(obj)
            listIdFPGA = find(~cellfun(@isempty,obj.FPGAList));
        end
        
        function oneFPGA = getFPGA(obj,idFPGA)
            oneFPGA = obj.FPGAList{idFPGA};
        end
        
        function power= getPowerFPGA(obj,idFPGA)
            power= getPower(obj.FPGAList{idFPGA});
        end
        
        function idAlgorithm = getIdsAlgorithmFPGA(obj,idFPGA)
            idAlgorithm = getIdsAlgorithm(obj.FPGAList{idFPGA});
        end
        
        %ASIC
        function listIdASIC = getListIdASIC(obj)
            listIdASIC = find(~cellfun(@isempty,obj.ASICList));
        end
        
        function oneASIC = getASIC(obj,idASIC)
            oneASIC = obj.ASICList{idASIC};
        end
        
        function power= getPowerASIC(obj,idASIC)
            power= getPower(obj.ASICList{idASIC});
        end
        
        function algorithmIdImpl = getAlgorithmIdImplASIC(obj,idASIC)
            algorithmIdImpl = getAlgorithmIdImpl(obj.ASICList{idASIC});
        end
        
        function processingRate = getProcessingRateASIC(obj,idASIC)
            processingRate = getProcessingRate(obj.ASICList{idASIC});
        end
        
        %Algorithm
        function listIdAlgorithm = getListIdAlgorithm(obj)
            listIdAlgorithm = find(~cellfun(@isempty,obj.algorithmList));
        end
        
        function oneAlgorithm = getAlgorithm(obj,idAlgorithm)
            oneAlgorithm = obj.algorithmList{idAlgorithm};
        end
        
        function success = setModeIdAlgo(obj,idAlgorithm,idMode)
            success = setModeId(obj.algorithmList{idAlgorithm},idMode);
        end
        
        function [idMode, nameMode] = getActualModeAlgo(obj,idAlgorithm)
            [idMode, nameMode] = getActualMode(obj.algorithmList{idAlgorithm});
        end
        
        function idMode = getActualModeAlgoId(obj,idAlgorithm)
            idMode = getActualModeId(obj.algorithmList{idAlgorithm});
        end
        
        function idMemoryLinked = getIdMemoryLinkedAlgo(obj,idAlgorithm)
            idMemoryLinked = getIdMemoryLinked(obj.algorithmList{idAlgorithm});
        end
        
        function  requested = requestDataInAlgo(obj,idAlgorithm,timeStep)
            requested = requestDataIn(obj.algorithmList{idAlgorithm},timeStep);
        end
        
        function setPacketInFinishReadingAlgo(obj,idAlgorithm, finish)
            setPacketInFinishReading(obj.algorithmList{idAlgorithm}, finish);
        end
        
        function nbOperationPerS = getNbOperationPerSAlgo(obj,idAlgorithm)
            nbOperationPerS = getNbOperationPerS(obj.algorithmList{idAlgorithm});
        end
        
        function processingRate = getProcessingRateAlgo(obj,idAlgorithm)
            processingRate = getProcessingRate(obj.algorithmList{idAlgorithm});
        end
        
        function success = setOnFPGAAlgo(obj,idAlgorithm)
            success = setOnFPGA(obj.algorithmList{idAlgorithm});
        end
        
        function [nbModeMax, allModeNbOperationPerS, allModeProcessingSpeed,allModeProcessingRate,allModeFrequency,allModePeriode] = getAllModeParamAlgo(obj)
            listIdAlgo = getListIdAlgorithm(obj);
            nbModeMax = 6;
           
            allModeNbOperationPerS = {zeros(1+nbModeMax,+size(listIdAlgo,2))};
            allModeNbOperationPerS{1}(1,:) = listIdAlgo;
            allModeProcessingSpeed = {zeros(1+nbModeMax,+size(listIdAlgo,2))};
            allModeProcessingSpeed{1}(1,:) = listIdAlgo;
            allModeProcessingRate = {zeros(1+nbModeMax,+size(listIdAlgo,2))};
            allModeProcessingRate{1}(1,:) = listIdAlgo;
            allModeFrequency = {zeros(1+nbModeMax,+size(listIdAlgo,2))};
            allModeFrequency{1}(1,:) = listIdAlgo;
            allModePeriode = {zeros(1+nbModeMax,+size(listIdAlgo,2))};
            allModePeriode{1}(1,:) = listIdAlgo;
            it = 1;
            
            for idAlgo = listIdAlgo
                [nbModeAlgo, modeNbOperationPerS, modeProcessingSpeed,modeProcessingRate,modeFrequency,modePeriode] = getParamPerMode(obj.algorithmList{idAlgo});
                
                
                allModeNbOperationPerS{1}(2:end,it) = [modeNbOperationPerS  ones(1,nbModeMax-nbModeAlgo)*-1];
                allModeProcessingSpeed{1}(2:end,it) = [modeProcessingSpeed  ones(1,nbModeMax-nbModeAlgo)*-1];
                allModeProcessingRate{1}(2:end,it) = [modeProcessingRate  ones(1,nbModeMax-nbModeAlgo)*-1];
                allModeFrequency{1}(2:end,it) = [modeFrequency  ones(1,nbModeMax-nbModeAlgo)*-1];
                allModePeriode{1}(2:end,it) = [modePeriode  ones(1,nbModeMax-nbModeAlgo)*-1];

                it = it +1;
            end
        end
        
        %Param of mode
        
        function MIPS = getMIPS(obj)
            MIPS = obj.MIPSMode(obj.actualMode);
        end
        
        
        function power = getPower(obj)
            power = obj.powerMode(obj.actualMode);
        end
        
        % Internal function of preprocess
    end
end

