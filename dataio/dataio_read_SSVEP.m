function [EEGdata] = dataio_read_SSVEP(set, datatype)
%DATAIO_READ_SSVEP : dispatcher function to read epoched data called
%                    from run_analysis_SSVEP functions
%  Arguments:
%     In:
%         set : STR datset title from a list of availble datasets.
%
%         datatype : STR wether load train or test dataset.
%
%     Returns:
%         data : cell{1xN} N subjects in dataset of STRUCT
%                  data.epochs 1x1 STRUCT
%                       data.epochs.signal DOUBLE 3D-matrix [NxMxL]
%                          [sample channels epochs] of total epochs.
%                       data.epochs.events DOUBLE [LxP] [epochs trials]
%                           a matrix of events description.
%                       data.epochs.y DOUBLE [LxP] [epochs trials]
%                           a matrix of binary labels.
%                  data.phrase STR target phrase.
%                  data.fs DOUBLE sampling rate.
%                  data.montage 1x1 STRUCT
%                       data.montage.clab cell of STR channels labels.
%                  data.classes cell {1x2} STR classes descriptions
%                       target , non_target
%                  data.paradigm STRUCT 1x1 experimental protocol.
%                       data.paradigm.title STR paradigm description.
%                       data.paradigm.stimulation DOUBLE stimulation
%                                       duration in msec
%                       data.paradigm.isi DOUBLE ISI in msec.
%                       data.paradigm.repetition DOUBLE stimuli repetition.
%                       data.paradigm.stimuli_count DOUBLE number of
%                                       stimuli in paradigm experiement.
%                       data.paradigm.type STR
%                  data.subject STRUCT 1X1
%                       data.subject.id STR subject id
%                       data.subject.gender CHAR male or female.
%                       data.subject.age DOUBLE subject age
%                       data.subject.condition STR health condition.
% Example :
%       set value defined in define_approach_ERP script and passed to
%           run_analysis_ERP
%    trainEEG = dataio_read_ERP(set,'train');
%

% created 03-21-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
disp(['EVALUATING: dataio_read_SSVEP -- ARGUMNETS: ' set.title]);

if(~isfield(set, 'mode'))
    set.mode = 'SM';
end

switch upper(set.mode)
    case 'BM'
        EEGdata = dataio_read_SSVEP_Batch(set.title, datatype);
    case 'SM'
        EEGdata = dataio_read_SSVEP_Single(set, datatype);
    otherwise
        error('Incorrect Data read mode');
end
end


