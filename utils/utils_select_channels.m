function [EEG] = utils_select_channels(EEG,channelset)
%SELECT_CHANNELS Summary of this function goes here
%   Detailed explanation goes here

% created 08/09/2016
% last revised -- -- --
channels_count = length(channelset);
ch_idx = zeros(1,channels_count);
% EEG
for ch = 1:channels_count
    
    ch_idx(1,ch) = find(strcmpi(EEG.montage.clab,channelset{ch}));
    
end
% ch_idx
EEG.epochs = EEG.epochs(:,ch_idx,:);
EEG.montage.clab = channelset;

end

