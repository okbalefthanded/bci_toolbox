function [ output ] = ml_applyLogitBoost(features, model)
%ML_APPLYLOGITBOOST Summary of this function goes here
%   Detailed explanation goes here

% created 11-06-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% Adapted to the ERP_ClASSIFICATION_BENCHMARK from the original Code

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

nSamples = size(features.x, 1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y';

x = features.x';
model.n_channels
size(model.regressors)
for i = 1:size(x,2)
    f = 0;
    for j = 1:length(model.indices)
        k = model.indices(j);
        x_1 = x((k-1)*model.n_channels + 1:k*model.n_channels, i);
        x_1 = [x_1; 1];
        resp = model.regressors((j-1)*(model.n_channels+1)+1:j*(model.n_channels+1))*x_1;
        f = f + model.stepsize*resp;
        p(j,i) = exp(f) / (exp(f) + exp(-f));
    end    
end

output.score = mean(p, 1);
y1 = output.score > 0.5;
y0 = output.score <=0.5;
output.y(y1) = 1;
output.y(y0) = -1;
% est_y = zeros(size(p));
% est_y(y0) = 0;
% est_y(y1) = 1;
% test_y = features.y';
% test_y(test_y==-1) = 0;
% for j = 1:size(est_y,1)
%     n_correct(j) = length(find(est_y(j,:) == test_y));
% end
% output.n_correct = n_correct;
% p_correct = n_correct / size(est_y,2);
% output.correct = [correct ; p_correct];
nMisClassified = sum(output.trueClasses ~= output.y);
output.accuracy = ((nSamples - nMisClassified)/nSamples) * 100;
% output.confusion = flip(confusionmat(output.trueClasses, output.y));
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

