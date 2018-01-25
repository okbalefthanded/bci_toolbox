function [results] = evaluation_ERP(output, paradigm, desired_phrase)
%EVALUATION_ERP Summary of this function goes here
%   Detailed explanation goes here


% created 11-05-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>


step = paradigm.repetition * paradigm.stimuli_count;
score = zeros(1, length(paradigm.stimuli_count));
character_idx = 1;

for idx = 1:step:length(output.y)
    y_tmp = output.y(idx:idx+step-1);
    e_tmp = output.events(idx:idx+step-1);    
    for repetition = 1:paradigm.repetition
        yy_tmp = y_tmp(1:repetition*paradigm.stimuli_count);
        ee_tmp = e_tmp(1:repetition*paradigm.stimuli_count);
        for idx_event = 1:paradigm.stimuli_count
            tmp = yy_tmp(ee_tmp==idx_event)==1;
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


