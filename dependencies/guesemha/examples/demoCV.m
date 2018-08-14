%% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz> 07-18-2018
% workers settings
tic;
nworkers = 3;
settings.isWorker = true;
settings.nWorkers = nworkers;
% settings.debugMode = 1;
% load training data
load iris_dataset
x = irisInputs';
[y, ~] = find(irisTargets);
datacell.data = {y, x};
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
fHandle.tr = 'svmtrain';
fHandle.pr = 'svmpredict';
% generate param cell
Cs = [0.001, 0.01, 0.1, 1, 10, 100];
% gammas = [0.001, 0.01, 0.1, 1, 10, 100];
gammas = 0:0.01:2;
nWorkers = settings.nWorkers + settings.isWorker;
paramcell = cell(1, nWorkers);
searchSpace = length(Cs)*length(gammas);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
m = 1;
n = 1;
off = 0;
for i=1:nWorkers
    for k=1:(paramsplit+off)
%         tmp{k} = ['-t 2 -g ',num2str(gammas(n)),' ','-c ',num2str(Cs((m))),' ','-w1 1 -w-1 1'];
        tmp{k} = ['-t 2 -g ',sprintf('%d',gammas(n)),' ','-c ',sprintf('%d',Cs((m))),' ','-w1 1 -w-1 1'];
        n = n + 1;
        if(n > length(gammas) && m < length(Cs))
            n = 1;
            m = m+1;
        end
    end
    paramcell{i} = tmp;
    if(i == offset)
        off = 1;
    end
end
%% start parallel CV
[res, resKeys] = startMaster(fHandle, datacell, paramcell, settings);
% Do something with res
[best_worker, best_evaluation] = getBestParamIdx(res, paramcell);
best_param = paramcell{best_worker}{best_evaluation};
% detach Memory
SharedMemory('detach', resKeys, res);
toc;
% % kill slaves processes
terminateSlaves;
%   