%% SSVEP paradigm evaluation
% 03-21-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
tic
set = 'SSVEP_EXOSKELETON';
% set = 'SSVEP_DEMO';
approach.classifier.learner = 'CCA';
approach.classifier.options.harmonics = 2;
[results, output, model] = run_analysis_SSVEP(set, approach);
toc