function [model] = ml_trainSVMPLUS(features, alg, cv)
%ML_TRAINSVMPLUS Summary of this function goes here
%   Detailed explanation goes here

% created 03-16-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(isfield(alg,'o') || isfield(alg, 'n') || isfield(cv, 'n'))
    [alg, cv] = recoverStructs(alg, cv);
end
if(isfield(features,'p'))
    features.privileged = features.p;
    features = fRMField(features, {'p'});
end
if(isempty(alg.options))
    alg.options.kernel.type = 'LIN';
    alg.options.kernel_plus.type = 'LIN';
    alg.normalization = 'ZSCORE';
end
if (cv.nfolds == 0)
    if (isfield(alg,'normalization'))
        norml = utils_estimate_normalize(features.x, alg.normalization);
        norml_plus = utils_estimate_normalize(features.privileged, alg.normalization);
        trainData = utils_apply_normalize(features.x, norml);
        trainData_plus = utils_apply_normalize(features.privileged, norml_plus);
    else
        trainData = features.x;
        trainData_plus = features.privileged;
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
     if(~isfield(alg.options,'T') && ~isfield(alg.options.kernel_plus,'g'))
        cplus = 1;
        gpls = 1 / size(trainData_plus, 2);
    else
        cplus = alg.options.T;
        if(isfield(alg.options.kernel_plus,'g'))
            gpls = alg.options.kernel_plus.g;
        end
     end    
    aSMO_opt = ['-s 5 -a 1',' '];
    switch upper(alg.options.kernel.type)
        case 'RBF'
            aSMO_opt = [aSMO_opt,'-t 2',' ','-g',' ',sprintf('%d',g),' '];
        case 'LIN'
            aSMO_opt = [aSMO_opt,'-t 0',' '];
        otherwise
            error('Incorrect Kernel for training SVM');
    end
    switch upper(alg.options.kernel_plus.type)
        case 'RBF'
            aSMO_opt = [aSMO_opt,'-T 2',' ','-G',' ',sprintf('%d',gpls),' '];
        case 'LIN'
            aSMO_opt = [aSMO_opt,'-T 0',' '];
        otherwise
            error('Incorrect Kernel for training SVM');
    end
    
    aSMO_opt = [aSMO_opt, '-c',' ',sprintf('%d',c),' ','-C',' ',sprintf('%d',cplus),' ','-w1 5 -w-1 1'];
    
    classifier = svm_train_plus(trainLabel, trainData, trainData_plus, aSMO_opt);
    model.normalization = norml;
    model.normalization_plus = norml_plus;
    model.classifier = classifier;
    model.alg.learner = 'SVMPLUS';
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
    model = ml_trainSVMPLUS(features, alg, cv);
end
end
%%
function [alg, cv] = recoverStructs(alg, cv)
if(isfield(alg.o,'k'))
    [alg.o.('kernel')] = alg.o.('k');
    [alg.o.('kernel').('type')] = alg.o.('k').('t');
    [alg.o.('kernel_plus')] = alg.o.('s');
    [alg.o.('kernel_plus').('type')] = alg.o.('s').('t');
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
if(size(alg.options.T,2)==2)
    Ts = alg.options.T(1):0.1:alg.options.T(2);
    Ts(Ts==0) = [];
else if(numel(alg.options.T) > 2)
        Ts = alg.options.T;
    else
        % default range
        Ts = [0.001, 0.01, 0.1, 1, 10, 100];
    end
end
if(strcmp(alg.options.kernel_plus.type,'RBF'))
    if(size(alg.options.kernel_plus.g,2)==2)
        gpls = alg.options.kernel_plus.g(1):0.1:alg.options.kernel_plus.g(2);
    else
        if(isvector(alg.options.kernel_plus.g))
            gpls = alg.options.kernel_plus.g;
        else
            gpls = [0.001, 0.01, 0.1, 1, 10, 100];
        end
    end
else
    gpls = 1;
end
searchSpace = length(Cs)*length(gammas)*length(Ts)*length(gpls);
[nWorkers, paramsplit, offset] = getRessources(settings, searchSpace);
paramcell = cell(1, nWorkers);
cv.n = 0;
alg.o.k.t = alg.options.kernel.type;
alg.o.k.g = [];
alg.o.s.t = alg.options.kernel_plus.type;
alg.o.s.g = [];
alg.n = alg.normalization;
m = 1;
n = 1;
l = 1;
p = 1;
off = 0;
for i=1:nWorkers
    tmp = cell(1, paramsplit+off);
    for k=1:(paramsplit+off)
        alg.o.C = Cs(m);
        if(isfield(alg.o.k,'g'))
            alg.o.k.g = gammas(n);
        end
        alg.o.T = Ts(l);
        if(isfield(alg.o.s,'g'))
            alg.o.s.g = gpls(p);
        end
        tmp{k} = {alg, cv};
        p = p + 1;
        if(p > length(gpls) && l < length(Ts))
            p = 1;
            l = l+1;
        end
        if(p > length(gpls) && l >= length(Ts))
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
end
%%
% Usage: svm-train [options] training_set_file [model_file]
% options:
% -s svm_type : set type of SVM (default 0)
%         0 -- C-SVC
%         1 -- nu-SVC
%         2 -- one-class SVM
%         3 -- epsilon-SVR
%         4 -- nu-SVR
%         5 -- SVM+
% -a n : optimization method
%     -1  -- Max Unconstrained Gain SMO (default)
%      0  -- Max Constrained Gain SMO (Glassmachers&Igel, JMLR2006)
%     k>0 -- Conjugate SMO of order k
% -t kernel_type : set type of kernel function (default 2)
%         0 -- linear: u'*v
%         1 -- polynomial: (gamma*u'*v + coef0)^degree
%         2 -- radial basis function: exp(-gamma*|u-v|^2)
%         3 -- sigmoid: tanh(gamma*u'*v + coef0)
%         4 -- precomputed kernel (kernel values in training_set_file)
% -T kernel_type_star : set type of kernel function for the correcting space (default 2), for SVM+
%         0 -- linear: u'*v
%         1 -- polynomial: (gamma*u'*v + coef0)^degree
%         2 -- radial basis function: exp(-gamma*|u-v|^2)
%         3 -- sigmoid: tanh(gamma*u'*v + coef0)
%         4 -- precomputed kernel (kernel values in training_set_file)
% -f star_file : name of the file containing star examples. Necessary parameter for SVM+
% -d degree : set degree in kernel function (default 3)
% -D degree_star : set degree_star in kernel function in the correcting space (default 3)
% -g gamma : set gamma in kernel function (default 1/number of features)
% -G gamma_star : set gamma_star in kernel function in the correcting space (default 1/number of features in the  correcting space)
% -r coef0 : set coef0 in kernel function (default 0)
% -R coef0_star : set coef0_star in kernel function (default 0)
% -c cost : set the parameter C of C-SVC, epsilon-SVR, nu-SVR and SVM+ (default 1)
% -C tau : set the parameter tau in SVM+ (default 1)
% -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
% -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
% -m cachesize : set cache memory size in MB (default 100)
% -e epsilon : set tolerance of termination criterion (default 0.001)
% -h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
% -b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
% -wi weight : set the parameter C of class i to weight*C, for C-SVC and SVM+ (default 1)
% -v n: n-fold cross validation mode
% -q : quiet mode (no outputs)
