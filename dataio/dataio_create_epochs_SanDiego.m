function [] = dataio_create_epochs_SanDiego(epoch_length, filter_band)
%DATAIO_CREATE_EPOCHS_SANDIEGO Summary of this function goes here
%   Detailed explanation goes here
% created 20-03-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

size(eeg) = [Num. of targets, Num. of channels, Num. of sampling points, Num. of trials]
Num. of Targets 	: 12
Num. of Channels 	: 8
Num. of sampling points : 1114
Num. of trials 		: 15
Sampling rate 		: 256 Hz
* The order of the stimulus frequencies in the EEG data: 
[9.25, 11.25, 13.25, 9.75, 11.75, 13.75, 10.25, 12.25, 14.25, 10.75, 12.75, 14.75] Hz
(e.g., eeg(1,:,:,:) and eeg(5,:,:,:) are the EEG data while a subject was gazing at the visual stimuli flickering at 9.25 Hz and 11.75Hz, respectively.)
* The onset of visual stimulation is at 39th sample point.

% Reference:
% Masaki Nakanishi, Yijun Wang, Yu-Te Wang and Tzyy-Ping Jung,
% "A Comparison Study of Canonical Correlation Analysis Based Methods for Detecting Steady-State Visual Evoked Potentials,"
% PLoS One, vol.10, no.10, e140703, 2015.



end

