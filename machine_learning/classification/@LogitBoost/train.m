function l = train(l, x, y, n_channels)
% -------------------------------------------------------------------------
% train is used to setup a classifier with LogitBoosting 
%
% INPUT 
%   l: an initialized LogitBoost object
%   x: matrix of feature vectors, columns are feature vectors, number of 
%      columns equals number of feature vectors. See example.m for format 
%      of feature vectors.
%   y: rowvector with labels of feature vectors, labels have to be 0 or 1
%   n_channels: number of EEG electrodes
%
% OUTPUT
%   l: an updated LogitBoost object (ready to be used as a classifier)
%
% Author: Ulrich Hoffmann - EPFL, 2005
% Copyright: Ulrich Hoffmann - EPFL
% -------------------------------------------------------------------------

l.n_channels = n_channels;               % number of electrodes
l.n_features = size(x, 1);               % number of features
n_epochs = size(x, 2);                   % number of feature vectors
p = ones(1, n_epochs)*0.5;               % p(y_i = 1 | x) 
f = zeros(1, n_epochs);                  % values of f at feature vectors
options = optimset('GradObj','on','Display','off');  % options for fminunc

for i = 1:l.n_steps;

    % compute gradient
    g = 2*(y-p);

    % find the best timepoint in epoch and corresponding weights
    min_err = inf;
    best_feat = 0;
    for j = 1:l.n_features/n_channels
        % append a feature that is 1 everywhere to allow for a bias
        x_1 = x((j-1)*n_channels+1:j*n_channels,:);
        x_1 = [x_1; ones(1,size(x_1,2))];
        % regress features to gradient and check goodness of fit
        C = x_1*x_1';
        if rcond(C) > eps
            reg = C  \ x_1*g';
            resp = x_1'*reg;
            err = sum((g'-resp).^2);
            % if fit is better than previous ones update best fit
            if (err < min_err)
                min_err = err;
                best_feat = j;
                best_reg = reg;
                best_resp = resp;
            end
        end
    end
    
    % compute the stepsize that minimizes the loss function
    best_reg = best_reg/norm(best_resp);    
    best_resp = best_resp/norm(best_resp);
    best_step = fminunc(@(step) lossfunc(y,f,best_resp',step), 0, options); 
    
    % multiply regressors by stepsize and update f
    best_reg = best_reg*best_step;
    l.indices(i) = best_feat;
    l.regressors = [l.regressors best_reg];
    for j = 1:n_epochs
        f(j) = f(j) + l.stepsize*[x((best_feat-1)*n_channels+1: ...
                                  best_feat*n_channels,j);1]'*best_reg;
    end
    
    % update probabilities + output
    p = exp(f)./(exp(f)+exp(-f));
    if (l.verboseflag) 
        fprintf('iteration %2.0f, average absolute error %2.2f, feature %4.0f \n', ...
                 i,mean(abs((y-p))), best_feat);
    end
    
end


%% helper function for optimization with fminunc
%% returns value and gradient of the loss function for stepsize s
function [fval,fgrad] = lossfunc(y, f, resp, s)

fval = -sum(2*y.*(f+s*resp)-log(1+exp(2*(f+s*resp))));
fgrad = -sum( 2*y.*resp - ...
             ((2*resp.*exp(2*(f+s*resp)))./(1+exp(2*(f+s*resp))) ));





