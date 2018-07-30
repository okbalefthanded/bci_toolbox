function [output] = ml_applyRF(features, model)
%APPLY_RF Summary of this function goes here
%   Detailed explanation goes here

% created 14/06/2016
% last modified -- -- --

nSamples = size(features.x,1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y';
testData = features.x;
nClasses = length(unique(output.trueClasses));

output.y = classRF_predict(testData, model);

nMisClassified = sum(output.trueClasses' ~= output.y);
output.accuracy = ((nSamples - nMisClassified)/nSamples) * 100;
% results.confusion = flip(confusionmat(results.trueClasses, results.y));
output = ml_get_performance(output);

end

