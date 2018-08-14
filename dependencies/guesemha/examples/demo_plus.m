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
% Cs = [0.001, 0.01, 0.1, 1, 10, 100];
Cs = [0.001, 0.01, 0.1, 1, 10,14,45,4,55,88];
% % Cs = [0.001, 0.01, 0.1, 1, 10, 100, 5, 6, 7];
gammas = [0.001, 0.01, 0.1, 1, 10, 100];
Ts = Cs;
gplus = gammas;

% gammas = 1;
searchSpace = length(Cs)*length(gammas)*length(Ts)*length(gplus);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
% alg.o.k.t = 'LIN';
alg.o.k.t = 'RBF';
alg.n = 'ZSCORE';
alg.o.k.g = [];
m = 1;
n = 1;
l = 1;
p = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.C = Cs(m);
        alg.o.k.g = gammas(n);        
        alg.o.T = Ts(l);      
        alg.o.s.g = gplus(p); 
        tmp{k} = {alg, cv};
        p = p + 1;
        if(p > length(gplus) && l < length(Ts))
            p = 1;
            l = l+1;
        end
        if(p > length(gplus) && l >= length(Ts))
            p = 1;
            l = 1;
            n = n + 1;          
        end
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
