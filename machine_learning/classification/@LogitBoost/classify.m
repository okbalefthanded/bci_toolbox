function p = classify(l, x)
% -------------------------------------------------------------------------
% classify is used to classify feature vectors 
%
% INPUT 
%   l: An initialized LogitBoost object
%   x: Matrix of feature vectors, columns are feature vectors, number of 
%      columns equals number of feature vectors. See xx for format of 
%      feature vectors.
%
% OUTPUT
%   p: Matrix containing probabilities p(y=1|x), values at column j
%      correspond to feature vector at column j in x. Values at row i
%      correspond to result after evaluating i weak classifiers
%      (timepoints)
%
% Author: Ulrich Hoffmann - EPFL, 2005
% Copyright: Ulrich Hoffmann - EPFL
% -------------------------------------------------------------------------

for i = 1:size(x,2)
    f = 0;
    for j = 1:length(l.indices)
        k = l.indices(j);
        x_1 = x((k-1)*l.n_channels + 1:k*l.n_channels,i);
        x_1 = [x_1; 1];
        resp = l.regressors((j-1)*(l.n_channels+1)+1: ...
                                 j*(l.n_channels+1))*x_1;
        f = f + l.stepsize*resp; 
        p(j,i) = exp(f) / (exp(f) + exp(-f));
    end
end
