function calib_thresh = WUR_function(residuals, rho, confidence)

    calib_thresh = zeros(1, size(residuals , 2));
    
    [sorted_R, index_R] = sort(residuals, "ascend");
    
    A = length(residuals) : -1 : 1;
    weights = rho .^ A;
    weights_calib = weights ./ (sum(weights) + 1);
    
    
    if sum(weights_calib) >= confidence
    
        for column_index = 1 : size(residuals, 2)
    
            cum_weights_calib = cumsum(weights_calib(index_R(: , column_index)));
    
            % Find the index where the cumulative sum exceeds or equals 1 - alpha
            ind_thresh = find(cum_weights_calib >= confidence, 1, 'first');
            calib_thresh(column_index) = sorted_R(ind_thresh , column_index);
    
        end
    
    else
    
        % disp('error')
        calib_thresh = inf;
    end
end