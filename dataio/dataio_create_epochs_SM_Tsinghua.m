function [] = dataio_create_epochs_SM_Tsinghua(epoch_length, filter_band, augment, all)
%DATAIO_CREATE_EPOCHS_TSINGHUA Summary of this function goes here
%   Detailed explanation goes here
% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% fs 250 hz
% stim freq: 8:0.2:15.8
% data dim : [64, 1500, 40, 6] [ch samples targets blocks]

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
% sampled sinusoidal joint frequency-phase modulation (JFPM) -0.5s, 5s, +0.5s
% Reference
%  [1] X. Chen, Y. Wang, M. Nakanishi, X. Gao, T. -P. Jung, S. Gao,
%       "High-speed spelling with a noninvasive brain-computer interface",
%       Proc. Int. Natl. Acad. Sci. U. S. A, 112(44): E6058-6067, 2015.
%   DOI: 10.1073/pnas.1508080112
tic
disp('Creating epochs for Tsinghua lab JPFM SSVEP dataset');

set_path = 'datasets\ssvep_tsinghua_jfpm';
dataSetFiles = dir([set_path '\S*.mat']);
dataSetFiles = {dataSetFiles.name};
% EEG montage
montage = fileread([set_path '\64-channels.loc']);
montage = strsplit(montage, '\n');
montage = cellfun(@deblank, montage, 'Uniformoutput', 0);
montage(end-1:end) = [];
clab = cellfun(@(x)x(end-2:end), montage,'Uniformoutput', 0);
% Subjects info
subjects_info = fileread([set_path '\Sub_info.txt']);
subjects_info = strsplit(subjects_info, '\n');
subjects_info([1,2,end]) = [];
%
freqPhase = load([set_path '\Freq_Phase.mat']);
paradigm.title = 'Tsinghua-SSVEP';
paradigm.stimulation = 5000;
paradigm.pause = 0.5;
paradigm.stimuli_count = 40;
paradigm.type = 'SSVEP-JFPM';
paradigm.stimuli = freqPhase.freqs;
paradigm.phase = freqPhase.phases; %0 pi/2 pi 3pi/2
%
classes_r = cellfun(@num2str,num2cell(paradigm.stimuli),'UniformOutput',0);
%
nSubj = 35;
%
fs = 250;
filter_order = 6;
ep = epoch_length;
epoch_length = epoch_length + 500;
wnd = (epoch_length * fs) / 10^3;
nTrainBlocks = 4;
nTestBlocks = 2;
classes = 1:40;
chs = {'PO8', 'PO7', 'PO6', 'PO5', 'PO4', 'PO3', 'POz', ' O2', ' O1',' Oz'}; 
index = [];
for i=1:length(chs)
index = [index,find(strcmpi(clab, chs{i}))];
end

% save

Config_path_SM = 'datasets\epochs\ssvep_tsinghua_jfpm\SM';

if(~exist(Config_path_SM,'dir'))
    mkdir(Config_path_SM);
end

for subj=1:nSubj
    %     load data, subject info
    disp(['Loading data for subject S0' num2str(subj)]);
    subject_path = [set_path '\' dataSetFiles{subj}];
    rawData = load(subject_path);
    eeg = permute(rawData.data, [2 1 3 4]);
    eeg = eeg(:,index,:,:);
    [~, channels, targets, blocks] = size(eeg);
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
    er = [];
    if augment
        % TODO
        
        % agmt = np.floor(stimulation / np.diff(epoch))[0].astype(int)
        agmt = floor(paradigm.stimulation / diff(ep));
        % for stride=0:3
        for stride=0:agmt-1            
            er = cat(3,er,eeg(wnd(1)+(stride*fs):wnd(2)+(stride*fs),:,:,:));
        end
        eeg = er;
        nTrainBlocks = 4*agmt;
        nTestBlocks = 2*agmt;
    else
        eeg = eeg(wnd(1):wnd(2),:,:,:);
    end
    %
    [samples, ~, ~, ~] = size(eeg);
    %     split data
    disp(['Spliting data for subject S0' num2str(subj)]);
    
    data.fs = fs;
    data.clab = clab;
    data.classes = classes;
    data.classes_r = classes_r;
    subj_info = strsplit(subjects_info{subj}, ' ');
    if all
        blocks = nTrainBlocks + nTestBlocks;
        train_data = reshape(eeg, [samples channels blocks*targets]);
        data.blocks = blocks;
        trainEEG = getEEGstruct(train_data, paradigm, data, subj_info);
        dataio_save_mat(Config_path_SM, subj, 'trainEEG');
        clear trainEEG
    else
        train_data = reshape(eeg(:,:,:,1:nTrainBlocks), [samples channels nTrainBlocks*targets]);
        
        data.blocks = nTrainBlocks;
        trainEEG = getEEGstruct(train_data, paradigm, data, subj_info);
        dataio_save_mat(Config_path_SM, subj, 'trainEEG');
        clear trainEEG
        
        test_data = reshape(eeg(:,:,:,nTrainBlocks+1:end), [samples channels nTestBlocks*targets]);
        data.blocks = nTestBlocks;
        testEEG = getEEGstruct(test_data, paradigm, data, subj_info);
        dataio_save_mat(Config_path_SM, subj, 'testEEG');
        clear testEEG eeg
    end
    disp('Data epoched saved in:');
    disp(Config_path_SM);
end
toc
end
%%
function [EEG] = getEEGstruct(eeg, paradigm, data, subj_info)
EEG.epochs.signal = eeg;
EEG.epochs.events = repmat(paradigm.stimuli, 1, data.blocks);
EEG.epochs.y = repmat(data.classes, 1, data.blocks);
EEG.fs = data.fs;
EEG.montage.clab = data.clab;
EEG.classes = data.classes_r;
EEG.paradigm = paradigm;
EEG.subject.id = subj_info{2};
EEG.subject.gender = subj_info{3};
EEG.subject.age = subj_info{4};
EEG.subject.handedness = subj_info{5};
EEG.subject.group = subj_info{6};
end
