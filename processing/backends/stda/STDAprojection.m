function projSTDA=STDAprojection(X,STDAmode)
% 
% STDA projection
% X: ch x point x trial
% by Yu Zhang, ECUST & RIKEN, June 2012. Email: yuzhang@ecust.edu.cn
% 

X=tensor(X);

projSTDA=ttm(X,STDAmode,1:length(STDAmode));
projSTDA=double(projSTDA);
Size=size(projSTDA);
projSTDA=reshape(projSTDA,prod(Size(1:length(Size)-1)),Size(end));










