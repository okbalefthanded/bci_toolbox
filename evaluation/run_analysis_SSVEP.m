function [results, output, model] = run_analysis_SSVEP(set, approach)
%RUN_ANALYSIS_SSVEP Summary of this function goes here
%   Detailed explanation goes here
%operations:
%                  - load train/test data
%                  - spatial filtering
%                  - feature extraction on train data
%                  - train classifier
%                  - feature extraction on test data
%                  - predict test data classes
%                  - display/plot classification and characters detection
%                  results
% Arguments:
%     In:
%         set : STR dataset title, from the set of available and epoched
%               datasets.
%
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
%         results : STRUCT 1x1
%                  results.phrase : CHAR [NxM] [repetition trials] matriix
%                      of characters detected per repetition
%                  results.correct : [Lx1] DOUBLE vector of rate of
%                      correct detected characters per repetition.
%         output : STRUCT 1x1 classification results/performance
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
%         model : STRUCT [1x1] trained classifier parameters, depending on
%         the algorithms the struct may contain weights and bias for linear
%         models and other specific attributes for non-linear models.See
%         specific models functions in machine_learning/classification
%         folder.
%
% Example :
%      call inside define_approach_SSVEP script.
%     [results, output, model] = run_analysis_ERP(set, approach);
% See also define_approach_SSVEP.m

% created 03-21-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

%% load  train data
trainEEG = dataio_read_SSVEP(set,'train');
testEEG = dataio_read_SSVEP(set, 'test');
nSubj = length(trainEEG);
interSubject_results = zeros(2, nSubj);
for subj = 1:nSubj
    disp(['Analyising data from subject:' ' ' trainEEG{subj}.subject.id]);
    %% Train & Test
    if (~isfield(approach, 'features'))
        features = trainEEG{subj}.epochs;
        features.fs = trainEEG{subj}.fs;
        features.stimuli_frequencies = trainEEG{subj}.paradigm.stimuli;
        test_features = testEEG{subj}.epochs;
    else
        approach.features.options.mode = 'estimate';
        features = extractSSVEP_features(trainEEG{subj}, approach);
        approach = utils_augment_approach(approach, features.af);
        approach.features.mode = 'transform';
        test_features = extractSSVEP_features(testEEG{subj}, approach);
    end
    model = ml_trainClassifier(features, approach.classifier, approach.cv);
    output_train = ml_applyClassifier(features, model);
    output_test = ml_applyClassifier(test_features, model);
    %% Display & plot results
    interSubject_results(1, subj) = output_train.accuracy;
    interSubject_results(2, subj) = output_test.accuracy;
    disp(['Accuracy on Train set: ' num2str(output_train.accuracy)]);
    disp(['Accuracy on Test set: ' num2str(output_test.accuracy)]);
    disp( ['Accuracy on Total data: ' num2str(mean(interSubject_results(:, subj)))]);
    disp(repmat('-',1,50))
    results = [];
    output ={output_train, output_test};
end
disp(['Average accuracy on ' set ' ' num2str(mean(interSubject_results(2,:)))]);
end