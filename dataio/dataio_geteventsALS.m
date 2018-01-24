function [events] = dataio_geteventsALS(trialsStimulation, trialsOnSet, stimDuration)
%DATAIO_GETEVENTSALS Summary of this function goes here
%   Detailed explanation goes here
% created : 10-11-2017
% last modified: -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% events.pos
% evetns.desc

stimuli_repetition = 10;
stimuli = 12;
n_stimuli = stimuli * stimuli_repetition;
trialDuration = n_stimuli * stimDuration;
trialsOffSet = trialsOnSet + trialDuration;

for i=1:length(trialsOnSet)
    idx(i,:) = trialsOnSet(i):stimDuration:trialsOffSet(i);
end
events.pos = idx(:,1:n_stimuli);
events.desc = trialsStimulation(events.pos);
end

