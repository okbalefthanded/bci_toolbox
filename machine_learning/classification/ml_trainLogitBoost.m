function [model] = ml_trainLogitBoost(features, alg, cv)
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
if(isfield(alg,'o') || isfield(alg, 's') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end
if(isempty(alg))
    alg.options.n_steps = 300;
    alg.options.stepsize = 0.05;
    alg.options.display = 1;
end

if (cv.nfolds==0)
    if(~isfield(alg.options,'n_steps'))
        alg.options.n_steps = 300;
    else
        if(~isfield(alg.options,'stepsize'))
            alg.options.stepsize = 0.05;
        else
            if(~isfield(alg.options,'display'))
                alg.options.display = 1;
                %
            end
        end
    end
    model = trainLogitBoost(features, alg.options);
else
     % parallel settings
    [settings, datacell, fHandle] = parallel_getInputs(cv,...
                                                       features,...
                                                       alg.learner...
                                                       );
    datacell.data.n_channels = features.n_channels;
    % generate param cell
    paramcell = genParams(alg, settings);
    %     start parallel CV
    [res, resKeys] = startMaster(fHandle, datacell, paramcell, settings);
    %     select_best_hyperparam
    alg = parallel_getBestParam(res, paramcell);
    %     detach Memory
    SharedMemory('detach', resKeys, res);
    %     kill slaves processes
    terminateSlaves;
    cv.nfolds = 0;
    cv = fRMField(cv, 'parallel');
    model = ml_trainLogitBoost(features, alg, cv);
end
model.alg.learner = 'GBOOST';
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg, 'o'))
    if(isfield(alg.o,'n'))
        [alg.options.('n_steps')] = alg.o.('n');
%         fields = {'n'};
    end
    if(isfield(alg.o,'s'))
        [alg.options.('stepsize')] = alg.o.('s');
%         fields = {fields{:}, 's'};
    end
    if(isfield(alg.o,'d'))
        [alg.options.('display')] = alg.o.('d');
%         fields = {fields{:}, 'd'};
    end
    fields = {'o'};
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');
end
alg = fRMField(alg, fields);
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(alg, settings)
M = 2:alg.options.n_steps;
searchSpace = length(M);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.s = alg.options.stepsize;
alg.o.d = alg.options.display;
if(isfield(alg, 'normalizarion'))
    alg.n = alg.normalization;
end
alg = fRMField(alg, {'options','learner'});
m = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.n = M(m);
        tmp{k} = {alg, cv};
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