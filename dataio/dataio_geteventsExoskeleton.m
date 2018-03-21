function [events] = dataio_geteventsExoskeleton(header)
%DATAIO_GETEVENTSEXOSKELETON converts SSVEP-Exoskeleton gdf format events
%  into to the format used in this toolbox
% Arguments:
%     In:
%         header : STRUCT
%
%
%     Returns:
%         events : DOUBLE
%                     events.y [Mx1] [stimulations_count 1] a vector of
%                       class labels 
% `                   events.desc [Mx1] [stimulations_count 1] a vector
%                       of events descriptions following OV code
%                     evetns.pos [Mx1] [stimulations_count 1] a vector
%                       of events onset in samples.
%
% Example :
%      called inside dataio function dataio_create_epochs_Exoskeleton
%      events = dataio_geteventsExoskeleton(header);
%
% created : 03-21-2018
% last modified: -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% ExperimentStart: 32769, 0x00008001,
% ExperimentStop: 32770, 0x00008002
% VisualStimulationStart: 32779, 0x0000800b
% VisualStimulationStop: 32780, 0x0000800c
% Label_00: 33024, 0x00008100, idle
% Label_01: 33025, 0x00008101, 13hz
% Label_02: 33026, 0x00008102, 21 hz
% Label_03: 33027, 0x00008103, 17 hz

OVTK_StimulationId_VisualStimulationStart = 32779;
label_00 = 33024;
label_01 = 33025;
label_02 = 33026;
label_03 = 33027;
events.desc = header.EVENT.TYP( header.EVENT.TYP == label_00 | ...
                                header.EVENT.TYP == label_01 | ...
                                header.EVENT.TYP == label_02 | ...
                                header.EVENT.TYP == label_03);
events.pos = header.EVENT.POS(header.EVENT.TYP == OVTK_StimulationId_VisualStimulationStart);
events.y = events.desc - 33023;
end

