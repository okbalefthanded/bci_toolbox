function Q = pairwise_frobenius(Km)
    P = size(Km, 3);
    Q = zeros(P, P);
    for m = 1:P
        for h = 1:m
            Q(m, h) = sum(sum(Km(:, :, m) .* Km(:, :, h)));
            Q(h, m) = Q(m, h);
        end
    end
    Q = (Q + Q') / 2;
end