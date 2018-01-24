function [] = dataio_create_epochs_ALS(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_ALS Summary of this function goes here
%   Detailed explanation goes here
% created : 10-08-2017
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
set_path = '..\datasets\P300-ALS';
dataSetFiles = dir([set_path '\A*.mat']);
dataSetFiles = {dataSetFiles.name};
labels = dir([set_path '\labels.mat']);
labels = {labels.name};
target_phrase = load(labels{:});
nSubj = 8;
trainEEG = cell(1, nSubj);
testEEG = cell(1, nSubj);
train_trials = 1:15;
test_trials = 16:35;
phrase_train = target_phrase.labels(train_trials);
phrase_test = target_phrase.labels(test_trials);

% paradigm
stimulation = 125; % in ms
isi = 125; % in ms
fs = 256;
stimDuration = ( (stimulation + isi) / 10^3 ) * fs;

% processing parameters
wnd = (epoch_length * fs) / 10^3;
filter_order = 2;

for subj= 1:nSubj
    
    subject = strsplit(dataSetFiles{subj}, '.');
    subject = subject{1};
    disp(['Loading data for subject: ' subject]);
    load(dataSetFiles{subj});
    clab = data.channels;
    channels = length(clab);
    
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
        %
        %         dur = [0:diff(wnd)]'*ones(1, length(events_train.pos(trial, :)));
        %         tDur = size(dur,1);
        %         epoch_idx = bsxfun(@plus, dur, events_train.pos(trial, :));
        %         eeg_epochs = reshape(s(epoch_idx, :),[tDur length(events_train.pos(trial, :)) channels]);
        %         eeg_epochs = permute(eeg_epochs, [1 3 2]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_train.pos(trial, :), s);
        trainEEG{subj}.epochs.signal(:,:,:,trial) = eeg_epochs;
        trainEEG{subj}.epochs.events(:,trial) = events_train.desc(trial, :);
        trainEEG{subj}.epochs.y(:,trial) = dataio_getlabelERP(events_train.desc(trial, :), phrase_train(trial), 'RC');
    end
    trainEEG{subj}.phrase = phrase_train;
    trainEEG{subj}.fs = fs;
    trainEEG{subj}.montage.clab = clab;
    trainEEG{subj}.classes = {'target', 'non_target'};
    trainEEG{subj}.paradigm = paradigm;
    trainEEG{subj}.subject.id = subject;
    trainEEG{subj}.subject.gender = data.gender;
    trainEEG{subj}.subject.age = data.age;
    trainEEG{subj}.subject.condition.ALSfrs = data.ALSfrs;
    trainEEG{subj}.subject.condition.onsetALS = data.onsetALS;
    disp(['Processing train data succeed for subject: ' subject]);
    
    
    for trial = 1:trials_test_count
        disp(['Segmenting Test data for subject: ' subject ' Trial: ' num2str(trial)]);
        %         dur = [0:diff(wnd)]'*ones(1, length(events_test.pos(trial, :)));
        %         tDur = size(dur,1);
        %         epoch_idx = bsxfun(@plus, dur, events_test.pos(trial, :));
        %         eeg_epochs = reshape(s(epoch_idx, :),[tDur length(events_test.pos(trial, :)) channels]);
        %         eeg_epochs = permute(eeg_epochs, [1 3 2]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_test.pos(trial, :), s);
        testEEG{subj}.epochs.signal(:,:,:,trial) = eeg_epochs;
        testEEG{subj}.epochs.events(:,trial) = events_test.desc(trial, :);
        testEEG{subj}.epochs.y(:,trial) = dataio_getlabelERP(events_test.desc(trial, :), phrase_test(trial), 'RC');
    end
    testEEG{subj}.phrase = phrase_test;
    testEEG{subj}.fs = fs;
    testEEG{subj}.montage.clab = clab;
    testEEG{subj}.classes = {'target', 'non_target'};
    testEEG{subj}.paradigm = paradigm;
    testEEG{subj}.subject.id = subject;
    testEEG{subj}.subject.gender = data.gender;
    testEEG{subj}.subject.age = data.age;
    testEEG{subj}.subject.condiution.ALSfrs = data.ALSfrs;
    testEEG{subj}.subject.condition.onsetALS = data.onsetALS;
    disp(['Processing Test data succeed for subject: ' subject]);
    
end
% save data
% save data
allEpoched_path = '..\datasets\epochs\P300-ALS\';
Config_path = '..\datasets\epochs\P300-ALS\';


if isempty(filter_band)
    %     allEpoched_path = [allEpoched_path 'Raw\all_epochs'];
    Config_path = [Config_path];
else
    %     allEpoched_path = [allEpoched_path 'all_epochs'];
    Config_path = [Config_path];
    
end

% save([allEpoched_path '\allEpochs.mat'],'allEpochs');
save([Config_path '\trainEEG.mat'],'trainEEG');
save([Config_path '\testEEG.mat'],'testEEG');

disp('Data epoched saved in:');
% disp(allEpoched_path);
disp(Config_path);

toc
end

