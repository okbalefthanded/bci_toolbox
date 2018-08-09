function draw_decision_function(output, problem, config)
    switch problem
        case {'binary', 'clustering'}
            x_count = (config.x_max - config.x_min) / config.x_step + 1;
            y_count = (config.y_max - config.y_min) / config.y_step + 1;
            [X1, X2] = meshgrid(config.x_min:config.x_step:config.x_max, config.y_min:config.y_step:config.y_max);
            Y = reshape(output.dis, x_count, y_count);
            contour(X1, X2, Y, 'LevelList', 0, 'LineColor', config.discriminant_color, ...
                                               'LineStyle', config.discriminant_style, ...
                                               'LineWidth', config.discriminant_width);
        case 'multiclass'
            x_count = (config.x_max - config.x_min) / config.x_step + 1;
            y_count = (config.y_max - config.y_min) / config.y_step + 1;
            [X1, X2] = meshgrid(config.x_min:config.x_step:config.x_max, config.y_min:config.y_step:config.y_max);
            O = zeros(x_count, y_count, 3);
            for l = 1:3
                O(:, :, l) = reshape(output.dis(:, l), x_count, y_count);
            end
            for i = 1:3
                for j = i + 1:3
                    Y = O(:, :, i) - O(:, :, j); 
                    for l = 1:3
                        if l ~= i && l ~= j
                            Y(O(:, :, i) < O(:, :, l) | O(:, :, j) < O(:, :, l)) = NaN;
                        end
                    end
                    if sum(sum(isnan(Y))) ~= x_count * y_count && sum(var(Y)) ~= 0
                        contour(X1, X2, Y, 'LevelList', 0, 'LineColor', config.discriminant_color, ...
                                                           'LineStyle', config.discriminant_style, ...
                                                           'LineWidth', config.discriminant_width);
                    end
                end
            end
        case 'regression'
            plot(config.x_min:config.x_step:config.x_max, output.dis, 'Color',     config.fit_color, ...
                                                                      'LineStyle', config.fit_style, ...
                                                                      'LineWidth', config.fit_width);
    end
end