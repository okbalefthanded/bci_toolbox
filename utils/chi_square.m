function [K] = chi_square(X,Y)
%CHI_SQUARE Summary of this function goes here
%   Detailed explanation goes here
% date created 10-03-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
[n,d] = size(X);
[n1,d1] = size(Y);
if(d ~= d1)
    error('matrices X and Y dimensions mismatch, cannot compute kernel matrix');
end
k1 = zeros(n, n1, d);
for i = 1:n
    for j = 1:n1
        k1(i,j,:) = (2 * X(i,:).*Y(j,:)) / (X(i,:)+Y(j,:));
    end
end
K = sum(k1,3);
end

