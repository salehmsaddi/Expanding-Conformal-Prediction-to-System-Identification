function PINAW = get_PINAW(y_test, intervals_list)

    R = max(y_test) - min(y_test);
    PINAW = sum(intervals_list(:, 2) - intervals_list(:, 1)) / (length(y_test) * R);
    
end