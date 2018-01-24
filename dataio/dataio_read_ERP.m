function [data] = dataio_read_ERP(set, datatype)
%DATAIO_READ_ERP Summary of this function goes here
%   Detailed explanation goes here


%
% created 10-30-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
disp(['EVALUATING: dataio_read_ERP -- ARGUMNETS: ' set]);

path = 'BCI_TOOLBOX\datasets\epochs\';
switch upper(set)
    
    case 'LARESI_FACE_SPELLER_120'
        laresi_set_path = [path 'LARESI_FACE_SPELLER_120\'];
        if (strcmp(datatype,'train'))
            data = load([laresi_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([laresi_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
    case 'LARESI_FACE_SPELLER_150'
        laresi_set_path = [path 'LARESI_FACE_SPELLER_150\'];
        if (strcmp(datatype,'train'))
            data = load([laresi_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([laresi_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    case 'P300_ALS'
        p300_als_set_path = [path 'P300-ALS\'];
        if (strcmp(datatype,'train'))
            data = load([p300_als_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([p300_als_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    case 'III_CH'
        ch_III_set_path = [path 'Comp_III_ch_2004\Comp_config\'];
        if (strcmp(datatype,'train'))
            data = load([ch_III_set_path 'trainEEG.mat']);
            data = data.trainEEG;
        else
            data = load([ch_III_set_path 'testEEG.mat']);
            data = data.testEEG;
        end
        
    case 'EPFL_IMAGE_SPELLER'
        epfl_set_path = [path 'EPFL\'];
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

