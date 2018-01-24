function [model] = ml_trainClassifier(features, alg, cv)
%TRAINCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

% created 05-12-2016
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

disp(['EVALUATING: trainClassifier: ' alg.learner]);

switch upper(alg.learner)
    case 'LDA'
        model = ml_trainRLDA(features, cv, '');
    case 'RLDA'
        model = ml_trainRLDA(features, cv, alg.options.regularizer);
    case 'SWLDA'
        model = ml_trainSWLDA(features, cv, alg.options);
    case 'BLDA'
        %         TODO
        model = ml_trainBLDA(features, cv);
    case 'SLDA'
        %         TODO
        model = ml_trainSLDA(features, cv, alg.options);
    case 'LR'
        model = ml_trainLR(features, alg, cv);
    case 'GBOOST'
        %         OLS-GBOOST
        model = ml_trainLogitBoost(features, cv, alg.options);
    case 'SVM'
        model = ml_trainSvm(features, alg, cv);
    case 'RF'
        model = ml_trainRF(features,alg,cv);
    case 'SVM+'
        model = ml_trainSVMPlus(features, alg, cv);
    case 'MDM'
%         TODO
        model = ml_trainMDM(features, alg);
    otherwise
        error('Incorrect classifier')
end

end

