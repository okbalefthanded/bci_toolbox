function [output] = ml_applyMDM(features, model)
%ML_APPLYMDM Summary of this function goes here
%   Detailed explanation goes here

% created 01-02-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

nTrials = size(features.x, 3);
output.accuracy = 0;
output.y = zeros(1,nTrials);
output.score = zeros(1,nTrials);
output.trueClasses = features.y';
labels = unique(features.y);
nClass = length(labels);

% classification
% NTesttrial = size(features.x, 3);

d = zeros(nTrials, nClass);
for j=1:nTrials
    for i=1:nClass
        d(j,i) = distance(features.x(:,:,j),model.classifier{i}, model.alg.dist);
    end
end
score = d(:,1) - d(:,2);
[~,ix] = min(d,[],2);
y = labels(ix);
output.y = y';
output.score = score;
nMisClassified = sum(output.trueClasses ~= output.y);
output.accuracy = ((nTrials - nMisClassified)/nTrials) *100;
output.confusion = flip(confusionmat(output.trueClasses, output.y));
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

