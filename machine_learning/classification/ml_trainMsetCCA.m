function [model] = ml_trainMsetCCA(features, alg, cv)
%ML_TRAINMSETCCA Summary of this function goes here
%   Detailed explanation goes here

% created 03-25-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>


[samples,~,epochs] = size(features.signal);

if (iscell(features.stimuli_frequencies))
    stimFrqId = cellfun(@isstr, features.stimuli_frequencies);
    stimFrq = features.stimuli_frequencies(~stimFrqId);
    frqs = cell2mat(stimFrq);
else
    frqs = features.stimuli_frequencies;
end
stimuli_count = length(frqs);
% reference_signals = cell(1, stimuli_count);
% stimuli_count = length(features.stimuli_frequencies);
% epochs_per_stimulus = round(epochs / stimuli_count);
epochs_per_stimulus = round(length(features.y) / length(unique(features.y)));
W = cell(1, stimuli_count);
reference_signals = repmat({zeros(epochs_per_stimulus*alg.options.n_comp, samples)}, 1, stimuli_count);
% stimuli_count = max(features.events);
eeg = permute(features.signal, [2 1 3]);
if (cv.nfolds == 0)
    % optimize reference signals
    for stimulus = 1:stimuli_count
        W{stimulus} = msetcca(eeg(:,:,features.y==stimulus), alg.options.n_comp);
        tmp = eeg(:,:, features.y==stimulus);        
        for ep = 1:epochs_per_stimulus           
            reference_signals{stimulus}...
                ((ep-1)*alg.options.n_comp + 1:ep*alg.options.n_comp, :) = W{stimulus}(:,:,ep)'*tmp(:,:,ep);
        end
    end
    
else
%     TODO
end
model.alg.learner = 'MSETCCA';
model.ref = reference_signals; 
end

