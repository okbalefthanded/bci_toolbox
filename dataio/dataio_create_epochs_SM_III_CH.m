function [] = dataio_create_epochs_SM_III_CH(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_SM_III_CH segment BCI Compeition III Challenge 2004
%  (P300 evoked potentials) dataset and save epochs in seperate files
%   for each subject
%
% Arguments:
%     In:
%         epoch_length : DOUBLE [1x2] [start end] in msec of epoch relative
%         to stimulus onset marker.
%         filter_band : DOUBLE [1x2] [low_cutoff high_cutoff] filte ring
%             frequency band in Hz
%
%
%     Returns:
%      None.
% Epoched files are aved in the folder:
%                       datasets\epochs\Comp_III_ch_2004\Comp_config\SM
% Example :
%     dataio_create_epochs_SM_III_CH([0 800], [0.5 10])
%
% Dependencies :
%   eeg_filter.m from EEGLAB toolbox

% created : 07-10-2018
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
set_path = 'datasets\BCI_Competition\Comp_III_ch_2004';
dataSetFiles = dir([set_path '\Subject*.mat']);
dataSetFiles = {dataSetFiles.name};
testSetLabels = dir([set_path '\test_labels_subject*.mat']);
testSetLabels = {testSetLabels.name};
clab_path = [set_path '\eloc64.txt'];
clab = dataio_read_loc(clab_path);
nSubj = 2;
% trainEEG = cell(1, nSubj);
% testEEG = cell(1, nSubj);
trainEEG = cell(1);
testEEG = cell(1);
%  paradigm
fs = 240;
stimulation = 100; % in ms
isi = 75; % in ms
stimDuration = ( (stimulation + isi) / 10^3 ) * 240;
% processing parameters
filter_order = 2;
wnd = (epoch_length * fs) / 10^3;
% correctionInterval = round([-100 0] * fs) / 10^3;
% wnd = [correctionInterval(1) wnd_epoch(2)];
subj = 1;
compConfig_path_SM = 'datasets\epochs\Comp_III_ch_2004\';
if isempty(filter_band)
    compConfig_path_SM = [compConfig_path_SM 'Raw\Comp_config\SM'];
else
    compConfig_path_SM = [compConfig_path_SM 'Comp_config\SM'];
end
if(~isdir(compConfig_path_SM))
    mkdir(compConfig_path_SM);
end

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
%         eeg_epochs = dataio_baselineCorrection(eeg_epochs, correctionInterval);
        trainEEG.epochs.signal(:,:,:,tr) = eeg_epochs;
        trainEEG.epochs.events(:,tr) = events.desc;
        trainEEG.epochs.y(:,tr) = dataio_getlabelERP(events.desc, train_set.TargetChar(tr), 'RC');
    end
    trainEEG.phrase = train_set.TargetChar;
    clear train_set
    trainEEG.fs = fs;
    trainEEG.montage.clab = clab;
    trainEEG.classes = {'target', 'non_target'};
    trainEEG.paradigm = data.paradigm;
    trainEEG.subject.id = subject;
    trainEEG.subject.gender = '';
    trainEEG.subject.age = 0;
    trainEEG.subject.condition = 'healthy';
    disp(['Processing train data succeed for subject: ' subject]);
    clear s    
    
    save([compConfig_path_SM,'\','S0',num2str(subj),'trainEEG.mat'],'trainEEG', '-v7.3');
    clear trainEEG
    
    test_set = load(dataSetFiles{file_index});
    test_set_true_labels = load(testSetLabels{subj});
    
    if file_index ==1
        test_set.TargetChar = test_set_true_labels.test_labels_subject1;
    else
        test_set.TargetChar = test_set_true_labels.test_labels_subject2;
    end
    clear test_set_true_labels
    % TEST data
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
%         eeg_epochs = dataio_baselineCorrection(eeg_epochs, correctionInterval);
        testEEG.epochs.signal(:,:,:,tr) = eeg_epochs;
        testEEG.epochs.events(:,tr) = events.desc;
        testEEG.epochs.y(:,tr) = dataio_getlabelERP(events.desc, test_set.TargetChar(tr), 'RC');
    end
    testEEG.phrase = test_set.TargetChar;
    clear test_set
    testEEG.fs = fs;
    testEEG.montage.clab = clab;
    testEEG.classes = {'target', 'non_target'};
    testEEG.paradigm = data.paradigm;
    testEEG.subject.id = subject;
    testEEG.subject.gender = '';
    testEEG.subject.age = 0;
    testEEG.subject.condition = 'healthy';
    clear s 
    disp(['Processing Test data succeed for subject: ' subject]);
    
    save([compConfig_path_SM,'\','S0',num2str(subj),'testEEG.mat'],'testEEG', '-v7.3');    
    disp('Data epoched saved in:');
    disp(compConfig_path_SM);
	clear trainEEG testEEG
    subj = subj + 1;
end
toc
end


