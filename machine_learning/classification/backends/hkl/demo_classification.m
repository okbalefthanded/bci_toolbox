% demo script for regression with HKL
%%
clear all
seed=1;
randn('state',seed);
rand('state',seed);

p = 1024;           % total number of variables (used to generate Wishart)
psub = 8;          % kept number of variables
n = 512;           % number of observations
s = 4;              % number of relevant variables
noise_std = .2;		% standard deviation of noise

proptrain = .5;     % proportion of data kept for training


% generate random covariance matrix from a Wishart distribution
Sigma_sqrt = randn(p,p);
Sigma = Sigma_sqrt' * Sigma_sqrt;


% normalize to unit trace and sample
diagonal = diag(Sigma);
Sigma = diag( 1./diagonal.^.5) * Sigma * diag( 1./diagonal.^.5);
Sigma_sqrt =   Sigma_sqrt * diag( 1./diagonal.^.5);
X = randn(n,p) * Sigma_sqrt;

X = X(:,1:psub);
p=psub;

% generate nonlinear function of X
J =  1:s;    % select variables
Y = zeros(n,1);
for i=1:s
	for j=1:i-1
		Y = Y + X(:,J(i)) .* X(:,J(j));
	end
end
Y = Y / std(Y);

% add some noise with known standard deviation
Y = 1/noise_std * Y / std(Y);
Y = double( ( rand(n,1) < 1./( 1 + exp(-Y) ) ) );
% Y(Y==0) = -1;


% split data in two groups
ntrain = round(n*proptrain);
ntest = n - ntrain;
rp = randperm(n);
trainset = rp(1:ntrain);
testset  = rp(ntrain+1:end);

% select some lambdas
lambdas = 10.^[1:-.5:-8];
% memory_cache = 1e9;
memory_cache = 2e8;
%%
% HKL with hermite polynomial decomposition
% (X,Y,lambdas,loss,kernel,kernel_params,varargin)
[outputs, model, accuracies]  = hkl(X(trainset,:),...
                                  Y(trainset),...
                                  lambdas,...
                                  'logistic',...
                                  'hermite',...
                                   [ .5 3 .1 4 ],...
                                  'maxactive', 400,...
                                  'memory_cache', memory_cache);

% perform testing on the test set provided separately (checking that predictions are the same, and showing how to do so)
accuracies_test = hkl_test(model,outputs,X(testset,:),'Ytest',Y(testset));
train_pred = sign(accuracies_test.predtrain-.5)+1;
train_pred(train_pred>1)=1;
test_pred = sign(accuracies_test.predtest-.5)+1;
test_pred(test_pred>1)=1;
train_acc = (sum(train_pred==repmat(Y(trainset),1,length(lambdas)), 1)/ntrain) * 100;
test_acc = (sum(test_pred==repmat(Y(testset),1,length(lambdas)), 1)/ntest) * 100;
% subplot(1,2,1);
% plot(-log10(lambdas),accuracies.testing_error,'r'); hold on;
% plot(-log10(lambdas),accuracies.training_error,'b'); hold on;
% legend('test','train');
% xlabel('log_{10}(\lambda)');
% title('hermite kernels');
clear global
%%


% HKL with anova kernel
[outputs,model,accuracies] = hkl(X(trainset,:),Y(trainset),lambdas,'logistic','anova',[ .0625 .1 8 30],...
	'Xtest',X(testset,:),'Ytest',Y(testset),'maxactive',400,'memory_cache',1e9);

subplot(1,2,2);
plot(-log10(lambdas),accuracies.testing_error_class,'r'); hold on;
plot(-log10(lambdas),accuracies.training_error_class,'b'); hold on;
legend('test','train');
xlabel('log_{10}(\lambda)');
title('anova kernels');






