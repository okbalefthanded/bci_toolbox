function [features] = utils_get_split(features, idx)
%UTILS_GET_SPLIT Summary of this function goes here
%   Detailed explanation goes here

% created : 11-09-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

features.x = features.x(idx, :);
features.y = features.y(idx);
features.events = features.events(idx);
if (isfield(features, 'privileged'))
    features.privileged = features.privileged(idx,:);
end
end

