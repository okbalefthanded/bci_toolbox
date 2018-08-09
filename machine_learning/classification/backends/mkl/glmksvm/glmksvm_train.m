% Group Lasso Multiple Kernel Support Vector Machine (GLMKSVM)

% Reference
%   xu10icml
%   Simple and Efficient Multiple Kernel Learning by Group Lasso
%   Zenglin Xu, Rong Jin, Stephane Canu, Haiqin Yang, Irwin King, Michael R. Lyu
%   Proceedings of the 27th International Conference on Machine Learning, 2010

% Summary
%   trains GLMKSVM on training data with given parameters

% Input(s)
%   tra: training data
%   par: parameters

% Output(s)
%   mod: GLMKSVM model

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function mod = glmksvm_train(tra, par)
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
    eta = ones(1, P) / P;
    yyKeta = kernel_eta_sum(yyKm, eta);
    alp = zeros(N, 1);
    [alp, obj] = solve_svm(tra{1}, par, yyKeta, alp);
    display(sprintf('%10.6f', obj));
    mod.obj = obj;
    mod.sol = 1;
    while 1 && P > 1
        oldObj = obj;
        [alp, eta, mod, obj, yyKeta] = learn_eta(tra, par, yyKm, alp, eta, mod);
        display(sprintf('%10.6f', obj));
        mod.obj = [mod.obj, obj];
        if abs(obj - oldObj) <= par.eps * abs(oldObj)
            break;
        end
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
    if isempty(act) == 0
        mod.b = mean(tra{1}.y(act) .* (1 - yyKeta(act, sup) * alp(sup)));
    else
        mod.b = 0;
    end
    mod.par = par;
end

function [alp, eta, mod, obj, yyKeta] = learn_eta(tra, par, yyKm, alp, eta, mod)
    sup = find(alp ~= 0);
    P = length(tra);
    nor = zeros(1, P);
    for m = 1:P
        nor(m) = eta(m) * sqrt(alp(sup)' *  yyKm(sup, sup, m) * alp(sup));
    end
    eta = nor.^(2 / (1 + par.p)) ./ (sum(nor.^(2 * par.p / (1 + par.p))))^(1 / par.p);    
    eta = eta ./ norm(eta, par.p);
    eta(eta < par.eps / P) = 0;
    eta = eta ./ norm(eta, par.p);
    yyKeta = kernel_eta_sum(yyKm, eta);
    [alp, obj] = solve_svm(tra{1}, par, yyKeta, alp);
    mod.sol = mod.sol + 1;
end