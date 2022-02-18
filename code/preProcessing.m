classdef preProcessing < handle
    %SENSOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type
        storageIn
        storageOut
        nbMode
        actualMode
        desiredMode
        listMode
        modeCompressionFactor
        modeCompressionRate
        modeCompressionLag
        modePower
        modeAccuaracyLoss
        listSubPacket
        idLineOut
    end
    
    methods
        function obj = preProcessing(fileInfo,type, storageIn, storageOut, listMode,modeCompressionFactor, modeCompressionRate,modeCompressionLag, modePower, modeAccuaracyLoss )
            %SENSOR Construct an instance of this class
            %   Detailed explanation goes here
            if nargin == 1
                DOMnode = xmlread(fileInfo);
                xRoot = DOMnode.getDocumentElement;
                if xRoot.getTagName ~= 'preProcessing'
                    return;
                end

                % type
               typeChild = xRoot.getElementsByTagName('type');
                if typeChild.getLength ~= 0
                    obj.type = char(typeChild.item(0).getTextContent);
                end
                
                %storageIn
                storageChild = xRoot.getElementsByTagName('storageIn');
                if storageChild.getLength ~= 0
                    oneChild = storageChild.item(0);
                    %storageType
                    storageType='';
                    storageTypeChild = oneChild.getElementsByTagName('type');
                    if storageTypeChild.getLength ~= 0
                        storageType = char(storageTypeChild.item(0).getTextContent);
                    end
                    %capacity 
                    capacity = 0;
                    storageCapacityChild = oneChild.getElementsByTagName('capacity');
                    if storageCapacityChild.getLength ~= 0
                        capacity = str2double(storageCapacityChild.item(0).getTextContent);
                    end
                    %inputRate
                    inputRate = 0;
                    storageInputRateChild = oneChild.getElementsByTagName('inputRate');
                    if storageInputRateChild.getLength ~= 0
                        inputRate = str2double(storageInputRateChild.item(0).getTextContent);
                    end
                    % outputRate
                    outputRate = 0;
                    storageOutputRateeChild = oneChild.getElementsByTagName('outputRate');
                    if storageOutputRateeChild.getLength ~= 0
                        outputRate = str2double(storageOutputRateeChild.item(0).getTextContent);
                    end
                    % readWriteSimultanous
                    readWriteSimultanous = false;
                    storageReadWriteSimultanousChild = oneChild.getElementsByTagName('readWriteSimultanous');
                    if storageReadWriteSimultanousChild.getLength ~= 0
                        readWriteSimultanousTxt = char(storageReadWriteSimultanousChild.item(0).getTextContent);
                        if string(readWriteSimultanousTxt) == "true"
                            readWriteSimultanous = true;
                        end
                    end
                    
                    obj.storageIn = storage(storageType, capacity, inputRate, outputRate, readWriteSimultanous);
                end
                
                %storageOut
                storageChild = xRoot.getElementsByTagName('storageOut');
                if storageChild.getLength ~= 0
                    oneChild = storageChild.item(0);
                    %storageType
                    storageType='';
                    storageTypeChild = oneChild.getElementsByTagName('type');
                    if storageTypeChild.getLength ~= 0
                        storageType = char(storageTypeChild.item(0).getTextContent);
                    end
                    %capacity 
                    capacity = 0;
                    storageCapacityChild = oneChild.getElementsByTagName('capacity');
                    if storageCapacityChild.getLength ~= 0
                        capacity = str2double(storageCapacityChild.item(0).getTextContent);
                    end
                    %inputRate
                    inputRate = 0;
                    storageInputRateChild = oneChild.getElementsByTagName('inputRate');
                    if storageInputRateChild.getLength ~= 0
                        inputRate = str2double(storageInputRateChild.item(0).getTextContent);
                    end
                    % outputRate
                    outputRate = 0;
                    storageOutputRateeChild = oneChild.getElementsByTagName('outputRate');
                    if storageOutputRateeChild.getLength ~= 0
                        outputRate = str2double(storageOutputRateeChild.item(0).getTextContent);
                    end
                    % readWriteSimultanous
                    readWriteSimultanous = false;
                    storageReadWriteSimultanousChild = oneChild.getElementsByTagName('readWriteSimultanous');
                    if storageReadWriteSimultanousChild.getLength ~= 0
                        readWriteSimultanousTxt = char(storageReadWriteSimultanousChild.item(0).getTextContent);
                        if string(readWriteSimultanousTxt) == "true"
                            readWriteSimultanous = true;
                        end
                    end
                    
                    obj.storageOut = storage(storageType, capacity, inputRate, outputRate, readWriteSimultanous);
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
                    modeCompressionFactor=zeros(1,maxNbItem);
                    modeCompressionRate=zeros(1,maxNbItem);
                    modeCompressionLag=zeros(1,maxNbItem);
                    modePower=zeros(1,maxNbItem);
                    modeAccuaracyLoss=zeros(1,maxNbItem);
                    for i = 1:2:nbChild-1
                        oneMode=oneChild.item(i);
                        %modeInfo = oneMode.getChildNodes;
                        idMode = str2double(oneMode.getAttribute('id'));
                        
                        nameModeNode = oneMode.getElementsByTagName('name');
                        if nameModeNode.getLength ~= 0
                            listMode{idMode}=char(nameModeNode.item(0).getTextContent);
                        end
                        
                        modeCompressionFactorNode = oneMode.getElementsByTagName('compressionFactor');
                        if modeCompressionFactorNode.getLength ~= 0
                            modeCompressionFactor(idMode)=str2double(modeCompressionFactorNode.item(0).getTextContent);
                        end
                        
                        modeCompressionRateNode = oneMode.getElementsByTagName('compressionRate');
                        if modeCompressionRateNode.getLength ~= 0
                            modeCompressionRate(idMode)=str2double(modeCompressionRateNode.item(0).getTextContent);
                        end
                        
                        
                        modeCompressionLagNode = oneMode.getElementsByTagName('lagCompression');
                        if modeCompressionLagNode.getLength ~= 0
                            modeCompressionLag(idMode)=str2double(modeCompressionLagNode.item(0).getTextContent);
                        end
                        
                        modePowerNode = oneMode.getElementsByTagName('power');
                        if modePowerNode.getLength ~= 0
                            modePower(idMode)=str2double(modePowerNode.item(0).getTextContent);
                        end
                        
                        modeAccuaracyLossNode = oneMode.getElementsByTagName('power');
                        if modeAccuaracyLossNode.getLength ~= 0
                            modeAccuaracyLoss(idMode)=str2double(modeAccuaracyLossNode.item(0).getTextContent);
                        end
                    end
                end
            else
                obj.type = type;
                obj.storageIn = storageIn;
                obj.storageOut = storageOut;
                obj.actualMode = 1;
            end
        
            obj.listMode = listMode;
            obj.modeCompressionFactor = modeCompressionFactor;
            obj.modeCompressionRate = modeCompressionRate*(10^3); % from [Mb/s] to [b/ms]
            obj.modeCompressionLag = modeCompressionLag/(10^3); % from [us] to [ms] 
            obj.modePower = modePower/(10^3); % from [mW] to [W]
            obj.modeAccuaracyLoss = modeAccuaracyLoss;
            obj.nbMode = size(listMode,2);
            obj.listSubPacket = {}; % data,time, newPacket, EndPacket
            obj.idLineOut = 0;
            obj.desiredMode = obj.actualMode;
            
        end
        
        function [name, type] = getInfo(obj)
            type = obj.type;
            name = 'Pre-Processing unit';
        end
        
        function [nbMode, modeCompressionFactor, modeCompressionRate,modeCompressionLag, modePower, modeAccuaracyLoss] = getParamPerMode(obj)
            nbMode = obj.nbMode;
            modeCompressionFactor= obj.modeCompressionFactor;
            modeCompressionRate = obj.modeCompressionRate;
            modeCompressionLag = obj.modeCompressionLag;
            modePower = obj.modePower;
            modeAccuaracyLoss = obj.modeAccuaracyLoss;
        end
        
        function setIdLineOut(obj,id)
            obj.idLineOut = id;
        end
        
        function id = getIdLineOut(obj)
            id = obj.idLineOut;
        end
        
        function getInfoReadable(obj)
            disp(['PreProcessing type : ' obj.type]);
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
            idMode = obj.desiredMode;
            nameMode = obj.listMode{idMode};
        end
        
        function getActualModeReadable(obj)
            idMode = obj.desiredMode;
            disp(['Mode id : ' num2str(idMode) ' & mode name : ' obj.listMode{idMode}]);               
        end
        
        function storageIn = getStorageIn(obj)
            storageIn = obj.storageIn;
        end
        
        function storageOut = getStorageOut(obj)
            storageOut = obj.storageOut;
        end
        
        function compressionFactor = getCompressionFactor(obj)
            compressionFactor = obj.modeCompressionFactor(obj.actualMode);
        end
        
        function compressionRate = getCompressionRate(obj)
            compressionRate = obj.modeCompressionRate(obj.actualMode);
        end
        
        function lagCompression = getLagCompression(obj)
            lagCompression = obj.modeCompressionLag(obj.actualMode);
        end
        
        function power = getPower(obj)
            power = obj.modePower(obj.actualMode);% + getPower(obj.storageIn) + getPower(obj.storageOut);
        end
        
        function accuaracyLoss = getAccuaracyLoss(obj)
            accuaracyLoss = obj.modeAccuaracyLoss(obj.actualMode);
        end
        
        function [memeFullStIn,successStIn, memeFullStOut, successStOut, dataOutStOut, endOutPacketStOut, newOutPacketStOut ]= update(obj,timeStep,dataIn,newInPacketLine, EndInPacketLine, outRate)   
            if EndInPacketLine
                obj.actualMode = obj.desiredMode;
            end
            
            % memory read All the the time
            %inPrePro = {obj,timeStep,dataIn,newInPacketLine, EndInPacketLine, outRate};
            %toStorage = {obj.storageIn,dataIn,newInPacketLine, EndInPacketLine,timeStep,getCompressionRate(obj),true};
            [memeFullStIn, previsouInNotDoneStIn, successStIn, dataOutStIn, endOutPacketStIn, newOutPacketStIn] = update(obj.storageIn,dataIn,newInPacketLine, EndInPacketLine,timeStep,getCompressionRate(obj),true);
            %{memeFullStIn, previsouInNotDoneStIn, successStIn, dataOutStIn, endOutPacketStIn, newOutPacketStIn};
            %read data from meme and compress it for new mem
            % compression is a "buffer"
            
            [dataOutCompression, newOutPacketCompression, EndOutPacketCompression] = subPacketManagement(obj,timeStep, dataOutStIn/getCompressionFactor(obj),newOutPacketStIn, endOutPacketStIn);
            [memeFullStOut, previsouInNotDoneStOut, successStOut, dataOutStOut, endOutPacketStOut, newOutPacketStOut] = update(obj.storageOut,dataOutCompression,newOutPacketCompression, EndOutPacketCompression,timeStep,outRate,true);
        end
        
        function [dataOut, newOutPacket, EndOutPacket] = subPacketManagement(obj,time, dataIn,newInPacket, EndInPacket)
            dataOut = 0;
            newOutPacket = false;
            EndOutPacket = false;
            if ~(newInPacket && EndInPacket) % probably error
                if dataIn ~= 0.0
                    obj.listSubPacket{end+1} =  [dataIn, time, newInPacket, EndInPacket];
                end
                if ~isempty(obj.listSubPacket)
                    if time-obj.listSubPacket{1}(2)>getLagCompression(obj)
                        dataOut = obj.listSubPacket{1}(1);
                        newOutPacket = obj.listSubPacket{1}(3);
                        EndOutPacket = obj.listSubPacket{1}(4);
                        obj.listSubPacket(1) = []; % suppress subpacket
                    end
                end   
            end
        end
        
    end
end

