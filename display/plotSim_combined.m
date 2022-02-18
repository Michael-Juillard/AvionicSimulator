%% Plot the simulation result
set(groot, 'DefaultAxesFontSize', 14)
set(groot, 'DefaultLineLineWidth', 1.5)
close all


%% load data 
initPath = '/matlab/results/';

pick = input('Pick scneario number (1, 2 or 3) : ');

if pick == 1
    av1 = 'Avionic 1_CSO_scenario1_8';
    av2 = 'Avionic 2_CSO_scenario1_9';
elseif pick == 2
    av1 = 'Avionic 1_CSO_scenario2_7';
    av2 = 'Avionic 2_CSO_scenario2_2';
else
    av1 = 'Avionic 1_CSO_scenario3_7';
    av2 = 'Avionic 2_CSO_scenario3_2';
end

% load first av

selpath = [initPath av1];
load([selpath '/' 'powerConsumptionMat.mat']);
load([selpath '/' 'OBCMemeUsageMat.mat']);
%load([selpath '/' 'sensorOutDataMat.mat']);
load([selpath '/' 'ressourcesUsageMat.mat']);
%load([selpath '/' 'preProcOutDataMat.mat']);
load([selpath '/' 'lineBusynessMat.mat']);
%load([selpath '/' 'sensorsOutAverageMat.mat']);

av1_powerConsumptionMat = powerConsumptionMat;
av1_OBCMemeUsageMat = OBCMemeUsageMat;
av1_ressourcesUsageMat = ressourcesUsageMat;
av1_lineBusynessMat = lineBusynessMat;

% load second av

selpath = [initPath av2];
load([selpath '/' 'powerConsumptionMat.mat']);
load([selpath '/' 'OBCMemeUsageMat.mat']);
%load([selpath '/' 'sensorOutDataMat.mat']);
load([selpath '/' 'ressourcesUsageMat.mat']);
%load([selpath '/' 'preProcOutDataMat.mat']);
load([selpath '/' 'lineBusynessMat.mat']);
%load([selpath '/' 'sensorsOutAverageMat.mat']);

av2_powerConsumptionMat = powerConsumptionMat;
av2_OBCMemeUsageMat = OBCMemeUsageMat;
av2_ressourcesUsageMat = ressourcesUsageMat;
av2_lineBusynessMat = lineBusynessMat;

clear powerConsumptionMat OBCMemeUsageMat ressourcesUsageMat;% lineBusynessMat;




plotWidth = 900;%700;
plotHeight = 600;%400;

col=[         0    0.4470    0.7410;
            0.8500    0.3250    0.0980;
            0.9290    0.6940    0.1250;
            0.4940    0.1840    0.5560;
            0.4660    0.6740    0.1880;
            0.3010    0.7450    0.9330;
            0.6350    0.0780    0.1840
            0         0    1.0000;
            0    0.5000         0];



%% Plots

% powerConsoPlot = 0;
% if powerConsoPlot ~= 0
%     
%     timeScale = powerConsumptionMat(1,:)/(1000*60);
%     figure
%     set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
%     plot(timeScale,powerConsumptionMat(2,:))
%     hold on
%     plot(timeScale,powerConsumptionMat(3,:))
%     plot(timeScale,powerConsumptionMat(4,:))
%     plot(timeScale,powerConsumptionMat(5,:))
%     plot(timeScale,powerConsumptionMat(6,:))
%     allPower = powerConsumptionMat(2,:) + powerConsumptionMat(3,:)+powerConsumptionMat(4,:)+powerConsumptionMat(5,:)+powerConsumptionMat(6,:);
%     plot(timeScale,allPower)
%     plot(timeScale,powerConsumptionMat(7,:))
%     %(timeStep, Sensor, prepro, OBC, ASIC, FPGA, OBCMem)
%     title("Power usage");
%     legend("Sensors","Pre-Processing", "OBC", "ASIC", "FPGA","Total Power","Available Power", 'Location', 'best')
%     xlabel("Time [min]")
%     ylabel("Power [W]")
%     ylim([0 22])
%     grid(gca,'minor')
%     grid on
%     xticks(0:0.5:powerConsumptionMat(1,end)/(1000*60))
%     xtickangle(45)
%     hold off
% end

powerConsoPlot = 1;
spaceBetweenMarkker = 50000;
if powerConsoPlot ~= 0
    
    timeScale = av1_powerConsumptionMat(1,:)/(1000*60);
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    
    %AV2
    h(4) = plot(timeScale,av2_powerConsumptionMat(4,:),'Marker','*','Color',col(1,:),'MarkerIndices',1:spaceBetweenMarkker:length(av1_ressourcesUsageMat));
    hold on
    h(5) = plot(timeScale,av2_powerConsumptionMat(2,:)+av2_powerConsumptionMat(3,:)+av2_powerConsumptionMat(5,:)+av2_powerConsumptionMat(6,:),'Marker','*','Color',col(2,:),'MarkerIndices',1:spaceBetweenMarkker:length(av1_ressourcesUsageMat));


    allPower_av2 = av2_powerConsumptionMat(2,:) + av2_powerConsumptionMat(3,:)+av2_powerConsumptionMat(4,:)+av2_powerConsumptionMat(5,:)+av2_powerConsumptionMat(6,:);
    h(6) = plot(timeScale,allPower_av2,'Marker','*','Color',col(4,:),'MarkerIndices',1:spaceBetweenMarkker:length(av1_ressourcesUsageMat));
    %AV1
    h(1) = plot(timeScale,av1_powerConsumptionMat(4,:),'Marker','o','Color',col(1,:),'MarkerIndices',1:spaceBetweenMarkker:length(av1_ressourcesUsageMat));
    

    h(2) = plot(timeScale,av1_powerConsumptionMat(2,:)+av1_powerConsumptionMat(3,:)+av1_powerConsumptionMat(5,:)+av1_powerConsumptionMat(6,:),'Marker','o','Color',col(2,:),'MarkerIndices',1:spaceBetweenMarkker:length(av1_ressourcesUsageMat));

    allPower_av1 = av1_powerConsumptionMat(2,:) + av1_powerConsumptionMat(3,:)+av1_powerConsumptionMat(4,:)+av1_powerConsumptionMat(5,:)+av1_powerConsumptionMat(6,:);
    h(3) = plot(timeScale,allPower_av1,'Marker','o','Color',col(4,:),'MarkerIndices',1:spaceBetweenMarkker:length(av1_ressourcesUsageMat));
    % available power
    h(7) = plot(timeScale,av2_powerConsumptionMat(7,:),'Color',col(5,:));
    
    
    title("Power usage");
    hlegend=legend({ "Av2 - OBC","Av2 - Ext","Av2 - Tot","Av1 - OBC","Av1 - Ext","Av1 - Tot","Avlb Power", 'Location', 'best'},'FontSize',10);
    hlegend.NumColumns=3;
    
    
    xlabel("Time [min]")
    ylabel("Power [W]")
    ylim([0 22])
    grid(gca,'minor')
    grid on
    xticks(0:0.5:av1_powerConsumptionMat(1,end)/(1000*60))
    xtickangle(45)
    hold off
end

OBCMemeUsagePlot = 1;
if OBCMemeUsagePlot ~=0
    
    OBCMemLegend = [];
    %type =['o','-','+'];
    %subplot(1,2,2);
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    hold on
    
    for idMem = 1:size(av2_OBCMemeUsageMat,1)-1
         plot(av2_OBCMemeUsageMat(1,:)/(1000*60),av2_OBCMemeUsageMat(1+idMem,:),'Marker','*','Color',col(idMem,:),'MarkerIndices',1:30000:length(av2_OBCMemeUsageMat));%,type(idMem)
         OBCMemLegend = [OBCMemLegend; 'Av2 - Mem' num2str(idMem) ];
    end

    for idMem = 1:size(av1_OBCMemeUsageMat,1)-1
         plot(av1_OBCMemeUsageMat(1,:)/(1000*60),av1_OBCMemeUsageMat(1+idMem,:),'Marker','o','Color',col(idMem,:),'MarkerIndices',1:30000:length(av1_OBCMemeUsageMat) );%,type(idMem)
         OBCMemLegend = [OBCMemLegend; 'Av1 - Mem' num2str(idMem) ];
    end
    
    title("Memories usage");
    hlegend= legend(OBCMemLegend, 'Location', 'best');
    hlegend.NumColumns=2;
    xlabel("Time [min]")
    ylabel("Usage [%]")
    ylim([0 100])
    grid(gca,'minor')
    grid on
    xticks(0:0.5:av1_OBCMemeUsageMat(1,end)/(1000*60))
    xtickangle(45)
    hold off
end



linebusynessPlot = 1;  % have bo0th line listed

if linebusynessPlot ~= 0
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    set(groot,'defaultAxesColorOrder',col)
    lineBusyLegend = [];
    title("Lines usage");
    hold on
    for idLine = 1:size(av2_lineBusynessMat,1)-1
        plot(av2_lineBusynessMat(1,:)/(1000*60), smooth(av2_lineBusynessMat(1+idLine,:),0.05),'Marker','*','Color',col(idLine,:),'MarkerIndices',1:30000:length(av2_lineBusynessMat) );
        lineBusyLegend = [lineBusyLegend; 'Av2 - Line id ' num2str(idLine) ];
    end
    for idLine = 1:size(av1_lineBusynessMat,1)-1
        plot(av1_lineBusynessMat(1,:)/(1000*60), smooth(av1_lineBusynessMat(1+idLine,:),0.05),'Marker','o','Color',col(idLine,:),'MarkerIndices',1:30000:length(av2_lineBusynessMat) );
        lineBusyLegend = [lineBusyLegend; 'Av1 - Line id ' num2str(idLine) ];
    end

    xlabel("Time [min]")
    ylabel("Usage [%]")
    grid(gca,'minor')
    grid on
    xticks(0:0.5:lineBusynessMat(1,end)/(1000*60))
    xtickangle(45)
    ylim([0 100])
    lgd = legend(lineBusyLegend, 'Location', 'best');
    lgd.NumColumns = 2;
    hold off
    
end

ressourceUsage2 = 1;
if ressourceUsage2 ~= 0
    
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    plot(av2_ressourcesUsageMat(1,:)/(1000*60),100.0*av2_ressourcesUsageMat(2,:)./av2_ressourcesUsageMat(3,:),'Marker','*','Color',col(1,:),'MarkerIndices',1:30000:length(av2_ressourcesUsageMat) )
    hold on
    plot(av2_ressourcesUsageMat(1,:)/(1000*60),100.0*av2_ressourcesUsageMat(4,:)./av2_ressourcesUsageMat(3,:),'Marker','*','Color',col(2,:),'MarkerIndices',1:30000:length(av2_ressourcesUsageMat) )
    plot(av1_ressourcesUsageMat(1,:)/(1000*60),100.0*av1_ressourcesUsageMat(2,:)./av1_ressourcesUsageMat(3,:),'Marker','o','Color',col(1,:),'MarkerIndices',1:30000:length(av1_ressourcesUsageMat) )
    title("Resources usage");
    legend("Av 2 - OBC usage", "Av 2 - Equ FPGA usage","Av 1 - OBC usage", 'Location', 'best')
    xlabel("Time [min]")
    ylabel("Usage [%]")
    grid(gca,'minor')
    grid on
    xticks(0:0.5:av1_ressourcesUsageMat(1,end)/(1000*60))
    xtickangle(45)
    ylim([0 120])
    hold off
end

disp('End plot')
