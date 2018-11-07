function [model] = easymkl_train(Ks, y,lambda, tracenorm)
%EASYMKL_TRAIN train an EasyMKL model[1]
% Input : 
%         Ks : [NxNxL] [double] Set of Kernels
%               N : Kernel value of training examples  
%               L : Number of Kernels
%         y  : [1xN] [double] Training labels 1|-1
%         lambda : regularization parameter [0,1]
%         tracenorm : 0|1 logical value whether to normalize trace or not
% Output :
%        model : EasyMKL model Struct
%              .gamma   : [Nx1] [double] instance coefficients 
%                         N : number of training examples  
%              .bias    : 1x1 double bias
%              .weights : [1xL] [double] kernel weights
%              .labels  : [NxN] [double] training labes in diagonal format
% Requirements:
% -  MOSEK : quadprog function 
% References:
% [1] Fabio Aiolli and Michele Donini 
%      EasyMKL: a scalable multiple kernel learning algorithm
%      Paper @ http://www.math.unipd.it/~mdonini/publications.html
% created 11-04-2018
% last modfied -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
nr_kernels = size(Ks, 3);
% trace normalization
if(tracenorm)
    for i=1:nr_kernels
        Ks(:,:,i) = (Ks(:,:,i)*size(Ks(:,:,i),1)) / trace(Ks(:,:,i));
    end
end
% sum of kernels
K = sum_kernels(Ks);
% 
x = optimize(K, y, lambda);
YY = diag(y);
bias = 0.5 * x' * K * YY * x;
yg = x'.*y;
weights = zeros(1,nr_kernels);
for i=1:nr_kernels
    weights(i) = yg*Ks(:,:,i)*yg';
end
weights = weights ./ sum(weights);
K = sum_kernels(Ks, weights);
% 
x = optimize(K, y, lambda);
% model
model.gamma = x;
model.bias = bias;
model.weights = weights;
model.labels = YY;
end

function [x] = optimize(K, y, lambda)
YY = diag(y);
KLL = (1-lambda) * YY * K * YY;
LID = diag(lambda* ones(1,length(y)));
Q = 2 * (KLL+LID);
p = zeros(length(y),1);
G = - diag(ones(length(y),1));
h = zeros(size(K,1),1);
A = double([y<0;y>0]);
b = [1;1];
[x, fval, exitflag,output] = quadprog(Q,p,G,h,A,b);
end
