function [epochs] = dataio_baselineCorrection(epochs, correctionInterval)
%DATAIO_BASELINECORRECTION Summary of this function goes here
%   Detailed explanation goes here
% created : 08-13-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
correctionInterval = round(correctionInterval);
idx = [0:diff(correctionInterval)] +1;
baseline = mean(epochs(idx,:,:), 1);
epochs = bsxfun(@minus, epochs, baseline);
epochs = epochs(idx(end)+1:end,:,:);
end

