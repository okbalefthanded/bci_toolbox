function [features] = extractERP_STDA(EEG, opt)
%EXTRACTERP_STDA Summary of this function goes here
%   Detailed explanation goes here
% created 08-12-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz> 
[nSamples, nChannels, nEpochs, nTrials] = size(EEG.epochs.signal);
if (strcmp(opt.mode, 'estimate'))    
    trainlabel = reshape(EEG.epochs.y, [1 nEpochs*nTrials]);
    trainlabel(trainlabel ==-1) = 2;
    traindata = reshape(EEG.epochs.signal, [nSamples nChannels nEpochs*nTrials]);
%     x = EEG.epochs.signal(1:decimation:end,:,:,:);
    traindata = traindata(1:12:end,:,:);
    [STDAmode, error]=STDA(traindata, trainlabel,opt.itrmax);
    features.af.STDAmode = STDAmode;
    features.af.error = error;
    features.x = STDAprojection(traindata, STDAmode);
    features.x = features.x';
    features.y =  reshape(EEG.epochs.y,[nEpochs*nTrials 1]);
    features.events = reshape(EEG.epochs.events,[nEpochs*nTrials 1]);
    features.paradigm = EEG.paradigm;
    features.n_channels = nChannels;
else
    testdata = reshape(EEG.epochs.signal, [nSamples nChannels nEpochs*nTrials]);
    testdata = testdata(1:12:end,:,:);
    features.x = STDAprojection(testdata, opt.STDAmode);
    features.x = features.x';
    features.y =  reshape(EEG.epochs.y,[nEpochs*nTrials 1]);
    features.events = reshape(EEG.epochs.events,[nEpochs*nTrials 1]);
    features.paradigm = EEG.paradigm;
    features.n_channels = nChannels;
    
end
end

