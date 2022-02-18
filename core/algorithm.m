classdef algorithm < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        ASICimplemented
        FPGAoperationReductionFactor
        idMemoryLinked
        onFPGA
        nbMode
        actualMode
        listMode
        modeNbOperationPerS
        modeNbGateFPGA
        modeProcessingSpeed
        modeProcessingRate
        modeFrequency
        modePeriode
        
        lastSent
        packetFinish
    end
   
    methods
        function obj = algorithm(name, ASICimplemented, FPGAoperationReductionFactor,idMemoryLinked, listMode, modeNbOperationPerS, modeNbGateFPGA,modeProcessingSpeed,modeProcessingRate,  modeFrequency)
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here

            obj.name = name;
            obj.ASICimplemented= ASICimplemented;
            obj.FPGAoperationReductionFactor = FPGAoperationReductionFactor;
            obj.idMemoryLinked= idMemoryLinked;
            obj.listMode = listMode;
            obj.modeNbOperationPerS = modeNbOperationPerS;
            obj.modeNbGateFPGA = modeNbGateFPGA;
            obj.modeProcessingSpeed = modeProcessingSpeed; % [ms]
            obj.modeProcessingRate = modeProcessingRate*(10^3); % from [Mb/s] to [b/ms]
            obj.modeFrequency = 1.0*(10^-3)*modeFrequency; % from [Hz] to [mHz] 
            obj.modePeriode = 1.0./obj.modeFrequency;
            obj.nbMode = size(listMode,2);
            obj.actualMode = 1;
            obj.onFPGA = false;
            
            obj.lastSent = 0;
            obj.packetFinish = false;
        end
        
        function [name, ASICimplemented] = getInfo(obj)
            name = obj.name;
            ASICimplemented = obj.ASICimplemented;
        end
        
        function [nbMode, modeNbOperationPerS, modeProcessingSpeed,modeProcessingRate,modeFrequency,modePeriode] = getParamPerMode(obj)
            nbMode = obj.nbMode;
            modeNbOperationPerS= obj.modeNbOperationPerS;
            modeProcessingSpeed = obj.modeProcessingSpeed;
            modeProcessingRate = obj.modeProcessingRate;
            modeFrequency = obj.modeFrequency;
            modePeriode = obj.modePeriode;
        end
        
        function ASICimplemented= isASICimplemented(obj)
            ASICimplemented = obj.ASICimplemented;
        end
        
        function FPGAoperationReductionFactor = getFPGAoperationReductionFactor(obj)
            FPGAoperationReductionFactor = obj.FPGAoperationReductionFactor;
        end
        
        function idMemoryLinked = getIdMemoryLinked(obj)
            idMemoryLinked = obj.idMemoryLinked;
        end
        
        function onFPGA = isOnFPGA(obj)
            onFPGA = obj.onFPGA;
        end
        
        function success = setOnFPGA(obj)
            if obj.onFPGA
                success = false;
            else
                obj.onFPGA = true;
                success = true;
            end
        end
        
        function success = removeOnFPGA(obj)
            if ~obj.onFPGA
                success = false;
            else
                obj.onFPGA = false;
                success = true;
            end
        end
        
        
        function getInfoReadable(obj)
            disp(['Algorithm name : ' obj.name ' & ASIC implemented : ' num2str(obj.ASICimplemented) ]);
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
        
        function idMode = getActualModeId(obj)
            idMode = obj.actualMode;
        end
        
        function getActualModeReadable(obj)
            idMode = obj.actualMode;
            disp(['Mode id : ' num2str(idMode) ' & mode name : ' obj.listMode{idMode}]);               
        end
        
        function nbOperationPerS = getNbOperationPerS(obj)
            if obj.onFPGA
                nbOperationPerS = obj.modeNbOperationPerS(obj.actualMode)/(obj.FPGAoperationReductionFactor);
            else
                nbOperationPerS = obj.modeNbOperationPerS(obj.actualMode);
            end
        end
        
        function nbGateFPGA = getNbGateFPGA(obj)
            nbGateFPGA= obj.modeNbGateFPGA(obj.actualMode);
        end
        
        function processingSpeed = getProcessingSpeed(obj)
            if obj.onFPGA
                processingSpeed = obj.modeProcessingSpeed(obj.actualMode)/obj.FPGAoperationReductionFactor;
            else
                processingSpeed = obj.modeProcessingSpeed(obj.actualMode);
            end
        end
        
        function processingRate = getProcessingRate(obj)
            processingRate = obj.modeProcessingRate(obj.actualMode);
        end
        
        function frequency = getFrequency(obj)
            frequency = obj.modeFrequency(obj.actualMode);
        end
        
        function periode = getPeriode(obj)
            periode = obj.modePeriode(obj.actualMode);
        end
        
        function  requested = requestDataIn(obj,timeStep)
            requested = false;
            if 1.0*(timeStep-obj.lastSent) >= getPeriode(obj) % time between in miliseconds
                obj.lastSent = timeStep;
                requested = true;
                obj.packetFinish = false;
            end
            if ~obj.packetFinish
                requested = true;
            end
        end
        
        function setPacketInFinishReading(obj, finish)
            if finish
                obj.packetFinish = true;
            end
        end
    end
end

