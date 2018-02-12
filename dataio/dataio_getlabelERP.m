function [y] = dataio_getlabelERP(events, character, paradigm)
%DATAIO_GETLABELERP : returns binary labels vector 1/-1 target/non_target
%                            for different datasets and paradigms.
% Arguments:
%     In:
%         event : STRUCT 
%                 events.desc : DOUBLE [1xD] [1xstimulus_count]a vector of 
%                                 stimulus 
%                 events.pos : DOUBLE [1xD] [1xstimulus_count] a vector of
%                                   stimulus onset position in samples
%         
%         character : CHAR | STR [1] target character presented in during
%                             the actual trial.
%       
%         paradigm : STRING dataset stimulus presentation paradigm.
%     Returns:
%         y : DOUBLE [Nx1] [events_count 1] a vector of binary labels. 
% 
% 
% Example :
%      - called inside dataio function dataio_create_epochs_III_CH
%     trainEEG{subj}.epochs.y = dataio_getlabelERP(events.desc, ...,
%                                     train_set.TargetChar(tr), 'RC');
%     


% created : 10-10-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

speller_BCI2000 = ['A','B','C','D','E','F';
    'G','H','I','J','K','L';
    'M','N','O','P','Q','R';
    'S','T','U','V','W','X';
    'Y','Z','1','2','3','4';
    '5','6','7','8','9','_'];

% group_speller = [];

switch paradigm
    case 'RC'
        [target_row, target_column] = find(speller_BCI2000==character);
        target_row = target_row + 6;
        rows = events==target_row;
        columns = events==target_column;
        y = rows + columns;
        y(y==0) = -1;
    case 'SC'
%         TODO
    case 'GROUP'
%         TODO
    otherwise
        error('Incorrect Paraidgm');
end
end

