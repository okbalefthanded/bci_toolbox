function [pred, score] = easymkl_predict(model, Ks)
%EASYMKL_PREDICT predict labels for unseen test instances [1]
% Input : 
%        model : EasyMKL model Struct
%              .gamma   : [Nx1] [double] instance coefficients 
%                         N : number of training examples  
%              .bias    : 1x1 double bias
%              .weights : [1xL] [double] kernel weights
%              .labels  : [NxN] [double] training labes in diagonal format
%         Ks : [NxMxL] [double] Set of Kernels
%               N : number of testing examples
%               M : number of trainins examples
%               L : Number of Kernels
% Output :
%        pred  : [Nx1] [double] predicted labels 1|-1
%        score : [Nx1] [double] evaluation function value
% References:
% [1] Fabio Aiolli and Michele Donini 
%      EasyMKL: a scalable multiple kernel learning algorithm
%      Paper @ http://www.math.unipd.it/~mdonini/publications.html
% created 11-04-2018
% last modfied -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% created 11-06-2018
% last modfied -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
K = sum_kernels(Ks, model.weights);
score = K * model.labels * model.gamma;
pred = sign(score);
end

