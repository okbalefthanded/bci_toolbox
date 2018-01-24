function [model] = ml_trainMDM(features, alg)
%ML_TRAINMDM Summary of this function goes here
%   Detailed explanation goes here

% created 01-02-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% Estimate Geometric Mean for each class
labels = unique(features.y);
Nclass = length(labels);
C = cell(Nclass,1);

% estimation of center
for i=1:Nclass
    C{i} = mean_covariances(features.x(:,:,features.y==labels(i)), alg.mean);
end
model.classifier = C;
model.alg.learner = 'MDM';
model.alg.dist = alg.dist;
end

