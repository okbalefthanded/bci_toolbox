function [output] = ml_applySVMPlus(features, model)
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

switch model.lupi_learner
    case 'gSMO'
        %         g_SMO_test = 'svm-predict-plus.exe ';
        %         test_data = 'svm_plus_data\test_data ';
        %         svm_plus_prediction = 'svm_plus_models\svm_plus_prediction';
        %         libsvmwrite(test_data, features.y, sparse(testData));
        %         gSMO_cmd = [g_SMO_test test_data model.classifier ' ' svm_plus_prediction];
        %         system(gSMO_cmd);
        %         predicted_label = load(svm_plus_prediction);
        if (isempty(model.classifier.ProbA) && isempty(model.classifier.ProbB))
            [predicted_label, accuracy, decision_values] = svm_predict_plus(output.trueClasses,testData, model.classifier);
        else
            [predicted_label, accuracy, decision_values] = svm_predict_plus(output.trueClasses,testData, model.classifier,'-b 1');
        end
        output.y = predicted_label;
        output.score = decision_values;
        output.accuracy = accuracy(1);       
       
%         output.score = predicted_label;
%         idx = predicted_label >= 0;
%         predicted_label(idx) = 1;
%         predicted_label(~idx) = -1;
%         output.y = predicted_label;
%         nMisClassified = sum(output.trueClasses ~= output.y);
%         output.accuracy = ((nSamples - nMisClassified)/nSamples) * 100;
%         
    case 'L2_SVM+'
        testK       = getKernel(testData', model.train_features', model.train_kparam);
        alpha       = zeros(length(model.train_labels), 1);
        alpha(model.classifier.SVs) = full(model.classifier.sv_coef);
        alpha       = abs(alpha);
        output.score = (testK + 1)*(alpha.*model.train_labels);
        output.y = 2*(output.score>0)-1;
        output.accuracy = sum( output.y == output.trueClasses)/length(output.trueClasses);
    otherwise
        error('Incorrect Lupi Learner');
end
% predicted_label = load(svm_plus_prediction);
% output.score = predicted_label;
% idx = predicted_label >= 0;
% predicted_label(idx) = 1;
% predicted_label(~idx) = -1;
% output.y = predicted_label;
% nMisClassified = sum(output.trueClasses ~= output.y);
% output.accuracy = ((nSamples - nMisClassified)/nSamples) * 100;
output.confusion = flip(confusionmat(output.trueClasses, output.y));
output.subject = '';
output.alg = model.alg;
end

