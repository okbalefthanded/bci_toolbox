function [model] = ml_trainFBCCA(features, alg, cv)
%ML_TRAINFBCCA Summary of this function goes here
%   Detailed explanation goes here
% created 07-01-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end
if(~isfield(alg, 'options'))
    alg.options.harmonics = 5;
    alg.options.nrFbs = 5;
end

model.fs = features.fs;
[samples, ~, ~] = size(features.signal);

if (iscell(features.stimuli_frequencies))
    stimFrqId = cellfun(@isstr, features.stimuli_frequencies);
    stimFrq = features.stimuli_frequencies(~stimFrqId);
    frqs = cell2mat(stimFrq);
else
    frqs = features.stimuli_frequencies;
end

stimuli_count = length(frqs);
reference_signals = cell(1, stimuli_count);

if(cv.nfolds == 0)
    if(~isfield(alg.options, 'fbCoefs'))
        model.fbCoefs = (1:alg.options.nrFbs).^(-alg.options.a)+alg.options.b;
    end
    % construct reference signals
    for stimulus=1:stimuli_count
        reference_signals{stimulus} = refsig(frqs(stimulus),...
            features.fs, ...
            samples, ...
            alg.options.harmonics...
            );
    end
    model.alg.learner = 'FBCCA';
    model.ref = reference_signals;
    model.nrFbs = alg.options.nrFbs;
else
       % parallel settings
    [settings, datacell, fHandle] = parallel_getInputs(cv,...
                                                       features,...
                                                       alg.learner...
                                                       );
    %     generate param cell
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
    model = ml_trainFBCCA(features, alg, cv);
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg,'o'))
    if(isfield(alg.o,'h'))
        [alg.options.('harmonics')] = alg.o.('h');
        fields = {'h'};
    end
    if(isfield(alg.o,'n'))
        [alg.options.('nrFbs')] = alg.o.('n');
        fields = {fields{:}, 'n'};
    end
    if(isfield(alg.o,'a'))
        [alg.options.('a')] = alg.o.('a');
        fields = {fields{:}, 'a'};
    end
     if(isfield(alg.o,'b'))
        [alg.options.('b')] = alg.o.('b');
        fields = {fields{:}, 'a'};
    end
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');
end
alg = fRMField(alg, fields);
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(alg, settings)
if(size(alg.options.a,2)==2)
    a = alg.options.a(1):0.25:alg.options.a(2);
else if(numel(alg.options.a) > 2)
        a = alg.options.a;
    else
        % default range
        a = 0:0.25:1;
    end
end
if(size(alg.options.b,2)==2)
    b = alg.options.b(1):0.25:alg.options.b(2);
else if(numel(alg.options.b) > 2)
        b = alg.options.b;
    else
        % default range
        b = 0:0.25:1;
    end
end
searchSpace = length(a)* length(b);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.h = alg.options.harmonics;
alg.o.n = alg.options.nrFbs;
alg = fRMField(alg, {'options', 'learner'});
m = 1;
n = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.a = a(m);       
        alg.o.b = b(n);      
        tmp{k} = {alg, cv};
        n = n + 1;
        if(n > length(b) && m < length(a))
            n = 1;
            m = m+1;
        end
    end
    paramcell{i} = tmp;
    if((nWorkers - i) == offset)
        off = 1;
    end
end
end
