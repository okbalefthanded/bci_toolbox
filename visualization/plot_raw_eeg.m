function [] = plot_raw_eeg(eeg, duration, onset)
%PLOT_RAW_EEG plot continuous EEG in a specified duration starting from
% onest
% intput :
%     - eeg : 
%       raw LARESI eeg format.
%     - duration :
%       duration in seconds
%     - onset :
%       starting marker, in samples
% output :
% created 06-20-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
time = 0:1/eeg.fs:duration;
[~, channels] = size(eeg.signal);
sig = bsxfun(@plus, eeg.signal(onset:onset+length(time)-1,:), 40*[channels:-1:1]);
baseline = bsxfun(@plus, zeros(channels,length(time))', 40*[channels:-1:1]);
%
plot(time,sig,'Color','b');
hold on,
plot(time, baseline,'k--')
set(gca,'ytick', flip(baseline(1,:)),'yticklabel', flip(eeg.montage));
xlabel('Time [seconds]')
end

