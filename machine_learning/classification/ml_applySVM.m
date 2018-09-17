function [output] = ml_applySVM(features, model)
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
%  precomputed kernel
if(model.classifier.Parameters(2)==4)
    K = utils_compute_kernel(testData, model.classifier.trainData, model.classifier.opts);
    %     K = utils_compute_kernel(testData, full(model.classifier.SVs), model.classifier.opts);
    K = [(1:nSamples)' K];
    model.classifier = fRMField(model.classifier, 'opts');
    model.classifier = fRMField(model.classifier, 'trainData');
    [predicted_label, accuracy, decision_values] = svmpredict(output.trueClasses', K, model.classifier);
else    
    if (isempty(model.classifier.ProbA) && isempty(model.classifier.ProbB))
        [predicted_label, accuracy, decision_values] = svmpredict(output.trueClasses',testData, model.classifier);
    else
        [predicted_label, accuracy, decision_values] = svmpredict(output.trueClasses',testData, model.classifier,'-b 1');
    end
end
output.y = predicted_label;
output.score = decision_values;
output.accuracy = accuracy(1);
output.accuracy = 0;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

