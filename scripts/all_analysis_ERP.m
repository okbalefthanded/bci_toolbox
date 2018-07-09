% 07-09-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% All datasets and methods analysis
% ERP
tic

sets = {'LARESI_FACE_SPELLER_120', 'LARESI_FACE_SPELLER_150', 'P300_ALS', 'III_CH', 'EPFL_IMAGE_SPELLER'};
features.algs = {'DOWNSAMPLE'};
learners = {'LDA','RLDA', 'SWLDA', 'SVM', 'LR', 'RF', 'GBOOST'};

approach.features.options = [];
approach.classifier.options = [];
approach.cv.method = 'KFOLD';
approach.cv.nfolds = 0;

report = 1;

for set = 1:length(sets)
    for feature = 1:length(features.algs)
        approach.features.alg = features.algs{feature};
        for learner = 1:length(learners)                        
            approach.classifier.learner = learners{learner};            
            [results, output, model] = run_analysis_ERP(sets{set}, approach, report);
        end
    end
end

t = toc;
if(t>=60)
    t = t/60;
    disp(['Time elapsed for computing: ' num2str(t) ' minutes']);
else
    disp(['Time elapsed for computing: ' num2str(t) ' seconds']);
end



