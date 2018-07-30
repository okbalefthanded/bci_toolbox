function [model] = ml_trainRF(features, alg, cv)
%ML_TRAINRF Summary of this function goes here
%   Detailed explanation goes here

% created 06-14-2016
% last revised -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% recover struct fields, works for Guesemha
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end
if (cv.nfolds == 0)
    trainData = features.x;
    trainLabel = features.y;
    nFeatures = size(trainData,2);
    
    if (~isfield(alg.options,'ntrees') && ~isfield(alg.options,'mtry') && ~isfield(alg.options,'replace'))
        nTrees = 500;
        mtry = round(sqrt(nFeatures));
        opts.replace = 1;
    else
        nTrees = alg.options.ntrees;
        mtry = alg.options.mtry;
        opts = alg.options.replace;
    end    
    
    % nTrees (n_estimators), mtry (max_features), replace (bootstrap)    
    model = classRF_train(trainData, trainLabel, nTrees, mtry, opts);
    model.alg.learner = 'RF';    
else
    % parallel settings
    settings.isWorker = cv.parallel.isWorker;
    settings.nWorkers = cv.parallel.nWorkers;
    datacell.data.x = features.x;
    datacell.data.y = features.y;
    %     cv split, kfold
    datacell.fold = ml_crossValidation(cv, size(features.x, 1));
    %     Train & Predict functions
    %     SharedMatrix bug, fieldnames should have same length
    fHandle.tr = 'ml_trainRF';
    fHandle.pr = 'ml_applyRF';
    alg.nFeatures = floor(sqrt(size(features.x,2)));
    %     generate param cell
    paramcell = genParams(alg, settings);
    %     start parallel CV
    [res, resKeys] = startMaster(fHandle, datacell, paramcell, settings);
    %     select_best_hyperparam
    [best_worker, best_evaluation] = getBestParamIdx(res, paramcell);
    best_param = paramcell{best_worker}{best_evaluation}{1};
    %     detach Memory
    SharedMemory('detach', resKeys, res);
    %     kill slaves processes
    terminateSlaves;
    alg = best_param;
    cv.nfolds = 0;
    cv = fRMField(cv, 'parallel');
    model = ml_trainRF(features, alg, cv);
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg,'o'))
    [alg.('options').('ntrees')] = alg.('o').('n');
    [alg.('options').('mtry')] = alg.('o').('m');
    [alg.('options').('replace')] = alg.('o').('r');
    [alg.('options')] = alg.('o');
    fields = {'o'};
end
if(isfield(alg, 'n'))
    [alg.('normalization')] = alg.('n');
    fields = {fields{:}, 'n'};
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');
end
alg = fRMField(alg, fields);
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(alg, settings)
% ntrees
if(size(alg.options.ntrees,2)==2)
    ntrees = alg.options.ntrees:50:alg.options.ntrees(2);
else if(numel(alg.options.ntrees) > 2)
        ntrees = alg.options.ntrees;
    else
        % default range
        ntrees = 100:100:500;
    end
end
% mtry
if(size(alg.options.mtry,2)==2)
    mtry = alg.options.mtry:10:alg.options.mtry(2);
else if(numel(alg.options.mtry) > 2)
        mtry = alg.options.mtry;
    else
        % default range
        mtry = alg.nFeatures:alg.nFeatures+50;
    end
end
% replace
if(numel(alg.options.replace)==2)
    replace = alg.options.replace;
else
    replace = 1;
end
%
searchSpace = length(ntrees)*length(mtry)*length(replace);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.r = alg.options.replace;
if(isfield(alg, 'normalization'))
    alg.n = alg.normalization;
end
m = 1;
n = 1;
% p = 1;
off = 0;
alg = fRMField(alg, {'options', 'nFeatures','learner'});
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.n = ntrees(m);       
        alg.o.m = mtry(n);        
%         if(isfield(alg.o,'r'))
%             alg.o.r = replace;
%         end
        tmp{k} = {alg, cv};
        n = n + 1;
        if(n > length(mtry) && m < length(ntrees))
            n = 1;
            m = m+1;
        end
    end
    paramcell{i} = tmp;
    if((nWorkers - i) == offset)
        off = 1;
    end
end

end

