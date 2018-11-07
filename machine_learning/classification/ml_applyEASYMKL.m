function [output] = ml_applyEASYMKL(features, model)
%ML_APPLYEASYMKL Summary of this function goes here
%   Detailed explanation goes here
% created 11-06-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
nSamples = size(features.x, 1);
nClasses = numel(unique(features.y));
output.accuracy = 0;
output.y = zeros(1, nSamples);
output.score = zeros(nClasses, nSamples);
output.trueClasses = features.y;
if (isfield(model, 'normalization'))
    testData = utils_apply_normalize(features.x, model.normalization);
else
    testData = features.x;
end
n1 = size(model.classifier.trainData, 1);
Ks_ts = zeros(nSamples, n1, model.classifier.opts.r);
reps = model.classifier.opts.repartitions;
trainData = model.classifier.trainData;
for i=1:model.classifier.opts.r
    Ks_ts(:,:,i) = utils_compute_kernel(testData(:,reps(i,:)), trainData(:,reps(i,:)), model.classifier.opts);
end
[predicted_label, decision_values] = easymkl_predict(model.classifier, Ks_ts);

output.y = predicted_label;
output.score = decision_values;
nMisClassified = sum(output.trueClasses ~= output.y);
output.accuracy = ((nSamples - nMisClassified)/nSamples) *100;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

