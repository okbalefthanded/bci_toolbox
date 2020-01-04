function [data] = dataio_fuse_data(path)
%DATAIO_FUSE_DATA fuse train and test data to form an unified dataset
% created 01-02-2020
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
data = load([path 'trainEEG.mat']);
train = data.trainEEG;
data = load([path 'testEEG.mat']);
test = data.testEEG;
clear data
%
data.fs = train.fs;
data.classes = train.classes;
data.subject = train.subject;
data.paradigm = train.paradigm;
data.montage = train.montage;
%
data.epochs.signal = cat(3, train.epochs.signal,test.epochs.signal);
data.epochs.y = cat(2, train.epochs.y, test.epochs.y);
data.epochs.events = cat(2, train.epochs.events, test.epochs.events);
end

