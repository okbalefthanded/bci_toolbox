function [] = dataio_create_epochs_EPFL(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_EPFL Summary of this function goes here
%   Detailed explanation goes here
% created : 10-19-2017
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
% 100 ms stimulations - 300 ms ISI
tic
disp('Creating epochs for EPFL Image ERP dataset');
% path to a session:
% datasets\EPFL\subject1\subject1\session1
% subject1\session1
%          \session2
%          \session3
%          \session4

reference = [7 24]; %1:32;         % indices of channels used as reference
%
data.paradigm.title = 'EPFL_Image_Speller';
data.paradigm.stimulation = 100;
data.paradigm.isi = 300;
data.paradigm.repetition = 20;
data.paradigm.stimuli_count = 6;
data.paradigm.type = 'SC';

disabled_subjects.id = {'S1','S2', 'S3', 'S4'};
disabled_subjects.gender = ['M','M', 'M', 'F'];
disabled_subjects.age = [56 51 47 33];
disabled_subjects.condition = {'Cerebral palsy','Multiple sclerosis',...
    'Late-stage amyotrophic lateral sclerosis',...
    'Traumatic brain and spinal-cord injury, C4 level'};

%
set_path = '..\datasets\EPFL';
set_subfolders = dir(set_path);
set_subfolders = set_subfolders(~ismember({set_subfolders.name},{'.','..'}));
nSubj = length(set_subfolders);
nSessions = 4;
trainEEG = cell(1, nSubj);
testEEG = cell(1, nSubj);
nTrain_session = 3;
eeg_channels = 1:32;
fs = 2048;
n_trials = 120;
%
downsample = 512;
decimation = fs / downsample;
filter_order = 2;
% wnd = (epoch_length * fs) / 10^3;
wnd = (epoch_length * downsample) / 10^3;
for subj=1:nSubj
    subject_path = [set_path '\' set_subfolders(subj).name];
    tr_trial = 1;
    for session = 1:nTrain_session
        session_path = [subject_path '\' set_subfolders(subj).name '\session' num2str(session)];
        runs = dir(session_path);
        runs = runs(~ismember({runs.name},{'.','..'}));
        runs_path = strcat(repmat({session_path}, 1, length(runs)), '\', {runs.name});
        
        for run = 1:length(runs)
            d = load(runs_path{run});
            n_channels = size(d.data, 1);
            ref = repmat(mean(d.data(reference, :),1), n_channels, 1);
            d.data = d.data - ref;
            d.data = d.data(eeg_channels,:);
            s = eeg_filter(d.data', fs, filter_band(1), filter_band(2), filter_order);
            s = s(1:decimation:end, :);
            disp(['Segmenting Train data for subject: subj' num2str(subj)]);
            %             pos = round(etime(d.events(1:n_trials,:), repmat(d.events(1,:), n_trials,1)) .* (fs) + 1 + 0.4*fs);
            
            pos = round(etime(d.events(1:n_trials,:), repmat(d.events(1,:), n_trials,1)) .* (downsample) + 1 + 0.4*downsample);
            %             dur = [0:diff(wnd)]'*ones(1, length(pos));
            %             tDur = size(dur,1);
            %             epoch_idx = bsxfun(@plus, dur, pos');
            %             eeg_epochs = reshape(s(epoch_idx, :),[tDur length(pos) length(eeg_channels)]);
            %             eeg_epochs = permute(eeg_epochs, [1 3 2]);
            eeg_epochs = dataio_getERPEpochs(wnd, pos, s);
            trainEEG{subj}.epochs.signal(:,:,:,tr_trial) = eeg_epochs;
            trainEEG{subj}.epochs.events(:,tr_trial) = d.stimuli(1:n_trials);
            trainEEG{subj}.epochs.y(d.stimuli(1:n_trials) == d.target, tr_trial) = 1;
            trainEEG{subj}.epochs.y(d.stimuli(1:n_trials) ~= d.target, tr_trial) = -1;
            data.desired_phrase(tr_trial) = num2str(d.target);
            tr_trial = tr_trial + 1;
        end
    end
    trainEEG{subj}.phrase = data.desired_phrase;
    trainEEG{subj}.fs = fs;
    trainEEG{subj}.montage.clab = '';
    trainEEG{subj}.classes = {'target', 'non_target'};
    trainEEG{subj}.paradigm = data.paradigm;
    if (subj < 5)
        trainEEG{subj}.subject.id = disabled_subjects.id{subj};
        trainEEG{subj}.subject.gender = disabled_subjects.gender(subj);
        trainEEG{subj}.subject.age = disabled_subjects.age(subj);
        trainEEG{subj}.subject.condition = disabled_subjects.condition{subj};
    else
        trainEEG{subj}.subject.id = ['subject ' num2str(subj)];
        trainEEG{subj}.subject.gender = '';
        trainEEG{subj}.subject.age = 0;
        trainEEG{subj}.subject.condition = 'healthy';
    end
    disp(['Processing Train data succeed for subject: ' num2str(subj)]);
    clear s d eeg_epochs
    data.desired_phrase = '';
    
    %     Test Data
    session = nTrain_session + 1;
    session_path = [subject_path '\' set_subfolders(subj).name '\session' num2str(session)];
    runs = dir(session_path);
    runs = runs(~ismember({runs.name},{'.','..'}));
    runs_path = strcat(repmat({session_path}, 1, length(runs)), '\', {runs.name});
    for run = 1:length(runs)
        d = load(runs_path{run});
        n_channels = size(d.data, 1);
        ref = repmat(mean(d.data(reference, :),1), n_channels, 1);
        d.data = d.data - ref;
        d.data = d.data(eeg_channels,:);
        s = eeg_filter(d.data', fs, filter_band(1), filter_band(2), filter_order);
        s = s(1:decimation:end, :);
        disp(['Segmenting Test data for subject: subj' num2str(subj)]);
        pos = round(etime(d.events(1:n_trials,:), repmat(d.events(1,:), n_trials,1)) .* (downsample) + 1 + 0.4*downsample);
        %         dur = [0:diff(wnd)]'*ones(1, length(pos));
        %         tDur = size(dur,1);
        %         epoch_idx = bsxfun(@plus, dur, pos');
        %         eeg_epochs = reshape(s(epoch_idx, :),[tDur length(pos) length(eeg_channels)]);
        %         eeg_epochs = permute(eeg_epochs, [1 3 2]);
        eeg_epochs = dataio_getERPEpochs(wnd, pos, s);
        testEEG{subj}.epochs.signal(:,:,:,run) = eeg_epochs;
        testEEG{subj}.epochs.events(:,run) = d.stimuli(1:n_trials);
        testEEG{subj}.epochs.y(d.stimuli(1:n_trials) == d.target, run) = 1;
        testEEG{subj}.epochs.y(d.stimuli(1:n_trials) ~= d.target, run) = -1;
        data.desired_phrase(run) = num2str(d.target);
    end
    testEEG{subj}.phrase = data.desired_phrase;
    testEEG{subj}.fs = fs;
    testEEG{subj}.montage.clab = '';
    testEEG{subj}.classes = {'target', 'non_target'};
    testEEG{subj}.paradigm = data.paradigm;
    if (subj < 5)
        testEEG{subj}.subject.id = disabled_subjects.id{subj};
        testEEG{subj}.subject.gender = disabled_subjects.gender(subj);
        testEEG{subj}.subject.age = disabled_subjects.age(subj);
        testEEG{subj}.subject.condition = disabled_subjects.condition{subj};
    else
        testEEG{subj}.subject.id = ['subject ' num2str(subj)];
        testEEG{subj}.subject.gender = '';
        testEEG{subj}.subject.age = 0;
        testEEG{subj}.subject.condition = 'healthy';
    end
    disp(['Processing Test data succeed for subject: ' num2str(subj)]);
    clear s d eeg_epochs
end
% filter data
% segment data
% valide data structure
% save
allEpoched_path = '..\datasets\epochs\EPFL\';
Config_path = '..\datasets\epochs\EPFL\';

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
save([Config_path '\trainEEG.mat'],'trainEEG','-v7.3');
save([Config_path '\testEEG.mat'],'testEEG','-v7.3');

disp('Data epoched saved in:');
% disp(allEpoched_path);
disp(Config_path);

toc
end

