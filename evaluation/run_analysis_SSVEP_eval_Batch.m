function [results, output, model] = run_analysis_SSVEP_eval_Batch(set, approach)
%RUN_ANALYSIS_SSVEP_EVAL_BATCH Summary of this function goes here
%   Detailed explanation goes here
% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
%% load  train data
trainEEG = dataio_read_SSVEP(set,'train');
testEEG = dataio_read_SSVEP(set, 'test');
samples = size(trainEEG{1}.epochs,1);
windowLength = samples / trainEEG{1}.fs;
nSubj = length(trainEEG);
interSubject_results = zeros(2, nSubj);
results = zeros(2, nSubj);
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
    trainEEG{subj} = [];
    testEEG{subj} = [];
    model = ml_trainClassifier(features, approach.classifier, approach.cv);    
    output_train = ml_applyClassifier(features, model);
    clear features
    output_test = ml_applyClassifier(test_features, model);
    clear test_features
    %% Display & plot results
    interSubject_results(1, subj) = output_train.accuracy;
    interSubject_results(2, subj) = output_test.accuracy;
    disp(['Accuracy on Train set: ' num2str(output_train.accuracy)]);
    disp(['Accuracy on Test set: ' num2str(output_test.accuracy)]);
    disp( ['Accuracy on Total data: ' num2str(mean(interSubject_results(:, subj)))]);
    disp(repmat('-',1,50))
    output ={output_train, output_test, windowLength};
    %     accuracy, kappa, alg
    results(1,subj) = output_train.accuracy;
    results(2,subj) = output_test.accuracy;
end
disp(['Average accuracy on ' set ' ' num2str(mean(interSubject_results(2,:)))]);
end

