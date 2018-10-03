function [K] = generalized_hist_intersection(X, Y, alg)
%GENERALIZED_HIST_INTERSECTION Summary of this function goes here
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
        k1(i,j,:) = min(abs(X(i,:)).^alg.kernel.alpha, abs(Y(j,:)).^alg.kernel.beta);
    end
end
K = sum(k1,3);
end

