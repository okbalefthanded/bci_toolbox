function [model] = ml_trainEASYMKL(features, alg, cv)
%ML_TRAINEASYMKL Summary of this function goes here
%   Detailed explanation goes here
% created 11-06-2018
% last modfied -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end
if(isempty(alg.options))
    alg.options.parameters.lambda = 0.5;
    alg.options.kernel.gamma = 0.1;
    alg.options.d = 5;
    alg.options.r = 50;
end
if(cv.nfolds == 0)
     if (isfield(alg,'normalization'))
        norml = utils_estimate_normalize(features.x, alg.normalization);
        trainData = utils_apply_normalize(features.x, norml);
    else
        trainData = features.x;
     end    
    [n,m,~] = size(trainData);
    if(alg.options.d > m)
       alg.options.d = m; 
    end
    repartitions = randi(alg.options.d, [alg.options.r alg.options.d]);
    Ks_tr = zeros(n, n, alg.options.r);
    for i=1:alg.options.r
        tmp = trainData(:,repartitions(i,:));
        Ks_tr(:,:,i) = utils_compute_kernel(tmp, tmp, alg.options);
    end
    alg.options.repartitions = repartitions;
    classifier = easymkl_train(Ks_tr, features.y', alg.options.lambda, alg.options.tracenorm);
    classifier.opts = alg.options;
    classifier.trainData = trainData;
    model.classifier = classifier;
    model.alg.learner = 'EASYMKL';    
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
    model = ml_trainEASYMKL(features, alg, cv);
    model.alg.cv_perf = alg.cv_perf;
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg.o,'k'))
    [alg.('options').('kernel').('type')] = alg.o.('k').('t');
    [alg.('options').('kernel').('gamma')] = alg.o.('k').('g');
    [alg.('options').('lambda')] = alg.('o').('l');
    [alg.('options').('r')] = alg.('o').('r');
    [alg.('options').('d')] = alg.('o').('d');
    [alg.('normalization')] = alg.('n');
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');
end
alg = fRMField(alg, {'o','n'});
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(alg, settings)
if(size(alg.options.lambda,2)==2)
    lambdas = alg.options.lambda(1):0.1:alg.options.lambda(2);
    lambdas(lambdas==0) = [];
else if(numel(alg.options.lambda) > 2)
        lambdas = alg.options.lambda;
    else
        % default range
        lambdas = [0.001, 0.01, 0.1, 1, 10, 100];
    end
end
if(strcmp(alg.options.kernel.type,'RBF'))
    if(size(alg.options.kernel.gamma,2)==2)
        gammas = alg.options.kernel.gamma(1):0.1:alg.options.kernel.gamma(2);
    else
        if(isvector(alg.options.kernel.gamma))
            gammas = alg.options.kernel.gamma;
        else
            gammas = 2.^[-5:5];
        end
    end
else
    gammas = 1;
end
searchSpace = length(lambdas)*length(gammas);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.r = alg.options.r;
alg.o.d = alg.options.d;
alg.o.k.t = alg.options.kernel.type;
alg.o.k.g = [];
alg.n = alg.normalization;
m = 1;
n = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.l = lambdas(m);
        if(isfield(alg.o.k,'g'))
            alg.o.k.g = gammas(n);
        end
        tmp{k} = {alg, cv};
        n = n + 1;
        if(n > length(gammas) && m < length(lambdas))
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

