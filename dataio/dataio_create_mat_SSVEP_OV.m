function [] = dataio_create_mat_SSVEP_OV(folder)
%DATAIO_CREAT_MAT_SSVEP_OV Summary of this function goes here
%   Detailed explanation goes here
% created : 01-10-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic
set_path = ['datasets\',folder];
dataSetFiles = dir([set_path,'\*.csv']);
dataSetFiles = {dataSetFiles.name};
file_signal = dataSetFiles{1};
file_markers = dataSetFiles{2};
% files_parts = strsplit(file_signal, '\');
% data.subject = files_parts{4};
folder_parts = strsplit(folder, '\');
date = folder_parts(end);
data.subject = folder_parts(end-1);
disp(['Creating mat files for subject: ' data.subject]);

% event markers
file_markers = [set_path, '\', file_markers];
fid = fopen(file_markers);
num_attrib = 3;
fmt = repmat('%s',1, num_attrib);
datacell_stim = textscan(fid, fmt, 'Delimiter', ';', 'CollectOutput', 1);
fclose(fid);

% signal & montage
file_signal = [set_path, '\', file_signal];
fid = fopen(file_signal);
% num_attrib_sig = 15; % nchannels + 2
num_attrib_sig = 18; % nchannels + 2, nchannels = 16 for the max possible electrodes I have at the lab %
fmt = repmat('%s', 1, num_attrib_sig);
datacell_signal = textscan(fid, fmt, 'Delimiter', ';', 'CollectOutput', 1);
fclose(fid);
%
montage = {datacell_signal{1,1}{1,2:end-1}};
emptyEntries = ~cellfun(@isempty, montage);
emptyEntries = emptyEntries(emptyEntries);
nCells = length(emptyEntries);
data.montage = montage(emptyEntries(1:end-1));
data.fs = str2double(datacell_signal{1}{2,nCells+1});
disp('Processing Signal...');
all = datacell_signal{:};
all_str = all(2:end,2:nCells);
% c = reshape(b, [size(b,1) 10]);
all_str = cellfun(@(x) x(1,1:17), all_str, 'UniformOutput', false);
data.signal = cellfun(@str2num, all_str);
disp('Processing Markers...');
markers = datacell_stim{:};
markers = markers(2:end, 1:2);
data.events.pos = cell2mat(cellfun(@str2num, markers(:,1),  'UniformOutput', false));
data.events.desc = cell2mat(cellfun(@str2num, markers(:,2),  'UniformOutput', false));
[data.paradigm.stimulation, data.paradigm.pause] = dataio_getExperimentInfo(data.events);
data.events = dataio_geteventsLARESI(data.events, data.fs);
clear datacell datacell_stim all_str
data.paradigm.title = 'SSVEP_OV';
stimuli = {'idle', '6','7.5','8.57','10'};
if(isscalar(unique(data.events.y)))
    data.paradigm.stimuli = stimuli{data.events.y(1)};
else
    data.paradigm.stimuli = stimuli; 
end
% data.paradigm.stimulation = 5000;
% data.paradigm.pause = 2000;

data.paradigm.stimuli_count = length(data.paradigm.stimuli);
data.paradigm.type = 'ON/OFF';

% data.paradigm.stimuli = {'6','7.5','8.57','10'};

% save
tmp = strsplit(file_signal, 'CSV');
path = [tmp{1} 'raw_mat\'];
if(~exist(path,'dir'))
    mkdir(path);
end
path = [path,date{:},'\'];
if(~exist(path,'dir'))
    mkdir(path);
end
save([path data.subject{:} date{:} '_ssvep_ov.mat'], 'data');
toc
end

