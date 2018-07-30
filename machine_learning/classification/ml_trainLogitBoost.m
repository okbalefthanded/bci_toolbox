function [model] = ml_trainLogitBoost(features, opts, cv)
%ML_TRAINLOGITBOOST Summary of this function goes here
%   Detailed explanation goes here

% created 11-06-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% Adapted to the ERP_ClASSIFICATION_BENCHMARK from the original Code
% -------------------------------------------------------------------------
% train is used to setup a classifier with LogitBoosting
%
% INPUT
%   l: an initialized LogitBoost object
%   x: matrix of feature vectors, columns are feature vectors, number of
%      columns equals number of feature vectors. See example.m for format
%      of feature vectors.
%   y: rowvector with labels of feature vectors, labels have to be 0 or 1
%   n_channels: number of EEG electrodes
%
% OUTPUT
%   l: an updated LogitBoost object (ready to be used as a classifier)
%
% Author: Ulrich Hoffmann - EPFL, 2005
% Copyright: Ulrich Hoffmann - EPFL
% -------------------------------------------------------------------------
%
% recover struct fields, works for Guesemha
if(isfield(opts,'n') || isfield(opts, 's') || isfield(cv, 'n'))
    [opts, cv] = recoverStructs(opts, cv);
end
if(isempty(opts))
    opts.n_steps = 300;
    opts.stepsize = 0.05;
    opts.display = 1;
end

if (cv.nfolds==0)
    if(~isfield(opts,'n_steps'))
        opts.n_steps = 300;
    else
        if(~isfield(opts,'stepsize'))
            opts.stepsize = 0.05;
        else
            if(~isfield(opts,'display'))
                opts.display = 1;
                %
            end
        end
    end
    model = trainLogitBoost(features, opts);
else
    % parallel settings
    settings.isWorker = cv.parallel.isWorker;
    settings.nWorkers = cv.parallel.nWorkers;
    datacell.data.x = features.x;
    datacell.data.y = features.y;
    datacell.data.n_channels = features.n_channels;
    %     cv split, kfold
    datacell.fold = ml_crossValidation(cv, size(features.x, 1));
    %     Train & Predict functions
    %     SharedMatrix bug, fieldnames should have same length
    fHandle.tr = 'ml_trainLogitBoost';
    fHandle.pr = 'ml_applyLogitBoost';
    %     generate param cell
    paramcell = genParams(opts, settings);
    %     start parallel CV
    [res, resKeys] = startMaster(fHandle, datacell, paramcell, settings);
    %     select_best_hyperparam
    [best_worker, best_evaluation] = getBestParamIdx(res, paramcell);
    best_param = paramcell{best_worker}{best_evaluation}{1};
    %     detach Memory
    SharedMemory('detach', resKeys, res);
    %     kill slaves processes
    terminateSlaves;
    opts = best_param;
    cv.nfolds = 0;
    cv = fRMField(cv, 'parallel');
    model = ml_trainLogitBoost(features, opts, cv);
end
model.alg.learner = 'GBOOST';
end
%%
function [opts, cv] = recoverStructs(opts, cv)
if(isfield(opts,'n'))
    [opts.('n_steps')] = opts.('n');
    fields = {'n'};
end
if(isfield(opts,'s'))
    [opts.('stepsize')] = opts.('s');
    fields = {fields{:}, 's'};
end
if(isfield(opts,'d'))
    [opts.('display')] = opts.('d');
    fields = {fields{:}, 'd'};
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');
end
opts = fRMField(opts, fields);
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(opts, settings)
M = 2:opts.n_steps;
searchSpace = length(M);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
opts.s = opts.stepsize;
opts.d = opts.display;
if(isfield(opts, 'normalizarion'))
    opts.n = opts.normalization;
end
m = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        opts.n = M(m);
        tmp{k} = {opts, cv};
        if(m < length(M))
            m = m+1;
        end
    end
    paramcell{i} = tmp;
    if(i == offset)
        off = 1;
    end
end
end