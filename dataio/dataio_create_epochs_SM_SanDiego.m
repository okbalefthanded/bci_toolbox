function [] = dataio_create_epochs_SM_SanDiego(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_SM_SANDIEGO Summary of this function goes here
%   Detailed explanation goes here
% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% EEG structure: epochs     : struct
%                           :       : signal :  [samples channels trials]
%                           :       : events :  [1 trials]
%                           :       : y      :  [1 trials]
%                fs         : sampling rate
%                montage    : clab
%                classes    : classes {F1,...Fn}
%                paradigm   : struct
%                           :        : title : [str]
%                           :        : stimulation 1
%                           :        : pause 1
%                           :        : stimuli_count 1
%                           :        : type [str]
%                           :        : stimuli [1 stimuli_count]
%                subject    : (depending on the availability of info about
%                                 the subject)
% dataset paradigm:
% Square-joint frequency-phase modulation (JFPM) 1s, 4s,
% Reference:
%   Masaki Nakanishi, Yijun Wang, Yu-Te Wang and Tzyy-Ping Jung,
%   "A Comparison Study of Canonical Correlation Analysis Based Methods for
%   Detecting Steady-State Visual Evoked Potentials,"
%   PLoS One, vol.10, no.10, e140703, 2015.
%   DOI : 10.1371/journal.pone.0140703

tic
disp('Creating epochs for San Diego lab JPFM SSVEP dataset');

set_path = 'datasets\ssvep_sandiego';
dataSetFiles = dir([set_path '\s*.mat']);
dataSetFiles = {dataSetFiles.name};
% EEG montage
clab = {'PO7','PO3','POz','PO4','PO8','O1','Oz','O2'};
%
paradigm.title = 'SSVEP-SANDIEGO';
paradigm.stimulation = 4000;
paradigm.pause = 1000;
paradigm.stimuli_count = 12;
paradigm.type = 'SSVEP-SQUARE-JFPM';
paradigm.stimuli = [9.25, 11.25, 13.25, ...
    9.75, 11.75, 13.75, ...
    10.25, 12.25, 14.25, ...
    10.75, 12.75, 14.75];
paradigm.phase = [0.0, 0.0, 0.0, ...
    0.5*pi, 0.5*pi, 0.5*pi, ...
    pi, pi, pi, ...
    1.5*pi, 1.5*pi, 1.5*pi];
%
nSubj = 10;
%
fs = 256;
filter_order = 6;
wnd = (epoch_length * fs) / 10^3;
nTrainBlocks = 10;
nTestBlocks = 5;
classes = 1:12;
classes_c = cellfun(@num2str,num2cell(1:12),'UniformOutput',0);
stimulation_onset = 39;

% save
Config_path_SM = 'datasets\epochs\ssvep_sandiego\SM';

if(~exist(Config_path_SM,'dir'))
    mkdir(Config_path_SM);
end

for subj=1:nSubj
    %     load data, subject info
    disp(['Loading data for subject S0' num2str(subj)]);
    subject_path = [set_path '\' dataSetFiles{subj}];
    rawData = load(subject_path);
    %     [Num. of targets, Num. of channels, Num. of sampling points, Num. of trials]
    eeg = permute(rawData.eeg, [3 2 4 1]);
    [~,channels, ~, blocks] = size(eeg);
    disp(['Filtering data for subject S0' num2str(subj)]);
    % filter data
    for block=1:blocks
        eeg(:,:,:,block) = eeg_filter(eeg(:,:,:,block), ...
            fs,...
            filter_band(1),...
            filter_band(2),...
            filter_order...
            );
    end
    %     segment data
    eeg = eeg(stimulation_onset:stimulation_onset+wnd(2),:,:,:);
    [samples,~,~,~] = size(eeg);
    train_data = eeg(:,:,1:nTrainBlocks,:);
    test_data = eeg(:,:,nTrainBlocks+1:end,:);
    events = repmat(paradigm.stimuli, [nTrainBlocks+nTestBlocks 1]);
    y = repmat(classes, [nTrainBlocks+nTestBlocks 1]);
    info.clab = clab;
    info.classes = classes;
    info.classes_c = classes_c;
    info.paradigm = paradigm;
    info.subj = subj;
    info.samples = samples;
    info.channels = channels;
    info.Blocks = nTrainBlocks;
    ev = reshape(events(1:nTrainBlocks, :), [1 nTrainBlocks*max(classes)]);
    y_tr = reshape(y(1:nTrainBlocks, :), [1 nTrainBlocks*max(classes)]);
    trainEEG = getEEGstruct(train_data, ev, y_tr, fs, info);
    dataio_save_mat(Config_path_SM, subj, 'trainEEG');
    %     split data
    disp(['Spliting data for subject S0' num2str(subj)]);
    clear trainEEG train_data eeg    
  
 
    info.Blocks = nTestBlocks;
    ev = reshape(events(nTrainBlocks+1:end,:), [1 nTestBlocks*max(classes)]);
    y_ts = reshape(y(nTrainBlocks+1:end,:), [1 nTestBlocks*max(classes)]);
    testEEG = getEEGstruct(test_data, ev, y_ts, fs, info);
    dataio_save_mat(Config_path_SM, subj, 'testEEG');
    clear testEEG test_data event
    
    disp('Data epoched saved in:');
    disp(Config_path_SM);
end
toc
end
%%
function [EEG] = getEEGstruct(data, events, y, fs, info)
EEG.epochs.signal = reshape(data, [info.samples info.channels info.Blocks*max(info.classes)]);
EEG.epochs.events = events;
EEG.epochs.y = y;
EEG.fs = fs;
EEG.montage.clab = info.clab;
EEG.classes = info.classes_c;
EEG.paradigm = info.paradigm;
EEG.subject.id =['S' num2str(info.subj)];
end
