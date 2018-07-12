function [itr] = evaluation_ITR(n_targets, p, selection_time)
%EVALUATION_ITR Summary of this function goes here
%   Detailed explanation goes here

% created 07-12-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
p = p / 100;
if(p == 1)
    itr = log2(n_targets)*60/selection_time;
else if(p < 1/n_targets)
        itr = 0;
    else
        itr = (log2(n_targets) + p*log2(p) + (1-p)*log2((1-p)/(n_targets-1)))*60/selection_time;
    end
end
end

