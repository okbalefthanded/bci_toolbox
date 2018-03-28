function [features] = extractSSVEP_features(EEG, approach)
%EXTRACTSSVE Summary of this function goes here
%   Detailed explanation goes here

% created 03-26-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

method = approach.features.alg;
switch upper(method)
    case 'MLR'
       features = extractSSVEP_mlr(EEG.epochs, approach.features.options);
    otherwise
        error('Incorrect feature extraction method');
end
if(~isfield(features, 'af'))
    features.af = [];
end
% if(isfield(approach,'privileged'))
%     f = extractERP_features(EEG, approach.privileged);
%     features.privileged = f.x;
% end
end

