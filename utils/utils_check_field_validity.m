function [validity] = utils_check_field_validity(field, value)
%UTILS_CHECK_FIELD_VALIDITY Summary of this function goes here
%   Detailed explanation goes here
% created : 01-25-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
validity = logical(sum(strcmp(field, value)));
end

