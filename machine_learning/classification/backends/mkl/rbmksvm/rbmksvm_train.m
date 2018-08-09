% Rule-Based Multiple Kernel Support Vector Machine (RBMKSVM)

% Reference
%   cristianini00book
%   Nello Cristianini, John Shawe-Taylor
%   An Introduction to Support Vector Machines and Other Kernel-Based Learning Methods
%   Cambridge University Press, 2000

% Summary
%   trains RBMKSVM on training data with given parameters

% Input(s)
%   tra: training data
%   par: parameters

% Output(s)
%   mod: RBMKSVM model

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function mod = rbmksvm_train(tra, par)
    P = length(tra);
    for m = 1:P
        mod.nor.dat{m} = mean_and_std(tra{m}.X, par.nor.dat{m});
        tra{m}.X = normalize_data(tra{m}.X, mod.nor.dat{m});
    end
    N = size(tra{1}.X, 1);
    Km = zeros(N, N, P);
    for m = 1:P
        Km(:, :, m) = kernel(tra{m}, tra{m}, par.ker{m}, par.nor.ker{m});
    end
    yyKeta = (tra{1}.y * tra{1}.y') .* combination_rule(Km, par.rul);
    alp = zeros(N, 1);
    alp = solve_svm(tra{1}, par, yyKeta, alp);
    sup = find(alp ~= 0);
    act = find(alp ~= 0 & alp < par.C);
    for m = 1:P
        mod.sup{m}.ind = tra{m}.ind(sup);
        mod.sup{m}.X = tra{m}.X(sup, :);
        mod.sup{m}.y = tra{m}.y(sup);
        mod.sup{m}.alp = alp(sup);
    end
    if isempty(act) == 0
        mod.b = mean(tra{1}.y(act) .* (1 - yyKeta(act, sup) * alp(sup)));
    else
        mod.b = 0;
    end
    mod.par = par;
end