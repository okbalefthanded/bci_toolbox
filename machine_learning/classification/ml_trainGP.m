function [model] = ml_trainGP(features, alg)
%ML_TRAINGP train Gaussian Process classification model using
% the GPML toolbox
% Dependencies : GPML toolbox [1]
% References :
% [1] Rasmussen, C., & Hannes, N. (2010). Gaussian processes for machine
% learning (GPML) toolbox. Journal of Machine Learning Research,
% 11, 3011–3015. https://doi.org/10.1142/S0129065704001899
% created 01-21-2019
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

%TODO Mlticlass
hyp = alg.options.hyp;
nFunc = -alg.options.nfunc;
infFunc = str2func(strcat('inf', alg.options.inference));
meanFunc = str2func(strcat('mean', alg.options.mean));
covFunc = str2func(strcat('cov', alg.options.cov));
likFunc = str2func(strcat('lik', alg.options.likelihood));
% hyperparameter tuning is performed without cross-validation
hyp = minimize(hyp, @gp, nFunc, infFunc, meanFunc, covFunc, likFunc, ...
               features.x, features.y);
% train
[nl, dnl] = gp(hyp, infFunc, meanFunc, covFunc, likFunc, ...,
              features.x, features.y);
model.nl = nl;
model.hyp = hyp;
model.infFunc = infFunc;
model.meanFunc = meanFunc;
model.covFunc = covFunc;
model.likFunc = likFunc;
model.x = features.x;
model.y = features.y;
model.alg.learner = 'GP';
end

