function [output] = ml_applyCCA(features, model)
%ML_APPLYCCA 

% created 03-21-2018
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if(strcmp(model.mode, 'sync') && ~isempty(model.idle_ind))
    sync_epochs = features.y ~= model.idle_ind;
    features.signal = features.signal(:,:,sync_epochs);
    features.y = features.y(sync_epochs) - 1;
end

[~,~,epochs] = size(features.signal);
stimuli_count = length(model.ref);
output.y = zeros(1, epochs);
output.score = zeros(1, epochs);
% apply CCA
for epo=1:epochs
    r = cell(1, stimuli_count);
    for stimulus=1:stimuli_count
            [~,~,r{stimulus}] = cca(features.signal(:,:,epo)', ...
                                    model.ref{stimulus});     
    end
    [output.score(epo), output.y(epo)] = max(cellfun(@max,r)); 
end

output.accuracy = ((sum(features.y == output.y)) / epochs)*100;
output.trueClasses = features.y;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

