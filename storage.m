classdef storage < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type
        capacity
        inputRate
        outputRate
        readWriteSimultanous
        listPacket
        lastUpdateTime
        dataActual
    end
    
    methods
        function obj = storage(type, capacity, inputRate, outputRate, readWriteSimultanous )
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here

            obj.type = type;
            obj.capacity = capacity*10^6; % from [Mb] to [b]
            obj.inputRate = inputRate*10^3; % from [Mb/s] to [b/ms]
            obj.outputRate = outputRate*10^3; % from [Mb/s] to [b/ms]
            obj.readWriteSimultanous = readWriteSimultanous;
            obj.listPacket = []; % [data, finished, beingRead]
            obj.lastUpdateTime = 0;
            obj.dataActual = 0;
            
        end
        
        function [type, capacity] = getInfo(obj)
            type = obj.type;
            capacity = obj.capacity;
        end
        
        function getInfoReadable(obj)
            disp(['Memory type : ' obj.type ' & Capacity : ' obj.capacity ' Mbits' ]);
        end
        
        function capacity = getCapacity(obj)
            capacity = obj.capacity;
        end
        
        function inputRate = getInputRate(obj)
            inputRate = obj.inputRate;
        end
        
        function outputRate = getOutputRate(obj)
            outputRate = obj.outputRate;
        end
        
        function readWriteSimultanous = getReadWriteSimultanous(obj)
            readWriteSimultanous = obj.readWriteSimultanous;
        end
        
        function dataActual = getDataActual(obj)
%             if isempty(obj.listPacket)
%                 dataActual = 0;
%             else
%                 dataActual =  sum(obj.listPacket(:,1));
%             end
            dataActual = obj.dataActual;
        end
        
        function percentage = utilisationStorage(obj)
            percentage = 100.0*obj.dataActual/obj.capacity;
        end
        
        function [memeFull, previsouInNotDone, successOut, dataOut, endOutPacket, newOutPacket] = update(obj,dataIn,newInPacket, endInPacket,time,rateOut, readRequest)
            % write in meme
            %insideStorage = {obj,dataIn,newInPacket, endInPacket,time,rateOut, readRequest};
            [memeFull, previsouInNotDone] = addData(obj,dataIn,newInPacket, endInPacket);
            %inStorageInfo = {memeFull, previsouInNotDone};
            %obj.listPacket{:};
            
            % read in meme
            successOut = true;
            dataOut=0;
            endOutPacket=false;
            newOutPacket = false;
            if readRequest && (obj.readWriteSimultanous || dataIn == 0)
                [successOut, dataOut, endOutPacket, newOutPacket] = readPacket(obj,time,rateOut);
                %dataOutStorage = {successOut, dataOut, endOutPacket, newOutPacket};
            elseif readRequest && ~(obj.readWriteSimultanous || dataIn == 0)
                successOut = flase;        
            end
  
            obj.lastUpdateTime = time;
        end
        
        function [memeFull, previsouNotDone] = addData(obj,dataAmount,newPacket, endPacket)
            memeFull = false;
            previsouNotDone = false;
            if obj.dataActual+dataAmount > obj.capacity
                memeFull = true;
            else
                if newPacket % new packet of data
                    if ~isempty(obj.listPacket) && ~obj.listPacket(end,2) %if previous packet done
                        previsouNotDone = true;
                        obj.listPacket(end,2) = true;
                    end
                    if ~isempty(obj.listPacket) % if already one packet
                        obj.listPacket(end,2) = true; %flag packet finished (on previous)
                    end
                    obj.listPacket(end+1,:) = [0, false, false];
                end
                if dataAmount ~= 0 && obj.dataActual ~= 0 %prevent accessing non existing packet
                    %obj.listPacket{end}(1)
                    obj.listPacket(end,1) = obj.listPacket(end,1) + dataAmount;
                    obj.dataActual = obj.dataActual + dataAmount;
                    if endPacket
                        obj.listPacket(end,2) = true; %flag packet finished
                    end
                end
            end
        end
        
        function success = isOnePacketAvialable(obj)
            success = false;
            if obj.dataActual ~= 0
                success = true;
            end
%             if ~isempty(obj.listPacket)
%                 success = obj.listPacket(1,2); %if first packet  finsihed
%             end
        end
        
        function [success, data, endPacket, newPacket] = readPacket(obj,time,rate)
            data = 0;
            endPacket = false;
            newPacket =false;
            success = true;
            if obj.dataActual ~= 0
                if ~obj.listPacket(1,3) % if not beaing read
                    newPacket = true;
                    obj.listPacket(1,3) = true;
                end
                data = (time-obj.lastUpdateTime)*rate;
                if obj.listPacket(1,1)-data <= 0
                    data = obj.listPacket(1,1);
                    obj.listPacket(1,:) = []; %supress packet
                    endPacket = true;
                else
                    obj.listPacket(1,1) = obj.listPacket(1,1)-data;
                end
                obj.dataActual = obj.dataActual - data;
            else
                success = false;
            end
        end
    end
end

