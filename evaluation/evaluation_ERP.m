function [results] = evaluation_ERP(output, paradigm, desired_phrase)
%EVALUATION_ERP : extract characters detected after binary classification
%
% Arguments:
%     In:
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
%         paradigm : STRUCT 1x1 experimental protocol.
%                  paradigm.title STR paradigm description.
%                  paradigm.stimulation DOUBLE stimulation duration in msec
%                  paradigm.isi DOUBLE ISI in msec.
%                  paradigm.repetition DOUBLE stimuli repetition.
%                  paradigm.stimuli_count DOUBLE number of stimuli in
%                         paradigm experiement.
%                  paradigm.type STR
%
%         derised_phrase : STR correct characters presented to the subject
%                           during trials.
%     Returns:
%         results : STRUCT 1x1
%                  results.phrase : CHAR [NxM] [repetition trials] matriix
%                      of characters detected per repetition
%                  results.correct : [Lx1] DOUBLE vector of rate of
%                      correct detected characters per repetition.
% Example :
%      call inside run_analysis_ERP function
%      results = evaluation_ERP(output, test_features.paradigm, ...,
%                                     testEEG{subj}.phrase);
% See Also run_analysis_ERP.m

% created 11-05-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

step = paradigm.repetition * paradigm.stimuli_count;
score = zeros(1, length(paradigm.stimuli_count));
character_idx = 1;
if(strcmp(output.alg.learner,'BLDA'))
    yy = output.score;
else
    yy = output.y;
end
for idx = 1:step:length(output.y)
    %     y_tmp = output.y(idx:idx+step-1);
    y_tmp = yy(idx:idx+step-1);
    e_tmp = output.events(idx:idx+step-1);
    for repetition = 1:paradigm.repetition
        yy_tmp = y_tmp(1:repetition*paradigm.stimuli_count);
        ee_tmp = e_tmp(1:repetition*paradigm.stimuli_count);
        for idx_event = 1:paradigm.stimuli_count
            if(strcmp(output.alg.learner,'BLDA'))
                tmp = yy_tmp(ee_tmp==idx_event);
            else
                tmp = yy_tmp(ee_tmp==idx_event)==1;
            end
            score(idx_event) = sum(tmp) / paradigm.stimuli_count;
        end
        results.phrase(repetition, character_idx) = utils_get_CharacterERP(score, paradigm);
    end
    character_idx = character_idx + 1;
end
idx = repmat(desired_phrase, paradigm.repetition, 1) == results.phrase;
results.correct = (sum(idx,2) / length(desired_phrase)) * 100;
% results.incorrect_characters = desired_phrase(~idx);
% desired_phrase
% results.phrase
%         idx = desired_phrase(character_idx) == results.phrase;
%         results.correct(repetition,character_idx) = (sum(idx) / length(desired_phrase)) * 100;
%         results.incorrect_characters{repetition, character_idx} = desired_phrase(~idx);
end


