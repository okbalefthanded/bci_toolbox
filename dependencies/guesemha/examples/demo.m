%% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz> 06-21-2018
% load training data
tic
nworkers = 3;
settings.isWorker = true;
settings.nWorkers = nworkers;
load iris_dataset
x = irisInputs';
[y, ~] = find(irisTargets);
datacell = {y, x};
fHandle = 'svmtrain';
% generate param cell
Cs = [0.001, 0.01, 0.1, 1, 10, 100];
gammas = [0.001, 0.01, 0.1, 1, 10, 100];
% svmopts = '-s 0 -t 2';
nWorkers = settings.nWorkers + settings.isWorker;
paramcell = cell(1, nWorkers);
searchSpace = length(Cs)*length(gammas);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
m = 1;
n = 1;
off = 0;
for i=1:nWorkers
    for k=1:(paramsplit+off)
        tmp{k} = ['-t 2 -g ',num2str(gammas(n)),' ','-c ',num2str(Cs((m))),' ','-w1 1 -w-1 1'];
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
%% start parallel
[res, resKeys] = startMaster(fHandle, datacell, paramcell, settings);
% Do something with res
% detach Memory
SharedMemory('detach', resKeys, res);
toc;
terminateSlaves; 