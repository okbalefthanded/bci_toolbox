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
data.clab = dataio_read_loc(clab_path);
nSubj = 2;

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

    data.stimDuration = stimDuration;
%     data.correctionInterval = correctionInterval;
    data.subject = subject;
    trainEEG = getEEGstruct(train_set, wnd, fs, filter_band, filter_order, data);

    dataio_save_mat(compConfig_path_SM, subj, 'trainEEG');
    disp(['Processing train data succeed for subject: ' subject]);
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
    testEEG = getEEGstruct(test_set, wnd, fs, filter_band, filter_order, data);
    dataio_save_mat(compConfig_path_SM, subj, 'testEEG');
    disp(['Processing train data succeed for subject: ' subject]);
    disp(['Processing Test data succeed for subject: ' subject]);  
    disp('Data epoched saved in:');
    disp(compConfig_path_SM);
	clear testEEG
    subj = subj + 1;
end
toc
end
%%
function [EEG] = getEEGstruct(set, wnd, fs, filter_band, filter_order, data)
% filter data
disp(['Filtering  Train data for subject: ' data.subject]);
s = permute(set.Signal,[2 3 1]);
s = eeg_filter(double(s), fs, filter_band(1), filter_band(2), filter_order);
trials_count = size(s, 3);
%     segment the training data into epochs
for tr = 1:trials_count
    disp(['Segmenting Train data for subject: ' data.subject ' Trial: ' num2str(tr)]);
    events = dataio_getevents_BCI2000(set.StimulusCode(tr, :), data.stimDuration);
    eeg_epochs = dataio_getERPEpochs(wnd, events.pos, s(:,:,tr));
%     eeg_epochs = dataio_baselineCorrection(eeg_epochs, data.correctionInterval);
    EEG.epochs.signal(:,:,:,tr) = eeg_epochs;
    EEG.epochs.events(:,tr) = events.desc;
    EEG.epochs.y(:,tr) = dataio_getlabelERP(events.desc, set.TargetChar(tr), 'RC');
end
EEG.phrase = set.TargetChar;
clear set
EEG.fs = fs;
EEG.montage.clab = data.clab;
EEG.classes = {'target', 'non_target'};
EEG.paradigm = data.paradigm;
EEG.subject.id = data.subject;
EEG.subject.gender = '';
EEG.subject.age = 0;
EEG.subject.condition = 'healthy';
end

