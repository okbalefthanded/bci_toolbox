function W=msetcca(X,K)
% Multiset Canonical Correlation Analysis for learning joint spatial filters
% 
% Input:  X -- EEG data (channel x point x trial)
%         K -- Number of extracted joint spatial filters
% Output: W -- Joint spatial filters in the columns
% 
% by Yu Zhang, ECUST, 2013.2.12
% 
% Reference: [1] Y. Zhang, G. Zhou, J. Jin, X. Wang, A. Cichocki. 
%                Frequency recognition in SSVEP-based BCI using multiset canonical correlation analysis.
%                International Journal of Neural Systems, 24(4): 1450013, (14 pages), 2014.
%            [2] Y.-O. Li, T. Adali, W. Wang, V. D. Calhoun.
%                Joint Blind Source Separation by Multiset Canonical Correlation 
%                Analysis. IEEE Trans. Signal Process., 57(10): 3918-3929, 2009.
%            [3] J. R. Kettenring. Canonical analysis of several sets of variables. 
%                Biometrika, 58(3): 433-451, 1971.
% 


nchannel=size(X,1);
W=zeros(size(X,1),K,size(X,3));
N_trial=size(X,3);

% Whiten transformation
V=zeros(nchannel,nchannel);
for n=1:N_trial
    Xwhit=X(:,:,n);
    npot=size(Xwhit,2);
    Xwhit=Xwhit-repmat(mean(Xwhit,2),1,npot);
    C=Xwhit*Xwhit'/npot;
    [vec,val]=eig(C);
    V(:,:,n)=sqrt(val)\vec';
    X(:,:,n)=V(:,:,n)*Xwhit;
end

% Multiset CCA for learning joint spatial filters W
Y=[];
for n=1:N_trial
    Y=[Y;X(:,:,n)];
end
R=cov(Y.');
S=diag(diag(R));
[tempW rho]=eigs(R-S,S,K);
for n=1:N_trial
    W(:,:,n)=tempW((n-1)*nchannel+1:n*nchannel,:)./norm(tempW((n-1)*nchannel+1:n*nchannel,:));
end
for n=1:N_trial
    W(:,:,n)=(W(:,:,n)'*V(:,:,n))';
end


