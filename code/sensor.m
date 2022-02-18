classdef sensor < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        type
        nbMode
        actualMode
        desiredMode
        listMode
        modePower
        modePackSize
        modeRatePacket
        modeAccuracySensor
        dataTransmit
        lastTransmission
        lastStartPacket
        transmissionFinished
    end
    
    methods
        function obj = sensor(fileInfo,name,type, listMode,modePower, modePackSize, modeRatePacket, modeAccuracySensor )
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 1  % if load from document
                DOMnode = xmlread(fileInfo);
                xRoot = DOMnode.getDocumentElement;
                if xRoot.getTagName ~= 'sensor'
                    return;
                end

                % name
                nameChild = xRoot.getElementsByTagName('name');
                if nameChild.getLength ~= 0
                    obj.name = char(nameChild.item(0).getTextContent);
                end
                
                % type
                typeChild = xRoot.getElementsByTagName('type');
                if typeChild.getLength ~= 0
                    obj.type = char(typeChild.item(0).getTextContent);
                end
                
                % type
                initialModeChild = xRoot.getElementsByTagName('initalMode');
                if initialModeChild.getLength ~= 0
                    obj.actualMode = str2double(initialModeChild.item(0).getTextContent);
                end
                
                modesChild = xRoot.getElementsByTagName('modes');
                if modesChild.getLength ~= 0
                    oneChild = modesChild.item(0);
                    nbChild = oneChild.getLength;
                    maxNbItem = ceil((nbChild-1)/2);
                    listMode =cell(1,maxNbItem);
                    modePower=zeros(1,maxNbItem);
                    modePackSize=zeros(1,maxNbItem);
                    modeRatePacket=zeros(1,maxNbItem);
                    modeAccuracySensor=zeros(1,maxNbItem);
                    for i = 1:2:nbChild-1
                        oneMode=oneChild.item(i);
                        %modeInfo = oneMode.getChildNodes;
                        idMode = str2double(oneMode.getAttribute('id'));
                        
                        nameModeNode = oneMode.getElementsByTagName('name');
                        if nameModeNode.getLength ~= 0
                            listMode{idMode}=char(nameModeNode.item(0).getTextContent);
                        end
                        
                        powerModeNode = oneMode.getElementsByTagName('power');
                        if powerModeNode.getLength ~= 0
                            modePower(idMode)=str2double(powerModeNode.item(0).getTextContent);
                        end
                        
                        packetSizeModeNode = oneMode.getElementsByTagName('packetSize');
                        if packetSizeModeNode.getLength ~= 0
                            modePackSize(idMode)=str2double(packetSizeModeNode.item(0).getTextContent);
                        end
                        
                        ratePacketModeNode = oneMode.getElementsByTagName('ratePacket');
                        if ratePacketModeNode.getLength ~= 0
                            modeRatePacket(idMode)=str2double(ratePacketModeNode.item(0).getTextContent);
                        end
                        
                        modeAccuracySensorNode = oneMode.getElementsByTagName('accuracySensor');
                        if modeAccuracySensorNode.getLength ~= 0
                            modeAccuracySensor(idMode)=str2double(modeAccuracySensorNode.item(0).getTextContent);
                        end
                    end
                end
            else
                obj.name = name;
                obj.type = type;
                obj.actualMode = 1;
            end
            
            obj.listMode = listMode;
            obj.modePower = modePower/(10^3); % from [mW] to [W]
            obj.modePackSize = modePackSize*10^6; % from [Mbits] in [bits]
            obj.modeRatePacket = modeRatePacket; % in [ms]
            obj.modeAccuracySensor = modeAccuracySensor; 
            obj.nbMode = size(listMode,2);
            obj.dataTransmit = 0.0;
            obj.lastTransmission = 0;
            obj.transmissionFinished = true;
            obj.desiredMode = obj.actualMode;
            obj.lastStartPacket = 0;
            
        end
        
        function [name, type] = getInfo(obj)
            name = obj.name;
            type = obj.type;
        end
        
        function [nbMode, modePower, modePackSize,modeRatePacket, modeAccuracySensor] = getParamPerMode(obj)
            nbMode = obj.nbMode;
            modePower= obj.modePower;
            modePackSize = obj.modePackSize;
            modeRatePacket = obj.modeRatePacket;
            modeAccuracySensor = obj.modeAccuracySensor;
        end
        
        function getInfoReadable(obj)
            disp(['Sensor name : ' obj.name ' & Sensor type : ' obj.type ]);
        end
        
        function success = setModeId(obj,idMode)
            if idMode >= 1 && idMode <= obj.nbMode
                obj.desiredMode = idMode;
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
            idMode = obj.desiredMode;%obj.actualMode;
            nameMode = obj.listMode{idMode};
        end
        
        function getActualModeReadable(obj)
            idMode = obj.desiredMode;%obj.actualMode;
            disp(['Mode id : ' num2str(idMode) ' & mode name : ' obj.listMode{idMode}]);               
        end
        
        function power = getPower(obj)
            power = obj.modePower(obj.actualMode);
        end
        
        function packetSize = getPacketSize(obj)
            packetSize = obj.modePackSize(obj.actualMode);
        end
        
        function ratePacket = getRatePacket(obj)
            ratePacket = obj.modeRatePacket(obj.actualMode);
        end
        
        function accuracySensor = getAccuracySensor(obj)
            accuracySensor = obj.modeAccuracySensor(obj.actualMode);
        end 
        
        function dataOutAverage = getDataOutAverage(obj)
            dataOutAverage = getPacketSize(obj)/(getRatePacket(obj)/1000);
        end
        
        function [success, dataSend, newTransmission, endTransmission] = update(obj,time, rateSending)
            endTransmission = false;
            newTransmission = false;
            dataSend = 0;
            success = true;
            %if mod(time,getRatePacket(obj)) <
            %mod(obj.lastTransmission,getRatePacket(obj)) % in case step
            %higher and need to strat a new transmission (WRONG !)
            if (time-obj.lastStartPacket) >=  getRatePacket(obj) % If time between the last packet and now is bigger than the refresh rate of packets
                if ~obj.transmissionFinished
                    success = false; % errorprevious transmission not finished
                end
                newTransmission = true;
                obj.lastStartPacket = time;
                obj.transmissionFinished = false;
                dataSend = (time-obj.lastTransmission)*(rateSending);
                obj.dataTransmit =  dataSend; % new packet
                
            elseif ~obj.transmissionFinished % if transmission not finished then data beeing transmitted
                if obj.dataTransmit >= getPacketSize(obj) % if already transmit all the data (normally never call)
                    obj.transmissionFinished = true; % end transmission
                    obj.actualMode = obj.desiredMode; % need if a new mode is required
                    endTransmission = true; %why not ?
                else % if data still need to be transmist
                    dataSend = (time-obj.lastTransmission)*(rateSending); %microseconds
                    if obj.dataTransmit+dataSend >= getPacketSize(obj) % check that not to much data is sent
                        dataSend = getPacketSize(obj)-obj.dataTransmit;
                        endTransmission = true;
                        obj.transmissionFinished = true;
                        obj.actualMode = obj.desiredMode; % need if a new mode is required
                    end
                    obj.dataTransmit = obj.dataTransmit + dataSend; % rember how much data was send
                end
            end
            obj.lastTransmission = time;
        end
        
    end
end

