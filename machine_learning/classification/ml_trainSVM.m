function [model] = ml_trainSVM(features, alg, cv)
%ML_TRAINSVM : wrapper function to LIBSVM[1], train SVM model.
%
% Arguments:
%     In:
%         features : TYPE [NxM (dimension)] [N_ M_] lorem opsum
%
%         alg : TYPE [N1xN1 (dimesnion)] [N1_ M1_]  lorem opsum
%
%         cv : ...
%     Returns:
%         model : TYPE [NxM (dimension)] [N_ M_] lorem opsum
%
% [further explanation goes here]
% Example :
%     FUNCTIONALITY_TASK_OBJECT_TYPE(ARG_IN1, ARG_IN2)
%
% Dependencies :
%   LIBSVM mex files: svmtrain.mexw64
% See Also : ml_trainClassifier.m,
% References :
% [1] C.-C. Chang and C.-J. Lin, “LIBSVM,” ACM Trans. Intell. Syst.
%  Technol., 2011.

% date created 06-02-2016
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% Train SVM
% recover struct fields, works for Guesemha
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end
if(isempty(alg.options))
    alg.options.kernel.type = 'LIN';
    alg.normalization = 'ZSCORE';
end
if (cv.nfolds == 0)
    if (isfield(alg,'normalization'))
        norml = utils_estimate_normalize(features.x, alg.normalization);
        trainData = utils_apply_normalize(features.x, norml);
    else
        trainData = features.x;
    end
    trainLabel = features.y;
    
    if(~isfield(alg.options,'C') && ~isfield(alg.options.kernel,'g'))
        c = 1;
        g = 1 / size(trainData, 2);
    else
        c = alg.options.C;
        if(isfield(alg.options.kernel,'g'))
            g = alg.options.kernel.g;
        end
    end
    switch upper(alg.options.kernel.type)
        case 'RBF'
            classifier = svmtrain(trainLabel, trainData, ['-t 2 -g ',num2str(g),' ','-c ',num2str(c),' ','-w1 2 -w-1 1']);
        case 'LIN'
          classifier = svmtrain(trainLabel, trainData, ['-t 0 -c ',num2str(c),' ','-w1 2 -w-1 1']);
        otherwise
            error('Incorrect Kernel for training SVM');
    end
    model.normalization = norml;
    model.classifier = classifier;
    model.alg.learner = 'SVM';
    
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
    model = ml_trainSVM(features, alg, cv);
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg.o,'k'))
    [alg.o.('kernel')] = alg.o.('k');
    [alg.o.('kernel').('type')] = alg.o.('k').('t');
    [alg.('options')] = alg.('o');
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
if(size(alg.options.C,2)==2)
    Cs = alg.options.C(1):0.1:alg.options.C(2);
    Cs(Cs==0) = [];
else if(numel(alg.options.C) > 2)
        Cs = alg.options.C;
    else
        % default range
        Cs = [0.001, 0.01, 0.1, 1, 10, 100];
    end
end
if(strcmp(alg.options.kernel.type,'RBF'))
    if(size(alg.options.kernel.g,2)==2)
        gammas = alg.options.kernel.g(1):0.1:alg.options.kernel.g(2);
    else
        if(isvector(alg.options.kernel.g))
            gammas = alg.options.kernel.g;
        else
            gammas = [0.001, 0.01, 0.1, 1, 10, 100];
        end
    end
else
    gammas = 1;
end
searchSpace = length(Cs)*length(gammas);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.k.t = alg.options.kernel.type;
alg.o.k.g = [];
alg.n = alg.normalization;
m = 1;
n = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.C = Cs(m);
        if(isfield(alg.o.k,'g'))
            alg.o.k.g = gammas(n);
        end
        tmp{k} = {alg, cv};
        n = n + 1;
        if(n > length(gammas) && m < length(Cs))
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