function c = optimal_frobenius(Km, y)
    P = size(Km, 3);
    c = zeros(P, 1);
    for m = 1:P
        c(m) = y' * Km(:, :, m) * y;
    end
end