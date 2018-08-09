function Keta = kernel_eta(Km, eta)
    N = size(Km, 1);
    P = size(Km, 3);
    Keta = zeros(N, N);
    for m = 1:P
        Keta = Keta + (eta(:, m) * eta(:, m)') .* Km(:, :, m);
    end
end