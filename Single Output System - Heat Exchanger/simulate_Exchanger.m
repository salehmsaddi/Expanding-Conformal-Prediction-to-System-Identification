clear; close all; clc;

addpath('../helpers')

data = importdata("exchanger.dat");
Input = data(:, 2);
Output = data(:, 3);

rho = 0.995;   
n_trials = 10;
confidence_vector = [0.1 , 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99];


% Initialization to store values
PICP_SCP = cell(size(Output, 2),1);
PICP_UR = cell(size(Output, 2),1);
PICP_WUR = cell(size(Output, 2),1);


PINAW_SCP = cell(size(Output, 2),1);
PINAW_UR = cell(size(Output, 2),1);
PINAW_WUR = cell(size(Output, 2),1);


for cell_index = 1 : size(Output, 2)

    PICP_SCP{cell_index} = zeros(n_trials , numel(confidence_vector));
    PICP_UR{cell_index} = zeros(n_trials , numel(confidence_vector));
    PICP_WUR{cell_index} = zeros(n_trials , numel(confidence_vector));

    PINAW_SCP{cell_index} = zeros(n_trials , numel(confidence_vector));
    PINAW_UR{cell_index} = zeros(n_trials , numel(confidence_vector));
    PINAW_WUR{cell_index} = zeros(n_trials , numel(confidence_vector));


end


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
    
    Ts = 1;
    training_size = 1000;
    
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

    data = iddata(Output_propTrain, Input_propTrain, 1);
    obj = nlarx(data, [3 3 1], 'idWaveletNetwork');
    
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

        
        %-----------------------------------------------------------------------------------------------------%
        % Loop over all the test points
        for i = 1 : length(Output_Test)

            %-------------------------------------------------------------------------------------------------%
            % Updating and sorting the residuals is common for UR and WUR
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
        end

        %-------------------------------------------------------------------------------------------------%
        % Loop over the output size to store PICP and PINAW
        for output_column_index = 1 : size(Output, 2)

            intervals_list_SCP = [LB_SCP(:, output_column_index) UB_SCP(:, output_column_index)];
            PICP_SCP{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_SCP);
            PINAW_SCP{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_SCP);

         
            intervals_list_UR = [LB_UR(:, output_column_index) UB_UR(:, output_column_index)];
            PICP_UR{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_UR);
            PINAW_UR{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_UR);

            intervals_list_WUR = [LB_WUR(:, output_column_index) UB_WUR(:, output_column_index)];
            PICP_WUR{output_column_index}(trial, ii) = get_PICP(Output_Test(:, output_column_index), intervals_list_WUR);
            PINAW_WUR{output_column_index}(trial, ii) = get_PINAW(Output_Test(:, output_column_index), intervals_list_WUR);

        end

    end
end

%% Save the results in a structure
modelNames = {'SCP', 'UR', 'WUR'};

results = struct();

prefixes = {'PICP', 'PINAW'};
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

save("resultsFile_exchanger.mat",'results');