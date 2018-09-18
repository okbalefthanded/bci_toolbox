function [K] = ink_spline(X,Y, order)
% INK_SPLINE
% created 09-12-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% References :
% [1] R. Izmailov, V. Vapnik, and A. Vashist, “Multidimensional Splines
%      with Infinite Number of Knots as SVM Kernels,” vol. 2.
% [2] V. Vapnik, “Learning Using Privileged Information : Similarity
%      Control and Knowledge Transfer,” J. Mach. Learn. Res., vol. 16,
%      pp. 2023–2049, 2015.
delta = 1;
a = -3;
[n,d] = size(X);
[n1,d1] = size(Y);
if(d ~= d1)
    error('matrices X and Y dimensions mismatch, cant compute kernel matrix');
end
% if(n<n1)
%     m = n;
% else
%     m = n1;
% end
mins = zeros(n,n1,d);
for i = 1:n
    for j = 1:n1
        mins(i,j,:) = min(X(i,:),Y(j,:))+ delta;
    end
end

if(order==0)
    K = prod(mins,3);
else
    k1 = zeros(n,n1,d);
    for i = 1:n
        for j = 1:n1
            k1(i,j,:) = X(i,:).*Y(j,:) + 0.5*(abs(X(i,:)-Y(j,:)).*squeeze(mins(i,j,:))'.^2) + (squeeze(mins(i,j,:))'.^3)/3;
            % k1(i,j,:) = ((X(i,:)-a).*(Y(j,:)-a)) + (0.5.*(X(i,:)-Y(j,:)).*(Y(j,:)-a).^2) + ((Y(j,:)-a).^3)/3;
        end
    end
    K = prod(k1,3);
    %         if(n==n1)
    %             K = K ./sqrt(diag(K) * diag(K)');
    %         else
    %
    %         end
end
end

