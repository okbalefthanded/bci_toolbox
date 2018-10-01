function [best_param] = parallel_getBestParam(res, paramcell)
%PARALLEL_GETBESTPARAM Summary of this function goes here
%   Detailed explanation goes here
% created 07-31-2016
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
[best_worker, best_evaluation, best_accuracy] = getBestParamIdx(res, paramcell);
best_param = paramcell{best_worker}{best_evaluation}{1};
best_param.cv_perf = best_accuracy;
end

