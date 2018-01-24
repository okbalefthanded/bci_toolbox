function [ features ] = extractERP_features(EEG, approach)
%EXTRACTERP_FEATURES Summary of this function goes here
%   Detailed explanation goes here

%
% created 11-02-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

method = approach.features.alg;
switch upper(method)
    case 'DOWNSAMPLE'
        %         TODO
        %     features = extractERP_downsample(EEG, approach.features.options, privileged);
        %         opts.decimation = approach.features.options;
        features = extractERP_downsample(EEG, approach.features.options);
    case 'MOVING_AVERAGE'
        %         TODO
    case 'SPARSE_CODING'
        %         TODO
    case 'REIMANN'
        features = extractERP_Reimann(EEG, approach.features.options, mode);
    case 'TSA'
        % Reimannian Geometry on tangent space
        %         TODO
    otherwise
        error('Incorrect feature extraction method');
end

if(isfield(approach,'privileged'))
    f = extractERP_features(EEG, approach.privileged);
    features.privileged = f.x;
end


end

