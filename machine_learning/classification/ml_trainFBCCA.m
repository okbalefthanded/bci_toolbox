function [model] = ml_trainFBCCA(features, alg, cv)
%ML_TRAINFBCCA Summary of this function goes here
%   Detailed explanation goes here
% created 07-01-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

model.fs = features.fs;
[samples, ~, ~] = size(features.signal);
stimuli_count = length(features.stimuli_frequencies);
reference_signals = cell(1, stimuli_count);

if(cv.nfolds == 0)   
  
    if(~isfield(alg.options, 'fbCoefs'))
        model.fbCoefs = (1:alg.options.nrFbs).^(-1.25)+0.25;
    end    
    % construct reference signals
    for stimulus=1:stimuli_count
        reference_signals{stimulus} = refsig(features.stimuli_frequencies(stimulus),...
                                             features.fs, ...
                                             samples, ...
                                             alg.options.harmonics...
                                             );
    end
else
    % TODO
    % model.fbCoefs = ; cross-val determination
end
model.alg.learner = 'FBCCA';
model.ref = reference_signals;
model.nrFbs = alg.options.nrFbs;

end

