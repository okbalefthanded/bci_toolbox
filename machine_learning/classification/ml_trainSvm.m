function [model] = ml_trainSVM(features, alg, cv)
%ML_TRAINSVM Summary of this function goes here
%   Detailed explanation goes here

% date created 06-02-2016
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% Train SVM
if (cv.nfolds == 0)
    if (isfield(alg,'normalization'))
        norml = utils_estimate_normalize(features.x, alg.normalization);
        trainData = utils_apply_normalize(features.x, norml);
    else
        trainData = features.x;
    end
    trainLabel = features.y;
    
    if(~isfield(cv,'c') || ~isfield(cv,'g'))
        c = 1;
        g = 1 / size(trainData, 2);
    else
        c = cv.c;
        g = cv.g;
    end
    switch upper(alg.options.kernel)
        case 'RBF'
            classifier = svmtrain(trainLabel, trainData, ['-t 2 -g ',num2str(g),' ','-c ',num2str(c),' ','-w1 2 -w-1 1']);
        case 'LIN'
            classifier = svmtrain(trainLabel, trainData, ['-t 0 -c ',num2str(c),' ','-w1 2 -w-1 1']);
        otherwise
            error('Incorrect Kernel for training SVM');
    end
    model.normalization = norml;
    model.classifier = classifier;
    model.alg.learner = 'SVM';
    
else    
    acc_cv = 0;
    accuracy_folds = zeros(1,cv.nfolds);
    cv_models = cell(1,cv.nfolds);
    folds = ml_crossValidation(cv, size(features.x, 1));
    %     TODO RANDOM SEARCH HYPERPARAMETER TUNING?
    Cs = [0.001, 0.01, 0.1, 1, 10, 100];
    gammas = [0.001, 0.01, 0.1, 1, 10, 100];
    if(strcmp(alg.options.kernel,'RBF'))
        %         for c = 1:10:100
        %             for g = 0.01:0.1:100
        for c=Cs
            for g=gammas
                for fold = 1:cv.nfolds
                    idx = folds==fold;
                    train = ~idx;
                    test = idx;
                    x_train = utils_get_split(features, train);
                    x_test = utils_get_split(features, test);
                    cv_fold.c = c;
                    cv_fold.g = g;
                    cv_fold.nfolds = 0;
                    cv_models{fold} = ml_trainSvm(x_train, alg, cv_fold);
                    output = applySvm(x_test, cv_models{fold});
                    accuracy_folds(fold) = output.accuracy;
                end
                if(mean(accuracy_folds) > acc_cv)
                    acc_cv = mean(accuracy_folds);
                    best_c = c;
                    best_g = g;
                end
                
                disp(['//CV values ',num2str(c),' G: ',num2str(g)]);
                disp(['//Best values for SVM RBF kernel: C ',num2str(best_c),' Gamma: ',num2str(best_g)]);
                %                 disp(['Cross-Validation: ' cv.method]);
                %                 disp(['Cross-Validation On N-Folds: ' num2str(cv.nfolds)]);
                %                 disp(['Cross-Validation results: ' 'Accuracy: ' num2str(accuracy_folds)]);
                %                 disp(['                          Mean: ' num2str(mean(accuracy_folds))]);
                %                 disp(['                          Std: ' num2str(std(accuracy_folds))]);
                %                 disp(['Best values for SVM RBF kernel: C ',num2str(best_c),' Gamma: ',num2str(best_g)]);
            end
        end
        
    else
        Cs = [0.001, 0.01, 0.1, 1, 10, 100];
        for c = Cs
            for fold = 1:cv.nfolds
                idx = folds==fold;
                train = ~idx;
                test = idx;
                x_train = utils_get_split(features, train);
                x_test = utils_get_split(features, test);
                cv_fold.c = c;
                cv_fold.nfolds = 0;
                cv_models{fold} =  ml_trainSvm(x_train, alg, cv_fold);
                output = applySvm(x_test, cv_models{fold});
                accuracy_folds(fold) = output.accuracy;
            end
            if(mean(accuracy_folds) > acc_cv)
                acc_cv = mean(accuracy_folds);
                best_c = c;
            end
            %             disp(['Cross-Validation: ' cv.method]);
            %             disp(['Cross-Validation On N-Folds: ' num2str(cv.nfolds)]);
            %             disp(['Cross-Validation results: ' 'Accuracy: ' num2str(accuracy_folds)]);
            %             disp(['                          Mean: ' num2str(mean(accuracy_folds))]);
            %             disp(['                          Std: ' num2str(std(accuracy_folds))]);
            %             disp(['Best values for SVM linear kernel: C ',num2str(best_c)]);
        end
    end
    cv.nfolds = 0;
    cv.c = best_c;
    if(strcmp(alg.options.kernel,'RBF'))
        cv.g = best_g;
    end
    model = ml_trainSvm(features, alg, cv);
    
end
end

% % helpers: LIBSVM options
% Usage: model = svmtrain(training_label_vector, training_instance_matrix, 'libsvm_options');
% libsvm_options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC		(multi-class classification)
% 	1 -- nu-SVC		(multi-class classification)
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR	(regression)
% 	4 -- nu-SVR		(regression)
% -t kernel_type : set type of kernel function (default 2)
% 	0 -- linear: u'*v
% 	1 -- polynomial: (gamma*u'*v + coef0)^degree
% 	2 -- radial basis function: exp(-gamma*|u-v|^2)
% 	3 -- sigmoid: tanh(gamma*u'*v + coef0)
% 	4 -- precomputed kernel (kernel values in training_instance_matrix)
% -d degree : set degree in kernel function (default 3)
% -g gamma : set gamma in kernel function (default 1/num_features)
% -r coef0 : set coef0 in kernel function (default 0)
% -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
% -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
% -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
% -m cachesize : set cache memory size in MB (default 100)
% -e epsilon : set tolerance of termination criterion (default 0.001)
% -h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
% -b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
% -wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)
% -v n : n-fold cross validation mode
% -q : quiet mode (no outputs)