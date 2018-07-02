function [model] = ml_trainITCCA(features, alg)
%ML_TRAINITCCA Summary of this function goes here
%   Detailed explanation goes here
% created 07-03-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

stimuli_count = length(features.stimuli_frequencies);
reference_signals = cell(1, stimuli_count);
for stimulus=1:stimuli_count
    reference_signals{stimulus} = mean(features.signal(:,:,features.y==stimulus), 3)';
end
model.alg.learner = 'ITCCA';
model.ref = reference_signals;
end

