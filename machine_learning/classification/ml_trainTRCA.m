function [model] = ml_trainTRCA(features, alg, cv)
%ML_TRAINTRCA Summary of this function goes here
%   Detailed explanation goes here
% created 03-29-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% num_targs, num_chans, num_smpls num_blocks

% eeg = permute(features.signal, [3 2 1]);
model = train_trca(eeg, features.fs, alg.options.num_fbs);
end

