function [sigma,shrinkage]=cov1para(x,shrink)
%
%This function is not part of the RCSP toolbox
%Authors: Ledoit & Wolf
%
% function sigma=cov1para(x)
% x (t*n): t iid observations on n random variables
% sigma (n*n): invertible covariance matrix estimator
%
% Shrinks towards one-parameter matrix:
%    all variances are the same
%    all covariances are zero
% if shrink is specified, then this const. is used for shrinkage

% de-mean returns
[t,n]=size(x);
meanx=mean(x);
x=x-meanx(ones(t,1),:);

% compute sample covariance matrix
sample=(1/t).*(x'*x);

% compute prior
meanvar=mean(diag(sample));
prior=meanvar*eye(n);

if (nargin < 2 | shrink == -1) % compute shrinkage parameters
  
  % what we call p 
  y=x.^2;
  phiMat=y'*y/t-2*(x'*x).*sample/t+sample.^2;
  phi=sum(sum(phiMat)); 
  
  % what we call r is not needed for this shrinkage target
  
  % what we call c
  gamma=norm(sample-prior,'fro')^2;

  % compute shrinkage constant
  kappa=phi/gamma;
  shrinkage=max(0,min(1,kappa/t));
    
else % use specified number
  shrinkage=shrink;
end

% compute shrinkage estimator
sigma=shrinkage*prior+(1-shrinkage)*sample;







