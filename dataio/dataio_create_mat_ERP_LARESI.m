function [] = dataio_create_mat_ERP_LARESI(folder)
%DATAIO_CREATE_MAT_ERP_LARESI convert CSV datafiles recorded in an
% ERP experiments using LARESI BCI as stimulation and
% OpenVibe (>= 2.2.0) to a mat file.
%
%   input: folder [1xN] path of the folder containing csv files to be
%           converted one subject at a time
%
%   output:
%      None
% saved EEG data format:
%       data : struct [1x1]
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
% created : 06-18-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic

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
        create_mat([set_path,'calib\',calib_files{file}], 'calib', ...
                   folder_parts, subject);
    end
else
    error('Calibration EEG file does not exist/not found');
end
% online copy data
if(~isempty(online_copy_files))
    nFiles = length(online_copy_files);
    for file = 1:nFiles
        create_mat([set_path,'online\copy\',online_copy_files{file}], 'copy', ...
                   folder_parts, subject);
    end
else
    error('Online Copy EEG file does not exist/not found');
end
% online free data
if(~isempty(online_free_files))
    nFiles = length(online_free_files);
    for file = 1:nFiles
        create_mat([set_path,'online\free\',online_free_files{file}], 'free', ...
                   folder_parts, subject);
    end
else
     error('Online Free EEG file does not exist/not found');
end
utils_get_time(toc);
end

function create_mat(file_signal, mode, folder_parts, subject)
% fs, montage, signal, events
disp(['Processing file: ', file_signal]);
fid = fopen(file_signal);
num_attrib = 21; %fs, epoch, 16 channels (max possible at the lab, event id, event
fmt = repmat('%s', 1, num_attrib);
datacell = textscan(fid, fmt, 'Delimiter', ',', 'CollectOutput', 1);
fclose(fid);
%
header = datacell{1,1}(1,:);
event_id_idx = find(strcmp(header, 'Event Id'), 1);
fs = strsplit(header{1},':');
fs = strsplit(fs{2},'Hz');
fs = str2double(fs{1});
montage = header(3:event_id_idx-1);
nCells = event_id_idx - 1;
%
disp('Processing Signal...');
all = datacell{:};
all_str = all(2:end,3:nCells);
all_str = cellfun(@(x) x(1,1:10), all_str, 'UniformOutput', false); % 10 for precision
signal = cellfun(@str2num, all_str);
%
disp('Processing Markers...');
markers = all(2:end, event_id_idx:event_id_idx+2);
emptyEntries = ~cellfun(@isempty, markers);
markers = markers(emptyEntries(:,1), :);

clear datacell datacell_stim all_str
length_markers_each = cell2mat(cellfun(@length, markers(:,1), 'UniformOutput', false));
length_markers = unique(length_markers_each);

if(length(length_markers) > 1)
    % in some entries a single entry of markers has two : makrer1:marker2
    % longer_markers_id = length_markers_each == length_markers(2);
    tmp_pos = cellfun(@(s) strsplit(s, ':'),markers(:,2),'UniformOutput', false);
    tmp_markers = cellfun(@(s) strsplit(s, ':'),markers(:,1),'UniformOutput', false);
    data.events.pos = str2double([tmp_pos{:}]');
    data.events.desc = str2double([tmp_markers{:}]');
else
    % sequential markers, normal case
    data.events.desc = cell2mat(cellfun(@str2num, markers(:,1),  'UniformOutput', false));
    data.events.pos = cell2mat(cellfun(@str2num, markers(:,2),  'UniformOutput', false));
end

data.events = dataio_geteventsLARESI(data.events, fs);
paradigm.title = 'Inverted_Face_Speller';
paradigm.stimulation = 100;
paradigm.isi = 50;
paradigm.repetition = 10;
paradigm.stimuli_count = 9;
paradigm.type = 'SC';

% all data
data.signal = signal;
data.fs = fs;
data.montage = montage;
data.paradigm = paradigm;
data.subject = subject;
data.mode = mode;
if(strcmp(mode,'calib') || strcmp(mode,'copy'))
    data.desired_phrase = '123456789';
end

if(isnan(str2double(folder_parts(end))))
    subject_folder = [folder_parts{end-1} '\' folder_parts{end}];
else
    subject_folder = ['\',folder_parts(end)];
end
file_date = dir(file_signal);
file_date = file_date.date;
date = datestr(file_date,'dd_mmmm_yyyy_HH.MM.SS.FFF');
disp(['Creating mat files for subject: ' data.subject]);
% save
tmp = strsplit(file_signal, 'CSV');
path = [tmp{1},'raw_mat\'];

if(~exist(path,'dir'))
    mkdir(path);
end
if(strcmp(mode,'copy') || strcmp(mode,'free'))
    path = [path,subject_folder,'\online\',mode,'\'];
else
    path = [path,subject_folder,'\calib\'];
end

if(~exist(path,'dir'))
    mkdir(path);
end
file_name = [path data.subject,'_',date,'_erp_laresi_',mode,'.mat'];
save(file_name, 'data');
disp([' file saved in: ', file_name]);
end

