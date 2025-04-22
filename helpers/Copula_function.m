function [results_alpha_s_coupula] = Copula_function(residuals_cal, confidence)

    results_alpha_s_coupula = zeros(size(residuals_cal, 2), 1)';
    
    % Calculate alphas as absolute differences
    alphas_coupula = abs(residuals_cal);
    
    % Create a mapping of sorted alpha values
    sorted_alphas_coupula = cell(1, size(alphas_coupula, 2));
    for i = 1:size(alphas_coupula, 2)
        sorted_alphas_coupula{i} = sort(alphas_coupula(:, i));
    end
    
    % Generate x_candidates equivalent to linspace(0.0001, 0.999, 300)
    quantile_candidates = linspace(0.0001, 0.999, 300);
    
    x_fun = zeros(length(quantile_candidates), 1);
    
    for i = 1 : length(quantile_candidates)
        x_fun(i) = empirical_copula_loss(quantile_candidates(i), alphas_coupula, 1-confidence);
    end
    
    
    % Combine x_fun and x_candidates, then sort by x_fun
    x_sorted = sortrows([x_fun(:), quantile_candidates(:)]);
    
    
    % Find the quantile values based on the sorted results
    quantile = zeros(1, size(alphas_coupula, 2));
    for i = 1:size(alphas_coupula, 2)
        quantile(i) = sorted_alphas_coupula{i}(ceil(x_sorted(1, 2) * size(alphas_coupula, 1)));
    end
    
    
    % Store quantiles in results structure
    for i = 1:size(residuals_cal, 2)
        results_alpha_s_coupula(i) = quantile(i);
    end

end