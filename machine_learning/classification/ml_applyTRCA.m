function [output] = ml_applyTRCA(features, model)
%ML_APPLYTRCA Summary of this function goes here
%   Detailed explanation goes here
% created 03-29-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

[~, ~, epochs] = size(features.signal);
[~, idx] = sort(features.y);
eeg = features.signal(:,:, idx);
eeg = permute(eeg, [3 2 1]);
output = test_trca(eeg, model, model.options.is_ensemble);
output.accuracy = ((sum(features.y == output.y)) / epochs)*100;
output.trueClasses = features.y;
% output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

