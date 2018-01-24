function [results, output, model] = run_analysis_ERP(set, approach)

%RUN_ANALYSIS_ERP Summary of this function goes here
%   Detailed explanation goes here
%
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
    
    %% Test
    test_features = extractERP_features(testEEG{subj}, approach);
    output = ml_applyClassifier(test_features, model);
    results = evaluation_ERP(output, test_features.paradigm, testEEG{subj}.phrase);
    
    %% Display & plot results
    interSubject_results(subj) = output.accuracy;
    [min_best_sequence(1,subj), min_best_sequence(2,subj)]= max(results.correct);
    disp(['Correct classification rate: ' num2str(output.accuracy)]);
    disp(['Desired Phrase: ' testEEG{subj}.phrase]);
    disp(['Characters output: ' results.phrase(end,:)]);
    disp(['Characters detection rate: ' num2str(results.correct(end))]);
    %     disp(['Failed detection: ' results.incorrect_characters]);
    disp(repmat('-',1,50))
    plot_results_sequenceERP(results, set, test_features.paradigm, testEEG{subj}.subject.id)
end
plot_results_minSequenceERP(min_best_sequence, set);
disp(['Average accuracy on ' set ' ' num2str(mean(interSubject_results))]);
end

