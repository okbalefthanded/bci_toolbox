function [alp, eta, obj] = solve_mksvm(tra, par, yyKm, alp)
    N = size(tra.X, 1);
    P = size(yyKm, 3);
    switch lower(par.opt)
        case 'mosek'
            count = N * (N + 1) / 2;
            [I, J] = meshgrid(1:N, 1:N);
            rows = reshape(I(triu(I) ~= 0), count, 1);
            columns = reshape(J(triu(J) ~= 0), count, 1);
            prob.c = [-ones(N, 1); 1];
            prob.qcsubk = zeros(count * P, 1);
            prob.qcsubi = zeros(count * P, 1);
            prob.qcsubj = zeros(count * P, 1);
            prob.qcval = zeros(count * P, 1);
            for m = 1:P
                start = (m - 1) * count + 1;
                finish = m * count;
                prob.qcsubk(start:finish) = m + 1;
                prob.qcsubi(start:finish) = rows;
                prob.qcsubj(start:finish) = columns;
                yyKc = yyKm(:, :, m);
                prob.qcval(start:finish) = yyKc(sub2ind(size(yyKc), rows, columns));
            end
            prob.a = sparse([tra.y' 0; zeros(P, N) -ones(P, 1)]);
            prob.blc = [0; -inf * ones(P, 1)];
            prob.buc = [0; zeros(P, 1)];
            prob.blx = [zeros(N, 1); -inf;];
            prob.bux = [par.C * ones(N, 1); +inf];
            [r, res] = mosekopt('minimize echo(0)', prob);
            while r ~= 0
                for m = 1:P
                    yyKm(:, :, m) = yyKm(:, :, m) + par.eps * diag(diag(yyKm(:, :, m)));
                end
                for m = 1:P
                    start = (m - 1) * count + 1;
                    finish = m * count;
                    yyKc = yyKm(:, :, m);
                    prob.qcval(start:finish) = yyKc(sub2ind(size(yyKc), rows, columns));
                end
                [r, res] = mosekopt('minimize echo(0)', prob);
            end
            alp = res.sol.itr.xx(1:N);
            eta = res.sol.itr.suc(2:P + 1)';
    end
    alp(alp < par.C * par.eps) = 0;
    alp(alp > par.C * (1 - par.eps)) = par.C;
    eta = eta ./ sum(eta);
    eta(eta < par.eps / P) = 0;
    eta = eta ./ sum(eta);
    obj = sum(alp);
    for m = 1:P
        obj = obj - 0.5 * eta(m) * alp' * yyKm(:, :, m) * alp;
    end
    obj = obj * (obj >= 0);
end