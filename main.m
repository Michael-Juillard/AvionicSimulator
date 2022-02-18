function main(varargin)
% main(wantToSave, missionProfileName, scenario, it, testFunc)

%% To Do
% -time scale 
% gate & IO use per FPGA


%% Input to sim
Defaults = {0,'avionic2_s2_dyn','scenario2','test_profile2',1};
Defaults(1:nargin) = varargin;

wantToSave = Defaults{1};
missionProfileName=Defaults{2};
scenario = Defaults{3};
it = Defaults{4};
testFunc = Defaults{5};


%% Simulator main loop
set(groot, 'DefaultAxesFontSize', 14)
set(groot, 'DefaultLineLineWidth', 1.5)
close all


%% Load mission profile
oneProfile = missionProfile(['missionProfile/' missionProfileName '.xml']);
disp(['Mission Profile loaded for ' missionProfileName '_' scenario '-' it] )
getInfoReadable(oneProfile);

%% Load the power and hardware profile sepcified in the missionProfile

scenarioPower = scenario;
%scenarioPower = 'scenario3';
if loadPowerProfile(oneProfile,scenarioPower)
    disp(['Power profile ' scenario ' for ' getPowerProfileFile(oneProfile) ' load successfully.'])
else
    disp(['Power profile ' scenario ' for ' getPowerProfileFile(oneProfile) ' FAILED.'])
    return;
end

if getDynamicSim(oneProfile)
    disp('Dynamic simulation is set. No hardware usage profile requiered.')
else
    if loadHardwareProfile(oneProfile,scenario)
        disp(['Hardware profile ' scenario ' for ' getHardwareUsageProfileFile(oneProfile) ' load successfully.'])
    else
        disp(['Hardware profile ' scenario ' for ' getHardwareUsageProfileFile(oneProfile) ' FAILED.'])
        return;
    end
end

failureCtrl = {{0,"",0,""}}; %time, type, HW id, description
infoSim = {{0,"",0,""}}; %time, type, HW id, description  

timeSim = getTimeSimulation(oneProfile); %mili seconds
if testFunc ~= 0 % if test function, run just a couple of iteration
    timeSim = 2*1000;%15*1000
    it = [it '_dummy'];
end
%timeSim = round(timeSim);
%timeSim = 15*1000;
interval =0.5;%0.5;%0.1;
nbPoint = round(timeSim/interval)-1;


listIdSensor = getListIdSensor(oneProfile);
listIdPrePro = getListIdPreProcessingUnit(oneProfile);
listIdLine = getListIdLineConnection(oneProfile);
listIdOBCMem = getListIdStorage(oneProfile);
listIdAlgo = getListIdAlgorithm(oneProfile);
listIdASIC = getListIdASIC(oneProfile);
listIdFPGA = getListIdFPGA(oneProfile);

powerConsumption = {zeros(7,nbPoint)}; %(timeStep, Sensor, prepro, OBC, ASIC, FPGA, OBCMem)
OBCMemUsage = {zeros(1+size(listIdOBCMem,2),nbPoint)};
sensorOutData = {zeros(1+size(listIdSensor,2),nbPoint)};
preProcOutData = {zeros(1+size(listIdPrePro,2),nbPoint)};
ressourcesUsage = {zeros(4,nbPoint)};%(timeStep, OBC, maxOBC, FPGA)
lineBusyness = {zeros(1+size(listIdLine,2),nbPoint)};
sensorsOutAverage = {zeros(1+size(listIdSensor,2),nbPoint)};

% Info for Optimizer 
if getDynamicSim(oneProfile)
    [nbModeMax, allModePower, allModePackSize,allModeRatePacket, allModeAccuracySensor] = getAllModeParamSensor(oneProfile)
    % [nbModeMax, allModeCompressionFactor, allModeCompressionRate,allModeCompressionLag,allModePower, allModeAccuaracyLoss] = getAllModeParamPrePro(oneProfile)
    [nbModeMax, allModeNbOperationPerS, allModeProcessingSpeed,allModeProcessingRate,allModeFrequency,allModePeriode] = getAllModeParamAlgo(oneProfile)
    [nbMode, MIPSMode, powerMode] = getParamPerModeOBC(oneProfile)
end

%Initialize algo in FPGA
for idFPGA = listIdFPGA
    idAlgo = getIdsAlgorithmFPGA(oneProfile,idFPGA);
    
    if idAlgo ~= 0
        %addAlgo(oneFPGA,1, getNbGateFPGA(oneAlgo)); dont care yet
        success = setOnFPGAAlgo(oneProfile,idAlgo);
    end
end

%% Simulation loop
tic; % time
iterationNumber =1;

startPoint = 0; % should be 0 !

initStep = startPoint+interval;
timeSim = timeSim + startPoint;
for timeStep = initStep:interval:timeSim % mili seconds
    
    if mod(timeStep,101) == 0
        disp([ missionProfileName '_' scenario '-' it ' at ' num2str(toc) ' seconds and progress '  num2str(100.0*(timeStep-startPoint)/(timeSim-startPoint)) ' %'])
    end
    %% Sensor Mode assignement 
    for idSensor = listIdSensor
        newMode = getActualModeHW(oneProfile, 1, idSensor, timeStep);
        if newMode == 0
            failureCtrl(end+1) = {{timeStep, "Sensor", idSensor, 'Fail to find profile'}};
        else
             [idMode, nameMode] = getActualModeSensor(oneProfile,idSensor);
             if idMode ~= newMode
                 if ~setModeIdSensor(oneProfile,idSensor,newMode)
                     failureCtrl(end+1) = {{timeStep, "Sensor", idSensor, ['Fail to load mode ' num2str(newMode)]}};
                 else
                     [newIdMode, newNameMode] = getActualModeSensor(oneProfile,idSensor);
                     infoSim(end+1) = {{timeStep, "Sensor", idSensor, ['Switch mode from ' nameMode '(' num2str(idMode) ') to ' newNameMode '(' num2str(newMode) ')'] }};
                 end
             end
        end
    end
    
    %% PreProcessing Mode assignement 
    for idPrePro = listIdPrePro
        newMode = getActualModeHW(oneProfile, 2, idPrePro, timeStep);
        if newMode == 0
            failureCtrl(end+1) = {{timeStep, "Preprocessing", idPrePro, {'Fail to find profile'}}};
        else
             [idMode, nameMode] = getActualModePrePro(oneProfile,idPrePro);
             if idMode ~= newMode
                 if ~setModeIdPrePro(oneProfile,idPrePro,newMode)
                     failureCtrl(end+1) = {{timeStep, "Preprocessing", idPrePro, ['Fail to load mode ' num2str(newMode)]}};
                 else
                     [newIdMode, newNameMode] = getActualModePrePro(oneProfile,idPrePro);
                     infoSim(end+1) = {{timeStep, "Preprocessing", idPrePro, ['Switch mode from ' nameMode '(' num2str(idMode) ') to ' newNameMode '(' num2str(newMode) ')'] }};
                 end
             end
        end
    end
    
    %% OBC Mode assignement
    newMode = getActualModeHW(oneProfile, 3, 1, timeStep);
    if newMode == 0
        failureCtrl(end+1) = {{timeStep, "OBC", 0, {'Fail to find profile'}}};
    else
         [idMode, nameMode] = getActualModeOBC(oneProfile);
         if idMode ~= newMode
             if ~setModeIdOBC(oneProfile,newMode)
                 failureCtrl(end+1) = {{timeStep, "OBC", 0, ['Fail to load mode ' num2str(newMode)]}};
             else
                 [newIdMode, newNameMode] = getActualModeOBC(oneProfile);
                 infoSim(end+1) = {{timeStep, "OBC", 0, ['Switch mode from ' nameMode '(' num2str(idMode) ') to ' newNameMode '(' num2str(newMode) ')'] }};
             end
         end
    end
    %% Algorithm Mode Management
    for idAlgo = listIdAlgo
        %Mode management
        newMode = getActualModeHW(oneProfile, 4, idAlgo, timeStep);
        if newMode == 0
            failureCtrl(end+1) = {{timeStep, "Algo", idAlgo, 'Fail to find profile'}};
        else
             
             idMode = getActualModeAlgoId(oneProfile,idAlgo);
             if idMode ~= newMode
                 if ~setModeIdAlgo(oneProfile,idAlgo,newMode)
                     failureCtrl(end+1) = {{timeStep, "Algo", idAlgo, ['Fail to load mode ' num2str(newMode)]}};
                 else
                     newIdMode = getActualModeAlgoId(oneProfile,idAlgo);
                     infoSim(end+1) = {{timeStep, "Algo", idAlgo, ['Switch mode from ' num2str(idMode) ' to '  num2str(newMode) ] }};
                 end
             end
        end
    end
    
    
    %% Data stream in architecture 
    powerConsumption{1}(1,iterationNumber) = timeStep;%powerConsumption(iterationNumber) = {[timeStep; 0;0;0; 0;0;0]};
    OBCMemUsage{1}(1,iterationNumber) = timeStep;%OBCMemUsage(iterationNumber) = {[timeStep;zeros(size(listIdOBCMem,2),1)]};
    sensorOutData{1}(1,iterationNumber) = timeStep;%sensorOutData(iterationNumber) = {[timeStep;zeros(size(listIdSensor,2),1)]};
    preProcOutData{1}(1,iterationNumber) = timeStep;%preProcOutData(iterationNumber) = {[timeStep;zeros(size(listIdPrePro,2),1)]};
    ressourcesUsage{1}(1,iterationNumber) = timeStep;%ressourcesUsage(iterationNumber) = {[timeStep;0;0;0]};
    lineBusyness{1}(1,iterationNumber) = timeStep;%lineBusyness(iterationNumber) = {[timeStep;zeros(size(listIdLine,2),1)]};
    sensorsOutAverage{1}(1,iterationNumber) = timeStep;%sensorsOutAverage(iterationNumber) = {[timeStep;zeros(size(listIdSensor,2),1)]};
    
    for idLine = listIdLine
        if ~isConnectToOBCLine(oneProfile,idLine) %if sensor connected to preprocess
            % Get hardware compoenent on the line
            idSensor = getSensorIdLine(oneProfile,idLine);
            idPrePro = getPreProcIdLine(oneProfile,idLine);

            powerConsumption{1}(2,iterationNumber) = powerConsumption{1}(2,iterationNumber) + getPowerSensor(oneProfile,idSensor);

            powerConsumption{1}(3,iterationNumber) = powerConsumption{1}(3) + getPowerPrePro(oneProfile,idPrePro);
            idLineToOBC = getIdLineOutPrePro(oneProfile,idPrePro);

            idOBCMem = getIdOBCMemLine(oneProfile,idLineToOBC);
            
            
            %emulated data stream 
            [success, dataSend, newTransmissionSave, endTransmissionSave] = updateSensor(oneProfile,idSensor,timeStep, getRateLine(oneProfile,idLine));
            sensorOutData{1}(idSensor+1,iterationNumber) = dataSend;
            sensorsOutAverage{1}(idSensor+1,iterationNumber) = getDataOutAverageSensor(oneProfile,idSensor);
%             if dataSend ~= 0
%                 dataSend
%             end
            [dataOut, lineBusy,newOutPacketLine, EndOutPacketLine] = updateLine(oneProfile,idLine,timeStep, dataSend,newTransmissionSave, endTransmissionSave);
            lineBusyness{1}(idLine+1,iterationNumber) = getBusynessLine(oneProfile,idLine);
%             if dataOut ~= 0
%                 dataOut
%             end
            %{onePrePro,timeStep,dataOut,newOutPacketLine, EndOutPacketLine, getRate(oneLineOut)};
            [memeFullStIn,successStIn, memeFullStOut, successStOut, dataOutStOut, endOutPacketStOut, newOutPacketStOut ]= updatePrePro(oneProfile,idPrePro,timeStep,dataOut,newOutPacketLine, EndOutPacketLine, getRateLine(oneProfile,idLineToOBC));
%             if idPrePro==1 && (dataOutStOut ~= 0 || endOutPacketStOut || newOutPacketStOut)
%                 outPrePro = {timeStep, memeFullStIn,successStIn, memeFullStOut, successStOut, dataOutStOut, endOutPacketStOut, newOutPacketStOut }
%             end
            preProcOutData{1}(idPrePro+1,iterationNumber) = dataOutStOut;
%             if dataOutStOut ~=0
%                 dataOutStOut
%             end
            [dataOut2, lineBusy2,newOutPacketLine2, EndOutPacketLine2] = updateLine(oneProfile,idLineToOBC,timeStep, dataOutStOut,newOutPacketStOut, endOutPacketStOut);
%             if dataOut2 ~= 0
%                 {timeStep, dataOut2, lineBusy2,newOutPacketLine2, EndOutPacketLine2}
%             end
            lineBusyness{1}(idLineToOBC+1,iterationNumber) = getBusynessLine(oneProfile,idLineToOBC);
            %getBusynessLine(oneProfile,idLineToOBC)
%             if dataOut2 ~=0
%                 dataOut2
%             end
            [OBCmemeFull, OBCprevisouNotDone] = addDataOBC(oneProfile,idOBCMem,dataOut2,newOutPacketLine2, EndOutPacketLine2);%OBC mem
        else
            if hasSensorConnectedLine(oneProfile,idLine) % if sensor connected directly to OBC. Prevent pre-process to be recompute
                % Get hardware component on the line
                idSensor = getSensorIdLine(oneProfile,idLine);

                powerConsumption{1}(2,iterationNumber) = powerConsumption{1}(2,iterationNumber) + getPowerSensor(oneProfile,idSensor);
                idOBCMem = getIdOBCMemLine(oneProfile,idLine);

                %emulated data stream 
                [success, dataSend, newTransmissionSave, endTransmissionSave] = updateSensor(oneProfile,idSensor,timeStep, getRateLine(oneProfile,idLine));
                sensorOutData{1}(idSensor+1,iterationNumber) = dataSend;
                sensorsOutAverage{1}(idSensor+1,iterationNumber) = getDataOutAverageSensor(oneProfile,idSensor);
                [dataOut, lineBusy,newOutPacketLine, EndOutPacketLine] = updateLine(oneProfile,idLine,timeStep, dataSend,newTransmissionSave, endTransmissionSave);
                lineBusyness{1}(idLine+1,iterationNumber) = getBusynessLine(oneProfile,idLine);
                [OBCmemeFull, OBCprevisouNotDone] = addDataOBC(oneProfile,idOBCMem,dataOut,newOutPacketLine, EndOutPacketLine); %OBC mem
            end
            %line from pre-processing to OBC are handle before
        end
        
        
    end
    
    
    %% Data mangement inside OBC
    listIdAlgoOnOBC = listIdAlgo;
    powerConsumption{1}(4,iterationNumber) = getPowerOBC(oneProfile);

    %Read All ASIC
    for idASIC = listIdASIC

        powerConsumption{1}(5,iterationNumber) = powerConsumption{1}(5,iterationNumber) + getPowerASIC(oneProfile,idASIC);
        idAlgo = getAlgorithmIdImplASIC(oneProfile,idASIC);
        if idAlgo ~= 0
            listIdAlgoOnOBC(listIdAlgoOnOBC==idAlgo)=[]; %remove algo from list

            idMemoryLinked = getIdMemoryLinkedAlgo(oneProfile,idAlgo);

            if requestDataInAlgo(oneProfile,idAlgo,timeStep)
                [success, data, endPacket, newPacket] = readPacketOBC(oneProfile,idMemoryLinked,timeStep,getProcessingRateASIC(oneProfile,idASIC));
                setPacketInFinishReadingAlgo(oneProfile,idAlgo, endPacket);
            end
        end
    end

    %Read all FPGA
    for idFPGA = listIdFPGA

        powerConsumption{1}(6,iterationNumber) = powerConsumption{1}(6,iterationNumber) + getPowerFPGA(oneProfile,idFPGA);
        idsAlgo = getIdsAlgorithmFPGA(oneProfile,idFPGA);
        for idOneAlgo = idsAlgo'
            if idOneAlgo > 0 % if the FPGA has an algo in it
                listIdAlgoOnOBC(listIdAlgoOnOBC==idOneAlgo)=[]; %remove algo from list
                
                ressourcesUsage{1}(4,iterationNumber) = ressourcesUsage{1}(4,iterationNumber) + getNbOperationPerSAlgo(oneProfile,idOneAlgo);
                idMemoryLinked = getIdMemoryLinkedAlgo(oneProfile,idOneAlgo);

                if requestDataInAlgo(oneProfile,idOneAlgo,timeStep)
                    [success, data, endPacket, newPacket] = readPacketOBC(oneProfile,idMemoryLinked,timeStep,getProcessingRateAlgo(oneProfile,idOneAlgo));
                    setPacketInFinishReadingAlgo(oneProfile,idOneAlgo, endPacket);
                end

            end
        end
    end
    
    for idAlgo = listIdAlgoOnOBC %Algo that run on the OBC

        ressourcesUsage{1}(2,iterationNumber) = ressourcesUsage{1}(2,iterationNumber) + getNbOperationPerSAlgo(oneProfile,idAlgo);
        idMemoryLinked = getIdMemoryLinkedAlgo(oneProfile,idAlgo);
        if requestDataInAlgo(oneProfile,idAlgo,timeStep)
            [success, data, endPacket, newPacket] = readPacketOBC(oneProfile,idMemoryLinked,timeStep,getProcessingRateAlgo(oneProfile,idAlgo));
            setPacketInFinishReadingAlgo(oneProfile,idAlgo, endPacket);
        end
    end
    
    ressourcesUsage{1}(3,iterationNumber) = getMIPSOBC(oneProfile);
    
     %% OBC memory
     for idMem = listIdOBCMem

         OBCMemUsage{1}(1+idMem,iterationNumber) = utilisationStorageOBC(oneProfile,idMem);
     end
    
     powerConsumption{1}(7,iterationNumber) = getAvailablePower(oneProfile, timeStep);
     
     iterationNumber = iterationNumber+1;

end

disp([ missionProfileName '_' scenario '-' it ' end loop at ' num2str(toc) ' seconds']);

%% Transform to mat 
anyPlot = 1;
if anyPlot ~=0
    powerConsumptionMat = cell2mat(powerConsumption);
    OBCMemeUsageMat = cell2mat(OBCMemUsage);
    sensorOutDataMat = cell2mat(sensorOutData);
    ressourcesUsageMat = cell2mat(ressourcesUsage);
    preProcOutDataMat = cell2mat(preProcOutData);
    lineBusynessMat = cell2mat(lineBusyness);
    sensorsOutAverageMat = cell2mat(sensorsOutAverage);
end

% to optimize => save directly as table
failureTable = table('size',[size(failureCtrl,2) 4],'VariableTypes',{'cell' 'string' 'cell' 'string'});
for i = 1:size(failureCtrl,2)
   failureTable(i,:) = table(failureCtrl{i}(1),failureCtrl{i}(2),failureCtrl{i}(3),failureCtrl{i}(4)); 
end

infoSimTable = table('size',[size(infoSim,2) 4],'VariableTypes',{'cell' 'string' 'cell' 'string'});
for i = 1:size(infoSim,2)
   infoSimTable(i,:) = table(infoSim{i}(1),infoSim{i}(2),infoSim{i}(3),infoSim{i}(4)); 
end

disp([ missionProfileName '_' scenario '-' it ' end transform to mat at ' num2str(toc) ' seconds']);

%% Data Smoothing
smoothPlot = 0;
if smoothPlot~=0
    OBCMemeUsageMatSmooth = OBCMemeUsageMat;
    for i = 2:size(OBCMemeUsageMat,1)
        OBCMemeUsageMatSmooth(i,:) = smooth(OBCMemeUsageMat(1,:),OBCMemeUsageMat(i,:),0.05);
    end
end

disp([ missionProfileName '_' scenario '-' it ' end smooth at ' num2str(toc) ' seconds']);

%% Saving Data 
if wantToSave ~= 0
    [name, satellite] = getInfo(oneProfile);
    initFolderName = '/matlab/';
    folderName = ['results/' name '_' satellite '_' scenario '_2' it ];
    mkdir([initFolderName folderName])
    save([initFolderName folderName '/' 'powerConsumptionMat.mat'],'powerConsumptionMat');
    save([initFolderName folderName '/' 'OBCMemeUsageMat.mat'],'OBCMemeUsageMat');
    save([initFolderName folderName '/' 'sensorOutDataMat.mat'],'sensorOutDataMat');
    save([initFolderName folderName '/' 'ressourcesUsageMat.mat'],'ressourcesUsageMat');
    save([initFolderName folderName '/' 'preProcOutDataMat.mat'],'preProcOutDataMat');
    save([initFolderName folderName '/' 'lineBusynessMat.mat'],'lineBusynessMat');
    save([initFolderName folderName '/' 'sensorsOutAverageMat.mat'],'sensorsOutAverageMat');
    if smoothPlot~=0
        save([initFolderName folderName '/' 'OBCMemeUsageMatSmooth.mat'],'OBCMemeUsageMatSmooth');
    end
    writetable(failureTable,[initFolderName folderName '/' 'failureTable.txt'],'Delimiter','tab')
    writetable(infoSimTable,[initFolderName folderName '/' 'infoSimTable.txt'],'Delimiter','tab')
end

disp([ missionProfileName '_' scenario '-' it ' end simualtion at ' num2str(toc) ' seconds']);
disp(['Simulation finished with ' num2str(size(failureTable,1)-1)  ' erros. Have a look at failureTable.txt.']);

end % end function
