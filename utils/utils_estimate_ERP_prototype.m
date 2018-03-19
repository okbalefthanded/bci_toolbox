function [P] = utils_estimate_ERP_prototype(x, y)
%UTILS_ESTIMATE_ERP_PROTOTYPE Summary of this function goes here
%   Detailed explanation goes here

% created 01-02-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% [nChannels, nSamples, nEpochs, nTrials] = size(x);
% P = zeros(nChannels, nSamples,nTrials);
% P = zeros(nChannels, nSamples);
% for trial = 1:nTrials
%     P = mean(x(:,:,y==1), 3);
% end
P = mean(x(:,:,y==1), 3);
end

