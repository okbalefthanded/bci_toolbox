function [model] = ml_trainTRCA(features, alg, cv)
%ML_TRAINTRCA Summary of this function goes here
%   Detailed explanation goes here
% created 03-29-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if(~isfield(alg, 'options'))
    alg.options.num_fbs = 5;
    alg.options.is_ensemble = 1;
end

% num_targs, num_chans, num_smpls num_blocks
[samples, channels, epochs] = size(features.signal);
[~, idx] = sort(features.y);
targets_count = max(features.y);

% TODO check for class imbalance / how to deal with it? (resample)
eeg = features.signal(:,:, idx);
eeg = permute(eeg, [3 2 1]);
eeg = reshape(eeg, [epochs/targets_count targets_count channels samples]);
eeg = permute(eeg, [2 3 4 1]);

model = train_trca(eeg, features.fs, alg.options.num_fbs);
model.alg.learner = 'TRCA';
model.options.is_ensemble = alg.options.is_ensemble;
end

