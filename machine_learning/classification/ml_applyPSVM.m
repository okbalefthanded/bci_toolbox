function [output] = ml_applyPSVM(features, model)
%ML_APPLYPSVM Summary of this function goes here
%   Detailed explanation goes here
% Reference
% O. Chapelle 2007
% date created 10-18-2018
% last modified -- -- --
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

if(strcmp(model.classifier.opts.kernel.type,'LIN'))
    output.score = testData*model.classifier.w + model.classifier.b;
else
    K = utils_compute_kernel(testData, model.classifier.trainData, model.classifier.opts);
    output.score = sign(K*model.classifier.beta + model.classifier.b);
end
output.y = sign(output.score);
output.accuracy = (sum(output.y==output.trueClasses) / nSamples)* 100;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

