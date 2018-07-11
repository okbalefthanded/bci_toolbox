function [] = dataio_create_epochs_SM_ALS(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_SM_ALS : segment ALS-P300 dataset and save epochs
%   in seperate files for each subject
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
% Epoched files are aved in the folder: datasets/epochs/P300-ALS/SM
% Example :
%     dataio_create_epochs_SM_ALS([0 800], [0.5 10])
%
% Dependencies :
%   eeg_filter.m from EEGLAB toolbox

% created : 07-11-2018
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
%                phrase     : character per trial

% dataset paradigm:
% 125ms stimulations - 125 ms ISI

tic
paradigm.title = 'P300_ALS';
paradigm.stimulation = 125;
paradigm.isi = 125;
paradigm.repetition = 10;
paradigm.stimuli_count = 12;
paradigm.type = 'RC';

disp('Creating epochs for P300-ALS dataset');

% dataset
set_path = 'datasets\P300-ALS';
dataSetFiles = dir([set_path '\A*.mat']);
dataSetFiles = {dataSetFiles.name};
labels = dir([set_path '\labels.mat']);
labels = {labels.name};
target_phrase = load(labels{:});
nSubj = 8;
trainEEG = cell(1);
testEEG = cell(1);
train_trials = 1:15;
test_trials = 16:35;
phrase_train = target_phrase.labels(train_trials);
phrase_test = target_phrase.labels(test_trials);

% paradigm
stimulation = 125; % in ms
isi = 125; % in ms
fs = 256; % in Hz
stimDuration = ( (stimulation + isi) / 10^3 ) * fs;

% processing parameters
wnd = (epoch_length * fs) / 10^3;
filter_order = 2;

% save data
Config_path_SM = 'datasets\epochs\P300-ALS\SM';

if isempty(filter_band)
    Config_path_SM = [Config_path_SM];
else
    % TODO
    Config_path_SM = [Config_path_SM];
end

if(~isdir(Config_path_SM))
    mkdir(Config_path_SM);
end

for subj= 1:nSubj
    
    subject = strsplit(dataSetFiles{subj}, '.');
    subject = subject{1};
    disp(['Loading data for subject: ' subject]);
    load(dataSetFiles{subj});
    clab = data.channels;
    
    s = eeg_filter(data.X, fs, filter_band(1), filter_band(2), filter_order);
    events = dataio_geteventsALS(data.y_stim, data.trial, stimDuration);
    events_train.pos = events.pos(train_trials, :);
    events_train.desc = events.desc(train_trials, :);
    events_test.pos = events.pos(test_trials, :);
    events_test.desc = events.desc(test_trials, :);
    trials_train_count = length(train_trials);
    trials_test_count = length(test_trials);
    
    for trial = 1:trials_train_count
        disp(['Segmenting Train data for subject: ' subject ' Trial: ' num2str(trial)]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_train.pos(trial, :), s);
        trainEEG.epochs.signal(:,:,:,trial) = eeg_epochs;
        trainEEG.epochs.events(:,trial) = events_train.desc(trial, :);
        trainEEG.epochs.y(:,trial) = dataio_getlabelERP(events_train.desc(trial, :), phrase_train(trial), 'RC');
    end
    trainEEG.phrase = phrase_train;
    trainEEG.fs = fs;
    trainEEG.montage.clab = clab;
    trainEEG.classes = {'target', 'non_target'};
    trainEEG.paradigm = paradigm;
    trainEEG.subject.id = subject;
    trainEEG.subject.gender = data.gender;
    trainEEG.subject.age = data.age;
    trainEEG.subject.condition.ALSfrs = data.ALSfrs;
    trainEEG.subject.condition.onsetALS = data.onsetALS;
    disp(['Processing train data succeed for subject: ' subject]);
    save([Config_path_SM,'\','S0',num2str(subj),'trainEEG.mat'],'trainEEG', '-v7.3');
    
    clear trainEEG
    
    for trial = 1:trials_test_count
        disp(['Segmenting Test data for subject: ' subject ' Trial: ' num2str(trial)]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_test.pos(trial, :), s);
        testEEG.epochs.signal(:,:,:,trial) = eeg_epochs;
        testEEG.epochs.events(:,trial) = events_test.desc(trial, :);
        testEEG.epochs.y(:,trial) = dataio_getlabelERP(events_test.desc(trial, :), phrase_test(trial), 'RC');
    end
    testEEG.phrase = phrase_test;
    testEEG.fs = fs;
    testEEG.montage.clab = clab;
    testEEG.classes = {'target', 'non_target'};
    testEEG.paradigm = paradigm;
    testEEG.subject.id = subject;
    testEEG.subject.gender = data.gender;
    testEEG.subject.age = data.age;
    testEEG.subject.condiution.ALSfrs = data.ALSfrs;
    testEEG.subject.condition.onsetALS = data.onsetALS;
    disp(['Processing Test data succeed for subject: ' subject]);
    
    save([Config_path_SM,'\','S0',num2str(subj),'testEEG.mat'],'testEEG', '-v7.3');  
    clear testEEG s
    disp('Data epoched saved in:');
    disp(Config_path_SM);    
end
toc
end

