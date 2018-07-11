function [] = dataio_create_epochs_SM_Exoskeleton(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_EXOSKELETON segment ssvep-exoskeleton dataset and
%  save epochs  in seperate files for each subject
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
% Epoched files are aved in the folder: datasets/epochs/SM/ssvep_exoskeleton
% Example :
%     dataio_create_epochs_SM_Exoskeleton([0 2000], [5 45])
%
% Dependencies :
%   eeg_filter.m from EEGLAB toolbox
% References
% [dataset]
% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% EEG structure: epochs     : TxNxEpo
%                             T   : time samples
%                             N   : channels
%                             Epo : epochs per trial
%                y          : Epo
%                             Epo : epochs  label
%                fs         : sampling rate
%                phrase     : character per trial

% dataset paradigm:
% ON/OFF 5s - 3s

tic
disp('Creating epochs for SSVEP-EXOSKELETON dataset');

% path to a subject data:
% datasets\ssvep_exoskeleton\subject01
paradigm.title = 'SSVEP-LED';
paradigm.stimulation = 5000;
paradigm.pause = 3000;
paradigm.stimuli_count = 3;
paradigm.type = 'ON/OFF';
paradigm.stimuli = {'idle',13,21,17};

set_path = 'datasets\ssvep_exoskeleton\';
set_subfolders = dir(set_path);
set_subfolders = set_subfolders(~ismember({set_subfolders.name},{'.','..'}));
nSubj = length(set_subfolders);
trainEEG = cell(1);
testEEG = cell(1);

fs = 256;
filter_order = 6;
wnd = (epoch_length * fs) / 10^3;
gain = 1000;

% save
Config_path_SM = 'datasets\epochs\ssvep_exoskeleton\SM';

if(~exist(Config_path_SM,'dir'))
    mkdir(Config_path_SM);
end

for subj = 1:nSubj
    subject_path = [set_path '\' set_subfolders(subj).name];
    subject_files = dir(subject_path);
    subject_files =  subject_files(~ismember({subject_files.name},{'.','..'}));
    files_count = length(subject_files);
    epo = [];
    ev.desc = [];
    ev.y = [];
    % Train data, first files
    disp(['Processing Train data succeed for subject: ' num2str(subj)]);
    for file = 1:files_count - 1
        [signal, header] = mexSLOAD([subject_path '\' subject_files(file).name]);
        signal = signal * gain; % amplifying the signal
        signal = eeg_filter(signal, fs, filter_band(1), filter_band(2), filter_order);
        events = dataio_geteventsExoskeleton(header);
        epochs = dataio_getERPEpochs(wnd, events.pos, signal);
        epo = cat(3, epo, epochs);
        ev.desc = cat(1, ev.desc, events.desc);
        ev.y = cat(1, ev.y, events.y);
    end
    trainEEG.epochs.signal = epo;
    trainEEG.epochs.events = ev.desc;
    trainEEG.epochs.y = ev.y';
    trainEEG.fs = fs;
    trainEEG.montage.clab = header.Label;
    trainEEG.classes = paradigm.stimuli;
    trainEEG.paradigm = paradigm;
    trainEEG.subject.id = num2str(subj);
    trainEEG.subject.gender = '';
    trainEEG.subject.age = 0;
    trainEEG.subject.condition = 'healthy';
    disp(['Processing Train data succeed for subject: ' num2str(subj)]);
    save([Config_path_SM,'\','S0',num2str(subj),'trainEEG.mat'],'trainEEG', '-v7.3');
    clear signal header trainEEG
    
    
    disp(['Processing Test data succeed for subject: ' num2str(subj)]);
    % Test data
    [signal, header] = mexSLOAD([subject_path '\' subject_files(files_count).name]);
    signal = signal * gain; % amplifying the signal
    signal = eeg_filter(signal, fs, filter_band(1), filter_band(2), filter_order);
    events = dataio_geteventsExoskeleton(header);
    epochs = dataio_getERPEpochs(wnd, events.pos, signal);
    testEEG.epochs.signal = epochs;
    testEEG.epochs.events = events.desc;
    testEEG.epochs.y = events.y';
    testEEG.fs = fs;
    testEEG.montage.clab = header.Label;
    testEEG.classes = paradigm.stimuli;
    testEEG.paradigm = paradigm;
    testEEG.subject.id = num2str(subj);
    testEEG.subject.gender = '';
    testEEG.subject.age = 0;
    testEEG.subject.condition = 'healthy';
    disp(['Processing Test data succeed for subject: ' num2str(subj)]);
    save([Config_path_SM,'\','S0',num2str(subj),'testEEG.mat'],'testEEG', '-v7.3');
    clear signal header testEEG
    
    disp('Data epoched saved in:');
    disp(Config_path_SM);
end

toc
end

