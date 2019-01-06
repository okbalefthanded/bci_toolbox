function [events] = dataio_geteventsOV(raw_events, fs)
%DATAIO_GETEVENTSOV  converts OpenVibe based events for datasets
%                           recorded at LARESI lab using OpenVibe SSVEP
%                           Demo into the format used in this toolbox
%
% Arguments:
%     In:
%         raw_events : STRUCT DOUBLE
%                     raw_events.pos [Nx1] [events_count 1] events on set
%                         in sec relative to experiment start.
%                     raw_events.desc [Nx1] [events_count 1] description of
%                           events in OpenVibe framework.
%
%         fs : DOUBLE [1] sampling frequency.
%
%
%     Returns:
%         events : DOUBLE 
%                     events.y [Mx1] [stimulations_count 1] a vector of 
%                       binary class labels 1/-1 target/non_target
% `                   events.desc [Mx1] [stimulations_count 1] a vector
%                       of events descriptions in numbers (1-9)
%                     evetns.pos [Mx1] [stimulations_count 1] a vector
%                       of events onset in samples.
%
% Example :
%       called inside dataio function dataio_create_epochs_LARESI
%      events = dataio_geteventsLARESI(data.events, data.fs);
%

% created : 12-19-2018
% last modified: -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% OpenVibe Stimulations
OVTK_StimulationId_TrialStart = 32773;
OVTK_StimulationId_TrialStop = 32774;
OVTK_StimulationId_ExperimentStart = 32769;
OVTK_StimulationId_ExperimentStop = 32770;
OVTK_StimulationId_VisualStimulationStart = 32779;
OVTK_StimulationId_Target = 33285;
OVTK_StimulationId_NonTarget = 33286;
Base_Stimulations = 33024;

y = raw_events.desc(raw_events.desc == OVTK_StimulationId_NonTarget | raw_events.desc == OVTK_StimulationId_Target);
y(y==OVTK_StimulationId_NonTarget) = -1;
y(y==OVTK_StimulationId_Target) = 1;
idx = raw_events.desc >= Base_Stimulations & raw_events.desc <= Base_Stimulations + 9;
events.desc = raw_events.desc(idx) - Base_Stimulations;
events.pos = floor(raw_events.pos(idx) * fs);
if (isempty(y))
    if(sum(events.desc==0))
        events.y = events.desc + 1;
    else
        events.y = events.desc;
    end
else
    events.y = y;
end
end

