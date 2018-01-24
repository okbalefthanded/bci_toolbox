function [events] = dataio_getevents_BCI2000(StimulusCode, stimDuration)
%DATAIO_GETEVENTS_BCI2000 Summary of this function goes here
%   Detailed explanation goes here
% StimulusCode  : 1xT vector of stimulus code
% stimuli       : 1xd vector of stimuli
% created : 10-10-2017
% last modified: -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
events_id = 1:stimDuration:length(StimulusCode);
events.desc = StimulusCode(events_id);
events.desc(events.desc == 0) = [];
events.pos = events_id(1:length(events.desc));
end

