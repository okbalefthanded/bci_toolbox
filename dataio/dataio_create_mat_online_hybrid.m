function [] = dataio_create_mat_online_Hybrid(folder, ssvep_stimuli)
%DATAIO_CREATE_ONLINE_HYBRID convert CSV datafiles recorded in an online
% Hybrid ERP/SSVEP experiments using OpenVibe (>= 2.2.0) to a mat file.
%
%   input: folder [1xN] path of the folder containing csv files to be
%           converted one subject at a time
%   ssvep_stimuli cell{1xN} : paradigm stimuli
%   output:
%      None
% saved EEG data format:
%       data : struct [1x1]
%             .erp   : struct [1x1]
%             .ssvep : struct [1x1]
%            each has the following fields:
%               .signal : [Samples x Channels] continuous EEG signal.
%               .events : struct [1x1]
%                        .y    [Mx1] [stimulations_count 1] a vector of
%                               binary class labels 1/-1 target/non_target
% `                      .desc [Mx1] [stimulations_count 1] a vector
%                               of events descriptions in numbers (1-9)
%                        .pos  [Mx1] [stimulations_count 1] a vector
%                               of events onset in samples.
%               .fs     : double : sampling rate.
%               .montage : cell of string containing channels names
%               .paradigm : struct [1x1]
%                       .stimulation: double : stimulation duration
%                       .pause: double : break duration
%                       .title: string : paradigm title
%                       .stimuli: cell of strings : experiment stimulations
%                       .stimuli_count: double : number of stimulations
%                       .type: string : stimulation method
%             .subject : string : subject name/id
%             .mode : string : operation mode for each paradigm
% created : 06-16-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic
OVTK_StimulationId_TrialStart = 32773;
OVTK_StimulationId_TrialStop = 32774;
OVTK_StimulationId_ExperimentStart = 32769;
OVTK_StimulationId_ExperimentStop = 32770;

ssvep_montage = {'Pz','PO5','PO3','POz','PO4','PO6', 'O1','Oz','O2'};

set_path = ['datasets\',folder,'\online\copy'];
dataSetFiles = dir([set_path,'\*.csv']);
filesDates = {dataSetFiles.date};
dataSetFiles = {dataSetFiles.name};
nFiles = length(dataSetFiles);

folder_parts = strsplit(folder, '\');
subject = folder_parts{3};
for file = 1:nFiles
    % fs, montage, signal, events
    file_signal = [set_path, '\', dataSetFiles{file}];
    fid = fopen(file_signal);
    num_attrib = 21; %fs, epoch, 16 channels (max possible at the lab, event id, event
    fmt = repmat('%s', 1, num_attrib);
    datacell = textscan(fid, fmt, 'Delimiter', ',', 'CollectOutput', 1);
    fclose(fid);
    %
    header = datacell{1,1}(1,:);
    event_id_idx = find(strcmp(header, 'Event Id'), 1);
    fs = strsplit(header{1},':');
    fs = strsplit(fs{2},'Hz');
    fs = str2double(fs{1});
    montage = header(3:event_id_idx-1);
    nCells = event_id_idx - 1;
    %
    disp('Processing Signal...');
    all = datacell{:};
    all_str = all(2:end,3:nCells);
    all_str = cellfun(@(x) x(1,1:10), all_str, 'UniformOutput', false); % 10 for precision
    signal = cellfun(@str2num, all_str);
    %
    disp('Processing Markers...');
    markers = all(2:end, event_id_idx:event_id_idx+2);
    emptyEntries = ~cellfun(@isempty, markers);
    markers = markers(emptyEntries(:,1), :);
    
    clear datacell datacell_stim all_str
    length_markers_each = cell2mat(cellfun(@length, markers(:,1), 'UniformOutput', false));
    length_markers = unique(length_markers_each);
    if(length(length_markers) > 1)
        % in some entries a single entry of markers has two : makrer1:marker2
        % longer_markers_id = length_markers_each == length_markers(2);
        tmp_pos = cellfun(@(s) strsplit(s, ':'),markers(:,2),'UniformOutput', false);
        tmp_markers = cellfun(@(s) strsplit(s, ':'),markers(:,1),'UniformOutput', false);
        pos = str2double([tmp_pos{:}]');
        desc = str2double([tmp_markers{:}]');
    else
        % sequential markers, normal case
        desc = cell2mat(cellfun(@str2num, markers(:,1),  'UniformOutput', false));
        pos = cell2mat(cellfun(@str2num, markers(:,2),  'UniformOutput', false));
    end
    % trials start and end
    exp_start = find(desc == OVTK_StimulationId_ExperimentStart, 1);
    ends_idx  = find(desc == OVTK_StimulationId_ExperimentStop);
    ends = pos(ends_idx);
    
    trials_start = desc == OVTK_StimulationId_TrialStart;
    trials_end = desc == OVTK_StimulationId_TrialStop;
    
    pos_trials_start = pos(trials_start);
    pos_trials_end = pos(trials_end);
    
    erp_trials_start = pos_trials_start(1:2:end);
    ssvep_trials_start = pos_trials_start(2:2:end);
    erp_trials_end = pos_trials_end(1:2:end);
    ssvep_trials_end = pos_trials_end(2:2:end);
    
    erp_id = bsxfun(@ge, pos, erp_trials_start') & bsxfun(@le, pos, erp_trials_end');
    ssvep_id = bsxfun(@ge, pos, ssvep_trials_start') & bsxfun(@le, pos, ssvep_trials_end');
    
    n_trials = length(erp_trials_start);
    for i=1:n_trials
        erp_id(:,1) = or(erp_id(:,1),erp_id(:,i));
        ssvep_id(:,1) = or(ssvep_id(:,1),ssvep_id(:,i));
    end
    erp_id = erp_id(:,1);
    ssvep_id = ssvep_id(:,1);
    ERP_desc = desc(erp_id);
    ERP_pos = pos(erp_id);
    SSVEP_desc = desc(ssvep_id);
    SSVEP_pos = pos(ssvep_id);
    
    % ERP data
    erp.montage = montage;
    erp.interval = [ceil(erp_trials_start*fs),ceil(ceil(erp_trials_end*fs))];
    erp.events.desc = ERP_desc;
    erp.events.pos = ERP_pos;
    erp.events = dataio_geteventsLARESI(erp.events, fs);
    erp.paradigm.title = 'Inverted_Face_Speller';
    erp.paradigm.stimulation = 100;
    erp.paradigm.isi = 50;
    %     erp.paradigm.repetition = 10;
    erp.paradigm.stimuli_count = 9;
    erp.paradigm.type = 'SC';
    erp.desired_phrase = '123456789';
    erp.mode = 'online';
    
    % SSVEP data
    ssvep.montage = ssvep_montage;
    ssvep.interval = [ceil(ssvep_trials_start*fs),ceil(ceil(ssvep_trials_end*fs))];
    ssvep.events.desc = SSVEP_desc;
    ssvep.events.pos = SSVEP_pos;
    [ssvep.paradigm.stimulation, ~, ssvep.paradigm.title] = dataio_getExperimentInfo(ssvep.events);
    ssvep.events = dataio_geteventsLARESI(ssvep.events, fs);
    %     stimuli = {'idle', '6','7.5','8.57','10'}; stimuli pattern
    ssvep.paradigm.stimuli = ssvep_stimuli;
    ssvep.paradigm.stimuli_count = length(ssvep.paradigm.stimuli);
    
    if(sum(mod(60,str2double(ssvep_stimuli))==0) > length(ssvep_stimuli)/2) %%
        ssvep.paradigm.type = 'ON_OFF';
    else
        ssvep.paradigm.type = 'Sinusoidal';
    end
    if( strcmp(ssvep_stimuli,'idle'))
        ssvep.mode = 'async_online';
    else
        ssvep.mode = 'sync_online';
    end
    
    % all data
    data.signal = signal;
    data.fs = fs;
    data.montage = montage;
    data.subject = subject;
    data.erp = erp;
    data.ssvep = ssvep;
    
    if(isnan(str2double(folder_parts(end))))
        subject_folder = [folder_parts{end-1} '\' folder_parts{end}];
    else
        subject_folder = ['\',folder_parts(end)];
    end
    
    date = datestr(filesDates{file},'dd_mmmm_yyyy_HH.MM.SS.FFF');
    disp(['Creating mat files for subject: ' data.subject]);
    % save
    tmp = strsplit(file_signal, 'CSV');
    path = [tmp{1} 'raw_mat\'];
    if(~exist(path,'dir'))
        mkdir(path);
    end
    
    path = [path,subject_folder,'\online\copy\'];
    if(~exist(path,'dir'))
        mkdir(path);
    end
    file_name = [path data.subject,'_',date,'_hybrid_online_ov.mat'];
    save(file_name, 'data');
    disp([' file saved in: ', file_name]);
end

end


