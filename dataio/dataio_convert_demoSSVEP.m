function [] = dataio_convert_demoSSVEP
%DATAIO_CONVERT_DEMOSSVEP Summary of this function goes here
%   Detailed explanation goes here

paradigm.title = 'SSVEP_FLICKER';
paradigm.stimulation = 4000;
paradigm.pause = 4000;
paradigm.stimuli_count = 4;
paradigm.type = 'ON/OFF';
% paradigm.stimuli = [10, 9, 8, 6];
paradigm.stimuli = [9.75, 8.75, 7.75, 5.75];
subj = 1;
fs = 250;
set_path = 'datasets\demo_ssvep';
set_subfolders = dir(set_path);
set_subfolders = set_subfolders(~ismember({set_subfolders.name},{'.','..'}));
file_path = [set_path '\' set_subfolders.name];
load(file_path);
[channels, samples, epochs, stimuli] = size(SSVEPdata);
train_data = SSVEPdata(:,:,1:15,:);
train_data = permute(train_data, [2 1 3 4]);
train_data = reshape(train_data, [samples channels 15*stimuli]);
test_data = SSVEPdata(:,:,16:end,:);
test_data = permute(test_data, [2 1 3 4]);
test_data = reshape(test_data, [samples channels 5*stimuli]);

train_events = [ones(1,15), 2*ones(1,15), 3*ones(1,15), 4*ones(1,15)]; 
test_events = [ones(1,5), 2*ones(1,5), 3*ones(1,5), 4*ones(1,5)]; 
trainEEG{subj}.epochs.signal = train_data;
trainEEG{subj}.epochs.events = train_events;
trainEEG{subj}.epochs.y = train_events;
trainEEG{subj}.fs = fs;
trainEEG{subj}.montage.clab = {'P7', 'P3', 'Pz', 'P4', 'P8', 'O1', 'Oz', 'O2'};
trainEEG{subj}.classes = {'F1', 'F2', 'F3', 'F4'};
trainEEG{subj}.paradigm = paradigm;
trainEEG{subj}.subject.id = '1';
trainEEG{subj}.subject.gender = '';
trainEEG{subj}.subject.age = 0;
trainEEG{subj}.subject.condition = 'healthy';

disp('Processing Test data succeed for subject: 1');
% Test data
testEEG{subj}.epochs.signal = test_data;
testEEG{subj}.epochs.events = test_events;
testEEG{subj}.epochs.y = test_events;
testEEG{subj}.fs = fs;
testEEG{subj}.montage.clab = {'P7', 'P3', 'Pz', 'P4', 'P8', 'O1', 'Oz', 'O2'};
testEEG{subj}.classes = {'F1', 'F2', 'F3', 'F4'};
testEEG{subj}.paradigm = paradigm;
testEEG{subj}.subject.id = '1';
testEEG{subj}.subject.gender = '';
testEEG{subj}.subject.age = 0;
testEEG{subj}.subject.condition = 'healthy';

% save
Config_path = 'datasets\epochs\demo_ssvep\';

if(~exist(Config_path,'dir'))
    mkdir(Config_path);
end

save([Config_path '\trainEEG.mat'],'trainEEG','-v7.3');
save([Config_path '\testEEG.mat'],'testEEG','-v7.3');

disp('Data epoched saved in:');
disp(Config_path);

end

