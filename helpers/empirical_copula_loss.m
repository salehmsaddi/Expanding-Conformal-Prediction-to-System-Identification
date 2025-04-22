function loss = empirical_copula_loss(x, data, epsilon)
    % Convert data to pseudo-observations

    py_data = py.numpy.array(data);
    pseudo_obs = py.copulae.core.pseudo_obs(py_data);

    pseudo_data = double(pseudo_obs);
    
    % Create an array of x values replicated across columns
    x_array = repmat(x, 1, size(pseudo_data, 2));
    
    % Compute the indicator function, equivalent to np.all in Python
    indicator = all(pseudo_data <= x_array, 2);
    
    % Calculate the empirical copula loss
    loss = abs(mean(indicator) - 1 + epsilon);
end