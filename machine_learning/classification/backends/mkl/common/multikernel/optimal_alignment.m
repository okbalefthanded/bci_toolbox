function c = optimal_alignment(Km, y)
    N = size(Km, 1);
    P = size(Km, 3);
    c = zeros(1, P);
    for m = 1:P
        c(m) = y' * Km(:, :, m) * y / (N * sqrt(sum(sum(Km(:, :, m).^2))));
    end
end