classdef lineConnection < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type
        rate
        powerLossPM
        lagPM
        length
        connectToOBC
        idOBCMem
        sensorConnID
        preProcId        
        powerLoss
        lag
        listSubPacket
        
        newPacket_prev
        newPacket_act
        endPacket_act
        
        packetCount
    end
    
    methods
        function obj = lineConnection(fileInfoLine, length,connectToOBC, idOBCMem, sensorConnID, preProcId ,type, rate,powerLossPM, lagPM )
            
            import java.util.LinkedList
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 6 % if load from document
                DOMnode = xmlread(fileInfoLine);
                xRoot = DOMnode.getDocumentElement;
                if xRoot.getTagName ~= 'line'
                    return;
                end

                % type
                typeChild = xRoot.getElementsByTagName('type');
                if typeChild.getLength ~= 0
                    obj.type = char(typeChild.item(0).getTextContent);
                end
                
                % rate
                rateChild = xRoot.getElementsByTagName('rate');
                if rateChild.getLength ~= 0
                    obj.rate = str2double(rateChild.item(0).getTextContent);
                end
                
                % powerLossPM
                powerLossPMChild = xRoot.getElementsByTagName('powerLossPM');
                if powerLossPMChild.getLength ~= 0
                    obj.powerLossPM = str2double(powerLossPMChild.item(0).getTextContent);
                end
                
                % lag per meter
                lagPMChild = xRoot.getElementsByTagName('lagPM');
                if lagPMChild.getLength ~= 0
                    obj.lagPM = str2double(lagPMChild.item(0).getTextContent);
                end
            else
                obj.type = type;
                obj.rate = rate;
                obj.powerLossPM = powerLossPM;
                obj.lagPM =lagPM;
            end
            
            obj.rate = obj.rate*10^3; % from [Mb/s] to [b/ms]
            obj.length = length;
            obj.connectToOBC = connectToOBC;
            obj.idOBCMem = idOBCMem;
            obj.sensorConnID = sensorConnID;
            obj.preProcId = preProcId;
            obj.powerLoss = obj.powerLossPM*obj.length/10^3; % from [mW/m] to [W/m]
            obj.lag = obj.lagPM*obj.length/10^3;  % from [us] to [ms]
            obj.listSubPacket = LinkedList(); % data,time, newPacket, EndPacket % LinkedList form java
            obj.newPacket_prev = 0;
            obj.newPacket_act = 0;
            obj.endPacket_act = 0;
            obj.packetCount = 0;
%             obj.statusTransmitting = false;
%             obj.dataToTransmit = 0.0;
%             obj.dataLeft = 0.0;
%             obj.lastUpDateTime = 0;
%             obj.timeFinishTransmitting= 0;
        end
        
        function [type, sensorConnID] = getInfo(obj)
            type = obj.type;
            sensorConnID = obj.sensorConnID;
        end
        
        function getInfoReadable(obj)
            disp(['Line type : ' obj.type ' & Sensor Connected id : ' num2str(obj.sensorConnID) ]);
        end
        
        function bool = isConnectToOBC(obj)
            bool = obj.connectToOBC;
        end
        
        function id = getIdOBCMem(obj)
            id = obj.idOBCMem;
        end
        
        function id = getSensorId(obj)
            id = obj.sensorConnID;
        end
        
        function success = hasSensorConnected(obj)
            success = ~isempty(obj.sensorConnID);
        end
        
        function id = getPreProcId(obj)
            id = obj.preProcId;
        end
        
        function length = getLength(obj)
            length = obj.length;
        end        
        
        function powerLoss = getPowerLoss(obj)
            powerLoss = obj.powerLoss;
        end
        
        function lag = getLag(obj)
            lag = obj.lag;
        end
        
        function rate = getRate(obj)
            rate = obj.rate;
        end
        
        function busynessLine=  getBusynessLine(obj)
            intPacket = obj.newPacket_act - obj.newPacket_prev;
            if intPacket <= 0
                busynessLine= 0;
            elseif obj.endPacket_act >= obj.newPacket_act
                busynessLine = 100.0*(obj.endPacket_act - obj.newPacket_act)/intPacket;
            else
                busynessLine = 100.0*(obj.endPacket_act - obj.newPacket_prev)/intPacket;
            end
            
            if busynessLine < 0.0
                busynessLine = 0.0;
            end
            
        end
        

        function [dataOut, lineBusy,newOutPacket, EndOutPacket] = update(obj,time, dataIn,newInPacket, EndInPacket)
            dataOut = 0;
            lineBusy = false;
            newOutPacket = false;
            EndOutPacket = false;
            %if ~((newInPacket &&  EndInPacket) || (dataIn==0 && (newInPacket || EndInPacket)) ) % if both prpobably an error
                if dataIn ~= 0.0 % if data received
                    obj.listSubPacket.add([dataIn, time, newInPacket, EndInPacket]); % store it (data on the line)
                    obj.packetCount = obj.packetCount +1;
                end
                
                if obj.packetCount ~= 0 % if data on the line
                    packetOut = obj.listSubPacket.peekFirst();
                    lineBusy = true;
                    if time-packetOut(2)>=obj.lag % if data at the end of the line
                        
                        dataOut = packetOut(1);
                        newOutPacket = packetOut(3);
                        EndOutPacket = packetOut(4);
                        obj.listSubPacket.remove(); % suppress packet$
                        obj.packetCount = obj.packetCount -1;
                    end
                end 

                if newInPacket
                    obj.newPacket_prev = obj.newPacket_act;
                    obj.newPacket_act = time;
                end

                if EndInPacket
                    obj.endPacket_act = time;
                end
            %end
        end
        
        function nbSubPacketLeft = getNbSubPacketLeft(obj)
            nbSubPacketLeft = obj.packetCount;
        end
        

%         
%         %% other stuff
%         function status = statusBusy(obj)
%             status = obj.statusTransmitting;
%         end
% 
%         
%         function success = setDataToTransmit(obj, dataQty)
%             if obj.dataLeft ~= 0
%                 success = false;
%             else
%                 obj.dataLeft = dataQty;
%                 obj.dataToTransmit = dataQty;
%                 success = true;
%             end
%         end
%         
%         function success = startTransmission(obj, time)
%             if obj.dataLeft == 0.0 
%                 success = false;
%             elseif obj.statusTransmitting == true && obj.lag > (time - obj.timeFinishTransmitting)
%                 success = false;
%             else
%                 obj.statusTransmitting = true;
%                 obj.lastUpDateTime = time;
%                 obj.timeFinishTransmitting =0;
%                 success = true;
%             end
%         end
%         
%         function update(obj, time)
%             if ~obj.statusTransmitting
%                 % nothing
%             elseif obj.dataLeft == 0.0 && obj.lag <= (time -obj. timeFinishTransmitting)
%                 obj.statusTransmitting = false;
%             elseif obj.dataLeft ~= 0.0
%                 obj.dataLeft = obj.dataLeft - obj.rate*(time - obj.lastUpDateTime);
%                 %obj.dataLeft
%                 if obj.dataLeft < 0.0
%                     obj.dataLeft = 0.0;
%                 end
%                 obj.timeFinishTransmitting = time;
%             else
%                 % ? 
%             end
%             obj.lastUpDateTime = time;
%         end
%         
%         function percentage = progress(obj)
%             if obj.dataToTransmit ~= 0
%                 percentage = 100.0*(obj.dataToTransmit-obj.dataLeft)/obj.dataToTransmit;
%             else
%                 percentage = -1;
%             end
%         end
        
            
        
        % line operation at given time !
        % data to transmit left
        %request data from sensor
    end
end

