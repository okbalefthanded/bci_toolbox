function [] = dataio_create_mat_LARESI(files)
%DATAIO_CREATE_MAT_LARESI Summary of this function goes here
%   Detailed explanation goes here
% created : 10-11-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% 80ms stimulations - 40 ms ISI
% 100ms stimulations - 50 ms ISI

file_signal = files{1};
file_markers = files{2};
files_parts = strsplit(file_signal, '\');
data.subject = files_parts{5};
disp(['Creating mat files for subject: ' data.subject]);

% signal & montage
fid = fopen(file_signal);
num_attrib = 12;
fmt = repmat('%s', 1, num_attrib);
datacell_signal = textscan(fid, fmt, 'Delimiter', ';', 'CollectOutput', 1);
fclose(fid);

% event markers
fid = fopen(file_markers);
num_attrib = 3;
fmt = repmat('%s',1, num_attrib);
datacell_stim = textscan(fid, fmt, 'Delimiter', ';', 'CollectOutput', 1);
fclose(fid);

data.montage = {datacell_signal{1,1}{1,2:end-1}};
data.fs = str2double(datacell_signal{1}{2,12});

all = datacell_signal{:};
all_str = all(2:end,2:11);
% c = reshape(b, [size(b,1) 10]);
all_str = cellfun(@(x) x(1,1:17), all_str, 'UniformOutput', false);
data.signal = cellfun(@str2num, all_str);

markers = datacell_stim{:};
markers = markers(2:end, 1:2);
data.events.pos = cell2mat(cellfun(@str2num, markers(:,1),  'UniformOutput', false));
data.events.desc = cell2mat(cellfun(@str2num, markers(:,2),  'UniformOutput', false));


data.paradigm.title = 'Inverted_Face_Speller';
data.paradigm.stimulation = 100;
data.paradigm.isi = 50;
data.paradigm.repetition = 10;
data.paradigm.stimuli_count = 9;
data.paradigm.type = 'SC';
data.desired_phrase = '123456789';
% save
tmp = strsplit(file_signal, 'subjects');
path = [tmp{1} 'raw_mat\'];
save([path data.subject '_150.mat'], 'data');

% % IMPORTANT NOTE: ??????
% % a remarkable difference on signal amplitude was noticed
% % when comparing the data in CSV format and the one convreted to
% vhdr????????????????
end

