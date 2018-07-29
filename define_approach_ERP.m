%% ERP paradigm evaluation
% 11-02-2017
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% sets = {'LARESI_FACE_SPELLER', 'P300_ALS', 'III_CH', 'EPFL_IMAGE_SPELLER'};
tic
set.title = 'P300-ALS';      
% set.title = 'LARESI_FACE_SPELLER_150';
% set.title = 'LARESI_FACE_SPELLER_120';
% set.title = 'III_CH';
% set.title = 'EPFL_IMAGE_SPELLER';
% set.mode = 'BM';
set.mode = 'SM';
report = 1;
%% Downsample
approach.features.alg = 'DOWNSAMPLE';
approach.features.options.decimation_factor = 12;
%% Regularized LDA approach
% 
% approach.classifier.learner = 'RLDA';
% approach.classifier.options.regularizer = 'OAS';
% approach.classifier.learner = 'LDA';
%  
% approach.classifier.learner = 'SWLDA';
% approach.classifier.options.penter = 0.1;
% approach.classifier.options.premove = 0.15;

% approach.classifier.learner = 'BLDA';

%% SVM approach
approach.classifier.normalization = 'ZSCORE';
approach.classifier.learner = 'SVM';
approach.classifier.options.kernel.type = 'LIN';
% approach.classifier.options.kernel.type = 'RBF';
approach.classifier.options.C = 2;
% approach.classifier.options.C = [-2,2];
%% Logistic Regression approach
% approach.classifier.learner = 'LR';
% approach.classifier.options.regularizer = 'L1';
% approach.classifier.options.regularizer = 'L2';
%% Random forests approach
% approach.classifier.learner = 'RF';
% approach.classifier.options.ntress ='';
% approach.classifier.options.mtry = '';
%% LogitBoost OLS approach
% approach.classifier.learner = 'GBOOST';
% approach.classifier.options.n_steps = 300;
% approach.classifier.options.stepsize = 0.05;
% approach.classifier.options.display = 1;
%% SVM+ approach
% approach.privileged.features.alg = 'DOWNSAMPLE';
% approach.privileged.features.options.decimation_factor = 4;
% approach.classifier.learner = 'SVM+';
% approach.classifier.lupi_learner = 'gSMO';
% % approach.classifier.lupi_learner = 'L2_SVM+';
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.options.svm_kernel = 'RBF';
% approach.classifier.options.svm_kernel = 'LIN';
% approach.classifier.options.svm_plus_kernel = 'LIN';

%% Cross-validation
approach.cv.method = 'KFOLD';
% approach.cv.nfolds = 0;
approach.cv.nfolds = 5;
approach.cv.parallel.isWorker = 1;
approach.cv.parallel.nWorkers = 3;
%% Check approach validity
% approach = check_approach_validity(set, approach);
%%
[results, output, model] = run_analysis_ERP(set, approach, report);
% toc
%% Reimann Geometry Based Analysis
% approach.features.alg = 'REIMANN';
% approach.features.options.decimation_factor = 4;
% % approach.features.mean = 'riemann';
% 
% approach.classifier.learner = 'MDM';
% approach.classifier.dist = 'riemann';
% % approach.classifier.dist = 'kullback';
% approach.classifier.mean = 'riemann';
%  
% [results, output, model] = run_analysis_ERP_Riemann(set, approach);
toc