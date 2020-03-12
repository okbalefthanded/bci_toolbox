%% SSVEP paradigm evaluation, comparison
% 01-02-2020
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic
% set.title = 'SSVEP_EXOSKELETON';
% set.title = 'SSVEP_DEMO'; 
% set.title = 'SSVEP_TSINGHUA_JFPM';
set.title = 'SSVEP_SANDIEGO';
% set.title = 'SSVEP_LARESI';
set.mode = 'SM';
report = 0;
%% vanilla CCA
% approach.classifier.learner = 'CCA';
% approach.classifier.options.harmonics = 3;
% approach.classifier.options.mode = 'sync';
%% L1 Multiway CCA
% approach.classifier.learner = 'L1MCCA';
% approach.classifier.options.harmonics = 2;
% approach.classifier.options.max_iter = 200; % the maximal number of iteration for running L1MCCA
% approach.classifier.options.n_comp = 1;  % number of projection components for learning the reference signals
% approach.classifier.options.lambda = 0.02; % regularization parameter for the 3rd-way (i.e., trial-way), which can be more precisely decided by cross-validation
% approach.classifier.options.lambda = [0, 0.2];
% approach.classifier.options.mode = 'sync';
%% Mset CCA
% approach.classifier.learner = 'MSETCCA';
% approach.classifier.options.n_comp = 1;
% approach.classifier.options.mode = 'sync';
%% MLR-SVM
% approach.features.alg = 'MLR';
% approach.features.options = [];
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.learner = 'SVM';
% approach.classifier.options.kernel.type = 'LIN';
%% MLR-HKL
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'HKL';
% % approach.classifier.options.lambda = 10.^[1:-.5:-8];
% approach.classifier.options.lambda = 0.02;
% approach.classifier.options.kernel.type = 'hermite';
% approach.classifier.options.kernel.params = [0.5,3,0.1,4];
% approach.classifier.options.memcache = 2e8;
% approach.classifier.options.maxactive = 400;
%% MLR-RBMKL 
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'RBMKL';
% approach.classifier.options.parameters = rbmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g0.5'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.rul = 'mean';
%%
%% MLR-RBMKL 
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'ABMKL';
% approach.classifier.options.parameters = abmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'p2'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.com = 'ratio'; % convex | ratio
%%
%% MKL : CABMKL
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'CABMKL';
% approach.classifier.options.parameters = cabmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.com = 'convex'; % linear | convex 
%%
%% MKL : SIMPLEMKL
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'SIMPLEMKL';
% approach.classifier.options.parameters = smksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
%% MKL : GMKL
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'GMKL';
% approach.classifier.options.parameters = gmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'p2'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.sig = 1; 
%%
%% MKL : GLMKL
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'GLMKL';
% approach.classifier.options.parameters = glmksvm_parameter();
% approach.classifier.options.parameters.C = 1;
% approach.classifier.options.parameters.ker = {'l', 'g0.1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.p = 2; 
%% MKL : NLMKL
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'NLMKL';
% approach.classifier.options.parameters = nlmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g10'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.p = 1; 
% approach.classifier.options.parameters.lam = 1;
%% MKL : LMKL
% approach.features.alg = 'MLR';
% approach.classifier.learner = 'LMKL';
% approach.classifier.options.parameters = lmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g10'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.gat.typ = 'linear_sigmoid'; % gating model function [linear_softmax, linear_sigmoid, rbf_softmax]  
% approach.classifier.options.parameters.loc.typ = 'linear'; % gating model complexity [linear, quadratic]   
% approach.classifier.options.parameters.nor.loc = 'true'; 
% approach.classifier.options.parameters.see = 7332; % seed
%% TRCA
% approach.classifier.learner = 'TRCA';
% approach.classifier.options.num_fbs = 5;
% approach.classifier.options.is_ensemble = 1;
%% FBCCA
% approach.classifier.learner = 'FBCCA';
% approach.classifier.options.harmonics = 5;
% approach.classifier.options.nrFbs = 5;
% approach.classifier.options.a = 1.8;
% approach.classifier.options.b = 0.4;
% approach.classifier.options.mode = 'sync';
% approach.classifier.options.a = [0, 2.5];
% approach.classifier.options.b = [0, 1.5];
%% ITCCA
% approach.classifier.learner = 'ITCCA'; 
%% Gaussian Process
approach.features.alg = 'MLR';
approach.classifier.learner = 'GP';
approach.classifier.options.mean = 'Const';
approach.classifier.options.cov = 'SEiso'; % kernel
approach.classifier.options.hyp.mean = 0;
approach.classifier.options.hyp.cov  = log([0.5 0.5]);
approach.classifier.options.inference = 'Laplace';
approach.classifier.options.likelihood = 'Logistic'; 
approach.classifier.options.nfunc = 10;
%%
approach.cv.method = 'KFOLD';
approach.cv.nfolds = 0;
% approach.cv.nfolds = 5;
approach.cv.parallel.isWorker = 1;
approach.cv.parallel.nWorkers = 3;
%%
% load folds
[results, output, model] = run_analysis_SSVEP_compare(set, approach, folds);
utils_get_time(toc);
%% Report analysis
% data sets, approach,
% subject  method
