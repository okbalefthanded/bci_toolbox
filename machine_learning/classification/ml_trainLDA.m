function [model] = ml_trainLDA(features, cv)
%TRAINLDA Summary of this function goes here
%   Detailed explanation goes here
warning('Deprecated function');
% created 12/05/2016

% if (nargin <2)
% sFold = cv(1);
% cvindices = crossvalind('Kfold',features(:,end),cv(2));
%
% for  cvind =1:sFold
%     non_selected = (cvindices == cvind);
%     selected = ~non_selected;

classes = unique(features.y);
class1Data = features.x(features.y==classes(1),:);
class2Data = features.x(features.y==classes(2),:);
    %mean vector estimation for each class
    mu1 = mean(class1Data);
    mu2 = mean(class2Data);

    %covariance matrix estimation
    sigma1 = cov(class1Data);
    sigma2 = cov(class2Data);
    sigma = (sigma1 + sigma2)/2;

    %computing the discriminant hyperplane coefficients
    sigmaInv = inv(sigma);
    model.b = - (1/2) * (mu1 + mu2) * sigmaInv * (mu1 - mu2)';
    model.w = sigmaInv * (mu1 - mu2)';

model.alg = 'LDA';

end
