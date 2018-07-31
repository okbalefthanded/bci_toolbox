function [settings, datacell, fHandle] = parallel_getInputs(cv, features, learner)
%PARALLEL_ Summary of this function goes here
%   Detailed explanation goes here
% created 07-31-2016
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

settings.isWorker = cv.parallel.isWorker;
settings.nWorkers = cv.parallel.nWorkers;

if(isfield(features, 'x'))
    datacell.data.x = features.x;
    datacell.data.y = features.y;
    %     cv split, kfold
else
    datacell.data = features;
end
datacell.fold = ml_crossValidation(cv, length(features.y));

%     Train & Predict functions
%     SharedMatrix bug, fieldnames should have same length
fHandle.tr = ['ml_train', upper(learner)];
if(isempty(which(['ml_apply',upper(learner)])))
    fHandle.pr = ['ml_apply',upper(learner(end-2:end))];
else
    fHandle.pr = ['ml_apply',upper(learner)];
end
end

