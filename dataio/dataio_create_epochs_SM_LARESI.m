function [] = dataio_create_epochs_SM_LARESI(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_SM_LARSESI segment LARESI Inverted face dataset
%   and save epochs in seperate files
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
%                       datasets\epochs\SM\LARESI_FACE_SPELLER_150
% Example :
%     dataio_create_epochs_SM_LARESI([0 800], [0.5 10])
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
% 80ms stimulations - 40 ms ISI
% 100ms stimulations - 50 ms ISI
% signal & montage
tic
disp('Creating epochs for LARESI INVERSE FACE SPELLER dataset');

% dataset
set_path = 'datasets\LARESI_FACE_SPELLER\raw_mat';
dataSetFiles = dir([set_path '\*.mat']);
dataSetFiles = {dataSetFiles.name};
nSubj = length(dataSetFiles);
train_trials = 1:5;
test_trials = 6:9;
%
filter_order = 2;
%
Config_path_SM = 'datasets\epochs\LARESI_FACE_SPELLER_150\SM';

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
    
    load(dataSetFiles{subj});
    disp(['Loading data for subject: ' data.subject]);
    % processing parameters
    wnd_epoch = (epoch_length * data.fs) / 10^3;
    correctionInterval = round([-100 0] * data.fs) / 10^3;
    wnd = [correctionInterval(1) wnd_epoch(2)];
    phrase_train = data.desired_phrase(train_trials);
    phrase_test = data.desired_phrase(test_trials);
    s = eeg_filter(data.signal, data.fs, filter_band(1), filter_band(2), filter_order);
    events = dataio_geteventsLARESI(data.events, data.fs);
    trials_train_count = length(train_trials);
    trials_test_count = length(test_trials);
    %
    epoch_count = data.paradigm.repetition * data.paradigm.stimuli_count;
    ii = repmat(1:epoch_count, length(data.desired_phrase), 1);
    rep = epoch_count * (length(data.desired_phrase) - 1);
    id = 0:epoch_count:rep;
    epoch_id = bsxfun(@plus, ii, repmat(id', 1, epoch_count));
    events_train.pos = events.pos(epoch_id(train_trials,:));
    events_train.desc = events.desc(epoch_id(train_trials,:));
    events_test.pos = events.pos(epoch_id(test_trials, :));
    events_test.desc = events.desc(epoch_id(test_trials, :));
    y_train = events.y(epoch_id(train_trials,:));
    y_test = events.y(epoch_id(test_trials, :));
    data.correctionInterval = correctionInterval;
    
    data.phrase = phrase_train;
    data.y = y_train;
    trainEEG = getEEGstruct(s, wnd, events_train, data, trials_train_count);
    dataio_save_mat(Config_path_SM, subj, 'trainEEG');
  
    disp(['Processing Train data succeed for subject: ' data.subject]);
    data.phrase = phrase_test;
    data.y = y_test;
    testEEG = getEEGstruct(s, wnd, events_test, data, trials_test_count);
    dataio_save_mat(Config_path_SM, subj, 'testEEG');
    
    disp(['Processing Test data succeed for subject: ' data.subject]);
    clear s testEEG
    disp('Data epoched saved in:');
    disp(Config_path_SM);
end
toc
end
%%
function [EEG] = getEEGstruct(s, wnd, events, data, trials_count)
for trial = 1:trials_count
    disp(['Segmenting Train data for subject:' data.subject]);
    eeg_epochs = dataio_getERPEpochs(wnd, events.pos(trial, :), s);
    eeg_epochs = dataio_baselineCorrection(eeg_epochs, data.correctionInterval);
    EEG.epochs.signal(:,:,:,trial) = eeg_epochs;
    EEG.epochs.events(:,trial) = events.desc(trial, :);
    EEG.epochs.y(:,trial) = data.y(trial,:);
end
EEG.phrase = data.phrase;
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
