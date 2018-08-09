function Q = pairwise_centered_frobenius(Km)
    P = size(Km, 3);
    Q = zeros(P, P);
    for m = 1:P
        Km(:, :, m) = bsxfun(@minus, bsxfun(@minus, Km(:, :, m), mean(Km(:, :, m), 1)), mean(Km(:, :, m), 2)) + mean(mean(Km(:, :, m)));
    end
    for m = 1:P
        for l = 1:m
            Q(m, l) = sum(sum(Km(:, :, m) .* Km(:, :, l)));
            Q(l, m) = Q(m, l);
        end
    end
    Q = (Q + Q') / 2;
end