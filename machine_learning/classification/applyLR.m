function [output] = applyLR(features, model)
%APPLYLR Summary of this function goes here
%   Detailed explanation goes here
% created: 05-10-2017
% last modified: -- -- --
% disp('EVALUATING APPLY LR');
nSamples = size(features.x,1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y';
testData = sparse(features.x);
nClasses = length(unique(output.trueClasses));

[predicted_label, accuracy, decision_values] = liblinpredict(output.trueClasses',testData, model.classifier);

output.y = predicted_label;
output.score = decision_values;
output.accuracy = accuracy(1);
output.confusion = flip(confusionmat(output.trueClasses, output.y));
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg; 
end

