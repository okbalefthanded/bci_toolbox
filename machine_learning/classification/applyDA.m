function [results] = applyDA(features, model)
%APPLYDA Summary of this function goes here
%   Detailed explanation goes here


% created 12/05/2016
% last modfied -- -- --
% 
% if(strcmp(model.alg,'SWLDA'))
%     features.x = features.x(:, model.inmodel);
% end
% features = test_features;

nSamples = size(features.x,1);
results.accuracy = 0;
results.y = zeros(1,nSamples);
results.score = zeros(1,nSamples);
results.trueClasses = features.y';
output = unique(results.trueClasses);

%
% size(model.w')
% size(model.b')
% size(features(1,1:end-1)')

for smp=1:nSamples
    %     size( model.w'*features(smp,1:end-1)' + model.b)
    results.score(smp) = model.w'*features.x(smp,:)' + model.b;
    if (results.score(smp) >= 0)
        results.y(smp) = output(2);
    else
        results.y(smp) = output(1);
    end
end
nMisClassified = sum(results.trueClasses ~= results.y);
results.accuracy = ((nSamples - nMisClassified)/nSamples) *100;
% results.confusion =  flip(confusionmat(results.trueClasses, results.y));
results = ml_get_performance(results);
results.subject = '';
results.alg = model.alg;
end

