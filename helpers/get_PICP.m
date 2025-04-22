function [PICP, total_false] = get_PICP(y_test, intervals_list)

    true_false_array = zeros(size(y_test));
    
    for j = 1:length(y_test)
        if y_test(j) >= intervals_list(j, 1) && y_test(j) <= intervals_list(j, 2)
            true_false_array(j) = 1;
        else
            true_false_array(j) = 0;
        end
    end
    
    total_true = sum(true_false_array);
    total_false = length(y_test) - total_true;
    PICP = total_true / length(y_test);
    
end