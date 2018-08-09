% Alignment-Based Multiple Kernel Support Vector Machine (ABMKSVM)

% References
%   lanckriet04jmlr
%   Learning the Kernel Matrix with Semidefinite Programming
%   Gert R. G. Lanckriet, Nello Cristianini, Peter Bartlett, Laurent El Ghaoui, Michael I. Jordan
%   Journal of Machine Learning Research, 2004
%
%   he08cvpr
%   Fast Kernel Learning for Spatial Pyramid Matching
%   Junfeng He, Shih-Fu Chang, Lexing Xie
%   Proceedings of the IEEE Computer Society Conference on Computer Vision and Pattern Recognition, 2008
%
%   qiu09tcbb
%   A Framework for Multiple Kernel Support Vector Regression and Its Applications to siRNA Efficacy Prediction
%   Shibin Qiu, Terran Lane
%   IEEE/ACM Transactions on Computational Biology and Bioinformatics, 2009 
            
% Summary
%   trains ABMKSVM on training data with given parameters

% Input(s)
%   tra: training data
%   par: parameters

% Output(s)
%   mod: ABMKSVM model

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function mod = abmksvm_train(tra, par)
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
        case 'conic' % lanckriet04jmlr
            Q = pairwise_frobenius(Km);
            c = optimal_frobenius(Km, tra{1}.y);
            switch(par.opt)
                case 'mosek'            
                    count = P * (P + 1) / 2;
                    [I, J] = meshgrid(1:P, 1:P);
                    prob.c = -c;
                    prob.qcsubk = ones(count, 1);
                    prob.qcsubi = reshape(I(triu(I) ~= 0), count, 1);
                    prob.qcsubj = reshape(J(triu(J) ~= 0), count, 1);
                    prob.qcval = Q(sub2ind(size(Q), prob.qcsubi, prob.qcsubj));
                    prob.a = sparse(zeros(1, P));
                    prob.blc = -inf;
                    prob.buc = 1 / 2;
                    prob.blx = zeros(P, 1);
                    prob.bux = +inf * ones(P, 1);
                    [r, res] = mosekopt('minimize echo(0)', prob);
                    while r ~= 0
                        display('perturbing ...');
                        Q = Q + par.eps * diag(diag(Q));
                        prob.qcval = Q(sub2ind(size(Q), prob.qcsubi, prob.qcsubj));
                        [r, res] = mosekopt('minimize echo(0)', prob);
                    end
                    eta = res.sol.itr.xx';
                    eta = eta ./ norm(eta, 2);
                    eta(abs(eta) < par.eps / P) = 0;
                    eta = eta ./ norm(eta, 2);
                otherwise
                    error('You need to install MOSEK for this classifier...');
            end
        case 'convex' % he08cvpr
            Q = pairwise_frobenius(Km);
            c = optimal_frobenius(Km, tra{1}.y);
            switch(par.opt)
                case 'mosek'
                    res = mskqpopt(Q, -c, ones(1, P), 1, 1, zeros(P, 1), ones(P, 1), [], 'minimize echo(0)');
                    while res.rcode ~= 0
                        Q = Q + par.eps * diag(diag(Q));
                        res = mskqpopt(Q, -c, ones(1, P), 1, 1, zeros(P, 1), ones(P, 1), [], 'minimize echo(0)');
                    end
                    eta = res.sol.itr.xx';
                otherwise
                    eta = quadprog(Q, -c, [], [], ones(1, P), 1, zeros(P, 1), ones(P, 1), zeros(P, 1), optimset('Display', 'off', 'LargeScale', 'off'));
                    while isempty(eta) == 1
                        Q = Q + par.eps * diag(diag(Q));
                        eta = quadprog(Q, -c, [], [], ones(1, P), 1, zeros(P, 1), ones(P, 1), zeros(P, 1), optimset('Display', 'off', 'LargeScale', 'off'));
                    end
                    eta = eta';
            end
            eta = eta ./ sum(eta);
            eta(eta < par.eps / P) = 0;
            eta = eta ./ sum(eta);
        case 'ratio' % qiu09tcbb
            eta = optimal_alignment(Km, tra{1}.y);
            eta = eta ./ sum(eta);
            eta(eta < par.eps / P) = 0;
            eta = eta ./ sum(eta);
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