function [] = dataio_create_epochs_LARESI(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_LARESI Summary of this function goes here
%   Detailed explanation goes here
% created : 10-16-2017
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
set_path = '..\datasets\LARESI_FACE_SPELLER\raw_mat';
dataSetFiles = dir([set_path '\*.mat']);
dataSetFiles = {dataSetFiles.name};
nSubj = length(dataSetFiles);
trainEEG = cell(1, nSubj);
testEEG = cell(1, nSubj);
train_trials = 1:5;
test_trials = 6:9;

%
filter_order = 2;

for subj = 1:nSubj
    
    load(dataSetFiles{subj});
    disp(['Loading data for subject: ' data.subject]);
    % processing parameters
    wnd = (epoch_length * data.fs) / 10^3;
    phrase_train = data.desired_phrase(train_trials);
    phrase_test = data.desired_phrase(test_trials);
    channels = length(data.montage);
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
        %
        %         dur = [0:diff(wnd)]'*ones(1, length(events_train.pos(trial, :)));
        %         tDur = size(dur,1);
        %         epoch_idx = bsxfun(@plus, dur, events_train.pos(trial, :));
        %         eeg_epochs = reshape(s(epoch_idx, :),[tDur length(events_train.pos(trial, :)) channels]);
        %         eeg_epochs = permute(eeg_epochs, [1 3 2]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_train.pos(trial, :), s);
        trainEEG{subj}.epochs.signal(:,:,:,trial) = eeg_epochs;
        trainEEG{subj}.epochs.events(:,trial) = events_train.desc(trial, :);
        trainEEG{subj}.epochs.y(:,trial) = y_train(trial,:);
    end
    trainEEG{subj}.phrase = phrase_train;
    trainEEG{subj}.fs = data.fs;
    trainEEG{subj}.montage.clab = data.montage;
    trainEEG{subj}.classes = {'target', 'non_target'};
    trainEEG{subj}.paradigm = data.paradigm;
    trainEEG{subj}.paradigm.type = 'SC';
    trainEEG{subj}.subject.id = data.subject;
    trainEEG{subj}.subject.gender = 'M';
    trainEEG{subj}.subject.age = 0;
    trainEEG{subj}.subject.condition = 'healthy';
    disp(['Processing Train data succeed for subject: ' data.subject]);
    
    for trial = 1:trials_test_count
        disp(['Segmenting Test data for subject: ' data.subject]);
        %         dur = [0:diff(wnd)]'*ones(1, length(events_test.pos(trial, :)));
        %         tDur = size(dur,1);
        %         epoch_idx = bsxfun(@plus, dur, events_test.pos(trial, :));
        %         eeg_epochs = reshape(s(epoch_idx, :),[tDur length(events_test.pos(trial, :)) channels]);
        %         eeg_epochs = permute(eeg_epochs, [1 3 2]);
        eeg_epochs = dataio_getERPEpochs(wnd, events_test.pos(trial, :), s);
        testEEG{subj}.epochs.signal(:,:,:,trial) = eeg_epochs;
        testEEG{subj}.epochs.events(:,trial) = events_test.desc(trial, :);
        testEEG{subj}.epochs.y(:,trial) = y_test(trial,:);
    end
    testEEG{subj}.phrase = phrase_test;
    testEEG{subj}.fs = data.fs;
    testEEG{subj}.montage.clab = data.montage;
    testEEG{subj}.classes = {'target', 'non_target'};
    testEEG{subj}.paradigm = data.paradigm;
    testEEG{subj}.paradigm.type = 'SC';
    testEEG{subj}.subject.id = data.subject;
    testEEG{subj}.subject.gender = 'M';
    testEEG{subj}.subject.age = 0;
    testEEG{subj}.subject.condition = 'healthy';
    disp(['Processing Test data succeed for subject: ' data.subject]);
end
% filter data
% segment data
% valide data structure
% save
allEpoched_path = '..\datasets\epochs\LARESI_FACE_SPELLER_150\';
Config_path = '..\datasets\epochs\LARESI_FACE_SPELLER_150\';

if(~exist(Config_path,'dir'))
    mkdir(Config_path);
end

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

