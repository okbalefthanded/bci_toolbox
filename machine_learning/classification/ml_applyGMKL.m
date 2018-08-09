function [output] = ml_applyGMKL(features, model)
%ML_APPLYGMKL Summary of this function goes here
%   Detailed explanation goes here
% created 09-08-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

nSamples = size(features.x, 1);
nClasses = numel(unique(features.y));
[classMode, nModels, classPart] = ml_get_classMode(nClasses);

output.accuracy = 0;
output.y = zeros(1, nSamples);
output.score = zeros(nClasses, nSamples);
output.trueClasses = features.y;
testing_data = cell(1, model.nKernel);
test.X = features.x;
for k=1:model.nKernel
    testing_data{k} = test;
end

if(nModels == 1)
    preds = gmksvm_test(testing_data, model.model);
    decision_values = preds.dis;
    predicted_label = sign(decision_values);
else
    decision_values = zeros(nSamples, nModels);
    for m=1:nModels
        preds = gmksvm_test(testing_data, model.model{m});        
        decision_values(:,m) = preds.dis;
    end
    if(strcmp(classMode,'OvA'))
        [~,predicted_label] = max(decision_values, [], 2);
    else
        binLabels = sign(decision_values);
        onesId = binLabels==1;
        predicted_label = zeros(nSamples, 1);
        for i=1:size(binLabels, 1)
            binLabels(i,onesId(i,:)) = classPart(onesId(i,:),1);
            binLabels(i,~onesId(i,:)) = classPart(~onesId(i,:),2);
            [occurence, value] = hist(binLabels(i,:), unique(binLabels(i,:)));
            [~, ii] = max(occurence);
            predicted_label(i) = value(ii);
        end
    end
end

output.y = predicted_label;
output.score = decision_values;
nMisClassified = sum(output.trueClasses ~= output.y);
output.accuracy = ((nSamples - nMisClassified)/nSamples) * 100;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;

end

