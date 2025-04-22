clear; close all; clc;

addpath('../helpers')

load("resultsFile_CD_Arm.mat")
struct2vars(results)

confidence_vector = [0.1 , 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99];
modelName = {'SCP', 'UR', 'WUR', 'Copula',  'UC'};


%% Organizing the data
for output_column_index = 1 : length(PICP_SCP)
    for ii = 1 : numel(confidence_vector)
        confidence = confidence_vector(ii) * 100;

        PICPexpName = sprintf('Experiment_PICP_%d_%d', output_column_index, confidence);
        PINAWexpName = sprintf('Experiment_PINAW_%d_%d', output_column_index, confidence);

        tempPICP = [];
        tempPINAW = [];


        for modelNameIndex = 1 : length(modelName)

            vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
            tempvec = eval(vecNamePICP);
            tempPICP = [tempPICP ; tempvec{output_column_index}(:, ii)*100];

            vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex))); 
            tempvec = eval(vecNamePINAW);
            tempPINAW = [tempPINAW ; tempvec{output_column_index}(:, ii)];
        end

        assignin('base', PICPexpName, tempPICP);
        assignin('base', PINAWexpName, tempPINAW);
    end
end

for ii = 1 : numel(confidence_vector)
    confidence = confidence_vector(ii) * 100;

    PICPexpName = sprintf('Experiment_all_PICP_%d', confidence);
    PINAWexpName = sprintf('Experiment_all_PINAW_%d', confidence);

    tempPICP = [];
    tempPINAW = [];


    for modelNameIndex = 1 : length(modelName)

        vecNamePICP = sprintf('PRCP_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNamePICP);
        tempPICP = [tempPICP ; tempvec(:, ii)*100];

        vecNamePINAW = sprintf('PRV_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNamePINAW);
        tempPINAW = [tempPINAW ; tempvec(:, ii)];
    end

    assignin('base', PICPexpName, tempPICP);
    assignin('base', PINAWexpName, tempPINAW);
end

%% Create the table of mean PICP and PINAW Values
for output_column_index = 1 : length(PICP_SCP)
    for ii = 1 : numel(confidence_vector)
        confidence = confidence_vector(ii) * 100;

        PICPexpName = sprintf('mockExperiment_PICP_%d_%d', output_column_index, confidence);
        PINAWexpName = sprintf('mockExperiment_PINAW_%d_%d', output_column_index, confidence);

        tempPICP = [];
        tempPINAW = [];


        for modelNameIndex = 1 : length(modelName)

            vecNamePICP = sprintf('PICP_%s', string(modelName(modelNameIndex)));
            tempvec = eval(vecNamePICP);
            tempPICP = [tempPICP , tempvec{output_column_index}(:, ii) * 100];

            vecNamePINAW = sprintf('PINAW_%s', string(modelName(modelNameIndex))); 
            tempvec = eval(vecNamePINAW);
            tempPINAW = [tempPINAW , tempvec{output_column_index}(:, ii)];
        end

        assignin('base', PICPexpName, tempPICP);
        assignin('base', PINAWexpName, tempPINAW);
    end
end

Output_1_Table = table(round(mean(abs(mockExperiment_PICP_1_90))', 3), ...
                       round(mean(mockExperiment_PINAW_1_90)', 3), ...
                       round(mean(abs(mockExperiment_PICP_1_95))', 3), ...
                       round(mean(mockExperiment_PINAW_1_95)', 3), ...
                       round(mean(abs(mockExperiment_PICP_1_99))', 3), ...
                       round(mean(mockExperiment_PINAW_1_99)', 3));

Output_2_Table = table(round(mean(abs(mockExperiment_PICP_2_90))', 3), ...
                       round(mean(mockExperiment_PINAW_2_90)', 3), ...
                       round(mean(abs(mockExperiment_PICP_2_95))', 3), ...
                       round(mean(mockExperiment_PINAW_2_95)', 3), ...
                       round(mean(abs(mockExperiment_PICP_2_99))', 3), ...
                       round(mean(mockExperiment_PINAW_2_99)', 3));


filename = 'Paper_Table8.xlsx';
writetable(Output_1_Table,filename,'Sheet',1)
writetable(Output_2_Table,filename,'Sheet',2)

%% Create the table of mean PRCP and PRV Values
for ii = 1 : numel(confidence_vector)
    confidence = confidence_vector(ii) * 100;

    PICPexpName = sprintf('mockExperiment_all_PICP_%d', confidence);
    PINAWexpName = sprintf('mockExperiment_all_PINAW_%d', confidence);

    tempPICP = [];
    tempPINAW = [];


    for modelNameIndex = 1 : length(modelName)

        vecNamePICP = sprintf('PRCP_%s', string(modelName(modelNameIndex)));
        tempvec = eval(vecNamePICP);
        tempPICP = [tempPICP , tempvec(:, ii)*100];

        vecNamePINAW = sprintf('PRV_%s', string(modelName(modelNameIndex))); 
        tempvec = eval(vecNamePINAW);
        tempPINAW = [tempPINAW , tempvec(:, ii)];
    end

    assignin('base', PICPexpName, tempPICP);
    assignin('base', PINAWexpName, tempPINAW);
end

Output_Joint_Table = table(round(mean(abs(mockExperiment_all_PICP_90))', 3), ...
                         round(mean(mockExperiment_all_PINAW_90)', 3), ...
                         round(mean(abs(mockExperiment_all_PICP_95))', 3), ...
                         round(mean(mockExperiment_all_PINAW_95)', 3), ...
                         round(mean(abs(mockExperiment_all_PICP_99))', 3), ...
                         round(mean(mockExperiment_all_PINAW_99)', 3));

filename = 'Paper_Table9.xlsx';
writetable(Output_Joint_Table,filename,'Sheet',1)

%% Creating the Miscoverage and PRV plot

DATA1 = [90 - Experiment_all_PICP_90 ; 95 - Experiment_all_PICP_95 ; 99 - Experiment_all_PICP_99];
DATA2 = [Experiment_all_PINAW_90 ; Experiment_all_PINAW_95 ; Experiment_all_PINAW_99];

SAVETITLE = 'Paper_Figure9';

YLABEL1 = 'Miscoverage';
YLABEL2 = 'PRV';

ymin1 = -2;
ymax1 = 12;

ymin2 = 0;
ymax2 = 0.023;


YLABEL_FONT = 14;
XLABEL_FONT = 14;

YTICK_FONT = 12;

LEGEND_FONT = 9;

algo = [repmat({'SCP'}, 10, 1) ; repmat({'UR'}, 10, 1) ; repmat({'WUR'}, 10, 1) ; repmat({'Copula'}, 10, 1) ;  repmat({'UC'}, 10, 1)];
algo = repmat(algo, 3, 1);
experiment_info = [repmat({'90 %'}, 50, 1) ; repmat({'95 %'}, 50, 1) ; repmat({'99 %'}, 50, 1)];


% Create a new figure for plotting
t = tiledlayout(2,1); 
% Miscoverage plot
ax1 = nexttile;
groupedBoxchart(categorical(experiment_info), categorical(algo), DATA1);
yline(0, '--');
ylabel(ax1, YLABEL1, 'FontSize', YLABEL_FONT) 
xticklabels([]); 
xlabel('');      
ylim([ymin1 ymax1])
set(ax1, 'FontSize', YTICK_FONT);
legend({'SCP', 'UR', 'WUR', 'Copula', 'UC'}, 'FontSize', LEGEND_FONT, 'Orientation', 'horizontal', 'Location', 'northoutside');

% PINAW plot
ax2 = nexttile;
groupedBoxchart(categorical(experiment_info), categorical(algo), DATA2);
yline(0, '--');
ylabel(ax2, YLABEL2, 'FontSize', YLABEL_FONT)
xlabel('Coverage', 'FontSize', XLABEL_FONT)
xticklabels({'90%', '95%', '99%'}); 
ylim([ymin2 ymax2])
set(ax2, 'FontSize', YTICK_FONT); 

t.TileSpacing = 'compact';
t.Padding = 'loose';

set(gcf, 'Units', 'inches'); 
set(gcf, 'Position', [0 0 6 4]); 
set(gca, 'LooseInset', get(gca,'TightInset'));
set(gcf,'PaperPositionMode','auto');
print(gcf, SAVETITLE, '-dpng', '-r300'); 

%% Creating the calibration plot
confidence_vector_calib_plot = [0.1 , 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]*100;

SAVETITLE = 'Paper_Figure8b';

% Create a new figure for plotting
t = figure;
hold on;

% Loop through each model and plot the error bars
for i = 1:length(modelName)
    currentVar = eval(['PRCP_' modelName{i}]);
    currentVar = currentVar(:,1:9)*100; %calibration plot for 10%, .., 90%
    
    mean_coverage = mean(currentVar, 1); 
    std_coverage = std(currentVar, 0, 1);
    
    errorbar(confidence_vector_calib_plot, mean_coverage, std_coverage, 'DisplayName', modelName{i}, ...
        'LineWidth', 2, 'MarkerSize', 6, 'LineStyle', '-', 'Marker', 'o');
end


% Plot the calibration line y=x
plot([confidence_vector_calib_plot(1) confidence_vector_calib_plot(end)], [confidence_vector_calib_plot(1) confidence_vector_calib_plot(end)], 'k--', 'DisplayName', 'Calibration Line', 'LineWidth', 2);

grid on;
axis([0 92 0 100]);
xlabel('Desired Coverage', 'FontSize', 14)
ylabel('PRCP', 'FontSize', 14)
xticklabels({'0','10%', '20%', '30%', '40%' , '50%', '60%', '70%', '80%','90%'});
yticklabels({'0','10%', '20%', '30%', '40%' , '50%', '60%', '70%', '80%','90%'});
legend({'SCP', 'UR', 'WUR', 'Copula', 'UC', 'Calibration Line'}, 'Location', 'northwest', 'FontSize', 9);
set(gcf, 'Units', 'inches');
set(gcf, 'Position', [0 0 6 4]);
set(gca, 'LooseInset', get(gca,'TightInset'));
set(gcf,'PaperPositionMode','auto');  
ax = gca;
ax.FontSize = 12;
print(gcf, SAVETITLE, '-dpng', '-r300');
