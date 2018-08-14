%% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz> 07-23-2018
% using struct instead of cell for Data
% workers settings
tic;
nworkers = 3;
settings.isWorker = 1;
settings.nWorkers = nworkers;
% load training data
load iris_dataset
x = irisInputs';
[y, ~] = find(irisTargets);
datacell.data.x = x;
datacell.data.y = y;
% cv split, kfold
nfolds = 5;
setsize = length(y);
N = floor(setsize / nfolds) + 1;
folds = bsxfun(@times, repmat(ones(1,N), 1, nfolds), ... ,
    repmat([1:nfolds], 1, N));
folds = sort(folds(1:setsize));
datacell.fold = folds;
% Train & Predict functions
% SharedMatrix bug, fieldnames should have same length
fHandle.tr = 'ml_trainSVM';
fHandle.pr = 'ml_applySVM';
% generate param cell
Cs = [0.001, 0.01, 0.1, 1, 10, 100];
% Cs = [0.001, 0.01, 0.1, 1, 10,14,45,4,55,88];
% % Cs = [0.001, 0.01, 0.1, 1, 10, 100, 5, 6, 7];
% gammas = [0.001, 0.01, 0.1, 1, 10, 100];


gammas = 1;
searchSpace = length(Cs)*length(gammas);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
% alg.o.k.t = 'LIN';
alg.o.k.t = 'RBF';
alg.n = 'ZSCORE';
alg.o.k.g = [];
m = 1;
n = 1;
off = 0;
for i=1:nWorkers
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
    if((nWorkers-i) == offset)
        off = 1;
    end
end
%% start parallel CV
[res, resKeys] = startMaster(fHandle, datacell, paramcell, settings);
% Do something with res
[best_worker, best_evaluation] = getBestParamIdx(res, paramcell);
best_param = paramcell{best_worker}{best_evaluation}{1};
% best_c = paramcell{p}{r}{1}.o.C;
% if(isfield(alg.o.k,'g'))
%     best_g = paramcell{p}{r}{1}.o.k.g;
% end
% detach Memory
SharedMemory('detach', resKeys, res);
toc;
% % kill slaves processes
terminateSlaves;
