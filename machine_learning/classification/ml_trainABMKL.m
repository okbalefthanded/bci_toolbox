function [model] = ml_trainABMKL(features, alg, cv)
%ML_TRAINABMKL Summary of this function goes here
%   Detailed explanation goes here
% created 09-08-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end

if(isempty(alg.options))
    alg.options.parameters = abmksvm_parameter();
end
nKernel = length(alg.options.parameters.ker);
train_data = cell(1, nKernel);
nClasses = numel(unique(features.y));
[classMode, nModels, classPart] = ml_get_classMode(nClasses);
if (~strcmp(classMode,'Bin'))
    models = cell(1, nModels);
end
if(cv.nfolds == 0)
    if(strcmp(classMode,'Bin'))
        negatives = sum(features.y==-1);
        if(negatives==0)
            features.y(features.y~=1) = -1;
        end
        
        % TODO : mutiple data representations
        for k=1:nKernel
            train_data{k}.X = features.x;
            train_data{k}.y = features.y;
            train_data{k}.ind = 1:length(features.y);
        end
        models = abmksvm_train(train_data, alg.options.parameters);
    else        
        for m =1:nModels
            ft = features;            
            if(strcmp(classMode,'OvO'))
                idTrain = ft.y==classPart(m,1) | ft.y==classPart(m,2);
                ft.x = ft.x(idTrain, :);
                ft.y = ft.y(idTrain);
                ft.y(ft.y==classPart(m,2)) = -1;
                ft.y(ft.y==classPart(m,1)) = 1;
            else
                ft.y(ft.y~=m) = -1;
                ft.y(ft.y==m) = 1;
            end
            for k=1:nKernel
                train_data{k}.X = ft.x;
                train_data{k}.y = ft.y;
                train_data{k}.ind = 1:length(ft.y);
            end
            models{m} = abmksvm_train(train_data, alg.options.parameters);
            clear ft
        end
    end        
    model.model = models;
    model.alg.learner = 'ABMKL';
    model.nKernel = nKernel;
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
    model = ml_trainABMKL(features, alg, cv);
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg,'o'))
    [alg.('options').('parameters').('nor').('dat')] = alg.o.p.n.d;
    [alg.('options').('parameters').('nor').('ker')] = alg.o.p.n.k;
    [alg.('options').('parameters').('C')] = alg.o.p.('C');
    [alg.('options').('parameters').('eps')] = alg.o.p.('e');
    [alg.('options').('parameters').('ker')] = alg.o.p.('k');
    [alg.('options').('parameters').('opt')] = alg.o.p.('o');
    [alg.('options').('parameters').('tau')] = alg.o.p.('t'); 
    [alg.('options').('parameters').('com')] = alg.o.p.('c'); 
    fields = {'o'};
end
if(isfield(cv, 'n'))
    [cv.('nfolds')] = cv.('n');    
end
alg = fRMField(alg, fields);
cv = fRMField(cv, 'n');
end
%%
function paramcell = genParams(alg, settings)

if(size(alg.options.parameters.C,2)==2)
    Cs = alg.options.parameters.C(1):0.1:alg.options.parameters.C(2);
    Cs(Cs==0) = [];
else if(numel(alg.options.parameters.C) > 2)
        Cs = alg.options.parameters.C;
    else
        % default range
        Cs = [0.001, 0.01, 0.1, 1, 10, 100];
    end
end
%TODO : gaussian kernel, 
searchSpace = length(Cs);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.p.e = alg.options.parameters.eps;
alg.o.p.k = alg.options.parameters.ker;
alg.o.p.n.d = alg.options.parameters.nor.dat;
alg.o.p.n.k = alg.options.parameters.nor.ker;
alg.o.p.o = alg.options.parameters.opt;
alg.o.p.c = alg.options.parameters.com;
alg.o.p.t = alg.options.parameters.tau;
m = 1;
n = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.p.C = Cs(n);
        %         if(isfield(alg.o.k,'g'))
        %             alg.o.k.g = gammas(n);
        %         end
        tmp{k} = {alg, cv};
        n = n + 1;
        %         if(n > length(gammas) && m < length(Cs))
        if(n > length(Cs))
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



