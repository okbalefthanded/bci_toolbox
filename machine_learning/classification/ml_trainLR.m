function [model] = ml_trainLR(features, alg, cv)
%ML_TRAINLR Summary of this function goes here
%   Detailed explanation goes here
% created : 05-10-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% recover struct fields, works for Guesemha
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end
if(isempty(alg.options))
    alg.options.regularizer = 'L1';
end
trainData = sparse(features.x);
trainLabel = features.y;
if(cv.nfolds == 0)
    if (isfield(alg,'options'))
        if(isfield(alg.options,'C'))
            C = alg.options.C;
        else 
            C = 1;
        end
        switch(alg.options.regularizer)
            case 'L1'
                lroptions = '-s 6';
            case 'L2'
                lroptions = '-s 7';
            otherwise
                error('Incorrect Regularizer for Logistic Regression');
        end
        lroptions = [lroptions,' -c ',sprintf('%d',C),' -e 0.001',' ','-w1 1 -w-1 1'];
        classifier = liblintrain(trainLabel, trainData, lroptions);
    else
        classifier = liblintrain(trainLabel, trainData, '-s 0 -q 1');
    end
    model.classifier = classifier;
    model.alg.learner = 'LR';
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
    fHandle.tr = 'ml_trainLR';
    fHandle.pr = 'ml_applyLR';
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
    model = ml_trainLR(features, alg, cv);
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg,'o'))
    [alg.('options')] = alg.('o');
    [alg.('options').('regularizer')] = alg.('o').('r');
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
if(size(alg.options.C,2)==2)
    Cs = alg.options.C(1):0.1:alg.options.C(2);
    Cs(Cs==0) = [];
else if(numel(alg.options.C) > 2)
        Cs = alg.options.C;
    else
        % default range
        Cs = [0.001, 0.01, 0.1, 1, 10, 50];
    end
end
searchSpace = length(Cs);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, settings.nWorkers);
cv.n = 0;
alg.o.r = alg.options.regularizer;
if(isfield(alg, 'normalizarion'))
    alg.n = alg.normalization;
end
m = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.C = Cs(m);
        tmp{k} = {alg, cv};
        if(m < length(Cs))
            m = m+1;
        end
    end
    paramcell{i} = tmp;
    if(i == offset)
        off = 1;
    end
end
end
