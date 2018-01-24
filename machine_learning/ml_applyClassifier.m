function [output] = ml_applyClassifier(features, model)
%APPLYCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

% created 12/05/2016
% last modfied -- -- --
% ml_alg = strsplit(model.alg,'_');

switch upper(model.alg.learner)
    case 'LDA'
        output = applyDA(features, model);        
    case 'RLDA'
        output = applyDA(features, model);
    case 'SWLDA'
        output = applyDA(features, model);
    case 'BLDA'
        output = ml_applyBLDA(features, model);
    case 'SVM'
        output = applySvm(features, model);
    case 'LR'
        output = applyLR(features,model);
    case 'GBOOST'
        output = ml_applyLogitBoost(features, model);
    case 'MDA'
        %         TODO
    case 'RF'
        output = applyRF(features, model);
    case 'SVM+'
%         TODO
        output = ml_applySVMPlus(features, model);
    case 'MDM'
%         TODO
        output = ml_applyMDM(features, model);
        
    otherwise
        error('Incorrect Classifier');
end
output.events = features.events;

% TODO : chance level with confidence interval


end

