function [] = dataio_create_epochs_SanDiego(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_SANDIEGO Summary of this function goes here
%   Detailed explanation goes here
% created 07-02-2018
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
% Masaki Nakanishi, Yijun Wang, Yu-Te Wang and Tzyy-Ping Jung,
% "A Comparison Study of Canonical Correlation Analysis Based Methods for 
%   Detecting Steady-State Visual Evoked Potentials,"
% PLoS One, vol.10, no.10, e140703, 2015.

disp('Creating epochs for Tsinghua lab JPFM SSVEP dataset');

set_path = 'datasets\sandiego_ssvep';
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
trainEEG = cell(1, nSubj);
testEEG = cell(1, nSubj);
%
fs = 256;
filter_order = 6;
wnd = (epoch_length * fs) / 10^3;
nTrainBlocks = 10;
nTestBlocks = 5;
classes = 1:12;
stimulation_onset = 39;
for subj=1:nSubj
%     load data, subject info
    disp(['Loading data for subject S0' num2str(subj)]);
    subject_path = [set_path '\' dataSetFiles{subj}];
    rawData = load(subject_path);
%     [Num. of targets, Num. of channels, Num. of sampling points, Num. of trials]
    eeg = permute(rawData.eeg, [3 2 4 1]);
    [~,channels, trials, blocks] = size(eeg);
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
    %     split data
    disp(['Spliting data for subject S0' num2str(subj)]);
    trainEEG{subj}.epochs.signal = reshape(train_data, [samples channels nTrainBlocks*max(classes)]);   
    trainEEG{subj}.epochs.events = reshape(events(1:nTrainBlocks, :), [1 nTrainBlocks*max(classes)]);
    trainEEG{subj}.epochs.y = reshape(y(1:nTrainBlocks, :), [1 nTrainBlocks*max(classes)]);
    
    testEEG{subj}.epochs.signal = reshape(test_data, [samples channels nTestBlocks*max(classes)]);
    testEEG{subj}.epochs.events = reshape(events(nTrainBlocks+1:end,:), [1 nTestBlocks*max(classes)]);
    testEEG{subj}.epochs.y = reshape(y(nTrainBlocks+1:end,:), [1 nTestBlocks*max(classes)]);  
    %     construct data structures
    trainEEG{subj}.fs = fs;
    trainEEG{subj}.montage.clab = clab;
    trainEEG{subj}.classes = classes;
    trainEEG{subj}.paradigm = paradigm;
    trainEEG{subj}.subject.id =['S' num2str(subj)];   
    
    testEEG{subj}.fs = fs;
    testEEG{subj}.montage.clab = clab;
    testEEG{subj}.classes = classes;
    testEEG{subj}.paradigm = paradigm;
    testEEG{subj}.subject = trainEEG{subj}.subject;    
end

% save
disp('Saving dataset SANDIEGO-SSVEP');
Config_path = 'datasets\epochs\sandiego_ssvep\';

if(~exist(Config_path,'dir'))
    mkdir(Config_path);
end

save([Config_path '\trainEEG.mat'],'trainEEG','-v7.3');
clear trainEEG
save([Config_path '\testEEG.mat'],'testEEG','-v7.3');
clear testEEG
disp('Data epoched saved in:');
disp(Config_path);
end

