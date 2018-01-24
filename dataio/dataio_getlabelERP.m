function [y] = dataio_getlabelERP(events, character, paradigm)
%DATAIO_GETLABELERP Summary of this function goes here
%   Detailed explanation goes here
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

