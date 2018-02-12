function [events] = dataio_getevents_BCI2000(StimulusCode, stimDuration)
%DATAIO_GETEVENTS_BCI2000 : converts BCI2000 markers format into the 
%   started format used in this toolbox
%                            
% Arguments:
%     In:
%         StimulusCode : DOUBLE [1XT] [1xsamples] vector of stimulus 
%                        presented to subject following the paradim timing   
%         
%         stimDuration : DOUBLE stimulation+isi duration (SOA)   
%         
%     Returns:
%         event : STRUCT 
%                 events.desc : DOUBLE [1xD] [1xstimulus_count]a vector of 
%                                 stimulus 
%                 events.pos : DOUBLE [1xD] [1xstimulus_count] a vector of
%                                   stimulus onset position in samples
% 
% Example :
%    called inside dataio functions related to BCI2000 datasets, looping
%     over trials.
%       
%    events = dataio_getevents_BCI2000(train_set.StimulusCode(tr, :),..., 
%                                         stimDuration);
%       
   

% created : 10-10-2017
% last modified: -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
events_id = 1:stimDuration:length(StimulusCode);
events.desc = StimulusCode(events_id);
events.desc(events.desc == 0) = [];
events.pos = events_id(1:length(events.desc));
end

