function [frqs, idle_ind] = utils_get_frequencies(stimuli_frequencies)
%UTILS_GET_FREQUENCIES Summary of this function goes here
%   Detailed explanation goes here
% created 11-19-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
idle_ind = [];
% checking if data contain idle stat
if (iscell(stimuli_frequencies))
    stimFrqId = ~strcmp(stimuli_frequencies,'idle');
    idle_ind = find(~stimFrqId);
    frqs = cellfun(@str2num, stimuli_frequencies(stimFrqId));
else
    frqs = stimuli_frequencies;
end
end

