% Rule-Based Multiple Kernel Support Vector Machine (RBMKSVM)

% Summary
%   tests RBMKSVM on test data with given model

% Input(s)
%   tes: test data
%   mod: RBMKSVM model

% Output(s)
%   out: classification outputs

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function out = rbmksvm_test(tes, mod)
    P = length(tes);
    for m = 1:P
        tes{m}.X = normalize_data(tes{m}.X, mod.nor.dat{m});
    end
    N = size(tes{1}.X, 1);
    out.dis = mod.b * ones(N, 1);
    Km = zeros(N, size(mod.sup{1}.X, 1), P);
    for m = 1:P
        Km(:, :, m) = kernel(tes{m}, mod.sup{m}, mod.par.ker{m}, mod.par.nor.ker{m});
    end
    out.dis = combination_rule(Km, mod.par.rul) * (mod.sup{1}.alp .* mod.sup{1}.y) + mod.b;
end