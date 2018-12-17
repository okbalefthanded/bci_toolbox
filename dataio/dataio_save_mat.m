function [] = dataio_save_mat(filepath, subj, varname)
%DATAIO_SAVE_MAT Summary of this function goes here
%   Detailed explanation goes here
% created : 12-17-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if(strcmp(varname, 'trainEEG'))
    trainEEG = evalin('caller', varname);
    save([filepath,'\','S0',num2str(subj),'trainEEG.mat'], 'trainEEG', '-v7.3'); 
else
    testEEG = evalin('caller', varname);
    save([filepath,'\','S0',num2str(subj),'testEEG.mat'], 'testEEG', '-v7.3'); 
end
   
end

