%% SSVEP paradigm evaluation
% 03-21-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic
% set.title = 'SSVEP_EXOSKELETON';
% set = 'SSVEP_DEMO'; 
set.title = 'SSVEP_TSINGHUA';
% set.title = 'SSVEP_SANDIEGO';
set.mode = 'SM';
report = 1;
%% vanilla CCA
approach.classifier.learner = 'CCA';
approach.classifier.options.harmonics = 2;
%% L1 Multiway CCA
% approach.classifier.learner = 'L1MCCA';
% approach.classifier.options.harmonics = 2;
% approach.classifier.options.max_iter = 200; % the maximal number of iteration for running L1MCCA
% approach.classifier.options.n_comp = 1;  % number of projection components for learning the reference signals
% approach.classifier.options.lambda = 0.02; % regularization parameter for the 3rd-way (i.e., trial-way), which can be more precisely decided by cross-validation
%% Mset CCA
% approach.classifier.learner = 'MSETCCA';
% approach.classifier.options.n_comp = 1;
%% MLR
% approach.features.alg = 'MLR';
% approach.features.options = [];
% approach.classifier.normalization = 'ZSCORE';
% approach.classifier.learner = 'SVM';
% approach.classifier.options.kernel = 'LIN';
%% TRCA
% approach.classifier.learner = 'TRCA';
% approach.classifier.options.num_fbs = 5;
% approach.classifier.options.is_ensemble = 1;
%% FBCCA
% approach.classifier.learner = 'FBCCA';
% approach.classifier.options.harmonics = 5;
% approach.classifier.options.nrFbs = 5;
%% ITCCA
% approach.classifier.learner = 'ITCCA';
%%
approach.cv.method = 'KFOLD';
approach.cv.nfolds = 0;
%%
[results, output, model] = run_analysis_SSVEP(set, approach, report);
t = toc;
if(t>=60)
    t = t/60;
    disp(['Time elapsed for computing: ' num2str(t) ' minutes']);
else
    disp(['Time elapsed for computing: ' num2str(t) ' seconds']);
end
%% Report analysis
% data sets, approach,
% subject  method
