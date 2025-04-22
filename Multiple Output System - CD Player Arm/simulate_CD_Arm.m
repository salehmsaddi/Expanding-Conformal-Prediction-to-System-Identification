clear; close all; clc;

addpath('../helpers')

data = importdata("CD_player_arm.dat");
Input = data(:, 1:2);
Output = data(:, 3:4);


rho = 0.995;   
n_trials = 1;
confidence_vector = [0.1 , 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99];


% Initialization to store values
PICP_SCP = cell(size(Output, 2),1);
PICP_Copula = cell(size(Output, 2),1);
PICP_UR = cell(size(Output, 2),1);
PICP_WUR = cell(size(Output, 2),1);
PICP_UC = cell(size(Output, 2),1);

PINAW_SCP = cell(size(Output, 2),1);
PINAW_Copula = cell(size(Output, 2),1);
PINAW_UR = cell(size(Output, 2),1);
PINAW_WUR = cell(size(Output, 2),1);
PINAW_UC = cell(size(Output, 2),1);

for cell_index = 1 : size(Output, 2)

    PICP_SCP{cell_index} = zeros(n_trials , numel(confidence_vector));
    PICP_Copula{cell_index} = zeros(n_trials , numel(confidence_vector));
    PICP_UR{cell_index} = zeros(n_trials , numel(confidence_vector));
    PICP_WUR{cell_index} = zeros(n_trials , numel(confidence_vector));
    PICP_UC{cell_index} = zeros(n_trials , numel(confidence_vector));

    PINAW_SCP{cell_index} = zeros(n_trials , numel(confidence_vector));
    PINAW_Copula{cell_index} = zeros(n_trials , numel(confidence_vector));
    PINAW_UR{cell_index} = zeros(n_trials , numel(confidence_vector));
    PINAW_WUR{cell_index} = zeros(n_trials , numel(confidence_vector));
    PINAW_UC{cell_index} = zeros(n_trials , numel(confidence_vector));

end



PRCP_SCP = zeros(n_trials , numel(confidence_vector));
PRV_SCP = zeros(n_trials , numel(confidence_vector));

PRCP_Copula = zeros(n_trials , numel(confidence_vector));
PRV_Copula = zeros(n_trials , numel(confidence_vector));

PRCP_UR = zeros(n_trials , numel(confidence_vector));
PRV_UR = zeros(n_trials , numel(confidence_vector));

PRCP_WUR = zeros(n_trials , numel(confidence_vector));
PRV_WUR = zeros(n_trials , numel(confidence_vector));


PRCP_UC = zeros(n_trials , numel(confidence_vector));
PRV_UC = zeros(n_trials , numel(confidence_vector));


%%

tic
for trial = 1 : n_trials

    fprintf('trial = %d\n', trial);

    seed = 123456 + (123 * trial);
    rng(seed)
    
    min_Output = min(Output);
    max_Output = max(Output);
    Output_norm = (Output - min_Output) ./ (max_Output - min_Output);

    min_Input = min(Input);
    max_Input = max(Input);
    Input_norm = (Input - min_Input) ./ (max_Input - min_Input);
    
    Ts = 0.1;
    training_size = 800;
    
    Input_Train = Input_norm(1 : training_size , :);
    Output_Train = Output_norm(1 : training_size , :);
    
    Input_Test = Input_norm(training_size + 1 : end , :);
    Output_Test = Output_norm(training_size + 1 : end , :);
    
    calibration_size = 100 * floor(length(Input_Train) / 400) -1;
    calibration_index = randi([1, length(Input_Train) - calibration_size]);
    
    
    Input_propTrain1 = Input_Train(1 : calibration_index - 1 , :);
    Output_propTrain1 = Output_Train(1 : calibration_index - 1 , :);
    
    Input_Cal = Input_Train(calibration_index : calibration_index + calibration_size - 1 , :);
    Output_Cal = Output_Train(calibration_index : calibration_index + calibration_size - 1 , :);
    
    Input_propTrain2 = Input_Train(calibration_index + calibration_size : end , :);
    Output_propTrain2 = Output_Train(calibration_index + calibration_size : end , :);
    
    Input_propTrain = [Input_propTrain1 ; Input_propTrain2];
    Output_propTrain = [Output_propTrain1 ; Output_propTrain2];
    

    %%
    DataPropTrain = iddata(Output_propTrain, Input_propTrain, Ts);
    DataCal = iddata(Output_Cal, Input_Cal, Ts);
    DataTest = iddata(Output_Test, Input_Test, Ts);

    opt = n4sidOptions('EnforceStability', true);
    obj = n4sid(Input_Train,Output_Train, 'best', 'Ts',Ts, opt);
    
    y_hat_propTrain = predict(obj, DataPropTrain, 1);
    y_hat_cal = predict(obj, DataCal, 1);
    y_hat_test = predict(obj, DataTest, 1);
    
    residuals_propTrain = abs(Output_propTrain - y_hat_propTrain.OutputData);
    residuals_cal = abs(Output_Cal - y_hat_cal.OutputData);
    residuals_test = abs(Output_Test - y_hat_test.OutputData);


    UB_UR = zeros(size(Output_Test));
    LB_UR = zeros(size(Output_Test));

    UB_WUR = zeros(size(Output_Test));
    LB_WUR = zeros(size(Output_Test));

    UB_WUR2 = zeros(size(Output_Test));
    LB_WUR2 = zeros(size(Output_Test));

    UB_WUR3 = zeros(size(Output_Test));
    LB_WUR3 = zeros(size(Output_Test));

    UB_UC = zeros(size(Output_Test));
    LB_UC = zeros(size(Output_Test));


    for ii = 1 : numel(confidence_vector)

        confidence = confidence_vector(ii);

        fprintf('confidence = %d\n', confidence);

        %-------------------------------------------------------------------------------------------------%
        % SCP happens here
        alphas_SCP = sort(residuals_cal, 'ascend');
        alphas_index = ceil((confidence)*(length(residuals_cal)+1));
        
        UB_SCP = y_hat_test.Outputdata + alphas_SCP(alphas_index , :);
        LB_SCP = y_hat_test.Outputdata - alphas_SCP(alphas_index , :);

        %-------------------------------------------------------------------------------------------------%
        % Copula happens here
        alpha_Coupula = Copula_function(residuals_cal, confidence);
        UB_Copula = y_hat_test.OutputData + alpha_Coupula;
        LB_Copula = y_hat_test.OutputData - alpha_Coupula;

        
        %-----------------------------------------------------------------------------------------------------%
        % Loop over all the test points
        for i = 1 : length(Output_Test)

            %-------------------------------------------------------------------------------------------------%
            % Updating and sorting the residuals is common for UR, WUR and UC
            if i == 1
                residuals = residuals_cal;
            else
                residuals = [residuals(2:end , :) ; residuals_test(i-1 , :)];
            end
            [sorted_R, index_R] = sort(residuals, "ascend");

            %-------------------------------------------------------------------------------------------------%
            % UR happens here
            UB_UR(i , :) = y_hat_test.OutputData(i , :) + sorted_R(alphas_index , :);
            LB_UR(i , :) = y_hat_test.OutputData(i , :) - sorted_R(alphas_index , :);

            %-------------------------------------------------------------------------------------------------%
            % WUR happens here
            calib_thresh = WUR_function(residuals, rho, confidence);
            UB_WUR(i , :) = y_hat_test.OutputData(i , :) + calib_thresh;
            LB_WUR(i , :) = y_hat_test.OutputData(i , :) - calib_thresh;

            %-------------------------------------------------------------------------------------------------%
            % UC happens here
            alpha_UpdatedCoupula = Copula_function(residuals, confidence);
            UB_UC(i , :) = y_hat_test.OutputData(i , :) + alpha_UpdatedCoupula;
            LB_UC(i , :) = y_hat_test.OutputData(i , :) - alpha_UpdatedCoupula;


        end

        %-------------------------------------------------------------------------------------------------%
        % Loop over the output size to store PICP and PINAW

        for output_column_index = 1 : size(Output, 2)

            intervals_list_SCP = [LB_SCP(:, output_column_index) UB_SCP(:, output_column_index)];
            PICP_SCP{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_SCP);
            PINAW_SCP{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_SCP);

            intervals_list_Copula = [LB_Copula(:, output_column_index) UB_Copula(:, output_column_index)];
            PICP_Copula{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_Copula);
            PINAW_Copula{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_Copula);


            intervals_list_UR = [LB_UR(:, output_column_index) UB_UR(:, output_column_index)];
            PICP_UR{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_UR);
            PINAW_UR{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_UR);

            intervals_list_WUR = [LB_WUR(:, output_column_index) UB_WUR(:, output_column_index)];
            PICP_WUR{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_WUR);
            PINAW_WUR{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_WUR);

            intervals_list_UC = [LB_UC(:, output_column_index) UB_UC(:, output_column_index)];
            PICP_UC{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_UC);
            PINAW_UC{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_UC);

        end

        [PRCP_SCP(trial, ii), PRV_SCP(trial, ii)] = get_PRCP_PRV(Output_Test, LB_SCP, UB_SCP);
        [PRCP_Copula(trial, ii), PRV_Copula(trial, ii)] = get_PRCP_PRV(Output_Test, LB_Copula, UB_Copula);
        [PRCP_UR(trial, ii), PRV_UR(trial, ii)] = get_PRCP_PRV(Output_Test, LB_UR, UB_UR);
        [PRCP_WUR(trial, ii), PRV_WUR(trial, ii)] = get_PRCP_PRV(Output_Test, LB_WUR, UB_WUR);
        [PRCP_UC(trial, ii), PRV_UC(trial, ii)] = get_PRCP_PRV(Output_Test, LB_UC, UB_UC);

    end
end


%% Save the results in a structure
modelNames = {'SCP', 'Copula', 'UR', 'WUR', 'UC'};

results = struct();

prefixes = {'PICP', 'PINAW', 'PRCP', 'PRV'};
for p = 1:length(prefixes)
    prefix = prefixes{p};
    
    % Loop over each model name
    for m = 1:length(modelNames)
        modelName = modelNames{m};
        
        % Construct the variable name for the current prefix and model
        varName = sprintf('%s_%s', prefix, modelName);
        
        % Check if the variable exists in the workspace
        if evalin('base', sprintf('exist(''%s'', ''var'')', varName))
            % Get the variable's value from the workspace
            value = evalin('base', varName);
            
            % Assign the value to the results structure
            results.(sprintf('%s_%s', prefix, modelName)) = value;
        else
            warning('Variable %s does not exist in the workspace.', varName);
        end
    end
end

save("resultsFile_CD_Arm.mat",'results');