function [results, output, model] = run_analysis_ERP_eval_Batch(set, approach)
%RUN_ANALYSIS_ERP_EVAL Summary of this function goes here
%   Detailed explanation goes here
% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

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
    trainEEG{subj} = [];
    model = ml_trainClassifier(features, approach.classifier, approach.cv);
    output_train = ml_applyClassifier(features, model);
    %% Test
    test_features = extractERP_features(testEEG{subj}, approach);
    output_test = ml_applyClassifier(test_features, model);
    res = evaluation_ERP(output_test, ...
        test_features.paradigm, ...
        testEEG{subj}.phrase);
    results(subj).phrase = res.phrase;
    results(subj).correct = res.correct;
    %% Display & plot results
    interSubject_results(subj) = output_test.accuracy;
    [min_best_sequence(1,subj), min_best_sequence(2,subj)]= max(results(subj).correct);
    disp(['Correct classification rate: ' num2str(output_test.accuracy)]);
    disp(['Desired Phrase: ' testEEG{subj}.phrase]);
    disp(['Characters output: ' results(subj).phrase(end,:)]);
    disp(['Characters detection rate: ' num2str(results(subj).correct(end))]);
    %     disp(['Failed detection: ' results.incorrect_characters]);
    disp(repmat('-',1,50))
    plot_results_sequenceERP(results(subj), ...
        set.title, ...
        test_features.paradigm, ...
        testEEG{subj}.subject.id);
    testEEG{subj} = [];
    output = {output_train, output_test};
    results(subj).train_acc = output_train.accuracy;
    results(subj).test_acc = output_test.accuracy;
    results(subj).min_subject_sequence = min_best_sequence(:,subj);
end
plot_results_minSequenceERP(min_best_sequence, set.title);
disp(['Average accuracy on ' set.title ' ' num2str(mean(interSubject_results))]);
end

