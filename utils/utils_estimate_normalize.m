function [norml] = utils_estimate_normalize(data, method)
%UTILS_NORMALIZE Summary of this function goes here
%   Detailed explanation goes here

% created 11-02-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

switch upper(method)
    
    case 'ZSCORE'
        norml.mu = mean(data);
        norml.sigma = std(data);
        norml.meth = 'ZSCORE';
        
    case 'MIN_MAX'
        norml.max_x = max(data);
        norml.min_x = min(data);
        norml.meth = 'MIN_MAX';
        
    case 'L1NORM'
        d       = size(data, 2);
        Xnorm   = sum(abs(data));
        Xnorm(Xnorm==0) = 1;
        Xnorm   = 1./Xnorm;
        norml.norm       = data.*repmat(Xnorm, [1, d]);
        
    otherwise
        error('Incorrect Normalization method');
end

