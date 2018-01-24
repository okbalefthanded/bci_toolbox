function [eeg_epochs] = dataio_getERPEpochs(wnd, pos, signal)
%DATAIO_GETEPOCHS Summary of this function goes here
%   Detailed explanation goes here

% created : 10-29-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if(size(pos, 2)== 1)
    pos = pos';
end

channels = size(signal, 2);
dur = [0:diff(wnd)]'*ones(1, length(pos));
tDur = size(dur,1);

epoch_idx = bsxfun(@plus, dur, pos);
eeg_epochs = reshape(signal(epoch_idx, :),[tDur length(pos) channels]);
eeg_epochs = permute(eeg_epochs, [1 3 2]);
end

