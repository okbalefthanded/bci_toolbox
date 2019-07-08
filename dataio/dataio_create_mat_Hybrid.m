function [] = dataio_create_mat_Hybrid(folder, ssvep_stimuli)
%DATAIO_CREATE_MAT_HYBRID Sconvert CSV datafiles recorded in 
% Hybrid ERP/SSVEP experiments using OpenVibe (>= 2.2.0) to a mat file.
%
%   input: folder [1xN] path of the folder containing csv files to be
%           converted one subject at a time
%   ssvep_stimuli cell{1xN} : paradigm stimuli
%   output:
%      None
% saved EEG data format:
%       data : struct [1x1]
%             .erp   : struct [1x1]
%             .ssvep : struct [1x1]
%            each has the following fields:
%               .signal : [Samples x Channels] continuous EEG signal.
%               .events : struct [1x1]
%                        .y    [Mx1] [stimulations_count 1] a vector of
%                               binary class labels 1/-1 target/non_target
% `                      .desc [Mx1] [stimulations_count 1] a vector
%                               of events descriptions in numbers (1-9)
%                        .pos  [Mx1] [stimulations_count 1] a vector
%                               of events onset in samples.
%               .fs     : double : sampling rate.
%               .montage : cell of string containing channels names
%               .paradigm : struct [1x1]
%                       .stimulation: double : stimulation duration
%                       .pause: double : break duration
%                       .title: string : paradigm title
%                       .stimuli: cell of strings : experiment stimulations
%                       .stimuli_count: double : number of stimulations
%                       .type: string : stimulation method
%             .subject : string : subject name/id
%             .mode : string : operation mode for each paradigm
% created : 07-08-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
set_path = ['datasets\',folder];
folder_parts = strsplit(folder, '\');
subject = folder_parts{3};

calib_folder = [set_path,'\calib'];
online_copy_folder = [set_path,'\online\copy'];
online_free_folder = [set_path,'\online\free'];

calib_files = dir([calib_folder,'\*.csv']);
calib_files = {calib_files.name};
online_copy_files =  dir([online_copy_folder,'\*.csv']);
online_copy_files = {online_copy_files.name};
online_free_files =  dir([online_free_folder,'\*.csv']);
online_free_files = {online_free_files.name};


% calib data
if(~isempty(calib_files))
    nFiles = length(calib_files);
    for file = 1:nFiles
        dataio_create_mat_calib_Hybrid(folder, ssvep_stimuli);
    end
else
    error('Calibration EEG file does not exist/not found');
end
% online copy data
if(~isempty(online_copy_files))
    nFiles = length(online_copy_files);
    for file = 1:nFiles
        dataio_create_mat_online_Hybrid(folder, ssvep_stimuli);
    end
else
    error('Online Copy EEG file does not exist/not found');
end
% online free data
if(~isempty(online_free_files))
    nFiles = length(online_free_files);
    for file = 1:nFiles
       % TODO 
    end
else
     error('Online Free EEG file does not exist/not found');
end
utils_get_time(toc);
end

