function [coverage, area] = get_PRCP_PRV(Output_Test, LowerBound, UpperBound)

    true_false_array = zeros(length(Output_Test), 1);
    area_vec = zeros(length(Output_Test), 1);
    
    for iter = 1 : length(Output_Test)
    
        
        if         Output_Test(iter , 1) >= LowerBound(iter, 1) && Output_Test(iter, 1) <= UpperBound(iter, 1) ...
                && Output_Test(iter , 2) >= LowerBound(iter, 2) && Output_Test(iter, 2) <= UpperBound(iter, 2)
    
            true_false_array(iter) = 1;
        else
            true_false_array(iter) = 0;
        end

        area_vec = ((UpperBound(iter, 1) - LowerBound(iter,1)) * (UpperBound(iter, 2) - LowerBound(iter,2)));
    
    end
    
    total_true = sum(true_false_array);
    coverage = total_true / length(Output_Test);

    area = mean(area_vec);

end