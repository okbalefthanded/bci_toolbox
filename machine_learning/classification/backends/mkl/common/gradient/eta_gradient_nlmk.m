function gra = eta_gradient_nlmk(alp, Km, eta)
    P = size(Km, 3);
    gra = zeros(1, P);
    first = alp * alp';
    for m = 1:P
        for h = 1:P
            gra(m) = gra(m) - sum(sum(eta(h) .* first .* Km(:, :, m) .* Km(:, :, h)));
        end
    end
end