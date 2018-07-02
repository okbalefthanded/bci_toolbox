function [model] = ml_trainCCA(features, alg)
%ML_TRAINCCA Summary of this function goes here
%   Detailed explanation goes here
% created 03-26-2018
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

[samples, ~, ~] = size(features.signal);
if (iscell(features.stimuli_frequencies))
    stimFrqId = cellfun(@isstr, features.stimuli_frequencies);
    stimFrq = features.stimuli_frequencies(~stimFrqId);
    frqs = cell2mat(stimFrq);
else
    frqs = features.stimuli_frequencies;
end
stimuli_count = length(frqs);
reference_signals = cell(1, stimuli_count);
for stimulus=1:stimuli_count
    reference_signals{stimulus} = refsig(frqs(stimulus),...
                                         features.fs, ...
                                         samples, ...
                                         alg.options.harmonics);
end
model.alg.learner = 'CCA';
model.ref = reference_signals;
end

