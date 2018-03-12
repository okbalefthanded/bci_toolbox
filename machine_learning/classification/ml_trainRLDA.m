function [model] = ml_trainRLDA(features, cv, shalg)
%TRAINLDA Summary of this function goes here
%   Detailed explanation goes here

% created 05-12-2016
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

c.nfolds = 0;

if (cv.nfolds ~=0)
    accuracy_folds = zeros(1, cv.nfolds);
    cv_models = cell(1,cv.nfolds);
    folds = ml_crossValidation(cv, size(features.x, 1));
    for fold = 1:cv.nfolds
        %         folds = ml_crossValidation(cv, size(features.x, 1));
        idx = folds==fold;
        train = ~idx;
        test = idx;
        x_train = utils_get_split(features, train);
        x_test = utils_get_split(features, test);
        cv_models{fold} = ml_trainRLDA(x_train, c, shalg);
        output = applyDA(x_test, cv_models{fold});
        accuracy_folds(fold) = output.accuracy;
    end
    disp(['Cross-Validation: ' cv.method]);
    disp(['Cross-Validation On N-Folds: ' num2str(cv.nfolds)]);
    disp(['Cross-Validation results: ' 'Accuracy: ' num2str(accuracy_folds)]);
    disp(['                          Mean: ' num2str(mean(accuracy_folds))]);
    disp(['                          Std: ' num2str(std(accuracy_folds))]);
    %     [~, best_model] = max(accuracy_folds);
    %     model = cv_models{best_model};
    model = ml_trainRLDA(features, c, shalg);
else
    
    mu = cell(2,1);
    dataC = cell(2,1);
    sig = cell(2,1);
    
    classes = unique(features.y);
    for c=1:2
        dataC{c} = features.x(features.y==classes(c),:);
        mu{c} = mean(dataC{c});
    end
    
    switch upper(shalg)
        case 'LW'
            for c=1:2
                [sig{c}, model.lambda(c)] = cov1para(dataC{c});
            end
            model.alg.learner = 'RLDA';
            model.alg.regularizer = 'LW';
        case 'RBLW'
            for c=1:2
                [sig{c}, model.lambda(c)] = shrinkage_cov(dataC{c}, 'rblw');
            end
            model.alg.learner = 'RLDA';
            model.alg.regularizer = 'RBLW';
            
        case 'OAS'
            for c=1:2
                [sig{c}, model.lambda(c)] = shrinkage_cov(dataC{c}, 'oas');
            end
            model.alg.learner = 'RLDA';
            model.alg.regularizer = 'OAS';
            
        otherwise
            for c=1:2
                sig{c} = cov(dataC{c});
                model.lambda(c) = 0;
            end
            model.alg.learner = 'LDA';
    end
    
    mu_both = (mu{1} + mu{2}) / 2;
    sig_both = (sig{1} + sig{2}) / 2;
    model.w = inv(sig_both)*(mu{2} - mu{1})';
    model.b = - mu_both * model.w;
end
model
model.alg
end
