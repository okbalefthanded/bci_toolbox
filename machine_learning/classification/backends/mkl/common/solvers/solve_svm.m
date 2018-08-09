function [alp, obj] = solve_svm(tra, par, yyK, alp)
    N = size(tra.X, 1);
    switch lower(par.opt)
        case 'libsvm'
            alp = zeros(N, 1);
            model = svmtrain(tra.y, [(1:1:N)' (tra.y * tra.y') .* yyK], sprintf('-s 0 -t 4 -c %g -e %g', par.C, par.tau));
            alp(model.SVs) = abs(model.sv_coef);
        case 'mosek'
            res = mskqpopt(yyK, -ones(N, 1), tra.y', 0, 0, zeros(N, 1), par.C * ones(N, 1), [], 'minimize echo(0)');
            while res.rcode ~= 0
                yyK = yyK + par.eps * diag(diag(yyK));
                res = mskqpopt(yyK, -ones(N, 1), tra.y', 0, 0, zeros(N, 1), par.C * ones(N, 1), [], 'minimize echo(0)');
            end
            alp = res.sol.itr.xx;
        case 'quadprog'
            alp = quadprog(yyK, -ones(N, 1), [], [], tra.y', 0, zeros(N, 1), par.C * ones(N, 1), alp, optimset('Display', 'off', 'LargeScale', 'off'));
            while isempty(alp) == 1
                yyK = yyK + par.eps * diag(diag(yyK));
                alp = quadprog(yyK, -ones(N, 1), [], [], tra.y', 0, zeros(N, 1), par.C * ones(N, 1), alp, optimset('Display', 'off', 'LargeScale', 'off'));
            end
        case 'smo'
            alp = zeros(N, 1);
            alp = smo_solver(alp, par.C * ones(N, 1), par.eps, tra.y, -ones(N, 1), yyK, par.tau);
    end
    alp(alp < par.C * par.eps) = 0;
    alp(alp > par.C * (1 - par.eps)) = par.C;
    obj = sum(alp) - 0.5 * alp' * yyK * alp;
    obj = obj * (obj >= 0);
end