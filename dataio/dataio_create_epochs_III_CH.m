function [] = dataio_create_epochs_III_CH(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS__III_CH segment BCI Compeition III Challenge 2004
%                           (P300 evoked potentials) dataset
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
%                       datasets\epochs\Comp_III_ch_2004\Comp_config
% Example :
%     dataio_create_epochs_III_CH([0 800], [0.5 10])
%
% Dependencies :
%   eeg_filter.m from EEGLAB toolbox

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
% 100ms stimulations - 75 ms ISI
tic

% dataset
data.paradigm.title = 'III_CH';
data.paradigm.stimulation = 100;
data.paradigm.isi = 75;
data.paradigm.repetition = 15;
data.paradigm.stimuli_count = 12;
data.paradigm.type = 'RC';

disp('Creating epochs for BCI Comp III Challenge 2004');
set_path = '\datasets\BCI_Competition\Comp_III_ch_2004';
dataSetFiles = dir([set_path '\Subject*.mat']);
dataSetFiles = {dataSetFiles.name};
testSetLabels = dir([set_path '\test_labels_subject*.mat']);
testSetLabels = {testSetLabels.name};
clab_path = [set_path '\eloc64.txt'];
clab = dataio_read_loc(clab_path);
nSubj = 2;
trainEEG = cell(1, nSubj);
testEEG = cell(1, nSubj);

%  paradigm
fs = 240;
stimulation = 100; % in ms
isi = 75; % in ms
stimDuration = ( (stimulation + isi) / 10^3 ) * 240;
% processing parameters
filter_order = 2;
wnd = (epoch_length * fs) / 10^3;
subj = 1;

for file_index=1:2:length(dataSetFiles)
    
    % load test and train set for each subject
    subject = strsplit(dataSetFiles{file_index}, '_');
    subject = [subject{1} subject{2}];
    disp(['Loading data for subject: ' subject]);
    train_set = load(dataSetFiles{file_index + 1});    
    
    % filter data
    disp(['Filtering  Train data for subject: ' subject]);
    s = permute(train_set.Signal,[2 3 1]);
    s = eeg_filter(double(s), fs, filter_band(1), filter_band(2), filter_order);
    trials_count = size(s, 3);
    
    %     segment the training data into epochs
    for tr = 1:trials_count
        disp(['Segmenting Train data for subject: ' subject ' Trial: ' num2str(tr)]);
        
        events = dataio_getevents_BCI2000(train_set.StimulusCode(tr, :), stimDuration);
        eeg_epochs = dataio_getERPEpochs(wnd, events.pos, s(:,:,tr));
        trainEEG{subj}.epochs.signal(:,:,:,tr) = eeg_epochs;
        trainEEG{subj}.epochs.events(:,tr) = events.desc;
        trainEEG{subj}.epochs.y(:,tr) = dataio_getlabelERP(events.desc, train_set.TargetChar(tr), 'RC');
    end
    trainEEG{subj}.phrase = train_set.TargetChar;
    trainEEG{subj}.fs = fs;
    trainEEG{subj}.montage.clab = clab;
    trainEEG{subj}.classes = {'target', 'non_target'};
    trainEEG{subj}.paradigm = data.paradigm;
    trainEEG{subj}.subject.id = subject;
    trainEEG{subj}.subject.gender = '';
    trainEEG{subj}.subject.age = 0;
    trainEEG{subj}.subject.condition = 'healthy';
    disp(['Processing train data succeed for subject: ' subject]);
    clear s train_set
    test_set = load(dataSetFiles{file_index});
    test_set_true_labels = load(testSetLabels{subj});
    
    if file_index ==1
        test_set.TargetChar = test_set_true_labels.test_labels_subject1;
    else
        test_set.TargetChar = test_set_true_labels.test_labels_subject2;
    end
    %     TEST data
    % filter data
    disp(['Filtering  Test data for subject: ' subject]);
    s = permute(test_set.Signal,[2 3 1]);
    s = eeg_filter(double(s), fs, filter_band(1), filter_band(2), filter_order);
    trials_count = size(s, 3);
    
    %     segment the training data into epochs
    for tr = 1:trials_count
        disp(['Segmentation of Test data for subject: ' subject ' Trial:' num2str(tr)]);
        events = dataio_getevents_BCI2000(test_set.StimulusCode(tr, :), stimDuration);
        eeg_epochs = dataio_getERPEpochs(wnd, events.pos, s(:,:,tr));
        testEEG{subj}.epochs.signal(:,:,:,tr) = eeg_epochs;
        testEEG{subj}.epochs.events(:,tr) = events.desc;
        testEEG{subj}.epochs.y(:,tr) = dataio_getlabelERP(events.desc, test_set.TargetChar(tr), 'RC');
    end
    testEEG{subj}.phrase = test_set.TargetChar;
    testEEG{subj}.fs = fs;
    testEEG{subj}.montage.clab = clab;
    testEEG{subj}.classes = {'target', 'non_target'};
    testEEG{subj}.paradigm = data.paradigm;
    testEEG{subj}.subject.id = subject;
    testEEG{subj}.subject.gender = '';
    testEEG{subj}.subject.age = 0;
    testEEG{subj}.subject.condition = 'healthy';
    
    disp(['Processing Test data succeed for subject: ' subject]);
    
    subj = subj + 1;
end
clear s test_set
% save data

compConfig_path = '\datasets\epochs\Comp_III_ch_2004\';


if isempty(filter_band)
    compConfig_path = [compConfig_path 'Raw\Comp_config'];
else
    compConfig_path = [compConfig_path 'Comp_config'];
    
end

save([compConfig_path '\trainEEG.mat'],'trainEEG', '-v7.3');
save([compConfig_path '\testEEG.mat'],'testEEG', '-v7.3');

disp('Data epoched saved in:');

disp(compConfig_path);
toc
end

