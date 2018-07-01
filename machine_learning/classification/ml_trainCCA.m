function [model] = ml_trainCCA(features, alg)
%ML_TRAINCCA Summary of this function goes here
%   Detailed explanation goes here
% created 03-26-2018
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

[samples, ~, ~] = size(features.signal);
stimuli_count = length(features.stimuli_frequencies);
reference_signals = cell(1, stimuli_count);
% construct reference signals
for stimulus=1:stimuli_count
    reference_signals{stimulus} = refsig(features.stimuli_frequencies(stimulus),...
                                         features.fs, ... 
                                         samples, ...
                                         alg.options.harmonics);
end
model.alg.learner = 'CCA';
model.ref = reference_signals; 
end

