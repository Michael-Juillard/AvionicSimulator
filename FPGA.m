classdef FPGA < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nbGates
        power
        nbIO
        reprogramable
        reprogramTime
        idAlgorithm
        nbGatesUsed
    end
   
    methods
        function obj = FPGA(nbGates, power, nbIO, reprogramable, reprogramTime, initalAlgo)
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here

            obj.nbGates = nbGates;
            obj.power= power/(10^3);  % from [mW] to [W]
            obj.nbIO = nbIO;
            obj.reprogramable = reprogramable;
            obj.reprogramTime = reprogramTime; % [ms]
            obj.idAlgorithm = initalAlgo;
            obj.nbGatesUsed = 0;
        end
        
        function [nbGates, reprogramable] = getInfo(obj)
            nbGates = obj.nbGates;
            reprogramable = obj.reprogramable;
        end
        
        function getInfoReadable(obj)
            disp(['Number of gate : ' num2str(obj.nbGates) ' & Reprogramable : ' num2str(obj.reprogramable) ]);
        end
        
        function power= getPower(obj)
            power = obj.power;
        end
        
        function nbIO = getNbIO(obj)
            nbIO = obj.nbIO;
        end
        
        function reprogramable = getReprogramable(obj)
            reprogramable = obj.reprogramable;
        end
        
        function reprogramTime = getReprogramTime(obj)
            reprogramTime = obj.reprogramTime;
        end
        
        function idAlgorithm = getIdsAlgorithm(obj)
            idAlgorithm = obj.idAlgorithm;
        end
        
        function success = isAlgoImplemented(obj,id)
            success = false;
            if sum(obj.idAlgorithm(:)==id) == 1
                success = true;
            end
        end
        
        function success = addAlgo(obj,id, nbGatesAlgo)
            success = false;
            if sum(obj.idAlgorithm(:)==id) == 0 && obj.nbGatesUsed+nbGatesAlgo <= obj.nbGates && obj.reprogramable
                success = true;
                obj.idAlgorithm = [obj.idAlgorithm; id];
                obj.nbGatesUsed =  obj.nbGatesUsed+nbGatesAlgo;
            end
        end
        
        function success = removeAlgo(obj,id, nbGatesAlgo)
            success = false;
            if sum(obj.idAlgorithm(:)==id) == 1 && obj.reprogramable
                success = true;
                obj.idAlgorithm(obj.idAlgorithm(:)==id) = [];
                obj.nbGatesUsed =  obj.nbGatesUsed-nbGatesAlgo;
            end
        end
        
        function percentageGate = FPGAUsage(obj)
            percentageGate = 100*obj.nbGatesUsed/obj.nbGates;
        end
        
        

    end
end

