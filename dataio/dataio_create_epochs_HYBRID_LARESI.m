function [] = dataio_create_epochs_HYBRID_LARESI(set, erp_epoch, erp_band, ssvep_epoch, ssvep_band)
%DATAIO_CREATE_EPOCHS_HYBRID_LARESI Summary of this function goes here
%   Detailed explanation goes here
% created : 07-08-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% EEG structure: epochs     : struct
%                           :       : signal :  [samples channels trials]
%                           :       : events :  [1 trials]
%                           :       : y      :  [1 trials]
%                fs         : sampling rate
%                montage    : clab
%                classes    : classes {F1,...Fn}
%                paradigm   : struct
%                           :        : title : [str]
%                           :        : stimulation 1
%                           :        : pause 1
%                           :        : stimuli_count 1
%                           :        : type [str]
%                           :        : stimuli [1 stimuli_count]
%                subject    : (depending on the availability of info about
%                                 the subject)

set_path = ['datasets\',set];
% folder_parts = strsplit(folder, '\');
% subject = folder_parts{3};


calib_folder = [set_path,'\calib'];
online_copy_folder = [set_path,'\online\copy'];
online_free_folder = [set_path,'\online\free'];

calib_files = dir([calib_folder,'\*.mat']);
calib_files = {calib_files.name};
online_copy_files =  dir([online_copy_folder,'\*.mat']);
online_copy_files = {online_copy_files.name};
online_free_files =  dir([online_free_folder,'\*.mat']);
online_free_files = {online_free_files.name};

% calib data
if(~isempty(calib_files))
    nFiles = length(calib_files);
    for file = 1:nFiles
        dataio_create_epochs_calib_HYBRID_LARESI(set, erp_epoch, erp_band, ...
                                          ssvep_epoch, ssvep_band);
    end
else
    error('Calibration EEG file does not exist/not found');
end
% online copy data
if(~isempty(online_copy_files))
    nFiles = length(online_copy_files);
    for file = 1:nFiles
        dataio_create_epochs_online_HYBRID_LARESI(set, erp_epoch, erp_band,...
                                           ssvep_epoch, ssvep_band);
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

