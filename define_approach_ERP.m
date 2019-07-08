%% ERP paradigm evaluation
% 11-02-2017
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% sets = {'LARESI_FACE_SPELLER', 'P300_ALS', 'III_CH', 'EPFL_IMAGE_SPELLER'};
tic
set.title = 'LARESI_FACE_SPELLER';
% set.title = 'P300-ALS';
% set.title = 'LARESI_FACE_SPELLER_150';
% set.title = 'LARESI_FACE_SPELLER_120';
% set.title = 'III_CH';
% set.title = 'EPFL_IMAGE_SPELLER';
% set.mode = 'BM';
set.mode = 'SM';
report = 0;

%% Downsample
% approach.features.alg = 'DOWNSAMPLE';
% approach.features.options.decimation_factor = 12;
% approach.features.options.moving_average = 12;

%% STDA
% approach.features.alg = 'STDA';
% approach.features.options.itrmax = 200;

%% EPFL
approach.features.alg = 'EPFL';
approach.features.options.decimation_factor = 12;
approach.features.options.p = 0.1;

%% Regularized LDA approach
%
% approach.classifier.learner = 'RLDA';
% approach.classifier.options.regularizer = 'OAS';
% approach.classifier.learner = 'LDA';
%
% approach.classifier.learner = 'SWLDA';
% approach.classifier.options.penter = 0.1;
% approach.classifier.options.premove = 0.15;
%% BLDA
approach.classifier.learner = 'BLDA';
approach.classifier.options.verbose = 1;
%% SVM approach
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.learner = 'SVM';
% approach.classifier.options.kernel.type = 'LIN';
% approach.classifier.options.kernel.type = 'RBF';
% approach.classifier.options.C = 2;
% approach.classifier.options.C = 2.^[0:5];
% approach.classifier.options.kernel.g = 2.^[-5:5];
%% One class SVM approach
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.learner = 'ONESVM';
% approach.classifier.options.kernel.type = 'LIN';
% approach.classifier.options.kernel.type = 'RBF';
% approach.classifier.options.C = 2;
% approach.classifier.options.C = 2.^[0:5];
% approach.classifier.options.kernel.g = 2.^[-5:5];
%% Primal SVM approach
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.learner = 'PSVM';
% approach.classifier.options.kernel.type = 'LIN';
%% Logistic Regression approach
% approach.classifier.learner = 'LR';
% approach.classifier.options.regularizer = 'L1';
% approach.classifier.options.regularizer = 'L2';
% approach.classifier.options.C = [0.1, 1];
%% Random forests approach
% approach.classifier.learner = 'RF';
% approach.classifier.options = [];
% approach.classifier.options.ntrees = [100, 200];
% approach.classifier.options.mtry = [20, 40];
% approach.classifier.options.replace = 1;
%% LogitBoost OLS approach
% approach.classifier.learner = 'GBOOST';
% approach.classifier.options.n_steps = 100;
% approach.classifier.options.stepsize = 0.05;
% approach.classifier.options.display = 1;
%% SVM+ approach
% approach.privileged.features.alg = 'DOWNSAMPLE';
% approach.privileged.features.options.decimation_factor = 12;
% approach.classifier.learner = 'SVMPlus';
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.options.kernel.type = 'LIN'; % LIN | RBF
% approach.classifier.options.kernel_plus.type = 'LIN';% LIN | RBF
% approach.classifier.options.C = [0,2];
% approach.classifier.options.T = [0,2];
% approach.classifier.options.kernel.g = [0,2];
% approach.classifier.options.kernel_plus.g = [0,2];
%% Hierarchical Multiple Kernel Learning
% approach.classifier.learner = 'HKL';
% approach.classifier.options.lambda = 10.^[1:-.5:-8];
% % approach.classifier.options.lambda = 0.02;
% approach.classifier.options.kernel.type = 'hermite';
% approach.classifier.options.kernel.params = [0.5,3,0.1,4];
% approach.classifier.options.memcache = 2e8;
% approach.classifier.options.maxactive = 400;
%% MKL : RBMKL
% approach.classifier.learner = 'RBMKL';
% approach.classifier.options.parameters = rbmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g0.5'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.rul = 'mean'; % mean | product
%% MKL : ABMKL
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
% approach.classifier.learner = 'CABMKL';
% approach.classifier.options.parameters = cabmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.com = 'convex'; % linear | convex
%% MKL : SIMPLEMKL
% approach.classifier.learner = 'SIMPLEMKL';
% approach.classifier.options.parameters = smksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
%% MKL : GMKL
% approach.classifier.learner = 'GMKL';
% approach.classifier.options.parameters = gmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'p2'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.sig = 1;
%% MKL : GLMKL
% approach.classifier.learner = 'GLMKL';
% approach.classifier.options.parameters = glmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g0.1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.p = 1;
%% MKL : NLMKL
% approach.classifier.learner = 'NLMKL';
% approach.classifier.options.parameters = nlmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.p = 1;
% approach.classifier.options.parameters.lam = 1;
%% MKL : LMKL
% approach.classifier.learner = 'LMKL';
% approach.classifier.options.parameters = lmksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'libsvm';
% approach.classifier.options.parameters.gat.typ = 'linear_softmax'; % gating model function [linear_softmax, linear_sigmoid, rbf_softmax]
% approach.classifier.options.parameters.loc.typ = 'linear'; % gating model complexity [linear, quadratic]
% approach.classifier.options.parameters.nor.loc = 'true';
% approach.classifier.options.parameters.see = 7332; % seed
%% MKL : MKL
% approach.classifier.learner = 'MKL';
% approach.classifier.options.parameters = mksvm_parameter();
% approach.classifier.options.parameters.C = 10;
% approach.classifier.options.parameters.ker = {'l', 'g1'};
% approach.classifier.options.parameters.nor.dat = {'true', 'true'};
% approach.classifier.options.parameters.nor.ker = {'true', 'true'};
% approach.classifier.options.parameters.opt = 'mosek';
% approach.classifier.options.parameters.eps = 1e-3;
% approach.classifier.options.parameters.p = 1; % regularization norm : 1:L1, 2:L2
%% EasyMKL
% approach.classifier.learner = 'easymkl';
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.options.lambda = 0.5;
% approach.classifier.options.kernel.gamma = 0.1;
% approach.classifier.options.lambda = [0:0.1:1];
% approach.classifier.options.kernel.gamma = 2.^[-5:5];
% approach.classifier.options.kernel.type = 'RBF';
% approach.classifier.options.d = 500; %  number of fatures in a kernel
% approach.classifier.options.r = 500; % number of weak kernels
% approach.classifier.options.tracenorm = 1;
%% Gaussian Process
% approach.classifier.learner = 'GP';
% approach.classifier.options.mean = 'Const';
% approach.classifier.options.cov = 'SEiso'; % kernel
% approach.classifier.options.hyp.mean = 0;
% approach.classifier.options.hyp.cov  = log([1 1]);
% approach.classifier.options.inference = 'Laplace';
% approach.classifier.options.likelihood = 'Logistic';
% approach.classifier.options.nfunc = 100;
%% Cross-validation
approach.cv.method = 'KFOLD';
approach.cv.nfolds = 0;
% approach.cv.nfolds = 5;
approach.cv.parallel.isWorker = 1;
approach.cv.parallel.nWorkers = 3;
%% Check approach validity
% approach = check_approach_validity(set, approach);
%%
[results, output, model] = run_analysis_ERP(set, approach, report);
nSubj = length(model);
for subj = 1:nSubj
    %         plot_roc_curve(output{subj}{1})
    %         plot_roc_curve(output{subj}{2})
    plot_classifier_scores(output{subj}{2})
end
%%
utils_get_time(toc);