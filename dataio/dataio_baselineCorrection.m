function [epochs] = dataio_baselineCorrection(epochs, correctionInterval)
%DATAIO_BASELINECORRECTION substract the average signal amplitude
%       prior to a stimulus. the window length for the signal average 
%       is required.
% 
% Arguments :
%   In :
%       epochs : DOUBLE [NxMxL] [samples channels trials] 3D-matrix
%                       of EEG epochs
%       correctionInterval : DOUBLE [1 2] signal length prior to stimulus
%   returns :
%      epochs : DOUBLE [NxMxL] [samples channels trials] 3D-matrix
%                       of EEG epochs
%
% created : 08-13-2018
% last modified : 02-10-2019
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
correctionInterval = round(correctionInterval);
idx = [0:diff(correctionInterval)] +1;
baseline = mean(epochs(idx,:,:), 1);
epochs = bsxfun(@minus, epochs, baseline);
epochs = epochs(idx(end)+1:end,:,:);
end

