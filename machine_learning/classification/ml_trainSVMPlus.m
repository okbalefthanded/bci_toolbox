function [model] = ml_trainSVMPlus(features, alg, cv)
%ML_TRAINSVMPLUS Summary of this function goes here
%   Detailed explanation goes here

% created 03-16-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if (cv.nfolds == 0)
    if (isfield(alg,'normalization'))
        norml = utils_estimate_normalize(features.x, alg.normalization);
        norml_plus = utils_estimate_normalize(features.privileged, alg.normalization);
        trainData = utils_apply_normalize(features.x, norml);
        trainData_plus = utils_apply_normalize(features.privileged, norml_plus);
    else
        trainData = features.x;
        trainData_plus = features.privileged;
    end
    trainLabel = features.y;
    if(~isfield(cv,'c') || ~isfield(cv,'g'))
        c = 1;
        g = 1 / size(trainData, 2);
        cplus = 1;
        gplus = 1 / size(trainData_plus, 2);
    else
        c = cv.c;
        g = cv.g;
        cplus = cv.cplus;
        gplus = cv.gplus;
    end
        
    aSMO_opt = ['-s 5 -a 1',' '];
    switch upper(alg.options.svm_kernel)
        case 'RBF'
            aSMO_opt = [aSMO_opt,'-t 2',' ','-g',' ',num2str(g),' '];
        case 'LIN'
            aSMO_opt = [aSMO_opt,'-t 0',' '];
        otherwise
            error('Incorrect Kernel for training SVM');
    end
    switch upper(alg.options.svm_plus_kernel)
        case 'RBF'
            aSMO_opt = [aSMO_opt,'-T 2',' ','-G',' ',num2str(gplus),' '];
        case 'LIN'
            aSMO_opt = [aSMO_opt,'-T 0',' '];
        otherwise
            error('Incorrect Kernel for training SVM');
    end
    
    aSMO_opt = [aSMO_opt, '-c',' ',num2str(c),' ','-C',' ',num2str(cplus),' ','-w1 5 -w-1 1'];
    
    switch alg.lupi_learner
        case 'gSMO'
            %  TODO
%             g_SMO_train = 'svm-train-plus.exe ';
%             
%             data_plus = 'svm_plus_data\current_dplus';
%             train_data = 'svm_plus_data\train_data ';
%             libsvmwrite(train_data, trainLabel, sparse(trainData));
%             libsvmwrite(data_plus, trainLabel, sparse(trainData_plus));
%             % Linear Kernel
%             % aSMO_opt = ['-s 5 -t 0 -T 0 -f ' data_plus ' -C 0.01 '];
%             % Gaussian Kernel
%             %         aSMO_opt = ['-s 5 -t 2 -T 2 -f ' data_plus ' -C 0.01 -g 13 '];
%             model_plus = 'svm_plus_models\currentplus_model';
%             aSMO_opt = [aSMO_opt,' ','-f',' ',data_plus,' ','-w1 5 -w-1 1',' '];
%             gSMO_cmd = [g_SMO_train aSMO_opt train_data model_plus];
%             system(gSMO_cmd);
            classifier = svm_train_plus(trainLabel, trainData, trainData_plus, aSMO_opt);
            model.normalization = norml;
            model.normalization_plus = norml_plus;
%             model.classifier = model_plus;
            model.classifier = classifier;
            model.lupi_learner = 'gSMO';
            
        case 'L2_SVM+'
            %         TODO
            %         only Kernel SVM+
            % calculate kernels
            kparam = struct();
            kparam.kernel_type = 'gaussian';
            [K, train_kparam] = getKernel(trainData', kparam);
            
            kparam = struct();
            kparam.kernel_type = 'gaussian';
            tK = getKernel(trainData_plus', kparam);
            %
            svmplus_param.svm_C = 1;
            svmplus_param.gamma = 1;
            svmplus_param.svm_C = 1;
            svmplus_param.gamma = 1;
            train_labels = features.y;
            model.classifier = solve_l2svmplus_kernel(train_labels, K, tK, svmplus_param.svm_C, svmplus_param.gamma);
            model.train_labels = train_labels;
            model.train_kparam = train_kparam;
            model.train_features = trainData;
            model.lupi_learner = 'L2_SVM+';
            
        case 'MATLAB_SVM+'
            %     TODO
        otherwise
            error('Incorrect SVM+ learner');
    end
    model.alg.learner = 'SVM+';
else
    %     TODO: cross-val
    
    acc_cv = 0;
    accuracy_folds = zeros(1,cv.nfolds);
    cv_models = cell(1,cv.nfolds);
    folds = ml_crossValidation(cv, size(features.x, 1));
    %     TODO RANDOM SEARCH HYPERPARAMETER TUNING
    Cs = [0.001, 0.01, 0.1, 1, 10, 100];
    Csplus = Cs;
    gammas = [0.001, 0.01, 0.1, 1, 10, 100];
    gammas_plus = gammas;
    if(strcmp(alg.options.svm_kernel,'RBF'))
        for c=Cs
            for cp = Csplus
                for g=gammas
                    for gp = gammas_plus
                        for fold = 1:cv.nfolds
                            idx = folds==fold;
                            train = ~idx;
                            test = idx;
                            x_train = utils_get_split(features, train);
                            x_test = utils_get_split(features, test);
                            cv_fold.c = c;
                            cv_fold.g = g;
                            cv_fold.cplus = cp;
                            cv_fold.gplus = gp;
                            cv_fold.nfolds = 0;
                            cv_models{fold} = ml_trainSVMPlus(x_train, alg, cv_fold);
                            output = ml_applySVMPlus(x_test, cv_models{fold});
                            accuracy_folds(fold) = output.accuracy;
                        end
                        if(mean(accuracy_folds) > acc_cv)
                            acc_cv = mean(accuracy_folds);
                            best_c = c;
                            best_g = g;
                            best_cplus = cp;
                            best_gplus = gp;
                        end
                        disp(['//CV values C:',num2str(c),' G: ',num2str(g),'C plus: ', num2str(cp),' Gplus: ',num2str(gp)]);
                        disp(['//Best values for SVM RBF kernel: C ',num2str(best_c),' Gamma: ',num2str(best_g),'C plus: ', num2str(best_cplus),' Gplus: ',num2str(best_gplus)]);
                    end
                end
            end
        end
    else
        for c = 0.001:0.01:100
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
        end
    end
    cv.nfolds = 0;
    cv.c = best_c;
    cv.g = best_g;
    cv.cplus = best_cplus;
    cv.gplus = best_gplus;
    model = ml_trainSVMPlus(features, alg, cv);
end
%%
% Usage: svm-train [options] training_set_file [model_file]
% options:
% -s svm_type : set type of SVM (default 0)
%         0 -- C-SVC
%         1 -- nu-SVC
%         2 -- one-class SVM
%         3 -- epsilon-SVR
%         4 -- nu-SVR
%         5 -- SVM+
% -a n : optimization method
%     -1  -- Max Unconstrained Gain SMO (default)
%      0  -- Max Constrained Gain SMO (Glassmachers&Igel, JMLR2006)
%     k>0 -- Conjugate SMO of order k
% -t kernel_type : set type of kernel function (default 2)
%         0 -- linear: u'*v
%         1 -- polynomial: (gamma*u'*v + coef0)^degree
%         2 -- radial basis function: exp(-gamma*|u-v|^2)
%         3 -- sigmoid: tanh(gamma*u'*v + coef0)
%         4 -- precomputed kernel (kernel values in training_set_file)
% -T kernel_type_star : set type of kernel function for the correcting space (default 2), for SVM+
%         0 -- linear: u'*v
%         1 -- polynomial: (gamma*u'*v + coef0)^degree
%         2 -- radial basis function: exp(-gamma*|u-v|^2)
%         3 -- sigmoid: tanh(gamma*u'*v + coef0)
%         4 -- precomputed kernel (kernel values in training_set_file)
% -f star_file : name of the file containing star examples. Necessary parameter for SVM+
% -d degree : set degree in kernel function (default 3)
% -D degree_star : set degree_star in kernel function in the correcting space (default 3)
% -g gamma : set gamma in kernel function (default 1/number of features)
% -G gamma_star : set gamma_star in kernel function in the correcting space (default 1/number of features in the  correcting space)
% -r coef0 : set coef0 in kernel function (default 0)
% -R coef0_star : set coef0_star in kernel function (default 0)
% -c cost : set the parameter C of C-SVC, epsilon-SVR, nu-SVR and SVM+ (default 1)
% -C tau : set the parameter tau in SVM+ (default 1)
% -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
% -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
% -m cachesize : set cache memory size in MB (default 100)
% -e epsilon : set tolerance of termination criterion (default 0.001)
% -h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
% -b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
% -wi weight : set the parameter C of class i to weight*C, for C-SVC and SVM+ (default 1)
% -v n: n-fold cross validation mode
% -q : quiet mode (no outputs)
