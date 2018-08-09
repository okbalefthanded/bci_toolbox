function draw_gating_boundaries(output, problem, config)
    switch problem
        case {'binary', 'clustering', 'multiclass'}
            x_count = (config.x_max - config.x_min) / config.x_step + 1;
            y_count = (config.y_max - config.y_min) / config.y_step + 1;
            [X1, X2] = meshgrid(config.x_min:config.x_step:config.x_max, config.y_min:config.y_step:config.y_max);
            P = size(output.eta, 2);
            E = zeros(x_count, y_count, P);
            for m = 1:P
                E(:, :, m) = reshape(output.eta(:, m), x_count, y_count);
            end
            for i = 1:P
                for j = i + 1:P
                    Y = E(:, :, i) - E(:, :, j);
                    for m = 1:P
                        if m ~= i && m ~= j
                            Y(E(:, :, i) < E(:, :, m) | E(:, :, j) < E(:, :, m)) = NaN;
                        end
                    end
                    if sum(sum(isnan(Y))) ~= x_count * y_count && sum(var(Y)) ~= 0
                        contour(X1, X2, Y, 'LevelList', 0, 'LineColor', config.gating_color, ...
                                                           'LineStyle', config.gating_style, ...
                                                           'LineWidth', config.gating_width);
                    end
                end
            end
        case 'regression'
            x_count = (config.x_max - config.x_min) / config.x_step + 1;
            X = (config.x_min:config.x_step:config.x_max)';
            P = size(output.eta, 2);
            for i = 1:P
                for j = i + 1:P
                    Y = output.eta(:, i) - output.eta(:, j);
                    for m = 1:P
                        if m ~= i && m ~= j
                            Y(output.eta(:, i) < output.eta(:, m) | output.eta(:, j) < output.eta(:, m)) = NaN;
                        end
                    end
                    if sum(sum(isnan(Y))) ~= x_count && sum(var(Y)) ~= 0
                        start = find(Y(1:end - 1) .* Y(2:end) <= 0);
                        intersection = X(start + 1) - Y(start + 1) * (X(start + 1) - X(start)) / (Y(start + 1) - Y(start));
                        line([intersection, intersection], [config.y_min, config.y_max], 'Color',     config.gating_color, ...
                                                                                         'LineStyle', config.gating_style, ...
                                                                                         'LineWidth', config.gating_width);
                    end
                end
            end
    end
end