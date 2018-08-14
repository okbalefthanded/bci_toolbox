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
trainEEG = cell(1);
testEEG = cell(1);
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
    
    for trial = 1:trials_train_count
        disp(['Segmenting Train data for subject:' data.subject]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_train.pos(trial, :), s);
        eeg_epochs = dataio_baselineCorrection(eeg_epochs, correctionInterval);
        trainEEG.epochs.signal(:,:,:,trial) = eeg_epochs;
        trainEEG.epochs.events(:,trial) = events_train.desc(trial, :);
        trainEEG.epochs.y(:,trial) = y_train(trial,:);
    end
    trainEEG.phrase = phrase_train;
    trainEEG.fs = data.fs;
    trainEEG.montage.clab = data.montage;
    trainEEG.classes = {'target', 'non_target'};
    trainEEG.paradigm = data.paradigm;
    trainEEG.paradigm.type = 'SC';
    trainEEG.subject.id = data.subject;
    trainEEG.subject.gender = 'M';
    trainEEG.subject.age = 0;
    trainEEG.subject.condition = 'healthy';
    disp(['Processing Train data succeed for subject: ' data.subject]);
    save([Config_path_SM,'\','S0',num2str(subj),'trainEEG.mat'],'trainEEG', '-v7.3');
    clear trainEEG
    
    for trial = 1:trials_test_count
        disp(['Segmenting Test data for subject: ' data.subject]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_test.pos(trial, :), s);
        eeg_epochs = dataio_baselineCorrection(eeg_epochs, correctionInterval);
        testEEG.epochs.signal(:,:,:,trial) = eeg_epochs;
        testEEG.epochs.events(:,trial) = events_test.desc(trial, :);
        testEEG.epochs.y(:,trial) = y_test(trial,:);
    end
    testEEG.phrase = phrase_test;
    testEEG.fs = data.fs;
    testEEG.montage.clab = data.montage;
    testEEG.classes = {'target', 'non_target'};
    testEEG.paradigm = data.paradigm;
    testEEG.paradigm.type = 'SC';
    testEEG.subject.id = data.subject;
    testEEG.subject.gender = 'M';
    testEEG.subject.age = 0;
    testEEG.subject.condition = 'healthy';
    disp(['Processing Test data succeed for subject: ' data.subject]);
    save([Config_path_SM,'\','S0',num2str(subj),'testEEG.mat'],'testEEG', '-v7.3');
    clear s testEEG
    disp('Data epoched saved in:');
    disp(Config_path_SM);    
end
toc
end

