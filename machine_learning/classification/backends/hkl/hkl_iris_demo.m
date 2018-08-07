tic;
%%
load iris_dataset
X = irisInputs';
[Y, ~] = find(irisTargets);
% split data to binary classes
idx = Y==1 | Y==2;
X = X(idx,:);
Y = Y(idx,:);
proptrain = .5; 
n = size(X, 1);
Y(Y==2) = 0;
% split data in two groups
ntrain = round(n*proptrain);
ntest = n - ntrain;
rp = randperm(n);
trainset = rp(1:ntrain);
testset  = rp(ntrain+1:end);

% select some lambdas
lambdas = 10.^[1:-.5:-8];

% HKL with hermite polynomial decomposition
% (X,Y,lambdas,loss,kernel,kernel_params,varargin)
% loss : logistic, square
[outputs, model, accuracies]  = hkl(X(trainset,:),...
                                  Y(trainset),...
                                  lambdas,...
                                  'logistic',...
                                  'hermite',...
                                   [ .5 3 .1 4 ],...
                                  'maxactive', 400,...
                                  'memory_cache', 1e9);
                  

% perform testing on the test set provided separately (checking that predictions are the same, and showing how to do so)
accuracies_test = hkl_test(model,outputs,X(testset,:),'Ytest',Y(testset));
train_pred = sign(accuracies_test.predtrain-.5)+1;
train_pred(train_pred>1)=1;
test_pred = sign(accuracies_test.predtest-.5)+1;
test_pred(test_pred>1)=1;
probs_tr = 1 ./ (1+exp(-accuracies_test.predtrain));
probs_test = 1 ./ (1+exp(-accuracies_test.predtest));
train_acc = (sum(train_pred==repmat(Y(trainset),1,length(lambdas)), 1)/ntrain) * 100;
test_acc = (sum(test_pred==repmat(Y(testset),1,length(lambdas)), 1)/ntest) * 100;

subplot(1,3,1);
plot(-log10(lambdas),test_acc,'r'); hold on;
plot(-log10(lambdas),train_acc,'b'); hold on;
legend('test','train');
xlabel('log_{10}(\lambda)');
title('hermite kernels');
%%

% HKL with anova kernel
[outputs,model,accuracies] = hkl(X(trainset,:),Y(trainset),lambdas,'logistic','anova',[ .0625 .1 8 30],...
	'maxactive',400,'memory_cache',1e9);

% perform testing on the test set provided separately (checking that predictions are the same, and showing how to do so)
accuracies_test = hkl_test(model,outputs,X(testset,:),'Ytest',Y(testset));
train_pred = sign(accuracies_test.predtrain-.5)+1;
train_pred(train_pred>1)=1;
test_pred = sign(accuracies_test.predtest-.5)+1;
test_pred(test_pred>1)=1;
train_acc = (sum(train_pred==repmat(Y(trainset),1,length(lambdas)), 1)/ntrain) * 100;
test_acc = (sum(test_pred==repmat(Y(testset),1,length(lambdas)), 1)/ntest) * 100;

subplot(1,3,2);
plot(-log10(lambdas),test_acc,'r'); hold on;
plot(-log10(lambdas),train_acc,'b'); hold on;
legend('test','train');
xlabel('log_{10}(\lambda)');
title('anova kernels');
%%

% HKL with gaussian kernel
[outputs,model,accuracies] = hkl(X(trainset,:),Y(trainset),lambdas,'logistic','gauss-hermite',[ 1 .05 3 .1 .5 ],...
	'maxactive',400,'memory_cache',1e9);
% perform testing on the test set provided separately (checking that predictions are the same, and showing how to do so)
accuracies_test = hkl_test(model,outputs,X(testset,:),'Ytest',Y(testset));
train_pred = sign(accuracies_test.predtrain-.5)+1;
train_pred(train_pred>1)=1;
test_pred = sign(accuracies_test.predtest-.5)+1;
test_pred(test_pred>1)=1;
train_acc = (sum(train_pred==repmat(Y(trainset),1,length(lambdas)), 1)/ntrain) * 100;
test_acc = (sum(test_pred==repmat(Y(testset),1,length(lambdas)), 1)/ntest) * 100;

subplot(1,3,3);
plot(-log10(lambdas),test_acc,'r'); hold on;
plot(-log10(lambdas),train_acc,'b'); hold on;
legend('test','train');
xlabel('log_{10}(\lambda)');
title('Gaussian kernels');

toc;