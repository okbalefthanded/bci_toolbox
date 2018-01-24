function [ features ] = extractERP_Reimann(EEG, opt, mode)
%EXTRACTERP_REIMANN Summary of this function goes here
%   Detailed explanation goes here

% created 01-02-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% downsample
decimation = opt.decimation_factor;
x = EEG.epochs.signal(1:decimation:end,:,:,:);

x = permute(x, [2 1 3 4]);
[nChannels, nSamples, nEpochs, nTrials] = size(x);
x_super = zeros(nChannels*2, nSamples, nEpochs, nTrials);

if (strcmp(mode,'TRAIN'))    
    P = utils_estimate_ERP_prototype(x, EEG.epochs.y);
    features.ERP_prototype = P;    
else
    P = EEG.P;
end

% Build super trials
for trial=1:nTrials
    for ep =1:nEpochs
        x_super(:,:,ep,trial) = cat(1, P, x(:,:,ep,trial));
        % shrinkage ?
        % build Sample covariance matrices for super trials
        features.x(:,:,ep,trial) = (x_super(:,:,ep,trial) * x_super(:,:,ep,trial)') / (nSamples - 1);
    end
end
features.x = reshape(features.x, [nChannels*2 nChannels*2 nEpochs*nTrials]);
features.y =  reshape(EEG.epochs.y,[nEpochs*nTrials 1]);
features.events = reshape(EEG.epochs.events,[nEpochs*nTrials 1]);
features.paradigm = EEG.paradigm;
features.n_channels = nChannels;
end

