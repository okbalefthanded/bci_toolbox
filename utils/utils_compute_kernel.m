function [K] = utils_compute_kernel(X, Y, alg)
%UTILS_COMPUTE_KERNEL Summary of this function goes here
%   Detailed explanation goes here
% date created 09-09-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

switch(alg.kernel.type)
    case 'TRIANGULAR'
        K = - pdist2(X, Y, 'euclidean').^ alg.p;
    case 'INK-SPLINE'
        % TODO
        [n,~] = size(X);
        [n1,~] = size(Y);
        K = ink_spline(X, Y, 1);
        if(n==n1)
            % normalize kernel
%             K = K ./ sqrt(diag(K) * diag(K)');
        else
            K1 = ink_spline(X, X, 1);
            K2 = ink_spline(Y, Y, 1);
%             K = K ./ sqrt(diag(K1)*diag(K2)');
        end
        
    otherwise
        error('Incorrect Kernel for training SVM');
end

end

