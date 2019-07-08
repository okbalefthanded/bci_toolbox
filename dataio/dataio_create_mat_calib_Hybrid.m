function [] = dataio_create_mat_calib_Hybrid(folder, ssvep_stimuli)
%DATAIO_CREATE_MAT_HYBRID convert CSV datafiles recorded in Hybrid
% ERP/SSVEP experiments using OpenVibe (>= 2.2.0) to a mat file.
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
% created : 05-16-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic

OVTK_StimulationId_TrialStart = 32773;
OVTK_StimulationId_TrialStop = 32774;
OVTK_StimulationId_ExperimentStart = 32769;
OVTK_StimulationId_ExperimentStop = 32770;

ssvep_montage = {'Pz','PO5','PO3','POz','PO4','PO6', 'O1','Oz','O2'};

set_path = ['datasets\',folder,'\calib'];
dataSetFiles = dir([set_path,'\*.csv']);
filesDates = {dataSetFiles.date};
dataSetFiles = {dataSetFiles.name};
nFiles = length(dataSetFiles);

folder_parts = strsplit(folder, '\');
subject = folder_parts{3};
% file_signal = dataSetFiles{1};
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
    %     exp_start = find(desc == OVTK_StimulationId_ExperimentStart, 1);
    exp_start = find(desc == OVTK_StimulationId_ExperimentStart);
    ends_idx  = find(desc == OVTK_StimulationId_ExperimentStop);
    ends = pos(ends_idx);
    if(isempty(exp_start))
        % Backward compatibility for experiments data where experiment
        % start marker is absent
        starts_idx = find(desc == OVTK_StimulationId_TrialStart);
        % desc
        ERP_expStart_desc = starts_idx(1);
        ERP_expEnd_desc = ends_idx(1);
        tmp =  starts_idx(starts_idx > ERP_expEnd_desc);
        SSVEP_expStart_desc = tmp(1);
        SSVEP_expEnd_desc = ends_idx(2);
        % pos : time
        starts_pos = pos(starts_idx);
        ERP_expStart_pos = starts_pos(1);
        ERP_expEnd_pos = ends(1); % adding 1 sec
        tmp = starts_pos(starts_pos > ERP_expEnd_pos);
        SSVEP_expStart_pos = tmp(1);
        SSVEP_expEnd_pos = ends(2);
    else
        %         TODO
        ERP_expStart_desc = 2; % indices
        ERP_expEnd_desc = ends_idx(1);
        %
        tmp =  exp_start(exp_start > ERP_expEnd_desc);
        SSVEP_expStart_desc = tmp(1);
        SSVEP_expEnd_desc = ends_idx(2);
        % pos : time
        ERP_expStart_pos = pos(exp_start(1));
        ERP_expEnd_pos = ends(1); % adding 1 sec
        
        SSVEP_expStart_pos = pos(tmp(1));
        SSVEP_expEnd_pos = ends(2);
    end
    % markers
    ERP_desc = desc(ERP_expStart_desc:ERP_expEnd_desc);
    ERP_pos = pos(ERP_expStart_desc:ERP_expEnd_desc);
    SSVEP_desc = desc(SSVEP_expStart_desc:SSVEP_expEnd_desc);
    SSVEP_pos = pos(SSVEP_expStart_desc:SSVEP_expEnd_desc);
    
    % ERP data
    erp.montage = montage;
    erp.interval = [ceil(ERP_expStart_pos*fs),ceil(ceil(ERP_expEnd_pos*fs))];
    erp.events.desc = ERP_desc;
    erp.events.pos = ERP_pos;
    erp.events = dataio_geteventsLARESI(erp.events, fs);
    erp.paradigm.title = 'Inverted_Face_Speller';
    erp.paradigm.stimulation = 100;
    erp.paradigm.isi = 50;
    erp.paradigm.repetition = 10;
    erp.paradigm.stimuli_count = 9;
    erp.paradigm.type = 'SC';
    erp.desired_phrase = '123456789';
    
    % SSVEP data
    ssvep.interval = [ceil(SSVEP_expStart_pos*fs),ceil(ceil(SSVEP_expEnd_pos*fs))];
    ssvep.montage = ssvep_montage;
    ssvep.events.desc = SSVEP_desc;
    ssvep.events.pos = SSVEP_pos;
    [ssvep.paradigm.stimulation, ssvep.paradigm.pause, ssvep.paradigm.title] = dataio_getExperimentInfo(ssvep.events);
    ssvep.events = dataio_geteventsLARESI(ssvep.events, fs);
    %     stimuli = {'idle', '6','7.5','8.57','10'}; stimuli pattern
    ssvep.paradigm.stimuli = ssvep_stimuli;
    ssvep.paradigm.stimuli_count = length(ssvep.paradigm.stimuli);
    
    if(sum(mod(60,str2double(ssvep_stimuli))==0) > length(ssvep_stimuli)/2) %%
        ssvep.paradigm.type = 'ON_OFF';
    else
        ssvep.paradigm.type = 'Sinusoidal';
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
    path = [path,subject_folder,'\calib\'];
    
    if(~exist(path,'dir'))
        mkdir(path);
    end 
        
    file_name = [path data.subject,'_',date,'_hybrid_ov.mat'];
    save(file_name, 'data');
    disp([' file saved in: ', file_name]);
end
utils_get_time(toc);
end


