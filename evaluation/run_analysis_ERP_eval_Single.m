function [results, output, model] = run_analysis_ERP_eval_Single(set, approach)
%RUN_ANALYSIS_ERP_EVAL_SIGNLE Summary of this function goes here
%   Detailed explanation goes here
% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

nSubj = utils_fetch_Set_Folder(set);
interSubject_results = zeros(1, nSubj);
min_best_sequence = zeros(2, nSubj);
eval_duration = 1; % 1 second time for evaluation

for subj = 1:nSubj
    set.subj = subj;
    trainEEG = dataio_read_ERP(set,'train');
    paradigm = trainEEG.paradigm;
    trial_dur = ((paradigm.isi+paradigm.stimulation)*0.001)*paradigm.stimuli_count*paradigm.repetition;
    disp(['Analyising data from subject:' ' ' trainEEG.subject.id]);
    disp(['Approach: ' approach.features.alg ' ' approach.classifier.learner]);    
    %% Train
    %     spatial filters (optional)
    features = extractERP_features(trainEEG, approach);
    clear trainEEG
    model = ml_trainClassifier(features, approach.classifier, approach.cv);
    output_train = ml_applyClassifier(features, model);    
    %% Test
    testEEG = dataio_read_ERP(set, 'test');
    test_features = extractERP_features(testEEG, approach);
    phrase = testEEG.phrase;
    subject_id = testEEG.subject.id;
    clear testEEG
    output_test = ml_applyClassifier(test_features, model);
    res = evaluation_ERP(output_test, ...
                         test_features.paradigm, ...
                         phrase...
                         );
    results(subj).phrase = res.phrase;
    results(subj).correct = res.correct;
    %% Display & plot results
    interSubject_results(subj) = output_test.accuracy;
    [min_best_sequence(1,subj), min_best_sequence(2,subj)]= max(results(subj).correct);
    disp(['Correct classification rate: ' num2str(output_test.accuracy)]);
    disp(['Desired Phrase: ' phrase]);
    disp(['Characters output: ' results(subj).phrase(end,:)]);
    disp(['Characters detection rate: ' num2str(results(subj).correct(end))]);
    %     disp(['Failed detection: ' results.incorrect_characters]);
    disp(repmat('-',1,50))
%     plot_results_sequenceERP(results(subj), ...
%                              set.title, ...
%                              test_features.paradigm, ...
%                              subject_id...
%                              );
    clear testEEG
    output = {output_train, output_test};
    results(subj).train_acc = output_train.accuracy;
    results(subj).test_acc = output_test.accuracy;
    results(subj).min_subject_sequence = min_best_sequence(:,subj); 
    max_evaluation_time = eval_duration + trial_dur;
    p1 = min_best_sequence(1,subj);
    p2 = res.correct(end);
    n_targets = paradigm.stimuli_count;
    min_evaluation_time = eval_duration + ((paradigm.isi+paradigm.stimulation)*0.001)*paradigm.stimuli_count*min_best_sequence(2,subj);
    results(subj).max_itr = evaluation_ITR(n_targets, p1, min_evaluation_time);
    results(subj).min_itr = evaluation_ITR(n_targets, p2, max_evaluation_time);
end
% plot_results_minSequenceERP(min_best_sequence, set.title);
disp(['Average accuracy on ' set.title ' ' num2str(mean(interSubject_results))]);
end

