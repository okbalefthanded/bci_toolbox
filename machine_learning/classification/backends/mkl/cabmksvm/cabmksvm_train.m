% Centered-Alignment-Based Multiple Kernel Support Vector Machine (CABMKSVM)

% References
%   cortes10icml
%   Two-Stage Learning Kernel Algorithms
%   Corinna Cortes, Mehryrar Mohri, Afshin Rostamizadeh
%   Proceedings of the 27th International Conference on Machine Learning, 2010
            
% Summary
%   trains CABMKSVM on training data with given parameters

% Input(s)
%   tra: training data
%   par: parameters

% Output(s)
%   mod: CABMKSVM model

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function mod = cabmksvm_train(tra, par)
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
    switch(par.com)
        case 'linear' % cortes10icml
            a = optimal_centered_frobenius(Km, tra{1}.y);
            M = pairwise_centered_frobenius(Km);
            eta = (M \ a)';
            eta = eta ./ norm(eta, 2);
            eta(abs(eta) < par.eps / P) = 0;
            eta = eta ./ norm(eta, 2);
        case 'convex' % cortes10icml
            a = optimal_centered_frobenius(Km, tra{1}.y);
            M = pairwise_centered_frobenius(Km);
            switch(par.opt)
                case 'mosek'
                	res = mskqpopt(M, -a, eye(P, P), zeros(P, 1), +Inf * ones(P, 1), [], [], [], 'minimize echo(0)');
                    while res.rcode ~= 0
                        M = M + par.eps * diag(diag(M));
                        res = mskqpopt(M, -a, [], [], [], zeros(P, 1), +Inf * ones(P, 1), [], 'minimize echo(0)');
                    end
                    eta = res.sol.itr.xx';
                otherwise
                    eta = quadprog(M, -a, [], [], [], [], zeros(P, 1), +Inf * ones(P, 1), zeros(P, 1), optimset('Display', 'off', 'LargeScale', 'off'));
                    while isempty(eta) == 1
                        M = M + par.eps * diag(diag(M));
                        eta = quadprog(M, -a, [], [], [], [], zeros(P, 1), +Inf * ones(P, 1), zeros(P, 1), optimset('Display', 'off', 'LargeScale', 'off'));
                    end
                    eta = eta';
            end
            eta = eta ./ norm(eta, 2);
            eta(eta < par.eps / P) = 0;
            eta = eta ./ norm(eta, 2);
    end    
    yyKeta = (tra{1}.y * tra{1}.y') .* kernel_eta_sum(Km, eta);
    alp = zeros(N, 1);
    alp = solve_svm(tra{1}, par, yyKeta, alp);
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