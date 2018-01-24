function [character] = utils_get_CharacterERP(score, paradigm)
%UTILS_GET_CHARACTERERP Summary of this function goes here
%   Detailed explanation goes here

% created 11-05-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

speller_BCI2000 = ['A','B','C','D','E','F';
    'G','H','I','J','K','L';
    'M','N','O','P','Q','R';
    'S','T','U','V','W','X';
    'Y','Z','1','2','3','4';
    '5','6','7','8','9','_'];

switch upper(paradigm.type)
    case 'RC'
        %         TODO
        if(paradigm.stimuli_count == 12)
            [~, column] = max(score(1:6));
            [~, row] = max(score(7:12));
            character = speller_BCI2000(row, column);
        else
            %             TODO
        end
    case 'SC'
        %         TODO
        [~, character] = max(score);
        character = num2str(character);
    case 'GROUP'
        %         TODO
    otherwise
        error('Incorrect paradigm type');
end

end

