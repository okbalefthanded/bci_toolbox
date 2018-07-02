function [] = dataio_create_epochs_Exoskeleton(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_EXOSKELETON segment ssvep-exoskeleton dataset and
%                         save epochs in files
% created 20-03-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
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
% Epoched files are aved in the folder: datasets/epochs/ssvep_exoskeleton
% Example :
%     dataio_create_epochs_Exoskeleton([0 2000], [5 45])
%
% Dependencies :
%   eeg_filter.m from EEGLAB toolbox
% References
% [dataset]

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

set_path = 'datasets\ssvep_exoskeleton';
set_subfolders = dir(set_path);
set_subfolders = set_subfolders(~ismember({set_subfolders.name},{'.','..'}));
nSubj = length(set_subfolders);
trainEEG = cell(1, nSubj);
testEEG = cell(1, nSubj);

fs = 256;
filter_order = 6;
wnd = (epoch_length * fs) / 10^3;
gain = 1000;

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
    trainEEG{subj}.epochs.signal = epo;
    trainEEG{subj}.epochs.events = ev.desc;
    trainEEG{subj}.epochs.y = ev.y';
    trainEEG{subj}.fs = fs;
    trainEEG{subj}.montage.clab = header.Label;
    trainEEG{subj}.classes = paradigm.stimuli;
    trainEEG{subj}.paradigm = paradigm;
    trainEEG{subj}.subject.id = num2str(subj);
    trainEEG{subj}.subject.gender = '';
    trainEEG{subj}.subject.age = 0;
    trainEEG{subj}.subject.condition = 'healthy';
    
    disp(['Processing Test data succeed for subject: ' num2str(subj)]); 
    % Test data
    [signal, header] = mexSLOAD([subject_path '\' subject_files(files_count).name]);
    signal = signal * gain; % amplifying the signal
    signal = eeg_filter(signal, fs, filter_band(1), filter_band(2), filter_order);
    events = dataio_geteventsExoskeleton(header);
    epochs = dataio_getERPEpochs(wnd, events.pos, signal);
    testEEG{subj}.epochs.signal = epochs;
    testEEG{subj}.epochs.events = events.desc;
    testEEG{subj}.epochs.y = events.y';
    testEEG{subj}.fs = fs;
    testEEG{subj}.montage.clab = header.Label;
    testEEG{subj}.classes = paradigm.stimuli;
    testEEG{subj}.paradigm = paradigm;
    testEEG{subj}.subject.id = num2str(subj);
    testEEG{subj}.subject.gender = '';
    testEEG{subj}.subject.age = 0;
    testEEG{subj}.subject.condition = 'healthy';     
end
% save
Config_path = 'datasets\epochs\ssvep_exoskeleton\';

if(~exist(Config_path,'dir'))
    mkdir(Config_path);
end

save([Config_path '\trainEEG.mat'],'trainEEG','-v7.3');
save([Config_path '\testEEG.mat'],'testEEG','-v7.3');

disp('Data epoched saved in:');
disp(Config_path);

toc
end

