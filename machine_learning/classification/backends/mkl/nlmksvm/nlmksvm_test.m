% Nonlinear Multiple Kernel Support Vector Machine (NLMKSVM)

% Summary
%   tests NLMKSVM on test data with given model

% Input(s)
%   tes: test data
%   mod: NLMKSVM model

% Output(s)
%   out: classification outputs

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function out = nlmksvm_test(tes, mod)
    P = length(tes);
    for m = 1:P
        tes{m}.X = normalize_data(tes{m}.X, mod.nor.dat{m});
    end
    out.dis = mod.b * ones(size(tes{1}.X, 1), 1);
    for m = 1:P
        if mod.sup{m}.eta ~= 0
            Km = kernel(tes{m}, mod.sup{m}, mod.par.ker{m}, mod.par.nor.ker{m});
            out.dis = out.dis + (Km .* Km) * (mod.sup{m}.eta * mod.sup{m}.eta * (mod.sup{m}.alp .* mod.sup{m}.y));
            for h = m + 1:P
                if mod.sup{h}.eta ~= 0
                    Kh = kernel(tes{h}, mod.sup{h}, mod.par.ker{h}, mod.par.nor.ker{h});
                    out.dis = out.dis + 2 * (Km .* Kh) * (mod.sup{m}.eta * mod.sup{h}.eta * mod.sup{m}.alp .* mod.sup{m}.y);
                end
            end
        end
    end
end