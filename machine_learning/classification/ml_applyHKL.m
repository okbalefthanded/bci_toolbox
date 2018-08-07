function [output] = ml_applyHKL(features, model)
%ML_APPLYHKL Summary of this function goes here
%   Detailed explanation goes here
% created : 08-06-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

nSamples = size(features.x, 1);
nClasses = numel(unique(features.y));
[classMode, nModels, classPart] = ml_get_classMode(nClasses);

output.accuracy = 0;
output.y = zeros(1, nSamples);
output.score = zeros(nClasses, nSamples);
output.trueClasses = features.y;
if(nModels == 1)
    preds = hkl_test(model.model, model.outputs, features.x, 'Ytest', features.y);
    probs = 1 ./  (1+exp(-preds.predtest));
    decision_values = preds.predtest;
    predicted_label = sign(preds.predtest-.5);
else
    probs = zeros(nSamples, nModels);
    decision_values = zeros(nSamples, nModels);
    for m=1:nModels
        preds = hkl_test(model.model{m}, model.outputs{m}, features.x, 'Ytest', features.y);
        probs(:,m) =  1 ./  (1+exp(-preds.predtest));
        decision_values(:,m) = preds.predtest;
    end
    if(strcmp(classMode,'OvA'))
        [~,predicted_label] = max(probs, [], 2);
    else
        binLabels = sign(decision_values-0.5);
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
output.prob = probs;
output.alg = model.alg;
end

