function [eeg_epochs] = dataio_getERPEpochs(wnd, pos, signal)
%DATAIO_GETERPEPOCHS : returns epoches of filtered continuos signal 
%% needs a rename   
%                            
% Arguments:
%     In:
%         wnd : DOUBLE [1x2] [start end] epoch window in samples. 
%         
%         pos : DOUBLE [1xM] [event_onset_marker] a vector of events onset
%               markers.
%       
%         signal : DOUBLE [NxM] [samples channels] filtered EEG data
%     Returns:
%         eeg_epochs : DOUBLE [NxMxL] [samples channels trials] 3D-matrix
%                       of EEG epochs
% 
% Example :
%   call inside a dataio function dataio_create_DATASETX
%    wnd = (epoch_length * data.fs) / 10^3; 
%    pos = events.pos;
%    signal = eeg_filter(data.signal, data.fs, filter_band(1), ...,
%                       filter_band(2), filter_order);
%    eeg_epochs = dataio_getERPEpochs(wnd, pos, signal)
%     

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

