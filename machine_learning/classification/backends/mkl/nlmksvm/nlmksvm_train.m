% Nonlinear Multiple Kernel Support Vector Machine (NLMKSVM)

% Reference
%   cortes10nips
%   Learning Non-Linear Combinations of Kernels
%   Corinna Cortes, Mehryar Mohri, Afshin Rostamizadeh
%   Advances in Neural Information Processing Systems, 2010

% Summary
%   trains NLMKSVM on training data with given parameters

% Input(s)
%   tra: training data
%   par: parameters

% Output(s)
%   mod: NLMKSVM model

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function mod = nlmksvm_train(tra, par)
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
    eta = ones(1, P) / P;
    [yyKeta, eta] = kernel_eta_sum_product(Km, eta, tra{1}.y, par);
    alp = zeros(N, 1);
    [alp, obj] = solve_svm(tra{1}, par, yyKeta, alp);
    display(sprintf('%10.6f', obj));
    mod.obj = obj;
    mod.sol = 1;
    while 1 && P > 1
        oldObj = obj;
        [alp, eta, mod, obj, yyKeta] = learn_eta(tra, par, Km, alp, eta, mod, obj, yyKeta);
        eta = project_eta(eta, par);
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

function [alp, eta, mod, obj, yyKeta] = learn_eta(tra, par, Km, alp, eta, mod, obj, yyKeta)    
    sup = find(alp ~= 0);
    gra = eta_gradient_nlmk(alp(sup) .* tra{1}.y(sup), Km(sup, sup, :), eta);
    srn = sqrt(sum(gra.^2));
    if srn ~= 0
        gra = gra ./ srn;
    else
        return;
    end
    coe = 1;
	oldCoe = 0;
    oldObj = obj;
    while 1
        if coe >= 1
            oldAlp = alp; oldEta = eta; oldObj = obj;
        end
        eta = eta - (coe - oldCoe) * gra;
        yyKeta = kernel_eta_sum_product(Km, eta, tra{1}.y, par);
		[alp, obj] = solve_svm(tra{1}, par, yyKeta, alp);
        mod.sol = mod.sol + 1;
        if obj < oldObj
            if coe >= 1 && norm(project_eta(eta, par) - project_eta(oldEta, par)) > par.eps
                oldCoe = coe;
                coe = coe * 2;
            else
                eta = project_eta(eta, par);
                break;
            end
        else
            if coe > 1
                alp = oldAlp; eta = oldEta; obj = oldObj;
                [yyKeta, eta] = kernel_eta_sum_product(Km, eta, tra{1}.y, par);
                break;
            else
                oldCoe = coe;
                coe = coe / 2;
                if (coe < par.eps)
                    alp = oldAlp; eta = oldEta; obj = oldObj;
                    [yyKeta, eta] = kernel_eta_sum_product(Km, eta, tra{1}.y, par);
                    break;
                end
            end
        end
    end
end

function [yyKeta, eta] = kernel_eta_sum_product(Km, eta, y, par)
    N = size(Km, 1);
    P = size(Km, 3);
    yyKeta = zeros(N, N);
    eta = project_eta(eta, par);
    for m = 1:P
        if eta(m) ~= 0
            for h = 1:P
                if eta(h) ~= 0
                    yyKeta = yyKeta + eta(m) * eta(h) * (Km(:, :, m) .* Km(:, :, h));
                end
            end
        end
    end
    yyKeta = (y * y') .* yyKeta;
end

function eta = project_eta(eta, par)
    P = length(eta);
    eta(eta < par.eps / P) = 0;
    switch par.p
        case 1
            eta = eta .* (par.lam / sum(eta));
        case 2
            eta = eta .* (par.lam / norm(eta));
    end    
end