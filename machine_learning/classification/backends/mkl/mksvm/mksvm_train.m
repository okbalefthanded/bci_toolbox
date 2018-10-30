% Multiple Kernel Support Vector Machine (MKSVM)

% Reference
%   bach04icml
%   Multiple Kernel Learning, Conic Duality, and the SMO Algorithm
%   Francis R. Bach, Gert R. G. Lanckriet, Michael I. Jordan
%   Proceedings of the 21st International Conference on Machine Learning, 2004

% Summary
%   trains MKSVM on training data with given parameters

% Input(s)
%   tra: training data
%   par: parameters

% Output(s)
%   mod: MKSVM model

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function mod = mksvm_train(tra, par)
    P = length(tra);
    for m = 1:P
        mod.nor.dat{m} = mean_and_std(tra{m}.X, par.nor.dat{m});
        tra{m}.X = normalize_data(tra{m}.X, mod.nor.dat{m});
    end
    N = size(tra{1}.X, 1);
    yyKm = zeros(N, N, P);
    for m = 1:P
        yyKm(:, :, m) = (tra{m}.y * tra{m}.y') .* kernel(tra{m}, tra{m}, par.ker{m}, par.nor.ker{m});
    end
    alp = zeros(N, 1);
    switch(par.opt)
        case 'mosek'
            [alp, eta] = solve_mksvm(tra{1}, par, yyKm, alp);
        otherwise
            error('You need to install MOSEK for this classifier...')
    end
    for m = 1:P
        sup = find(alp .* eta(m) ~= 0);
        mod.sup{m}.ind = tra{m}.ind(sup);
        mod.sup{m}.X = tra{m}.X(sup, :);
        mod.sup{m}.y = tra{m}.y(sup);
        mod.sup{m}.alp = alp(sup);
        mod.sup{m}.eta = eta(m);
    end
    sup = find(alp ~= 0);
    act = find(alp ~= 0 & alp < par.C);
    yyKeta = kernel_eta_sum(yyKm, eta);
    if isempty(act) == 0
        mod.b = mean(tra{1}.y(act) .* (1 - yyKeta(act, sup) * alp(sup)));
    else
        mod.b = 0;
    end
    mod.par = par;
end