% 01-25-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% add toolbox folder to path
if (~isdir('datasets'))
    mkdir('datasets');
end
folders = dir;
folders_idx = cell2mat({folders.isdir});
folders = folders(folders_idx);
folders = {folders(4:end).name};
pth = strcat({[pwd '\']}, folders);
p =[];
for i=1:length(pth)
    p = [p genpath(pth{i})];
end
pth = strcat(p, ';', pwd);
addpath(pth);
savepath
disp('Setup completed.');
clear