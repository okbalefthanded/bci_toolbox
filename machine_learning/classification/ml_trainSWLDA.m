function [model] = ml_trainSWLDA(features, cv, opts)
%ML_TRAINSWLDA Summary of this function goes here
%   Detailed explanation goes here

%
% created 11-04-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(isempty(opts))
    opts.penter = 0.1;
    opts.premove = 0.15;
end

if (cv.nfolds ~=0)
    accuracy_folds = zeros(1, cv.nfolds);
    cv_models = cell(1,cv.nfolds);
    folds = ml_crossValidation(cv, size(features.x, 1));
    for fold = 1:cv.nfolds
        idx = folds==fold;
        train = ~idx;
        test = idx;
        x_train = utils_get_split(features, train);
        x_test = utils_get_split(features, test);
        cv_folds.nfolds = 0;
        cv_models{fold} = ml_trainSWLDA(x_train, cv_folds, opts);
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
    model = ml_trainSWLDA(features, cv_folds, opts);
else
    
    classes = unique(features.y);
    for c=1:2
        dataC{c} = features.x(features.y==classes(c),:);
        mu{c} = mean(dataC{c});
    end
    
    [b, se, pval, inmodel, stats]= stepwisefit(features.x, features.y, ...
        'penter', opts.penter, 'premove', opts.premove,...
        'display','off');
    
    % mu_both = (mu{1}(:, inmodel) + mu{2}(:, inmodel)) / 2;
    
    mu_both = ( mu{1} + mu{2}) / 2;
    model.w = zeros(size(b));
    model.w(inmodel) = b(inmodel);
    model.b = - model.w' * mu_both';
    model.inmodel = inmodel;
    model.alg.learner = 'SWLDA';
end

