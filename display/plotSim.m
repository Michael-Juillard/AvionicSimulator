%% Plot the simulation result
set(groot, 'DefaultAxesFontSize', 14)
set(groot, 'DefaultLineLineWidth', 1.5)
close all


%% load data 
selpath = uigetdir('../result/');

load([selpath '/' 'powerConsumptionMat.mat']);
load([selpath '/' 'OBCMemeUsageMat.mat']);
load([selpath '/' 'sensorOutDataMat.mat']);
load([selpath '/' 'ressourcesUsageMat.mat']);
load([selpath '/' 'preProcOutDataMat.mat']);
load([selpath '/' 'lineBusynessMat.mat']);
load([selpath '/' 'sensorsOutAverageMat.mat']);

smoothPlot = 0;
if smoothPlot~=0
    load([selpath '/' 'OBCMemeUsageMatSmooth.mat'],'OBCMemeUsageMatSmooth');
end

disp(['Path selected : ' selpath]);

plotWidth = 700;
plotHeight = 500;



%% Plots

powerConsoPlot = 1;
if powerConsoPlot ~= 0
    
    timeScale = powerConsumptionMat(1,:)/(1000*60);
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    plot(timeScale,powerConsumptionMat(2,:))
    hold on
    plot(timeScale,powerConsumptionMat(3,:))
    plot(timeScale,powerConsumptionMat(4,:))
    plot(timeScale,powerConsumptionMat(5,:))
    plot(timeScale,powerConsumptionMat(6,:))
    allPower = powerConsumptionMat(2,:) + powerConsumptionMat(3,:)+powerConsumptionMat(4,:)+powerConsumptionMat(5,:)+powerConsumptionMat(6,:);
    plot(timeScale,allPower)
    plot(timeScale,powerConsumptionMat(7,:))
    %(timeStep, Sensor, prepro, OBC, ASIC, FPGA, OBCMem)
    title("Power usage");
    legend("Sensors","Pre-Processing", "OBC", "ASIC", "FPGA","Total Power","Available Power", 'Location', 'best')
    xlabel("Time [min]")
    ylabel("Power [W]")
    ylim([0 22])
    grid(gca,'minor')
    grid on
    xticks(0:0.5:powerConsumptionMat(1,end)/(1000*60))
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

    for idMem = 1:size(OBCMemeUsageMat,1)-1
         %plot(OBCMemeUsageMat(1,:)/1000000.0,OBCMemeUsageMatSmooth(1+idMem,:));%,type(idMem)
         plot(OBCMemeUsageMat(1,:)/(1000*60),OBCMemeUsageMat(1+idMem,:));%,type(idMem)
         OBCMemLegend = [OBCMemLegend; 'Memory id ' num2str(idMem) ];
    end
    title("Memories usage");
    legend(OBCMemLegend, 'Location', 'best')
    xlabel("Time [min]")
    ylabel("Usage [%]")
    ylim([0 100])
    grid(gca,'minor')
    grid on
    xticks(0:0.5:OBCMemeUsageMat(1,end)/(1000*60))
    xtickangle(45)
    hold off
end

sensorOutDataPlot = 0;
if sensorOutDataPlot ~= 0
    
    sensorOutLegend = [];
    figure
    h = suptitle("Sensor & Pre-Processor data output");
    posTitle = get(h,'Position');
    set(h,'Position',posTitle +  [0 0.02 0])
    hold on
    if size(preProcOutDataMat,1) == 1
        for idSensor =  1:size(sensorsOutAverageMat,1)-1
            subplot(size(sensorsOutAverageMat,1),1,idSensor+1);
            plot(sensorOutDataMat(1,:)/(1000*60),sensorOutDataMat(1+idSensor,:)/1000);%/(1000*60)
            xlabel("Time [min]")
            ylabel("Data sent [kbit]")
            title(['Sensor id '  num2str(idSensor)])
            %sensorOutLegend = [sensorOutLegend; 'Sensor id ' num2str(idSensor) ];
        end
    else
        for idSensor =  1:size(sensorsOutAverageMat,1)-1
            subplot(size(sensorsOutAverageMat,1),2,(idSensor-1).*2+1);
            plot(sensorOutDataMat(1,:)/(1000*60),sensorOutDataMat(1+idSensor,:)/1000);%/(1000*60)
            xlabel("Time [min]")
            ylabel("Data sent [kbit]")
            title(['Sensor id '  num2str(idSensor)])
            %sensorOutLegend = [sensorOutLegend; 'Sensor id ' num2str(idSensor) ];
        end
        for idPrePro =  1:size(preProcOutDataMat,1)-1
            subplot(size(sensorsOutAverageMat,1),2,idPrePro.*2);
            plot(preProcOutDataMat(1,:)/(1000*60),preProcOutDataMat(1+idPrePro,:)/1000);%/(1000*60)
            xlabel("Time [min]")
            ylabel("Data sent [kbit]")
            title(['Pre processor id '  num2str(idPrePro)])
        end
    end
    
    %legend("Sensors","Pre-Processing", "OBC", "ASIC", "FPGA","Total Power")
    %legend(sensorOutLegend)

    hold off
end

sensorOutAverageDataPlot = 0;
if sensorOutAverageDataPlot ~= 0
    
    sensorOutLegend = [];
    figure
    h = suptitle("Sensor average data output");
    posTitle = get(h,'Position');
    set(h,'Position',posTitle +  [0 0.02 0])
    hold on
    for idSensor = 1:size(sensorsOutAverageMat,1)-1
        subplot(size(sensorsOutAverageMat,1),1,idSensor);
        plot(sensorsOutAverageMat(1,:)/(1000*60),sensorsOutAverageMat(1+idSensor,:)/1000);
        xlabel("Time [min]")
        ylabel("Data sent [kbit/s]")
        title(['Sensor id '  num2str(idSensor)])
    end

    hold off
end

linebusynessPlot = 1;
col=[         0    0.4470    0.7410;
            0.8500    0.3250    0.0980;
            0.9290    0.6940    0.1250;
            0.4940    0.1840    0.5560;
            0.4660    0.6740    0.1880;
            0.3010    0.7450    0.9330;
            0.6350    0.0780    0.1840
            0         0    1.0000;
            0    0.5000         0];
if linebusynessPlot ~= 0
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    set(groot,'defaultAxesColorOrder',col)
    lineBusyLegend = [];
    title("Lines usage");
    hold on
    for idLine = 1:size(lineBusynessMat,1)-1
        plot(lineBusynessMat(1,:)/(1000*60), smooth(lineBusynessMat(1+idLine,:),0.05) );
        lineBusyLegend = [lineBusyLegend; 'Line id ' num2str(idLine) ];
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

ressourceUsage = 0;
if ressourceUsage ~= 0
    
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    plot(ressourcesUsageMat(1,:)/(1000*60),ressourcesUsageMat(2,:))
    hold on
    plot(ressourcesUsageMat(1,:)/(1000*60),ressourcesUsageMat(3,:))
    plot(ressourcesUsageMat(1,:)/(1000*60),ressourcesUsageMat(4,:))
    title("Resources usage");
    legend("OBC usage", "OBC available", "FPGA usage", 'Location', 'best')
    xlabel("Time [min]")
    ylabel("MIPS")
    grid(gca,'minor')
    grid on
    xticks(0:0.5:ressourcesUsageMat(1,end)/(1000*60))
    xtickangle(45)
    hold off
end

ressourceUsage2 = 1;
if ressourceUsage2 ~= 0
    
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    plot(ressourcesUsageMat(1,:)/(1000*60),100.0*ressourcesUsageMat(2,:)./ressourcesUsageMat(3,:))
    hold on
    plot(ressourcesUsageMat(1,:)/(1000*60),100.0*ressourcesUsageMat(4,:)./ressourcesUsageMat(3,:))
    title("Resources usage");
    legend("OBC usage", "Equivalent FPGA usage", 'Location', 'best')
    xlabel("Time [min]")
    ylabel("Usage [%]")
    grid(gca,'minor')
    grid on
    xticks(0:0.5:ressourcesUsageMat(1,end)/(1000*60))
    xtickangle(45)
    ylim([0 100])
    hold off
end

OBCRessources = 0;
if OBCRessources ~= 0
    
    figure
    set(gcf, 'Position',  [100, 100, plotWidth, plotHeight])
    plot(ressourcesUsageMat(1,:)/(1000*60),100.0*ressourcesUsageMat(2,:)./ressourcesUsageMat(3,:))
    title("OBC usage");
    grid(gca,'minor')
    grid on
    xticks(0:0.5:ressourcesUsageMat(1,end)/(1000*60))
    xtickangle(45)
    legend("OBC", 'Location', 'best')
    xlabel("Time [min]")
    ylabel("Usage [%]")
    ylim([0 100])
end
disp('End plot')
