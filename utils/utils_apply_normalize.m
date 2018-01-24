function [data] = utils_apply_normalize(data, norml)
%UTILS_APPLY_NORMALIZE Summary of this function goes here
%   Detailed explanation goes here

% created 11-02-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

[n ,~] = size(data);
switch upper(norml.meth)
    
    case 'ZSCORE'
        data = (data - repmat(norml.mu, n, 1)) ./ repmat(norml.sigma, n, 1);
        
    case 'MIN_MAX'
        data = (data - repmat(norml.min_x, n, 1)) ./ repmat(norml.max_x - norml.min_x , n, 1);
        
    case 'L1NORM'
        data = utils_estimate_normalize(data, 'L1NORM');
        
    otherwise
        error('Incorrect Normalization method');
        
end

