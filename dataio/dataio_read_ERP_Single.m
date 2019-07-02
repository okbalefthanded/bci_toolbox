function [data] = dataio_read_ERP_Single(set, datatype)
%DATAIO_READ_ERP_SINGLE Summary of this function goes here
%   Detailed explanation goes here

% created 07-11-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

path = 'datasets\epochs\';
subj = strcat('S0',num2str(set.subj));
switch upper(set.title)    
    
     case 'LARESI_FACE_SPELLER'
        laresi_set_path = [path 'LARESI_FACE_SPELLER\SM\' subj];
        if (strcmp(datatype,'train'))
            data = load([laresi_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([laresi_set_path 'testEEG.mat']);
            data = data.testEEG;
        end    
    %
    case 'LARESI_FACE_SPELLER_120'
        laresi_set_path = [path 'LARESI_FACE_SPELLER_120\SM\' subj];
        if (strcmp(datatype,'train'))
            data = load([laresi_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([laresi_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
    %
    case 'LARESI_FACE_SPELLER_150'
        laresi_set_path = [path 'LARESI_FACE_SPELLER_150\SM\' subj];
        if (strcmp(datatype,'train'))
            data = load([laresi_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([laresi_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
    %    
    case 'P300-ALS'
        p300_als_set_path = [path 'P300-ALS\SM\' subj];
        if (strcmp(datatype,'train'))
            data = load([p300_als_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([p300_als_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
    %    
    case 'III_CH'
        ch_III_set_path = [path 'Comp_III_ch_2004\Comp_config\SM\' subj];
        if (strcmp(datatype,'train'))
            data = load([ch_III_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([ch_III_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
    %    
    case 'EPFL_IMAGE_SPELLER'
        epfl_set_path = [path 'EPFL_image_speller\SM\' subj];
        if (strcmp(datatype,'train'))
            data = load([epfl_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([epfl_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    otherwise
        error('Incorrect Dataset');
        
end
end

