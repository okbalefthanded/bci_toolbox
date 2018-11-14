function [stimulation, pause] = dataio_getExperimentInfo(events)
%DATAIO_GETEXPERIMENTINFO Summary of this function goes here
%   Detailed explanation goes here
% created : 11-14-2018
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

startStop = events.desc == OVTK_StimulationId_VisualStimulationStart | ...
            events.desc == OVTK_StimulationId_VisualStimulationStart + 1;
posStartStop = events.pos(startStop);
posStartStop = posStartStop(1:2);
stimulation = diff(posStartStop);
idx = events.desc > Base_Stimulations & events.desc <= Base_Stimulations + 9 | events.desc == OVTK_StimulationId_VisualStimulationStart + 1;
idx2 = events.desc > Base_Stimulations & events.desc <= Base_Stimulations + 9 | events.desc == OVTK_StimulationId_VisualStimulationStart;

posStartStop = events.pos(idx);
posStartStop = posStartStop(1:2);

posStartStop2 = events.pos(idx2);
posStartStop2 = posStartStop2(1:2);

fixation = diff(posStartStop2);
pause = diff(posStartStop) - fixation;

end

