function ker = get_kernel(nam)
    sub = strfind(nam, '@');
    if isempty(sub) == 1
        switch nam(1)
            case 'l'
                ker = @(x, y)(x * y');
            case 'h'
                ker = @(x, y)histogram_kernel(x, y);
            case 'p'
                q = str2num(nam(2:end)); %#ok<ST2NM>
                ker = @(x, y)(x * y' + 1) .^ q;
            case 'g'
                s = str2num(nam(2:end)); %#ok<ST2NM>
                ker = @(x, y)exp((2 * x * y' - repmat(sqrt(sum(x .^ 2, 2) .^ 2), 1, size(y, 1)) - repmat(sqrt(sum(y .^ 2, 2)' .^ 2), size(x, 1), 1)) / s^2);
            case 's'
                s = str2num(nam(2:end)); %#ok<ST2NM>
                ker = @(x, y)spectrum_kernel(x, y, s);
        end
    else
        ind = str2num(nam(sub + 1:end)); %#ok<ST2NM>
        switch nam(1)
            case 'l'
                ker = @(x, y)(x(:, ind) * y(:, ind)');
            case 'h'
                ker = @(x, y)histogram_kernel(x(:, ind), y(:, ind));
            case 'p'
                q = str2num(nam(2:sub - 1)); %#ok<ST2NM>
                ker = @(x, y)(x(:, ind) * y(:, ind)' + 1) .^ q;
            case 'g'
                s = str2num(nam(2:sub - 1)); %#ok<ST2NM>
                ker = @(x, y)exp((2 * x(:, ind) * y(:, ind)' - repmat(sqrt(sum(x(:, ind) .^ 2, 2) .^ 2), 1, size(y, 1)) - repmat(sqrt(sum(y(:, ind) .^ 2, 2)' .^ 2), size(x, 1), 1)) / s^2);
            case 's'
                s = str2num(nam(2:sub - 1)); %#ok<ST2NM>
                ker = @(x, y)spectrum_kernel(x(:, ind), y(:, ind), s);
        end
    end
end