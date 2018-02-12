function [data] = dataio_read_ERP(set, datatype)
%DATAIO_READ_ERP  : dispatcher function to read epoched data called
%                    from run_analysis_ERP functions
% Arguments:
%     In:
%         set : STR datset title from a list of availble datasets.
%
%         datatype : STR wether load train or test dataset.
%
%     Returns:
%         data : cell{1xN} N subjects in dataset of STRUCT
%                  data.epochs 1x1 STRUCT
%                       data.epochs.signal DOUBLE 4D-matrix [NxMxLxP] 
%                          [sample channels epochs trials] of total epochs.
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
%                  data.paradigm STRUCT 1x1
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



% created 10-30-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
disp(['EVALUATING: dataio_read_ERP -- ARGUMNETS: ' set]);

path = 'BCI_TOOLBOX\datasets\epochs\';
switch upper(set)
    
    case 'LARESI_FACE_SPELLER_120'
        laresi_set_path = [path 'LARESI_FACE_SPELLER_120\'];
        if (strcmp(datatype,'train'))
            data = load([laresi_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([laresi_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
    case 'LARESI_FACE_SPELLER_150'
        laresi_set_path = [path 'LARESI_FACE_SPELLER_150\'];
        if (strcmp(datatype,'train'))
            data = load([laresi_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([laresi_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    case 'P300_ALS'
        p300_als_set_path = [path 'P300-ALS\'];
        if (strcmp(datatype,'train'))
            data = load([p300_als_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([p300_als_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    case 'III_CH'
        ch_III_set_path = [path 'Comp_III_ch_2004\Comp_config\'];
        if (strcmp(datatype,'train'))
            data = load([ch_III_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([ch_III_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    case 'EPFL_IMAGE_SPELLER'
        epfl_set_path = [path 'EPFL\'];
        if (strcmp(datatype,'train'))
            data = load([epfl_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([epfl_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    otherwise
        error('Incorrect Dataset');
        
end
end

