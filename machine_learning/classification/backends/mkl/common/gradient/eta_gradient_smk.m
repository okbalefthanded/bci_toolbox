function gra = eta_gradient_smk(alp, Km)
    P = size(Km, 3);
    gra = zeros(1, P);
    first = alp * alp';
    for m = 1:P
        gra(m) = -0.5 * sum(sum(first .* Km(:, :, m)));
    end
end