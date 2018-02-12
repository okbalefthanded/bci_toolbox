function [events] = dataio_geteventsALS(trialsStimulation, trialsOnSet, stimDuration)
%DATAIO_GETEVENTSALS: create events struct for P300-ALS dataset
%                            
% Arguments:
%     In:
%        trialsStimulation : INT16 [Nx1] [signal_length_in_samplesx1] 
%                              a vector of stimulus presented to subjects
%                              following signal samples.
%         
%        trialsOnSet : DOUBLE [1xM] [1xtrials] a vector of trials start
%                           in signal in samples.
%       
%        stimDuration : DOUBLE duration of stimulation + isi (SOA)
%     Returns:
%        events : STRUCT
%                 event.pos  DOUBLE [NxD] [trials total_stimulations]
%                            a matrix of stimulations onset
%                 event.desc INT16 [NxD] [trials total_stimulations]
%                            a matrix of stimulation description
% 
% Example :
%       called inside dataio function dataio_create_epochs_ALS
%     s = eeg_filter(data.X, fs, filter_band(1), filter_band(2), filter_order);
%     events = dataio_geteventsALS(data.y_stim, data.trial, stimDuration);
%     

% created : 10-11-2017
% last modified: -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

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

