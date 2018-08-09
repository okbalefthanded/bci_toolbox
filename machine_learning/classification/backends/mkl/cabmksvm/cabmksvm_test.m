% Centered-Alignment-Based Multiple Kernel Support Vector Machine (CABMKSVM)

% Summary
%   tests CABMKSVM on test data with given model

% Input(s)
%   tes: test data
%   mod: CABMKSVM model

% Output(s)
%   out: classification outputs

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function out = cabmksvm_test(tes, mod)
    P = length(tes);
    for m = 1:P
        tes{m}.X = normalize_data(tes{m}.X, mod.nor.dat{m});
    end
    out.dis = mod.b * ones(size(tes{1}.X, 1), 1);
    for m = 1:P
        if mod.sup{m}.eta ~= 0
            K = kernel(tes{m}, mod.sup{m}, mod.par.ker{m}, mod.par.nor.ker{m});
            out.dis = out.dis + K * (mod.sup{m}.eta * mod.sup{m}.alp .* mod.sup{m}.y);
        end
    end
end