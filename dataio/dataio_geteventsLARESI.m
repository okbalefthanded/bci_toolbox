function [events] = dataio_geteventsLARESI(raw_events, fs)
%DATAIO_GETEVENTSLARESI Summary of this function goes here
%   Detailed explanation goes here
% created : 10-17-2017
% last modified: -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% events.pos
% evetns.desc

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
events.y = y;
idx = raw_events.desc > Base_Stimulations & raw_events.desc <= Base_Stimulations + 9;
events.desc = raw_events.desc(idx) - Base_Stimulations;
events.pos = floor(raw_events.pos(idx) * fs);
end

