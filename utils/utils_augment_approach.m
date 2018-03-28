function [approach] = utils_augment_approach(approach, astruct)
%UTILS_AUGMENT_APPROACH Summary of this function goes here
%   Detailed explanation goes here
% add fields to approach (any estimated values at features extraction)
% created 03-27-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if(isempty(astruct))
    return;
else
    fields = fieldnames(astruct);
    for f = 1:numel(fields)
        approach.features.options.(fields{f}) = astruct.(fields{f});
    end
end
end

