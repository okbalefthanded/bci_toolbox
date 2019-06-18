function [] = dataio_create_epochs_ERP_LARESI(folder, epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_ERP_LARESI Summary of this function goes here
%   Detailed explanation goes here
% segment LARESI Inverted face dataset
%                             and save epochs in files
% Arguments:
%     In:
%         epoch_length : DOUBLE [1x2] [start end] in msec of epoch relative
%         to stimulus onset marker.
%         filter_band : DOUBLE [1x2] [low_cutoff high_cutoff] filtering
%             frequency band in Hz
%
%
%     Returns:
%      None.
% Epoched files are aved in the folder:
%                   datasets\epochs\LARESI_FACE_SPELLER\[SUBJECT]\[MODE]
% Example :
%     dataio_create_epochs_LARESI([0 800], [0.5 10])
%
% Dependencies :
%   eeg_filter.m from EEGLAB toolbox

% created : 06-18-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% EEG structure: epochs     : TxNxEpoxTr
%                             T   : time samples
%                             N   : channels
%                             Epo : epochs per trial
%                             Tr   : trial
%                y          : EpoxTr
%                             Epo : epochs per trial
%                             Tr  :  trial
%                fs         : sampling rate
% 80ms stimulations - 40 ms ISI
% 100ms stimulations - 50 ms ISI
% signal & montage
tic
disp('Creating epochs for LARESI INVERSE FACE SPELLER dataset');

if(strfind(folder,'subjects'))
    set_path = folder;
    files = dir(set_path);
    files = {files(3:end).name};
    nSubj = length(files);
else
    set_path = ['datasets\LARESI_FACE_SPELLER\subjects\',folder];
    nSubj = 1;
end

filter_order = 2;
%
Config_path_SM = 'datasets\epochs\LARESI_FACE_SPELLER\SM';

if(~exist(Config_path_SM,'dir'))
    mkdir(Config_path_SM);
end

if isempty(filter_band)
    Config_path_SM = [Config_path_SM];
else
    %TODO
    Config_path_SM = [Config_path_SM];
end

for subj = 1:nSubj
    tmp = set_path;
    if(nSubj > 1)       
        set_path = [set_path,'\',files{subj},'\raw_mat'];
        folders = dir(set_path);
        folders = folders(3:end);
        dates = datenum({folders.date});
        [~,sorted_idx] = sort(dates);
        folders = folders(sorted_idx);
        last_folder = folders(end).name;
        set_path = [set_path,'\',last_folder];
    end

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
            trainEEG = create_epochs([set_path,'\calib\',calib_files{file}],...
                                    'calib',epoch_length, filter_band,...
                                     filter_order);
        end
    else
        error('Calibration EEG file does not exist/not found');
    end
    
    % online copy data
    if(~isempty(online_copy_files))
        nFiles = length(online_copy_files);
        for file = 1:nFiles
            testEEG = create_epochs([set_path,'\online\copy\',online_copy_files{file}],... 
                                    'copy',epoch_length, filter_band,...
                                     filter_order);
        end
    else
        error('Online Copy EEG file does not exist/not found');
    end
    %%
    % TODO ONLINE FREE MODE DATA
    %%
    % save
    dataio_save_mat(Config_path_SM, subj, 'trainEEG');
    dataio_save_mat(Config_path_SM, subj, 'testEEG');    
    disp(['Processing Test data succeed for subject: ' trainEEG.subject.id]);
    disp('Data epoched saved in:');
    disp(Config_path_SM);
    set_path = tmp;
end
toc
end
%%
function [EEG] = create_epochs(path, mode, epoch_length, filter_band, filter_order)
load(path);
disp(['Loading data for subject: ' data.subject]);
% processing parameters
wnd_epoch = (epoch_length * data.fs) / 10^3;
correctionInterval = round([-100 0] * data.fs) / 10^3;
wnd = [correctionInterval(1) wnd_epoch(2)];
s = eeg_filter(data.signal, data.fs, filter_band(1), filter_band(2), filter_order);
%
epoch_count = data.paradigm.repetition * data.paradigm.stimuli_count;
ii = repmat(1:epoch_count, length(data.desired_phrase), 1);
rep = epoch_count * (length(data.desired_phrase) - 1);
id = 0:epoch_count:rep;
epoch_id = bsxfun(@plus, ii, repmat(id', 1, epoch_count));

data.correctionInterval = correctionInterval;
trials_count = length(data.desired_phrase);
EEG.phrase = data.desired_phrase;
for trial = 1:trials_count
    disp(['Segmenting Train data for subject:' data.subject]);
    eeg_epochs = dataio_getERPEpochs(wnd, data.events.pos(epoch_id(trial,:), :), s);
    eeg_epochs = dataio_baselineCorrection(eeg_epochs, data.correctionInterval);
    EEG.epochs.signal(:,:,:,trial) = eeg_epochs;
    EEG.epochs.events(:,trial) = data.events.desc(epoch_id(trial,:), :);
    EEG.epochs.y(:,trial) = data.events.y(epoch_id(trial,:),:);
end
EEG.fs = data.fs;
EEG.montage.clab = data.montage;
EEG.classes = {'target', 'non_target'};
EEG.paradigm = data.paradigm;
EEG.paradigm.type = 'SC';
EEG.subject.id = data.subject;
EEG.subject.gender = 'M';
EEG.subject.age = 0;
EEG.subject.condition = 'healthy';
end
