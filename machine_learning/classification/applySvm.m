function [output] = applySvm(features, model)
%ML_APPLYSVM Summary of this function goes here
%   Detailed explanation goes here

% created 02/06/2016
% last modfied -- -- --

nSamples = size(features.x,1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y';

if (isfield(model, 'normalization'))
    testData = utils_apply_normalize(features.x, model.normalization);
else
    testData = features.x;
end

nClasses = length(unique(output.trueClasses));

if (isempty(model.classifier.ProbA) && isempty(model.classifier.ProbB))
    [predicted_label, accuracy, decision_values] = svmpredict(output.trueClasses',testData, model.classifier);
else
    [predicted_label, accuracy, decision_values] = svmpredict(output.trueClasses',testData, model.classifier,'-b 1');
end

output.y = predicted_label;
output.score = decision_values;
output.accuracy = accuracy(1);
% output.confusion = flip(confusionmat(output.trueClasses, output.y));
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

