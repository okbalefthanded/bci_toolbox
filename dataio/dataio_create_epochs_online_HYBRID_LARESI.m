function [] = dataio_create_epochs_online_HYBRID_LARESI(set, erp_epoch, erp_band, ssvep_epoch, ssvep_band)
%DATAIO_CREATE_EPOCHS_HYBRID_ONLINE_LARESI
% created : 06-16-2019
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
tic
disp('Creating epochs for LARESI SSVEP dataset');
Config_path_SM = 'datasets\epochs\hybrid_laresi\SM';
dataSetFiles = dir(['datasets\',set,'\online\copy\*.mat']);
dataSetFiles = {dataSetFiles.name};


if(~exist(Config_path_SM,'dir'))
    mkdir(Config_path_SM);
end

date_now = datestr(now);
date_now = strrep(date_now,' ','_');
date_now = strrep(date_now,':','_');
Config_path_SM = [Config_path_SM,'\',date_now];

nSubj = length(dataSetFiles);
trainEEG = cell(1);
train_trials = 1:9;
% test_trials = 6:9;

erp_filter_order = 2;
ssvep_filter_order = 6;
fs = 512; %
erp_wnd = ceil((erp_epoch * fs) / 10^3);
ssvep_wnd = (ssvep_epoch * fs) / 10^3;
correctionInterval = floor([-100 0] * fs / 10^3);
wnd = [correctionInterval(1) erp_wnd(2)];


for subj=1:nSubj
    disp(['Loading data for subject S0' num2str(subj)]);
    subject_path = ['datasets\',set,'\online\copy\',dataSetFiles{subj}];
    load(subject_path);
    % ERP
    erp = data.erp;
    ssvep = data.ssvep;
    erp.subject = data.subject;
    erp.fs = data.fs;
    n_trials = length(erp.interval);
    for tr = 1:n_trials
        s = eeg_filter(data.signal(erp.interval(tr,1):erp.interval(tr,2),:),...
            data.fs, erp_band(1), erp_band(2), erp_filter_order);
        data.signal(erp.interval(tr,1):erp.interval(tr,2),:) = s;
        s = eeg_filter(data.signal(ssvep.interval(tr,1):ssvep.interval(tr,2),:),...
            data.fs, ssvep_band(1), ssvep_band(2),ssvep_filter_order);
        data.signal(ssvep.interval(tr,1):ssvep.interval(tr,2),:) = s;
    end
    events = erp.events;
    trials_train_count = length(train_trials);
    epoch_count = erp.paradigm.repetition * erp.paradigm.stimuli_count;
    ii = repmat(1:epoch_count, length(erp.desired_phrase), 1);
    rep = epoch_count * (length(erp.desired_phrase) - 1);
    id = 0:epoch_count:rep;
    epoch_id = bsxfun(@plus, ii, repmat(id', 1, epoch_count));
    events_train.pos = events.pos(epoch_id);
    events_train.desc = events.desc(epoch_id);
    y_train = events.y(epoch_id(train_trials,:));
    erp.correctionInterval = correctionInterval;
    erp.phrase = erp.desired_phrase;
    erp.y = y_train;
    ERP_testEEG = getEEGstruct(data.signal, wnd, events_train, erp, trials_train_count);
    % SSVEP
    %     ssvep = data.ssvep;
    %     s = eeg_filter(data.signal(ssvep.interval(1):ssvep.interval(2),:),...
    %                    data.fs, ssvep_band(1), ssvep_band(2),ssvep_filter_order);
    %     data.signal(ssvep.interval(1):ssvep.interval(2),:) = s;
    SSVEP_testEEG.epochs.signal = dataio_getERPEpochs(ssvep_wnd, ...
        ssvep.events.pos, data.signal);
    SSVEP_testEEG.epochs.events = ssvep.events.desc;
    SSVEP_testEEG.epochs.y = ssvep.events.y';
    SSVEP_testEEG.fs = data.fs;
    SSVEP_testEEG.montage.clab = ssvep.montage;
    SSVEP_testEEG.classes = ssvep.paradigm.stimuli;
    SSVEP_testEEG.paradigm = ssvep.paradigm;
    SSVEP_testEEG.subject.id = num2str(subj);
    SSVEP_testEEG.subject.gender = 'M';
    SSVEP_testEEG.subject.age = 0;
    SSVEP_testEEG.subject.condition = 'healthy';
    % save
    testEEG.ERP_testEEG = ERP_testEEG;
    testEEG.SSVEP_testEEG = SSVEP_testEEG;
    disp(['Processing Train data succeed for subject: ' num2str(subj)]);
    if(~exist(Config_path_SM,'dir'))
        mkdir(Config_path_SM);
    end
    save([Config_path_SM,'\','S0',num2str(subj),'testEEG.mat'],'testEEG', '-v7.3');
    
end
end

function [EEG] = getEEGstruct(s, wnd, events, data, trials_count)
for trial = 1:trials_count
    disp(['Segmenting Train data for subject:' data.subject]);
    eeg_epochs = dataio_getERPEpochs(wnd, events.pos(trial, :), s);
    eeg_epochs = dataio_baselineCorrection(eeg_epochs, data.correctionInterval);
    EEG.epochs.signal(:,:,:,trial) = eeg_epochs;
    EEG.epochs.events(:,trial) = events.desc(trial, :);
    EEG.epochs.y(:,trial) = data.y(trial,:);
end
EEG.phrase = data.phrase;
EEG.fs = data.fs;
EEG.montage.clab = data.montage;
EEG.classes = {'target', 'non_target'};
EEG.paradigm = data.paradigm;
EEG.paradigm.type = 'SC';
EEG.subject.id = data.subject;
EEG.subject.gender = 'M';
EEG.subject.age = 0;
EEG.subject.condition = 'healthy';
end
