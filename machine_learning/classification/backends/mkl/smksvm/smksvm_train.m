% Simple Multiple Kernel Support Vector Machine (SMKSVM)

% Reference
%   rakotomamonjy08jmlr
%   SimpleMKL
%   Alain Rakotomamonjy, Francis R. Bach, Stephane Canu, Yves Grandvalet
%   Journal of Machine Learning Research, 2008

% Summary
%   trains SMKSVM on training data with given parameters

% Input(s)
%   tra: training data
%   par: parameters

% Output(s)
%   mod: SMKSVM model

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function mod = smksvm_train(tra, par)
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
        [alp, eta, mod, obj, yyKeta] = learn_eta(tra, par, yyKm, alp, eta, mod, obj, yyKeta);
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

function [alp, eta, mod, obj, yyKeta] = learn_eta(tra, par, yyKm, alp, eta, mod, obj, yyKeta)
    sup = find(alp ~= 0);
    gra = eta_gradient_smk(alp(sup), yyKm(sup, sup, :));
    srn = sqrt(sum(gra.^2));
    if srn ~= 0
        gra = gra ./ srn;
    else
        return;
    end
    [eta_mu, mu] = max(eta); %#ok<ASGLU>
    gra = gra - gra(mu);
    des = -gra .* (eta > 0 | gra < 0);
    des(mu) = -sum(des);
    valid = find(des < 0);
    if isempty(valid) == 0
        ste_max = min(-eta(valid) ./ des(valid));
    else
        ste_max = 0;
    end
    if ste_max == 0
        return;
    end    
    alp_tem = alp;
    obj_tem = 0;
    while obj_tem < obj
        eta_tem = eta + ste_max * des;
        yyKeta_tem = kernel_eta_sum(yyKm, eta_tem);
        [alp_tem, obj_tem] = solve_svm(tra{1}, par, yyKeta_tem, alp_tem);
        mod.sol = mod.sol + 1;
        if obj_tem < obj
            alp = alp_tem;
            eta = eta_tem;
            obj = obj_tem;
            yyKeta = yyKeta_tem;
            des = des .* (des > 0 | eta > par.eps);
            des(mu) = -sum(des(1:mu - 1)) -sum(des(mu + 1:end));
            valid = find(des < 0);
            if isempty(valid) == 0
                ste_max = min(-eta(valid) ./ des(valid));
                obj_tem = 0;
            else
                ste_max = 0;
            end
        end
    end
    coe = 0.5;
	oldCoe = 0;
    oldObj = obj;
    while 1
        if coe >= 0.5
            oldAlp = alp; oldEta = eta; oldObj = obj;
        end
        eta = eta + (coe - oldCoe) * ste_max * des;
        yyKeta = kernel_eta_sum(yyKm, eta);
        [alp, obj] = solve_svm(tra{1}, par, yyKeta, alp);
        mod.sol = mod.sol + 1;
        if obj < oldObj
            if coe >= 1
                oldCoe = coe;
                coe = coe * 2;
            else
                break;
            end
        else
            if coe > 1
                alp = oldAlp; eta = oldEta; obj = oldObj;
                yyKeta = kernel_eta_sum(yyKm, eta);
                break;
            else
                oldCoe = coe;
                coe = coe / 2;
                if (coe < par.eps)
                    alp = oldAlp; eta = oldEta; obj = oldObj;
                    yyKeta = kernel_eta_sum(yyKm, eta);
                    break;
                end
            end
        end
    end
end