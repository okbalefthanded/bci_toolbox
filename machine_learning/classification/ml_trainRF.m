function [model] = ml_trainRF(features, alg, cv)
%ML_TRAINRF Summary of this function goes here
%   Detailed explanation goes here

% created 06-14-2016
% last revised -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if (cv.nfolds == 0)
    trainData = features.x;
    trainLabel = features.y;
    nFeatures = size(trainData,2);
    
    if (~isfield(cv,'ntrees') && ~isfield(cv,'mtry') && ~isfield(cv,'replace'))
        nTrees = 500;
        mtry = round(sqrt(nFeatures));
        opts.replace = 1;
    else
        nTrees = cv.ntrees;
        mtry = cv.mtry;
        opts = cv.replace;
    end
    
    % cross-validation
    % nTrees (n_estimators), mtry (max_features), replace (bootstrap)
    
    model = classRF_train(trainData, trainLabel, nTrees, mtry, opts);
    model.alg.learner = 'RF';
    
else
    %     TODO: crossval
    acc_cv = 0;
    accuracy_folds = zeros(1, cv.nfolds);
    cv_models = cell(1, cv.nfolds);
    folds = ml_crossValidation(cv, size(features.x, 1));
    %     TODO RANDOM SEARCH HYPERPARAMETER TUNING
    ntress = 500:100:5000;
    nFeatures = floor(sqrt(size(features.x,2)));
    mtry = nFeatures:nFeatures+100;
    for n=ntress
        for m=mtry
            for replace = [0,1]
                for fold = 1:cv.nfolds
                    idx = folds==fold;
                    train = ~idx;
                    test = idx;
                    x_train = utils_get_split(features, train);
                    x_test = utils_get_split(features, test);
                    cv_fold.ntrees = n;
                    cv_fold.mtry = m;
                    cv_fold.replace = replace;
                    cv_fold.nfolds = 0;
                    cv_models{fold} = ml_trainRF(x_train, alg, cv_fold);
                    output = applyRF(x_test, cv_models{fold});
                    accuracy_folds(fold) = output.accuracy;
                end
                if(mean(accuracy_folds) > acc_cv)
                    acc_cv = mean(accuracy_folds);
                    best_n = n;
                    best_m = m;
                    best_replace = replace;
                end
            end         
            
            disp(['//CV values ',num2str(n),' mtry: ',num2str(m)]);
            disp(['//Best values for RandomForests: ntress ',num2str(best_n),' mtry: ',num2str(best_m)]);
            %                 disp(['Cross-Validation: ' cv.method]);
            %                 disp(['Cross-Validation On N-Folds: ' num2str(cv.nfolds)]);
            %                 disp(['Cross-Validation results: ' 'Accuracy: ' num2str(accuracy_folds)]);
            %                 disp(['                          Mean: ' num2str(mean(accuracy_folds))]);
            %                 disp(['                          Std: ' num2str(std(accuracy_folds))]);
            %                 disp(['Best values for SVM RBF kernel: C ',num2str(best_c),' Gamma: ',num2str(best_g)]);
        end
    end

    cv.nfolds = 0;
    cv.ntress = best_n;
    cv.mtrey = best_m;
    cv.replace = best_replace;
    model = ml_trainRF(x_train, alg, cv_fold);
end

end

