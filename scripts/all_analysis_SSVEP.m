% 07-09-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% All datasets and methods analysis
% SSVEP
tic
epoch_length = [[0 500]; [0 2000]; [0 4000]];
filter_band = [5 50];
sets = {'SSVEP_EXOSKELETON', 'SSVEP_SANDIEGO', 'SSVEP_TSINGHUA'};
approaches = {'CCA', 'L1MCCA', 'MSETCCA','FBCCA', 'ITCCA','TRCA', 'MLR'};
report = 1;
for set = 1:length(sets)
    for len = 1:length(epoch_length)
        switch(sets{set})
            case 'SSVEP_EXOSKELETON'
                dataio_create_epochs_Exoskeleton(epoch_length(len,:), filter_band);
            case 'SSVEP_SANDIEGO'
                dataio_create_epochs_SanDiego(epoch_length(len,:), filter_band);
            case 'SSVEP_TSINGHUA'
                dataio_create_epochs_Tsinghua(epoch_length(len,:), filter_band);
            otherwise
                ('Incorrect dataset');
        end
        for app = 1:length(approaches)
            if(strcmp(approaches{app},'MLR'))
                approach.features.alg = 'MLR';
                approach.features.options = [];
                approach.classifier.normalization = 'ZSCORE';
                approach.classifier.learner = 'SVM';
                approach.classifier.options.kernel = 'LIN';
            else
                approach.classifier.learner = approaches{app};
            end
            approach.cv.method = 'KFOLD';
            approach.cv.nfolds = 0;            
            [results, output, model] = run_analysis_SSVEP(sets{set}, approach, report);
            clear approach
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