function [outputs,model,accuracies,accuracies_locs,bestlambda] = hkl_kfold(nfold,typefold,X,Y,lambdas,loss,kernel,kernel_params,varargin);
%%%%%%%%%%%%%%%%%%%%%%%
% HKL K-FOLD
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% required parameter
% nfold                 5 or 10
% typefold              'same' or 'scaled' -> using same lambda or same lambda/n
% X                     input data: n x p matrix (n=number of observations)
%						or kernel matrices ( n(n+1)/2 x p x q single)
% Y                     responses ( n x 1 matrix )
%                       NB: for classification in {0,1} (and not in {-1,1})
% lambdas               regularization parameters (might be vector or single number)
%						better to start first with large values of lambdas
% loss                  loss function ('square','logistic')
% kernel                kernel to be decomposed (see list below)
% kernel_params         kernel parameters
% varargin              see hkl.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('all folds\n')
% first perform learning on the full dataset%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[outputs,model,accuracies] = hkl(X,Y,lambdas,loss,kernel,kernel_params,varargin{:});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% centering and scaling is done separatetly for each fold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% cut into pieces
n = length(Y);

% cut into folds
folds = cell(1,nfold);
compfolds = cell(1,nfold);
for ifold = 1:nfold
    if ifold<nfold
        folds{ifold} = floor( (ifold-1)*n/nfold + 1): floor( ifold*n/nfold );
    else
        folds{ifold} = floor( (ifold-1)*n/nfold + 1):n;
    end
    compfolds{ifold}=1:n;
    compfolds{ifold}(folds{ifold}) = [];
    
end


% define lambdas on the fold
switch typefold,
    case 'same'
        lambdas_fold = lambdas;
    case 'scaled'
        lambdas_fold = lambdas / ( 1- 1/nfold) ;
end


for ifold = 1:nfold
    fprintf('fold %d\n',ifold)
    Yloc = Y(compfolds{ifold});
    Ytestloc = Y(folds{ifold});
    
    if ~strcmp(kernel,'base kernels') || ~strcmp(kernel,'base kernels-mkl') || ~strcmp(kernel,'base kernels-bimkl')
        Xloc = X(compfolds{ifold},:);
        Xtestloc = X(folds{ifold},:);
    else
        error('not implemented yet')
        
    end
    
    
    
    [outputs_loc,model_loc,accuracies_loc] = hkl(Xloc,Yloc,lambdas_fold,loss,kernel,kernel_params,varargin{:},'Xtest',Xtestloc,'Ytest',Ytestloc);
    
    accuracies_locs{ifold} = accuracies_loc;
end


temp = [];
for ifold=1:nfold, temp = [ temp; accuracies_locs{ifold}.testing_error]; end;

[a,bestlambda] = min(mean(temp,1));

estimated_best_error = accuracies.testing_error(bestlambda)
best_error = min(accuracies.testing_error)


