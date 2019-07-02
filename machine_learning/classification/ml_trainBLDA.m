function [model] = ml_trainBLDA(features, alg, cv)
%ML_TRAINBLDA Summary of this function goes here
%   Detailed explanation goes here
% created 10-07-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% Adapted to the ERP_ClASSIFICATION_BENCHMARK from the original Code

%%
% Author: Ulrich Hoffmann - EPFL, 2006
% Copyright: Ulrich Hoffmann - EPFL
%
% The algorithm implemented here was originally described by
% MacKay, D. J. C., 1992. Bayesian interpolation.
% Neural Computation 4 (3), pp. 415-447.
if(~isfield(alg,'verbose'))
    alg.verbose = 0;
end
%% compute regression targets from class labels (to do lda via regression)
y = features.y';
n_posexamples = sum(y==1);
n_negexamples = sum(y==-1);
n_examples    = n_posexamples + n_negexamples;
y(y==1) = n_examples/n_posexamples;
y(y==-1) = -n_examples/n_negexamples;


%% add feature that is constantly one (bias term)
x = features.x';
x = [x; ones(1,size(x,2))];  


%% initialize variables for fast iterative estimation of alpha and beta
n_features = size(x,1);            % dimension of feature vectors 
d_beta = inf;                      % (initial) diff. between new and old beta  
d_alpha = inf;                     % (initial) diff. between new and old alpha 
alpha    = 25;                     % (initial) inverse variance of prior distribution
biasalpha = 0.00000001;            % (initial) inverse variance of prior for bias term
beta     = 1;                      % (initial) inverse variance around targets
stopeps  = 0.0001;                 % desired precision for alpha and beta
i        = 1;                      % keeps track of number of iterations
maxit    = 500;                    % maximal number of iterations 
[v,d] = eig(x*x');                 % needed for fast estimation of alpha and beta  
vxy    = v'*x*y';                  % dito
d = diag(d);                       % dito
e = ones(n_features-1,1);          % dito


%% estimate alpha and beta iteratively
while ((d_alpha > stopeps) || (d_beta > stopeps)) && (i < maxit);
    alphaold = alpha;
    betaold  = beta;
    m = beta*v*((beta*d+[alpha*e; biasalpha]).^(-1).*vxy);
    err = sum((y-m'*x).^2);
    gamma = sum(beta*d./(beta*d+[alpha*e; biasalpha]));
    alpha = gamma/(m'*m);
    beta  = (n_examples - gamma)/err;
    if alg.verbose
        fprintf('Iteration %i: alpha = %f, beta = %f\n',i,alpha,beta);
    end
    d_alpha = abs(alpha-alphaold);
    d_beta  = abs(beta-betaold);
    i = i + 1;
end


%% process results of estimation 
if (i < maxit)
    
    % compute the log evidence
    % this can be used for simple model selection tasks
    % (see MacKays paper)
    model.evidence = (n_features/2)*log(alpha) + (n_examples/2)*log(beta) - ...
    (beta/2)*err - (alpha/2)*m'*m - ...
    0.5*sum(log((beta*d+[alpha*e; biasalpha]))) - (n_examples/2)*log(2*pi);

    % store alpha, beta, the posterior mean and the posterrior precision-
    % matrix in class attributes
    model.alpha = alpha;
    model.beta  = beta;
    model.w     = m;
    model.p     = v*diag((beta*d+[alpha*e; biasalpha]).^-1)*v';
 
    if alg.verbose
        fprintf('Optimization of alpha and beta successfull.\n');
        fprintf('The logevidence is %f.\n', model.evidence);
    end

else

    fprintf('Optimization of alpha and beta did not converge after %i iterations.\n',maxIt);
    fprintf('Giving up.');
end
model.alg.learner = 'BLDA';
end

