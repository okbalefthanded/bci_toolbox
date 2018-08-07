function [model] = ml_trainHKL(features, alg, cv)
%ML_TRAINHKL Summary of this function goes here
%   Detailed explanation goes here
% created 08-06-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% disp(['EVALUATING: trainHKL: ' alg.learner]);

if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end

if(isempty(alg.options))
    alg.options.kernel.type = 'hermite';
    alg.options.kernel.params = [0.5,3,0.1,4];
    alg.options.lambda = 0.02;
    alg.options.memcache = 2e8;
    alg.options.maxactive = 400;
end

nClasses = numel(unique(features.y));
[classMode, nModels, classPart] = ml_get_classMode(nClasses);
if (~strcmp(classMode,'Bin'))
    models = cell(1, nModels);
    outputs = cell(1, nModels);
end
if (cv.nfolds == 0)  
    if(strcmp(classMode,'Bin'))
        zeros = sum(features.y==0);
        if(zeros==0)
            features.y(features.y~=1) = 0;
        end
        [outputs, models,~]=hkl(features.x, features.y, alg.options.lambda,...
                               'logistic',...
                               alg.options.kernel.type, ...
                               alg.options.kernel.params,...
                               'maxactive', ...
                               alg.options.maxactive,...
                               'memory_cache',...
                               alg.options.memcache...
                               );
    else        
        for m =1:nModels 
            ft = features;
            if(strcmp(classMode,'OvO'))
                idTrain = ft.y==classPart(m,1) | ft.y==classPart(m,2);
                ft.x = ft.x(idTrain, :);
                ft.y = ft.y(idTrain);
                ft.y(ft.y==classPart(m,2)) = 0;
                ft.y(ft.y==classPart(m,1)) = 1;
            else
            ft.y(ft.y~=m) = 0; 
            ft.y(ft.y==m) = 1; 
            end
%             model{m} = ml_trainHKL(ft, alg, cv);
            [outputs{m}, models{m},~]=hkl(ft.x, ft.y, alg.options.lambda,...
                                         'logistic',...
                                         alg.options.kernel.type, ...
                                         alg.options.kernel.params,...
                                         'maxactive', ...
                                         alg.options.maxactive,...
                                         'memory_cache',...
                                         alg.options.memcache...
                                         );
             clear ft                       
        end
    end
    model.outputs = outputs;
    model.model = models;
    model.alg.learner = 'HKL';
    clear global
else
    % parallel settings
    [settings, datacell, fHandle] = parallel_getInputs(cv,...
                                                       features,...
                                                       alg.learner...
                                                       );
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
    models = ml_trainHKL(features, alg, cv);
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg,'o'))
    [alg.('options').('kernel').('type')] = alg.o.('k').('t');
    [alg.('options').('kernel').('params')] = alg.o.('k').('p');
    [alg.('options').('memcache')] = alg.('o').('m');
    [alg.('options').('maxactive')] = alg.('o').('a');
    [alg.('options').('lambda')] = alg.('o').('l');       
    fields = 'o';
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');
    fields = {fields, 'n'};
end
alg = fRMField(alg, fields);
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(alg, settings)
if(size(alg.options.lambda,2)==2)
    lambdas = alg.options.lambda(1):0.1:alg.options.lambda(2);
else if(numel(alg.options.lambda) > 2)
        lambdas = alg.options.lambda;
    else
        % default range
        lambdas = 10.^[1:-.5:-8];
    end
end
searchSpace = length(lambdas);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.k.t = alg.options.kernel.type;
alg.o.k.p = alg.options.kernel.params;
alg.o.m = alg.options.memcache;
alg.o.a = alg.options.maxactive;
m = 1;
n = 1;
off = 0;
alg = fRMField(alg, {'options', 'learner'});
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.l = lambdas(n);
        tmp{k} = {alg, cv};
        n = n + 1;
        if(n > length(lambdas))
            n = 1;
            m = m+1;
        end
    end
    paramcell{i} = tmp;
    if((nWorkers -i) == offset)
        off = 1;
    end
end
end

