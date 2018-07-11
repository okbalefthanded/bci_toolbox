function [] = dataio_create_epochs_SM_EPFL(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_SM_EPFL segment EPFL dataset and save epochs
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
% Epoched files are aved in the folder: datasets/epochs/EPFL/SM
% Example :
%     dataio_create_epochs_SM_EPFL([0 800], [0.5 10])
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
set_path = 'datasets\EPFL_image_speller';
set_subfolders = dir(set_path);
set_subfolders = set_subfolders(~ismember({set_subfolders.name},{'.','..'}));
nSubj = length(set_subfolders);
% nSessions = 4;
trainEEG = cell(1);
testEEG = cell(1);
nTrain_session = 3;
eeg_channels = 1:32;
fs = 2048;
n_trials = 120;
%
downsample = 512;
decimation = fs / downsample;
filter_order = 2;

wnd = (epoch_length * downsample) / 10^3;

% save
Config_path_SM = 'datasets\epochs\EPFL_image_speller\SM';

if(~exist(Config_path_SM,'dir'))
    mkdir(Config_path_SM);
end

if isempty(filter_band)
    Config_path_SM = [Config_path_SM];
else
    % TOOO
    Config_path_SM = [Config_path_SM];
end


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
            pos = round(etime(d.events(1:n_trials,:), repmat(d.events(1,:), n_trials,1)) .* (downsample) + 1 + 0.4*downsample);
            eeg_epochs = dataio_getERPEpochs(wnd, pos, s);
            trainEEG.epochs.signal(:,:,:,tr_trial) = eeg_epochs;
            trainEEG.epochs.events(:,tr_trial) = d.stimuli(1:n_trials);
            trainEEG.epochs.y(d.stimuli(1:n_trials) == d.target, tr_trial) = 1;
            trainEEG.epochs.y(d.stimuli(1:n_trials) ~= d.target, tr_trial) = -1;
            data.desired_phrase(tr_trial) = num2str(d.target);
            tr_trial = tr_trial + 1;
        end
    end
    trainEEG.phrase = data.desired_phrase;
    trainEEG.fs = fs;
    trainEEG.montage.clab = '';
    trainEEG.classes = {'target', 'non_target'};
    trainEEG.paradigm = data.paradigm;
    if (subj < 5)
        trainEEG.subject.id = disabled_subjects.id{subj};
        trainEEG.subject.gender = disabled_subjects.gender(subj);
        trainEEG.subject.age = disabled_subjects.age(subj);
        trainEEG.subject.condition = disabled_subjects.condition{subj};
    else
        trainEEG.subject.id = ['subject ' num2str(subj)];
        trainEEG.subject.gender = '';
        trainEEG.subject.age = 0;
        trainEEG.subject.condition = 'healthy';
    end
    disp(['Processing Train data succeed for subject: ' num2str(subj)]);
    save([Config_path_SM,'\','S0',num2str(subj),'trainEEG.mat'],'trainEEG', '-v7.3');
    clear s d eeg_epochs trainEEG
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
        eeg_epochs = dataio_getERPEpochs(wnd, pos, s);
        testEEG.epochs.signal(:,:,:,run) = eeg_epochs;
        testEEG.epochs.events(:,run) = d.stimuli(1:n_trials);
        testEEG.epochs.y(d.stimuli(1:n_trials) == d.target, run) = 1;
        testEEG.epochs.y(d.stimuli(1:n_trials) ~= d.target, run) = -1;
        data.desired_phrase(run) = num2str(d.target);
    end
    testEEG.phrase = data.desired_phrase;
    testEEG.fs = fs;
    testEEG.montage.clab = '';
    testEEG.classes = {'target', 'non_target'};
    testEEG.paradigm = data.paradigm;
    if (subj < 5)
        testEEG.subject.id = disabled_subjects.id{subj};
        testEEG.subject.gender = disabled_subjects.gender(subj);
        testEEG.subject.age = disabled_subjects.age(subj);
        testEEG.subject.condition = disabled_subjects.condition{subj};
    else
        testEEG.subject.id = ['subject ' num2str(subj)];
        testEEG.subject.gender = '';
        testEEG.subject.age = 0;
        testEEG.subject.condition = 'healthy';
    end
    disp(['Processing Test data succeed for subject: ' num2str(subj)]);
    save([Config_path_SM,'\','S0',num2str(subj),'testEEG.mat'],'testEEG', '-v7.3');
    clear s d eeg_epochs testEEG
    
    disp('Data epoched saved in:');
    disp(Config_path_SM);
end
toc
end

