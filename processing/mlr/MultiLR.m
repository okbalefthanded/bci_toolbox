function W_mlr=MultiLR(train_Feat,train_Y)

% Multiple linear regression
% train_Feat: training samples
% train_Y: label matrix

[U,Sigma,V]=svd(train_Feat,'econ');
r=rank(Sigma);
U1=U(:,1:r);
V1=V(:,1:r);
Sigma_r=diag(Sigma(1:r, 1:r));        
W_mlr=U1*diag(1./Sigma_r)*V1'*train_Y';

