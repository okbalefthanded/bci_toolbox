function [features] = extractFeatures(EEGdata,filters,nof)
%EXTRACTFILTERS Summary of this function goes here
%   Detailed explanation goes here

% created 12/05/2016
% last modfied 26/05/2016   
[~,~,nTrials] = size(EEGdata.epochs);
features = zeros(nTrials,nof*2);

% if (strcmp(filters.alg,'CSP_g'))
    
    filters.filters = filters.filters(:,[1:nof end-nof+1:end]);
% else
%     filters.filters = filters.filters([1:nof end-nof+1:end],:);
% end
% for f=1:length(features)
for f=1:nTrials    
    z = var(EEGdata.epochs(:,:,f)*filters.filters);
    features(f,:) = log(z);
end
% features = [features EEGdata.labels'];
features.x = features;
features.y = EEGdata.labels';
end

