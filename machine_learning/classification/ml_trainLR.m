function [model] = ml_trainLR(features, alg, cv)
%ML_TRAINLR Summary of this function goes here
%   Detailed explanation goes here

% created : 05-10-2017
% last modified : -- -- --

trainData = sparse(features.x);
trainLabel = features.y;
% -s -c -p -e -B -wi -v -C -q
if(cv.nfolds == 0)
    if (isfield(alg,'options'))
        %     lroptions = ml_parse_options(alg);
        switch(alg.options.regularizer)
            case 'L1'
                lroptions = '-s 6';
            case 'L2'
                lroptions = '-s 7';
            otherwise
                error('Incorrect Regularizer for Logistic Regression');
        end
        lroptions = [lroptions,' ','-e 0.001',' ','-w1 5 -w-1 1'];
        classifier = liblintrain(trainLabel, trainData, lroptions);
    else
        classifier = liblintrain(trainLabel, trainData, '-s 0 -q 1');
    end
    model.classifier = classifier;
    model.alg.learner = 'LR';
else
    acc_cv = 0;
    accuracy_folds = zeros(1,cv.nfolds);
    cv_models = cell(1,cv.nfolds);
    folds = ml_crossValidation(cv, size(features.x, 1));
    %     TODO RANDOM SEARCH HYPERPARAMETER TUNING
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
            cv_models{fold} =  ml_trainLR(x_train, alg, cv_fold);
            output = applyLR(x_test, cv_models{fold});
            accuracy_folds(fold) = output.accuracy;
        end
        if(mean(accuracy_folds) >= acc_cv)
            acc_cv = mean(accuracy_folds);
            best_c = c;
        end
        disp(['//CV values ',num2str(c)]);
        disp(['//Best values for C ',num2str(best_c)]);
        %             disp(['Cross-Validation: ' cv.method]);
        %             disp(['Cross-Validation On N-Folds: ' num2str(cv.nfolds)]);
        %             disp(['Cross-Validation results: ' 'Accuracy: ' num2str(accuracy_folds)]);
        %             disp(['                          Mean: ' num2str(mean(accuracy_folds))]);
        %             disp(['                          Std: ' num2str(std(accuracy_folds))]);
        %             disp(['Best values for SVM linear kernel: C ',num2str(best_c)]);
        cv.nfolds = 0;
        cv.c = best_c;
        model = ml_trainLR(features, alg, cv);
    end
end
end
%% helpers LIBLINEAR options
% Usage: model = train(training_label_vector, training_instance_matrix, 'liblinear_options', 'col');
% liblinear_options:
% -s type : set type of solver (default 1)
%   for multi-class classification
% 	 0 -- L2-regularized logistic regression (primal)
% 	 1 -- L2-regularized L2-loss support vector classification (dual)
% 	 2 -- L2-regularized L2-loss support vector classification (primal)
% 	 3 -- L2-regularized L1-loss support vector classification (dual)
% 	 4 -- support vector classification by Crammer and Singer
% 	 5 -- L1-regularized L2-loss support vector classification
% 	 6 -- L1-regularized logistic regression
% 	 7 -- L2-regularized logistic regression (dual)
%   for regression
% 	11 -- L2-regularized L2-loss support vector regression (primal)
% 	12 -- L2-regularized L2-loss support vector regression (dual)
% 	13 -- L2-regularized L1-loss support vector regression (dual)
% -c cost : set the parameter C (default 1)
% -p epsilon : set the epsilon in loss function of SVR (default 0.1)
% -e epsilon : set tolerance of termination criterion
% 	-s 0 and 2
% 		|f'(w)|_2 <= eps*min(pos,neg)/l*|f'(w0)|_2,
% 		where f is the primal function and pos/neg are # of
% 		positive/negative data (default 0.01)
% 	-s 11
% 		|f'(w)|_2 <= eps*|f'(w0)|_2 (default 0.001)
% 	-s 1, 3, 4 and 7
% 		Dual maximal violation <= eps; similar to libsvm (default 0.1)
% 	-s 5 and 6
% 		|f'(w)|_1 <= eps*min(pos,neg)/l*|f'(w0)|_1,
% 		where f is the primal function (default 0.01)
% 	-s 12 and 13
% 		|f'(alpha)|_1 <= eps |f'(alpha0)|,
% 		where f is the dual function (default 0.1)
% -B bias : if bias >= 0, instance x becomes [x; bias]; if < 0, no bias term added (default -1)
% -wi weight: weights adjust the parameter C of different classes (see README for details)
% -v n: n-fold cross validation mode
% -C : find parameter C (only for -s 0 and 2)
% -q : quiet mode (no outputs)
% col:
% 	if 'col' is setted, training_instance_matrix is parsed in column format, otherwise is in row format