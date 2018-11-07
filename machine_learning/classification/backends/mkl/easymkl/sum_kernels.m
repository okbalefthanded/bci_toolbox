function [K] = sum_kernels(varargin)
%SUM_KERNELS returns the kernel created by averaging of all the kernels [1]
% Input :
%           Ks      : [NxMxL] [double] Set of Kernels
%                     N : number of training examples  
%                     M : number of training/testing examples
%                     L : Number of Kernels
%           weights : [1xL] [double] kernel weights
% Output :
%           K : [NxM] : weighted average of kernels
% References:
% [1] Fabio Aiolli and Michele Donini 
%      EasyMKL: a scalable multiple kernel learning algorithm
%      Paper @ http://www.math.unipd.it/~mdonini/publications.html
% created 11-04-2018
% last modfied -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
Ks = varargin{1};
[n,m,~] = size(Ks);
if (nargin < 2)
    K = sum(Ks,3);
else
    w = varargin{2};
    K = zeros(n,m);
    for i=1:length(w)
        K = K + w(i)*Ks(:,:,i);
    end
end
end

