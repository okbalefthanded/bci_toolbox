function [EEG] = dataio_read_file(folder, file)
%DATAIO_READ_FILE read a single epoched EEG file stored in folder
% Input :
%    folder : str : path of an epoched dataset.
%    file   : int : index of file, assuming the files are ordered in an
%                   increasing order following the date of creation.
% Returns:
%     EEG: an EEG struct file
% created 29-04-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
sets_root = 'datasets\epochs\';
set = dir([sets_root,folder,'\*.mat']);
if(isempty(set))
    error('Folder not found: errounous path or does not exist');
else if(length(set) < file)
        error('file index exceeds set length');
    end
end
set = {set.name};
file_name = [sets_root,folder,'\',set{file}];
EEG = load(file_name);
EEG = EEG.trainEEG;
end

