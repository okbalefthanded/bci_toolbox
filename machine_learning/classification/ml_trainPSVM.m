function [model] = ml_trainPSVM(features, alg, cv)
%ML_TRAINPSVM wrapper for primal svm code
% Reference
% O. Chapelle 2007
% date created 10-18-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(cv.nfolds == 0)
    if(isempty(alg.options))
        alg.options.kernel.type = 'LIN';
        alg.normalization = 'ZSCORE';
    end
    if (isfield(alg,'normalization'))
        norml = utils_estimate_normalize(features.x, alg.normalization);
        trainData = utils_apply_normalize(features.x, norml);
    else
        trainData = features.x;
    end
    if(~isfield(alg.options,'C'))
        lambda = 1;
    else
        lambda = 1 / alg.options.C;
    end
    switch upper(alg.options.kernel.type)
        case 'LIN'
            [w, b0] = primal_svm(trainData, features.y, 1, lambda);
            classifier.w = w;
            classifier.b = b0;
        otherwise % PRECOMPUTED KERNEL
            K = utils_compute_kernel(trainData, trainData, alg.options);
            [beta, b] = primal_svm(K, features.y, 0, lambda);
            classifier.beta = beta;
            classifier.b = b;
            classifier.trainData = trainData;
    end
    classifier.opts = alg.options;
    model.normalization = norml;
    model.classifier = classifier;
    model.alg.params.c =  1/lambda;
    model.alg.learner = 'PSVM';
else
    % TODO cross-val
end

