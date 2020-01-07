function [] = dataio_create_epochs_SM_Exoskeleton(epoch_length, filter_band,augment)
%DATAIO_CREATE_EPOCHS_EXOSKELETON segment ssvep-exoskeleton dataset and
%  save epochs  in seperate files for each subject
% Arguments:
%     In:
%         epoch_length : DOUBLE [1x2] [start end] in msec of epoch relative
%         to stimulus onset marker.
%         filter_band : DOUBLE [1x2] [low_cutoff high_cutoff] filtering
%             frequency band in Hz
%     Returns:
%      None.
% Epoched files are aved in the folder: datasets/epochs/SM/ssvep_exoskeleton
% Example :
%     dataio_create_epochs_SM_Exoskeleton([0 2000], [5 45])
%
% Dependencies :
%   eeg_filter.m from EEGLAB toolbox
%
% Reference :
%   Emmanuel K. Kalunga, Sylvain Chevallier, Quentin Barthelemy. "Online
%   SSVEP-based BCI using Riemannian Geometry". Neurocomputing, 2016.
%   arXiv research report on arXiv:1501.03227.
%
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
paradigm.stimuli = {'idle','13','21','17'};

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
        if(~isempty(filter_band))
            signal = eeg_filter(signal, fs, filter_band(1), filter_band(2), filter_order);
        end
        % v = [eeg_epoch(raw_signal, epoch + np.diff(epoch) * i, pos) for i in range(augmented)]
        events = dataio_geteventsExoskeleton(header);
        if augment
            ep = diff(epoch_length) * fs / 10^3;
            agmt = floor(paradigm.stimulation / diff(epoch_length));
            for i=0:agmt-1
                epochs = dataio_getERPEpochs(wnd + ep*i, events.pos, signal);
                epo = cat(3, epo, epochs);
            end
            ev.desc = repmat(cat(1, ev.desc, events.desc), [agmt,1]);
            ev.y = repmat(cat(1, ev.y, events.y),[agmt,1]);
        else
            epochs = dataio_getERPEpochs(wnd, events.pos, signal);
            epo = cat(3, epo, epochs);
            ev.desc = cat(1, ev.desc, events.desc);
            ev.y = cat(1, ev.y, events.y);
        end
        %         epochs = dataio_getERPEpochs(wnd, events.pos, signal);
        %         epo = cat(3, epo, epochs);
        %         ev.desc = repmat(cat(1, ev.desc, events.desc), []);
        %         ev.y = repmet(cat(1, ev.y, events.y));
    end
    trainEEG = getEEGstruct(epo, ev, fs, header, paradigm, subj);
    dataio_save_mat(Config_path_SM, subj, 'trainEEG');
    disp(['Processing Train data succeed for subject: ' num2str(subj)]);
    clear signal header trainEEG ev events
    
    disp(['Processing Test data succeed for subject: ' num2str(subj)]);
    % Test data
    [signal, header] = mexSLOAD([subject_path '\' subject_files(files_count).name]);
    signal = signal * gain; % amplifying the signal
    if(~isempty(filter_band))
        signal = eeg_filter(signal, fs, filter_band(1), filter_band(2), filter_order);
    end
    events = dataio_geteventsExoskeleton(header);
    epo = [];
    ev.desc = [];
    ev.y = [];
    if augment
        for i=0:agmt-1
            epochs = dataio_getERPEpochs(wnd + ep*i, events.pos, signal);
            epo = cat(3, epo, epochs);
        end
        epochs = epo;
        ev.desc = repmat(cat(1, ev.desc, events.desc), [agmt,1]);
        ev.y = repmat(cat(1, ev.y, events.y),[agmt,1]);
    else
        epochs = dataio_getERPEpochs(wnd, events.pos, signal);
        ev.desc = cat(1, ev.desc, events.desc);
        ev.y = cat(1, ev.y, events.y);
    end
    %     events = dataio_geteventsExoskeleton(header);
    %     epochs = dataio_getERPEpochs(wnd, events.pos, signal);
    testEEG = getEEGstruct(epochs, ev, fs, header, paradigm, subj);
    dataio_save_mat(Config_path_SM, subj, 'testEEG');
    disp(['Processing Test data succeed for subject: ' num2str(subj)]);
    
    clear signal header testEEG events
    disp('Data epoched saved in:');
    disp(Config_path_SM);
end
toc
end

%%
function [EEG] = getEEGstruct(epo, ev, fs, header, paradigm, subj)
EEG.epochs.signal = epo;
EEG.epochs.events = ev.desc;
EEG.epochs.y = ev.y';
EEG.fs = fs;
EEG.montage.clab = header.Label;
EEG.classes = paradigm.stimuli;
EEG.paradigm = paradigm;
EEG.subject.id = num2str(subj);
EEG.subject.gender = '';
EEG.subject.age = 0;
EEG.subject.condition = 'healthy';
end

