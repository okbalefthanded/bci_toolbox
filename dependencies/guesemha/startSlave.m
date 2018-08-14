function [] = startSlave(debugMode)
%STARTSLAVE Summary of this function goes here
%   Detailed explanation goes here
% created 06-20-2018
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
clc;
if(debugMode)
    fprintf('Recovering shared memory.\n');
end
wPids = getWorkersPids();
nWorkers = length(wPids);
[~, workerRank] = find(sort(cellfun(@str2num, wPids))==feature('getPid'));
pid = sprintf('%d', workerRank);
clear wPids
% Set IPC
masterPorts = 9091:9091+nWorkers;
slavePorts = 9191:9191+nWorkers;
if(debugMode)
    fprintf('Worker %d Opening communication channel on port: %d\n', ...
            feature('getPid'), ...
            slavePorts(workerRank)...
            );
end
slaveSocket = udp('Localhost', masterPorts(workerRank), ...
                  'LocalPort', slavePorts(workerRank)...
                  );
fopen(slaveSocket);
clear masterPorts slavePorts

% Recover Shared Memory
fHandle = SharedMemory('attach', 'shared_fhandle');
datacell = SharedMemory('attach', 'shared_data');
if(debugMode)
fprintf('Data recovery succeded\n');
end
param = SharedMemory('attach', ['shared_' pid]);
workerResult = cell(1, length(param));

% Evaluate Functions
if(debugMode)
    fprintf('Worker %s Evaluating job\n', pid);
%     fprintf('Evaluatating function: %s\n', fHandle);
end
if(isstruct(fHandle) && isstruct(datacell))
    % Train & Predict mode
    mode = 'double';
else
    % Train only mode
    mode = 'single';
end

for p=1:length(param)
    if(strcmp(mode, 'single'))        
        workerResult{p} = feval(fHandle, datacell{:}, param{p});
    else
        if(strcmp(mode, 'double'))
            % split data and evaluate folds
            nfolds = max(datacell.fold);
            acc_folds = zeros(1, nfolds);
            for f=1:nfolds
                idx = datacell.fold==f;
                train = ~idx;
                test = idx;
                af = eval_fold(fHandle, ...
                               datacell.data, ...
                               param{p}, ...
                               train,...
                               test...
                               );
                acc_folds(f) = af;
            end
            workerResult{p} = mean(acc_folds);
        end
    end
end
% Detach SharedMemroy
if(debugMode)
    fprintf('Worker %s Detaching sharedMemory\n', pid);
end
SharedMemory('detach', 'shared_fhandle', fHandle);
SharedMemory('detach', 'shared_data', datacell);
SharedMemory('detach', ['shared_' pid], param);
clear fhandle datacell param
%
% Write results in SharedMemory
resKey = ['res_' pid];
if(debugMode)
    fprintf('Worker %s Writing results in sharedMemory\n', pid);
    fprintf('Worker %s shared result key %s\n', pid, resKey);
end
SharedMemory('clone', resKey, workerResult);
if(debugMode)
    fprintf('Opening slave socket\n');
    fprintf('writing data to socket \n');
end
fprintf(slaveSocket, '%d', feature('getPid'));
if(debugMode)
    fprintf('Data sent : %d to %d\n',... 
            slaveSocket.ValuesSent, ...
            slaveSocket.propinfo.RemotePort.DefaultValue...
            );
end
fclose(slaveSocket);
delete(slaveSocket);
end

function af = eval_fold(fhandle, data, param, trainIdx, predictIdx)
dTrain = getSplit(data, trainIdx);
dPredict = getSplit(data, predictIdx);
if(isstruct(data))  
    slaveModel  = feval(fhandle.tr, dTrain, param{:});
    predFold = feval(fhandle.pr, dPredict, slaveModel);
else    
    slaveModel  = feval(fhandle.tr, dTrain{:}, param);
    predFold = feval(fhandle.pr, dPredict{:}, slaveModel);
end
af = getAccuracy(predFold, dPredict);
end

function d = getSplit(d, id)
if(isstruct(d))
    fields = fieldnames(d);
    if(numel(fields)==2)
        d.x = d.x(id, :);
        d.y = d.y(id, :);
    else
        for fd = 1:length(fields)
            if(ndims(d.(fields{fd}))==3)
                d.(fields{fd}) = d.(fields{fd})(:,:, id);
            else if(ismatrix(d.(fields{fd})) && length(d.(fields{fd})) > sum(id) )
                    d.(fields{fd}) = d.(fields{fd})(id,:);
                end
            end
        end
    end
else
    d{1} = d{1}(id, :);
    d{2} = d{2}(id, :);
end
end

function acc = getAccuracy(predFold, data)
if(iscell(data))
    if(size(data{1}, 2) > size(data{2}, 2))
        % Label data in second cell
        i = 2;
    else
        i = 1;
    end
    acc = (sum(data{i}==predFold) / length(data{i})) * 100;
else
    acc = (sum(data.y==predFold.y) / length(data.y)) * 100;
end
end