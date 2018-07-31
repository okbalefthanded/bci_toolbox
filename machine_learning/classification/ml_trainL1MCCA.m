function [model] = ml_trainL1MCCA(features, alg, cv)
%ML_TRAINL1MCCA Summary of this function goes here
%   Detailed explanation goes here
% created 03-21-2016
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end

if(~isfield(alg, 'options'))
    alg.options.harmonics = 2;
    alg.options.max_iter = 200; % the maximal number of iteration for running L1MCCA
    alg.options.n_comp = 1;  % number of projection components for learning the reference signals
    alg.options.lambda = 0.02; % regularization parameter for the 3rd-way (i.e., trial-way), which can be more precisely decided b
end

[samples,~,~] = size(features.signal);

if (iscell(features.stimuli_frequencies))
    stimFrqId = cellfun(@isstr, features.stimuli_frequencies);
    stimFrq = features.stimuli_frequencies(~stimFrqId);
    frqs = cell2mat(stimFrq);
else
    frqs = features.stimuli_frequencies;
end

% stimuli_count = length(frqs);
% reference_signals = cell(1, stimuli_count);
% % stimuli_count = length(features.stimuli_frequencies);
% % reference_signals = cell(1, stimuli_count);
% % epochs_per_stimuli = round(epochs / stimuli_count);
% epochs_per_stimuli = round(length(features.y) / length(unique(features.y)));
% iniw3 = ones(epochs_per_stimuli, 1);
% w1 = cell(stimuli_count);
% w3 = cell(stimuli_count);
% op_refer = cell(stimuli_count, 1);
% % stimuli_count = max(features.events);
% eeg = permute(features.signal, [2 1 3]);

if (cv.nfolds == 0)
    stimuli_count = length(frqs);
    reference_signals = cell(1, stimuli_count);
%     epochs_per_stimuli = round(length(features.y) / length(unique(features.y)));
%     iniw3 = ones(epochs_per_stimuli, 1);
    w1 = cell(stimuli_count);
    w3 = cell(stimuli_count);
    op_refer = cell(stimuli_count, 1);
    eeg = permute(features.signal, [2 1 3]);
%     iniw3 = ones(size(eeg,1), 1);
    %     learn projections
    for stimulus=1:stimuli_count
        iniw3 = ones(size(eeg(:,:,features.y==stimulus),3), 1);
        reference_signals{stimulus} = refsig(frqs(stimulus),...
                                             features.fs,...
                                             samples, ...
                                             alg.options.harmonics);
        [w1{stimulus}, w3{stimulus}] = smcca(reference_signals{stimulus}, ...
                                      eeg(:,:,features.y==stimulus),...
            alg.options.max_iter,...
            iniw3,...
            alg.options.n_comp, ...
            alg.options.lambda);
        op_refer{stimulus} = ttm(tensor(eeg(:,:,features.y==stimulus)), w3{stimulus}', 3);
        op_refer{stimulus} = tenmat(op_refer{stimulus}, 1);
        op_refer{stimulus} = op_refer{stimulus}.data;
        op_refer{stimulus} = w1{stimulus}'*op_refer{stimulus};
    end
    model.alg.learner = 'L1MCCA';
    model.ref = op_refer;
else
    % parallel settings
    settings.isWorker = cv.parallel.isWorker;
    settings.nWorkers = cv.parallel.nWorkers;
    datacell.data = features;
    %     cv split, kfold
    cv.method = 'stratifiedkfold';
    cv.y = features.y;
    datacell.fold = ml_crossValidation(cv, length(features.y));
    %     Train & Predict functions
    %     SharedMatrix bug, fieldnames should have same length
    fHandle.tr = 'ml_trainL1MCCA';
    fHandle.pr = 'ml_applyCCA';
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
    model = ml_trainL1MCCA(features, alg, cv);
end

end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg,'o'))
    if(isfield(alg.o,'h'))
        [alg.options.('harmonics')] = alg.o.('h');
        fields = {'h'};
    end
    if(isfield(alg.o,'m'))
        [alg.options.('max_iter')] = alg.o.('m');
        fields = {fields{:},'m'};
    end
    if(isfield(alg.o,'n'))
        [alg.options.('n_comp')] = alg.o.('n');
        fields = {fields{:}, 'n'};
    end
    if(isfield(alg.o,'l'))
        [alg.options.('lambda')] = alg.o.('l');
        fields = {fields{:}, 'l'};
    end
    %     [alg.('options')] = alg.('o');
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');
end
alg = fRMField(alg, fields);
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(alg, settings)
if(size(alg.options.lambda,2)==2)
    lambdas = alg.options.lambda(1):0.01:alg.options.lambda(2);
else if(numel(alg.options.lambda) > 2)
        lambdas = alg.options.lambda;
    else
        % default range
        lambdas = 0:0.1:1;
    end
end
searchSpace = length(lambdas);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.h = alg.options.harmonics;
alg.o.m = alg.options.max_iter;
alg.o.n = alg.options.n_comp;
m = 1;
off = 0;
alg = fRMField(alg, {'options', 'learner'});
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.l = lambdas(m);
        tmp{k} = {alg, cv};
        if (m < length(lambdas))
            m = m+1;
        end
    end
    paramcell{i} = tmp;
    if((nWorkers -i) == offset)
        off = 1;
    end
end
end