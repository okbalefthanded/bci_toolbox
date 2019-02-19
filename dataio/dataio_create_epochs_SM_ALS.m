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
% 
% Reference: 
%   A. Riccio, L. Simione, F. Schettini, A. Pizzimenti, M. Inghilleri, 
%   M. O. Belardinelli, D. Mattia, e F. Cincotti, «Attention and P300-based
%   BCI performance in people with amyotrophic lateral sclerosis», Front. 
%   Hum. Neurosci., vol. 7:, pag. 732, 2013.
%   DOI : 10.3389/fnhum.2013.00732

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
wnd_epoch = (epoch_length * fs) / 10^3;
%
correctionInterval = round([-100 0] * fs) / 10^3;
wnd = [correctionInterval(1) wnd_epoch(2)];
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

    data.paradigm = paradigm;
    data.fs = fs;
    data.subject = subject;
    
    s = eeg_filter(data.X, fs, filter_band(1), filter_band(2), filter_order);      
    
    events = dataio_geteventsALS(data.y_stim, data.trial, stimDuration);
    events_train.pos = events.pos(train_trials, :);
    events_train.desc = events.desc(train_trials, :);
    events_test.pos = events.pos(test_trials, :);
    events_test.desc = events.desc(test_trials, :);
    
    trials_train_count = length(train_trials);
    trials_test_count = length(test_trials);   
    
    disp(['Processing Train data succeed for subject: ' subject]);
    trainEEG = getEEGstruct(s, data, events_train, wnd, correctionInterval, phrase_train, trials_train_count);
    dataio_save_mat(Config_path_SM, subj, 'trainEEG');
    clear trainEEG
    
    disp(['Processing Test data succeed for subject: ' subject]);
    testEEG = getEEGstruct(s, data, events_test, wnd, correctionInterval, phrase_test, trials_test_count);
    dataio_save_mat(Config_path_SM, subj, 'testEEG');
    clear testEEG s
    
    disp('Data epoched saved in:');
    disp(Config_path_SM);    
end
toc
end

%%
function [EEG] = getEEGstruct(s, data, events, wnd, correctionInterval, phrase, trials_count)
for trial = 1:trials_count
    eeg_epochs = dataio_getERPEpochs(wnd, events.pos(trial, :), s);
    eeg_epochs = dataio_baselineCorrection(eeg_epochs, correctionInterval);
    EEG.epochs.signal(:,:,:,trial) = eeg_epochs;
    EEG.epochs.events(:,trial) = events.desc(trial, :);
    EEG.epochs.y(:,trial) = dataio_getlabelERP(events.desc(trial, :), phrase(trial), 'RC');
end
EEG.phrase = phrase;
EEG.fs = data.fs;
EEG.montage.clab = data.channels;
EEG.classes = {'target', 'non_target'};
EEG.paradigm = data.paradigm;
EEG.subject.id = data.subject;
EEG.subject.gender = data.gender;
EEG.subject.age = data.age;
EEG.subject.condiution.ALSfrs = data.ALSfrs;
EEG.subject.condition.onsetALS = data.onsetALS;
end

