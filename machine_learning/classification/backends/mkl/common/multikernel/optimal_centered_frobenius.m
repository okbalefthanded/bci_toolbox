function c = optimal_centered_frobenius(Km, y)
    N = size(Km, 1);
    P = size(Km, 3);
    c = zeros(P, 1);
    for m = 1:P
        Km(:, :, m) = bsxfun(@minus, bsxfun(@minus, Km(:, :, m), mean(Km(:, :, m), 1)), mean(Km(:, :, m), 2)) + mean(mean(Km(:, :, m)));
    end
    for m = 1:P
        c(m) = sum(sum((y * y') .* Km(:, :, m)));
    end
end