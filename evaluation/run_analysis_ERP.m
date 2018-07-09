function [results, output, model] = run_analysis_ERP(set, approach)
%RUN_ANALYSIS_ERP : main analysis function, performs the following
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
%      call inside define_approach_ERP script.
%     [results, output, model] = run_analysis_ERP(set, approach);
% See also define_approach_ERP.m

% created 10-30-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

%% load  train data
trainEEG = dataio_read_ERP(set,'train');
testEEG = dataio_read_ERP(set, 'test');
nSubj = length(trainEEG);

interSubject_results = zeros(1, nSubj);
min_best_sequence = zeros(2, nSubj);
for subj = 1:nSubj
    disp(['Analyising data from subject:' ' ' trainEEG{subj}.subject.id]);
    disp(['Approach: ' approach.features.alg ' ' approach.classifier.learner]);
    
    %% Train
    %     spatial filters (optional)
    features = extractERP_features(trainEEG{subj}, approach);
    model = ml_trainClassifier(features, approach.classifier, approach.cv);
    output_train = ml_applyClassifier(features, model);
    %% Test
    test_features = extractERP_features(testEEG{subj}, approach);
    output_test = ml_applyClassifier(test_features, model);
    results = evaluation_ERP(output_test, test_features.paradigm, testEEG{subj}.phrase);
    
    %% Display & plot results
    interSubject_results(subj) = output_test.accuracy;
    [min_best_sequence(1,subj), min_best_sequence(2,subj)]= max(results.correct);
    disp(['Correct classification rate: ' num2str(output_test.accuracy)]);
    disp(['Desired Phrase: ' testEEG{subj}.phrase]);
    disp(['Characters output: ' results.phrase(end,:)]);
    disp(['Characters detection rate: ' num2str(results.correct(end))]);
    %     disp(['Failed detection: ' results.incorrect_characters]);
    disp(repmat('-',1,50))
    plot_results_sequenceERP(results, set, test_features.paradigm, testEEG{subj}.subject.id)
    output ={output_train, output_test};
end
plot_results_minSequenceERP(min_best_sequence, set);
disp(['Average accuracy on ' set ' ' num2str(mean(interSubject_results))]);
end

