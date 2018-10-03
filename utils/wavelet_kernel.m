function [K] = wavelet_kernel(X, Y, alg)
%WAVELET_KERNEL Summary of this function goes here
%   Detailed explanation goes here
% created 10-03-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
[n,d] = size(X);
[n1,d1] = size(Y);
if(d ~= d1)
    error('matrices X and Y dimensions mismatch, cannot compute kernel matrix');
end
k1 = zeros(n, n1, d);
for i = 1:n
    for j = 1:n1
        xx = (X(i,:) - Y(j,:)) ./ alg.kernel.a;        
        k1(i,j,:) = cos(1.75*xx).*exp(-(xx.^2)/(2*alg.kernel.a^2));
    end
end
K = prod(k1,3);
end
