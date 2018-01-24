function [ features ] = extractERP_downsample(EEG, opt)
%EXTRACTERP_DOWNSAMPLE Summary of this function goes here
%   Detailed explanation goes here

% created 11-02-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

decimation = opt.decimation_factor;
x = EEG.epochs.signal(1:decimation:end,:,:,:);
[nSamples, nChannels, nEpochs, nTrials] = size(x);

features.x = permute(reshape(x,[nSamples*nChannels nEpochs*nTrials]), [2 1]);
% features.y =  reshape(EEG.epochs.y,[1 nEpochs*nTrials]);
% features.events = reshape(EEG.epochs.events,[1 nEpochs*nTrials]);
features.y =  reshape(EEG.epochs.y,[nEpochs*nTrials 1]);
features.events = reshape(EEG.epochs.events,[nEpochs*nTrials 1]);
features.paradigm = EEG.paradigm;
features.n_channels = nChannels;

end

