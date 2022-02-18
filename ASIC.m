classdef ASIC < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        algorithmIdImpl
        power
        nbIO
        processingSpeed
        processingRate
    end
   
    methods
        function obj = ASIC(algorithmIdImpl, power, nbIO, processingSpeed, processingRate)
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here

            obj.algorithmIdImpl = algorithmIdImpl;% from [mW] to [W]
            obj.power= power/(10^3);  % from [mW] to [W]
            obj.nbIO = nbIO;
            obj.processingSpeed = processingSpeed; % [ms]
            obj.processingRate = processingRate*(10^3); % from [Mb/s] to [b/ms]
        end
        
        function algorithmIdImpl = getInfo(obj)
            algorithmIdImpl = obj.algorithmIdImpl;
        end
        
        function getInfoReadable(obj)
            disp(['Algorithm ID : ' num2str(obj.algorithmIdImpl)]);
        end
        
        function algorithmIdImpl = getAlgorithmIdImpl(obj)
             algorithmIdImpl = obj.algorithmIdImpl;
        end
        
        function power= getPower(obj)
            power = obj.power;
        end
        
        function nbIO = getNbIO(obj)
            nbIO = obj.nbIO;
        end
        
        function processingSpeed = getProcessingSpeed(obj)
            processingSpeed = obj.processingSpeed;
        end
        
        function processingRate = getProcessingRate(obj)
            processingRate = obj.processingRate;
        end
    end
end

