function [best_worker, best_evaluation] = getBestParamIdx(results, paramcell)
%GETBESTPARAMIDX Summary of this function goes here
%   Detailed explanation goes here
% created 07-29-2018
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
all_results = [results{1}{:}, results{2}{:}];
[best_accuracy, i] = max(cell2mat(all_results));
in = 1;
flag =0;
for p=1:length(paramcell)
    for r = 1:length(paramcell{p})
        if(in==i)
            flag = 1;
            break;
        else
            in = in+ 1;
        end
    end
    if(flag)
        break;
    end
end
best_worker = p;
best_evaluation = r;
end

