function [] = dataio_create_mat_SSVEP_OV(folder, stimuli)
%DATAIO_CREATE_MAT_SSVEP_OV convert CSV datafiles recorded using
% OpenVibe (>= 2.2.0) to a mat file.
%
%   input: folder [1xN] path of the folder containing csv files to be
%   converted one subject at a time
%         stimuli cell{1xN} : paradigm stimuli
%   output:
%      None
% saved EEG data format:
%       data : struct [1x1]
%             .signal : [Samples x Channels] continuous EEG signal.
%             .events : struct [1x1]
%                     .y    [Mx1] [stimulations_count 1] a vector of
%                           binary class labels 1/-1 target/non_target
% `                   .desc [Mx1] [stimulations_count 1] a vector
%                           of events descriptions in numbers (1-9)
%                     .pos  [Mx1] [stimulations_count 1] a vector
%                           of events onset in samples.
%             .fs     : double : sampling rate.
%             .montage : cell of string containing channels names
%             .paradigm : struct [1x1]
%                       .stimulation: double : stimulation duration
%                       .pause: double : break duration
%                       .title: string : paradigm title
%                       .stimuli: cell of strings : experiment stimulations
%                       .stimuli_count: double : number of stimulations
%                       .type: string : stimulation method
%             .subject : string : subject name/id
% created : 12-19-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic
set_path = ['datasets\',folder];
dataSetFiles = dir([set_path,'\*.csv']);
dataSetFiles = {dataSetFiles.name};
nFiles = length(dataSetFiles);
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
    data.fs = str2double(fs{1});
    data.montage = header(3:event_id_idx-1);
    nCells = event_id_idx - 1;
    %
    disp('Processing Signal...');
    all = datacell{:};
    all_str = all(2:end,3:nCells);
    all_str = cellfun(@(x) x(1,1:10), all_str, 'UniformOutput', false); % 10 for precision
    data.signal = cellfun(@str2num, all_str);
    %
    disp('Processing Markers...');
    markers = all(2:end, event_id_idx:event_id_idx+2);
    emptyEntries = ~cellfun(@isempty, markers);
    markers = markers(emptyEntries(:,1), :);
    
    clear datacell datacell_stim all_str
    
%     data.events.pos = cell2mat(cellfun(@str2num, markers(:,2),  'UniformOutput', false));
%     tmp_pos = cellfun(@(s) strsplit(s, ':'),markers(:,2),'UniformOutput', false);
%     data.events.pos = str2double([tmp_pos{:}]');
    length_markers_each = cell2mat(cellfun(@length, markers(:,1), 'UniformOutput', false));
    length_markers = unique(length_markers_each);
    
    if(length(length_markers) > 1)
        % in some entries a single entry of markers has two : makrer1:marker2
        % longer_markers_id = length_markers_each == length_markers(2);
        tmp_pos = cellfun(@(s) strsplit(s, ':'),markers(:,2),'UniformOutput', false);
        tmp_markers = cellfun(@(s) strsplit(s, ':'),markers(:,1),'UniformOutput', false);
        data.events.pos = str2double([tmp_pos{:}]');
        data.events.desc = str2double([tmp_markers{:}]');
    else
        % sequential markers, normal case
        data.events.desc = cell2mat(cellfun(@str2num, markers(:,1),  'UniformOutput', false));
        data.events.pos = cell2mat(cellfun(@str2num, markers(:,2),  'UniformOutput', false));
    end
    
    
    
    [data.paradigm.stimulation, data.paradigm.pause, data.paradigm.title] = dataio_getExperimentInfo(data.events);
    if(strcmp(data.paradigm.title,'SSVEP_OV_LARESI'))
        data.events = dataio_geteventsLARESI(data.events, data.fs);
    else
        data.events = dataio_geteventsOV(data.events, data.fs);
    end
    
    %     stimuli = {'idle', '6','7.5','8.57','10'}; stimuli pattern
    if(isscalar(unique(data.events.y)))
        data.paradigm.stimuli = stimuli{data.events.y(1)};
    else
        %         data.paradigm.stimuli = {stimuli{1:max(data.events.y)}};
        data.paradigm.stimuli = stimuli;
    end
    data.paradigm.stimuli_count = length(data.paradigm.stimuli);
    data.paradigm.type = 'ON/OFF';
    folder_parts = strsplit(folder, '\');
    date = folder_parts(end);
    data.subject = folder_parts(end-1);
    disp(['Creating mat files for subject: ' data.subject]);
    % save
    tmp = strsplit(file_signal, 'CSV');
    path = [tmp{1} 'raw_mat\'];
    if(~exist(path,'dir'))
        mkdir(path);
    end
    path = [path,date{:},'\'];
    if(~exist(path,'dir'))
        mkdir(path);
    end
    save([path data.subject{:},date{:},'_ssvep_ov_',num2str(file),'_.mat'], 'data');
end
toc
end

