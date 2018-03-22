function [model] = ml_trainClassifier(features, alg, cv)
%TRAINCLASSIFIER dispatcher function for model training.
% select the classification algorithm model to be trained then call its 
% specific function.
% Arguments:
%     In:
%      features : STRUCT [1x1] feature vector struct 
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
%         alg : STRUCT [1x1]
%               alg.learner : STR classification algorithm.
%               alg.options: STRUCT [1x1] classifier specific options like
%               regularization and other parameters.  
% 
%         cv : STRUCT [1x1] cross-validation settings
%            cv.method : STR cross-validation technique to be used from 
%                        the set of available methods.
%            cv.nfolds : DOUBLE number of folds for train/validation split.
% 
%     Returns:
%         model : STRUCT [1x1] trained classifier parameters, depending on
%         the algorithms the struct may contain weights and bias for linear
%         models and other specific attributes for non-linear models. See
%         specific models functions in machine_learning/classification
%         folder.
% Example :
%   call inside run_analysis_ERP.m
%   model = ml_trainClassifier(features, approach.classifier, approach.cv);
%     
% See Also : define_approach_ERP.m, run_analysis_ERP.m,
% extractERP_features.m

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
    case 'STDA'
%         TODO
        model = ml_trainSTDA(features, cv, alg.options);
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
    case 'MKL'
        % TODO
        % Implement classifier
    case 'RVM'
        % TODO
        % Implement classifier
    case 'MDM'
        %         TODO
        model = ml_trainMDM(features, alg);
    otherwise
        error('Incorrect classifier')
end

end

