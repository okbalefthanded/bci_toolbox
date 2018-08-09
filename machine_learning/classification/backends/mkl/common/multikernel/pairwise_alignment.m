function Q = pairwise_alignment(Km)
    P = size(Km, 3);
    Q = zeros(P, P);
    for m = 1:P
        for l = 1:m
            Q(m, l) = sum(sum(Km(:, :, m) .* Km(:, :, l))) / sqrt(sum(sum(Km(:, :, m).^2)) * sum(sum(Km(:, :, l).^2)));
            Q(l, m) = Q(m, l);
        end
    end
    Q = (Q + Q') / 2;
end