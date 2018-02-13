function [features] = extractERP_downsample(EEG, opt)
%EXTRACTERP_DOWNSAMPLE downsample EEG signal by a giving factor.[1]
% Arguments:
%     In:
%              EEG : STRUCT [1x1] EEG epoched data
%              EEG.epochs : STRUCT [1x1] EEG epochs
%                         EEG.epochs.signal DOUBLE 4D-matrix [NxMxLxP]
%                          [sample channels epochs trials] of total epochs.
%                         EEG.epochs.events DOUBLE [LxP] [epochs trials]
%                           a matrix of events description.
%                         EEG.epochs.y DOUBLE [LxP] [epochs trials]
%                           a matrix of binary labels.
%              EEG.phrase : STR target phrase.
%              EEG.fs : DOUBLE sampling rate.
%              EEG.montage : STRUCT [1x1]
%                          EEG.montage.clab cell of STR channels labels.
%              EEG.classes : cell {1x2} STR classes descriptions  target,
%                             non_target
%              EEG.paradigm : STRUCT [1x1] experimental protocol.
%                           EEG.paradigm.title STR paradigm description.
%                           EEG.paradigm.stimulation DOUBLE stimulation
%                                       duration in msec
%                           EEG.paradigm.isi DOUBLE ISI in msec.
%                           EEG.paradigm.repetition DOUBLE stimuli
%                             repetition.
%                           EEG.paradigm.stimuli_count DOUBLE number of
%                                       stimuli in paradigm experiement.
%                           EEG.paradigm.type STR
%              EEG.subject :  STRUCT [1x1] subject informations.
%                          EEG.subject.id STR subject id
%                          EEG.subject.gender CHAR male('M') or female('F').
%                          EEG.subject.age DOUBLE subject age
%                          EEG.subject.condition STR health condition.
%         opt : STRUCT [1x1] methods parameters.
%             opt.decimation_factor: DOUBLE factor that the sampling
%             frequency is divided by, select the first sample in a sliding
%             window of the same length as the factor.
%     Returns:
%      features : STRUCT [1x1] feature vector struct
%               features.x : DOUBLE [NxM] [feature_vector_dim epochs_count]
%                     a matrix of feature vectors.
%               features.y : DOUBLE [Mx1] [epochs_count 1] vector
%                   of class labels 1/-1 target/non_target.
%               features.events : DOUBLE | INT16  [Mx1] [epochs_count 1]
%                   a vector of stimuli following each epoch.
%               features.paradigm : STRUCT [1x1] experimental protocol.
%                    same as Input argument EEG.paradigm.
%               features.n_channels : DOUBLE number of electrodes used
%                   in the experiment.
% Example :
%     call inside extractERP_features.m
%     features = extractERP_downsample(EEG, approach.features.options);
% See Also extractERP_features.m
% References :
% [1] D. J. Krusienski, E. W. Sellers, D. J. McFarland, T. M. Vaughan, and
% J. R. Wolpaw, “Toward enhanced P300 speller performance,” J. Neurosci.
% Methods, vol. 167, no. 1, pp. 15–21, 2008.


% created 11-02-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

decimation = opt.decimation_factor;
x = EEG.epochs.signal(1:decimation:end,:,:,:);
[nSamples, nChannels, nEpochs, nTrials] = size(x);
features.x = permute(reshape(x,[nSamples*nChannels nEpochs*nTrials]), [2 1]);
% features.y =  reshape(EEG.epochs.y,[1 nEpochs*nTrials]);
% features.events = reshape(EEG.epochs.events,[1 nEpochs*nTrials]);
features.y =  reshape(EEG.epochs.y,[nEpochs*nTrials 1]);
features.events = reshape(EEG.epochs.events,[nEpochs*nTrials 1]);
features.paradigm = EEG.paradigm;
features.n_channels = nChannels;
end

