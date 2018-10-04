function [K] = utils_compute_kernel(X, Y, alg)
%UTILS_COMPUTE_KERNEL Summary of this function goes here
%   Detailed explanation goes here
% date created 09-09-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

switch(alg.kernel.type)
    case 'TRIANGULAR'
        K = - pdist2(X, Y, 'euclidean').^ alg.kernel.p;
    case 'INK-SPLINE'
        [n,~] = size(X);
        [n1,~] = size(Y);
        K = ink_spline(X, Y, 1);
        if(n==n1)
            % normalize kernel
            K = K ./ sqrt(diag(K) * diag(K)');
        else
            K1 = ink_spline(X, X, 1);
            K2 = ink_spline(Y, Y, 1);
            K = K ./ sqrt(diag(K1)*diag(K2)');
        end
    case 'EXP'
        K = exp(- pdist2(X,Y,'euclidean')./(2*alg.kernel.sigma^2));
    case 'LAPLACE'
        K = exp(- pdist2(X,Y,'euclidean')./ alg.kernel.sigma);
    case 'RQUAD'
        d = pdist2(X,Y,'euclidean').^2;
        K = (1 + alg.kernel.alpha*d).^-alg.kernel.beta;
    case 'IMQUAD'
        K = 1 ./ (sqrt(pdist2(X,Y,'euclidean').^2 + alg.kernel.cst));
    case 'LOG'
        K = - log(pdist2(X,Y,'euclidean').^alg.kernel.d + 1);
    case 'CAUCHY'
        d = pdist2(X,Y,'euclidean').^2;
        K = 1 ./ (1 + (d./alg.kernel.sigma^2));
    case 'CSQUARE'
        K = chi_square(X, Y);
        %         [n,~] = size(X);
        %         [n1,~] = size(Y);
        %         if(n==n1)
        %             % normalize kernel
        %             K = K ./ sqrt(diag(K) * diag(K)');
        %         else
        %             K1 = chi_square(X, X);
        %             K2 = chi_square(Y, Y);
        %             K = K ./ sqrt(diag(K1)*diag(K2)');
        %         end
    case 'GHI'
        K = generalized_hist_intersection(X, Y, alg);
        [n,~] = size(X);
        [n1,~] = size(Y);
        if(n==n1)
            % normalize kernel
            K = K ./ sqrt(diag(K) * diag(K)');
        else
            K1 = generalized_hist_intersection(X, X, alg);
            K2 = generalized_hist_intersection(Y, Y, alg);
            K = K ./ sqrt(diag(K1)*diag(K2)');
        end
    case 'GTSTUDENT'
        d = pdist2(X,Y,'euclidean');
        K = 1 ./ (1 + d.^alg.kernel.d);
    case 'WAVELET'
        K = wavelet_kernel(X, Y, alg);
    case 'MATERN32'
        d = pdist2(X,Y,'euclidean');
        K = (1 + sqrt(3)*d).*exp(-sqrt(3)*d);
    case 'MATERN52'
        d = pdist2(X,Y,'euclidean');
        K = (1 + sqrt(5)*d + (5*d)/3).*exp(-sqrt(5)*d);
    case 'BROWNIAN'
        K = min(X,Y);
    otherwise
        error('Incorrect Kernel');
end

end

