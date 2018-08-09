function [output] = ml_applyClassifier(features, model)
%ML_APPLYCLASSIFIER : dispatcher function for classifier application.
% select algoirthm to apply then call its specific function.
% Arguments:
%     In:
%      features : STRUCT [1x1] feature vectors struct
%                 features.x : DOUBLE [NxM] [feature_vector_dim epochs_count]
%                     a matrix of feature vectors.
%                 features.y : DOUBLE [Mx1] [epochs_count 1] vector
%                   of class labels 1/-1 target/non_target.
%                 features.events : DOUBLE | INT16  [Mx1] [epochs_count 1]
%                   a vector of stimuli following each epoch.
%                 features.paradigm : STRUCT [1x1] experimental protocol.
%                    same as Input argument EEG.paradigm.
%                 features.n_channels : DOUBLE number of electrodes used
%                   in the experiment.
%
%      model : STRUCT [1x1] trained classifier parameters, depending on
%            the algorithms the struct may contain weights and bias for linear
%            models and other specific attributes for non-linear models. See
%            specific models functions in machine_learning/classification
%            folder.
%   Returns:
%     output : STRUCT 1x1 classification results/performance
%                output.accuracy: DOUBLE correct classification rate
%                output.y: DOUBLE [1xN] [1 epochs_count] classifier
%                           binary classes output.
%                output.score: DOUBLE [1xN] [1 epochs_count] classifier's
%                               decision function output.
%                output.trueClasses: DOUBLE [1xN] [1 epochs_count] true
%                                    target labels.
%                output.confusion: DOUBLE [2x2] confusion matrix.
%                output.sensitivity: DOUBLE classifier's sensitivity.
%                output.specificity: DOUBLE classifier's specificicty.
%                output.fpr: DOUBLE classifier's false positive rate.
%                output.false_detection: DOUBLE classifier's false detection.
%                output. precision: DOUBLE classifier's precision.
%                output.hf_difference: DOUBLE classifier's hf difference.
%                output.kappa: DOUBLE classifier's kappa coefficient.
%                output.subject: STR subject id for the current data.
%                output.alg: STRUCT [1x1]
%                           output.alg.learner : STR classification algorithm
%                           output.alg.regularizer: (optional) STR regularization
%                                                   method for the alg.learner.
%                output.events: DOUBLE | INT16 [Nx1] [epochs_count 1]
%                                 stimulus presented to the subject.
% Example :
%   call inside run_analysis_ERP.m
%   output = ml_applyClassifier(test_features, model);
%
% See Also extractERP_features.m, ml_trainClassifier.m

% created 05-12-2016
% last modfied -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

switch upper(model.alg.learner)
    case 'LDA'
        output = ml_applyDA(features, model);
    case 'RLDA'
        output = ml_applyDA(features, model);
    case 'SWLDA'
        output = ml_applyDA(features, model);
    case 'BLDA'
        output = ml_applyBLDA(features, model);
    case 'STDA'
       % TODO
        output = ml_applySTDA(features, model);
    case 'SVM'
        output = ml_applySVM(features, model);
    case 'LR'
        output = ml_applyLR(features,model);
    case 'GBOOST'
        output = ml_applyLogitBoost(features, model);
    case 'MDA'
        %  TODO
        %  Implement classifier
    case 'RF'
        output = ml_applyRF(features, model);
    case 'SVM+'
        % TODO
        output = ml_applySVMPlus(features, model);
    case 'HKL'
        output = ml_applyHKL(features, model);
    case 'RBMKL'
        output = ml_applyRBMKL(features, model);
    case 'RVM'
        % TODO
        % Implement classifier
    case 'MDM'
        %         TODO
        output = ml_applyMDM(features, model);
    case {'CCA','L1MCCA', 'MSETCCA','ITCCA'}    
        output = ml_applyCCA(features, model);
    case 'FBCCA'
        output = ml_applyFBCCA(features, model);
    case 'TRCA'
        output = ml_applyTRCA(features, model);
    otherwise
        error('Incorrect Classifier');
end
output.events = features.events;
% TODO : chance level with confidence interval
end

