function [output] = ml_applyL1MCCA(features, model)
%ML_APPLYL1MCCA Summary of this function goes here
%   Detailed explanation goes here
% created 03-21-2016
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>


[~, ~, epochs] = size(features.signal);
stimuli_count = max(features.events);
% apply CCA
for epo=1:epochs
    r = cell(1, stimuli_count);
    for stimulus=1:stimuli_count
        [~, ~, r{stimulus}] = cca(features.signal(:,:,epo)', ...
                                model.ref{stimulus});    
    end
    [output.score(epo), output.y(epo)] = max(cellfun(@max,r)); 
end

output.accuracy = ((sum(features.y == output.y)) / epochs)*100;
output.trueClasses = features.y;
% output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

