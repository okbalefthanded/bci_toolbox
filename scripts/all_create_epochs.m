% 07-11-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% Create epochs for all datasets available
tic
%% ERP
epoch_length = [0 800]; filter_band = [1 10];
dataio_create_epochs_SM_ALS(epoch_length, filter_band);
dataio_create_epochs_SM_EPFL(epoch_length, filter_band);
dataio_create_epochs_SM_III_CH(epoch_length, filter_band);
dataio_create_epochs_SM_LARESI(epoch_length, filter_band);
%% SSVEP
epoch_length = [0 4000]; filter_band = [5 50];
dataio_create_epochs_SM_Exoskeleton(epoch_length, filter_band);
dataio_create_epochs_SM_SanDiego(epoch_length, filter_band);
dataio_create_epochs_SM_Tsinghua(epoch_length, filter_band);
toc