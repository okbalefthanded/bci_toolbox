function loc = locality(dat, typ)
    switch typ
        case 'linear'
            loc = dat;
        case 'quadratic'
            N = size(dat, 1);
            D = size(dat, 2);
            loc = zeros(N, D * (D + 3) / 2);
            loc(:, 1:D) = dat;
            loc(:, D + 1:2 * D) = dat.^2;
            cur = 1;
            for i = 1:D
                for j = i + 1:D
                   loc(:, 2 * D + cur) = dat(:, i) .* dat(:, j);
                   cur = cur + 1;
                end
            end
    end
end