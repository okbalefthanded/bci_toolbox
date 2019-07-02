function [features] = extractERP_features(EEG, approach)
%EXTRACTERP_FEATURES dispatcher function for ERP feature extraction
% select feature extraction method then call its specific function.
% Arguments:
%     In:
%         EEG : STRUCT [1x1] EEG epoched data
%              EEG.epochs : STRUCT [1x1] EEG epochs
%                         EEG.epochs.signal DOUBLE 4D-matrix [NxMxLxP]
%                          [sample channels epochs trials] of total epochs.
%                         EEG.epochs.events DOUBLE [LxP] [epochs trials]
%                           a matrix of events description.
%                         EEG.epochs.y DOUBLE [LxP] [epochs trials]
%                           a matrix of binary labels.
%              EEG.phrase : STR target phrase.
%              EEG.fs : DOUBLE sampling rate.
%              EEG.montage : STRUCT [1x1]
%                          EEG.montage.clab cell of STR channels labels.
%              EEG.classes : cell {1x2} STR classes descriptions  target,
%                             non_target
%              EEG.paradigm : STRUCT [1x1] experimental protocol.
%                           EEG.paradigm.title STR paradigm description.
%                           EEG.paradigm.stimulation DOUBLE stimulation
%                                       duration in msec
%                           EEG.paradigm.isi DOUBLE ISI in msec.
%                           EEG.paradigm.repetition DOUBLE stimuli
%                             repetition.
%                           EEG.paradigm.stimuli_count DOUBLE number of
%                                       stimuli in paradigm experiement.
%                           EEG.paradigm.type STR
%              EEG.subject :  STRUCT [1x1] subject informations.
%                          EEG.subject.id STR subject id
%                          EEG.subject.gender CHAR male('M') or female('F').
%                          EEG.subject.age DOUBLE subject age
%                          EEG.subject.condition STR health condition.
%         approach : STRUCT [1x1] analysis approach to be run.
%                  approach.features STRUCT [1x1]
%                           approach.features.alg : STR features extraction
%                                                     method.
%                           approach.features.alg.options (optional) STR
%                                               feature extrraction method
%                                               parameters.
%                  approach.classifier: STRUCT [1x1] machine learning
%                  method to be used.
%                                     approach.classifier.learner: STR
%                                     classifier to be used from the set of
%                                     classifiers available.
%                                     approach.classifier.option : STRUCT
%                                                         learners options.
%                                     this field may contain regularization
%                                     methods and other specific
%                                     parameters depending on the model to
%                                     be trained.
%                  approach.cv: STRUCT [1x1] cross validation
%                               approach.cv.method: STR cross-validation
%                                 technique to be used from the set of
%                                 available methods.
%                               approach.cv.nfolds: DOUBLE number of folds
%                               for train/validation split.
%     Returns:
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
% Only some a subset of fields from each struct is passed to subsequenct
% processing phase functions.
% Example :
%     call inside run_analysis_ERP.m
%     features = extractERP_features(trainEEG{subj}, approach);
%
% See Also run_analysis_ERP.m, extractERP_downsample.m,
% extractERP_Reimann.m

% created 11-02-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

method = approach.features.alg;
switch upper(method)
    case 'DOWNSAMPLE'
        % TODO
        % features = extractERP_downsample(EEG, approach.features.options, privileged);
        % opts.decimation = approach.features.options;
        features = extractERP_downsample(EEG, approach.features.options);
    case 'MOVING_AVERAGE'
        %         TODO
        features = extractERP_movingAverage(EEG, approach.features.options);
    
    case 'EPFL'
        % TODO 
        features = extractERP_epfl(EEG, approach.features.options);
    
    case 'SPARSE_CODING'
        %         TODO
    case 'REIMANN'
        features = extractERP_Reimann(EEG, approach.features.options, mode);
    case 'TSA'
        % Reimannian Geometry on tangent space
        %         TODO
    case 'STDA'
        %         TODO
        features = extractERP_STDA(EEG, approach.features.options);
    otherwise
        error('Incorrect feature extraction method');
end

if(isfield(approach,'privileged'))
    f = extractERP_features(EEG, approach.privileged);
    features.privileged = f.x;
end
end

