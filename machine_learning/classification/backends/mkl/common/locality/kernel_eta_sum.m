function Keta = kernel_eta_sum(Km, eta)
    N = size(Km, 1);
    P = size(Km, 3);
    Keta = zeros(N, N);
    for m = 1:P
        if eta(m) ~= 0
            Keta = Keta + eta(m) * Km(:, :, m);
        end
    end
end