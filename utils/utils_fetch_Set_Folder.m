function [nSubjects] = utils_fetch_Set_Folder(set)
%UTILS_FETCH_SET_FOLDER Summary of this function goes here
%   Detailed explanation goes here

% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

path = 'datasets\epochs\';
datasets = dir(path);
datasets = {datasets(3:end).name};
set_idx = ~cellfun(@isempty, (strfind(upper(datasets), set.title)));
set_in_folder = datasets(set_idx);
set_path = strcat(path, set_in_folder{:});
dataSetFiles = dir([set_path '\*.mat']);
flag = 1;
p = '';
ppth = set_path;
if(isempty(dataSetFiles))
    while(flag)
        drs = dir(ppth);
        drs = {drs(3:end).name};
        id = strcmp(drs, 'SM');
        if(sum(id)==0 && ~isempty(id))
            ppth = drs{:};          
            p = strcat(p,drs{:});
        else
            flag = 0;
        end
    end
    set_path = strcat(set_path,'\', p);
    dataSetFiles = dir([set_path '\SM\*.mat']);
    if(isempty(dataSetFiles))
        dataSetFiles = dir([set_path '\SM']);
        dataSetFiles(1:2) = [];
        dataSetFiles ={dataSetFiles.name};
        set_path = [set_path,'SM\',dataSetFiles{end}];
        dataSetFiles = dir([set_path '\*.mat']);        
    end
else
    dataSetFiles = {dataSetFiles.name};
end
nSubjects = sum(~cellfun(@isempty,(strfind({dataSetFiles.name}, 'trainEEG'))));
end

