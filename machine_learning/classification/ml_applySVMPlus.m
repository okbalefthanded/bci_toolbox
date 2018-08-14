function [output] = ml_applySVMPLUS(features, model)
%ML_APPLYSVMPLUS Summary of this function goes here
%   Detailed explanation goes here

% created 11-07-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

nSamples = size(features.x,1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y;

if (isfield(model, 'normalization'))
    testData = utils_apply_normalize(features.x, model.normalization);
else
    testData = features.x;
end
if (isempty(model.classifier.ProbA) && isempty(model.classifier.ProbB))
    [predicted_label, accuracy, decision_values] = svm_predict_plus(output.trueClasses,testData, model.classifier);
else
    [predicted_label, accuracy, decision_values] = svm_predict_plus(output.trueClasses,testData, model.classifier,'-b 1');
end
output.y = predicted_label;
output.score = decision_values;
output.accuracy = accuracy(1);
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;

end

