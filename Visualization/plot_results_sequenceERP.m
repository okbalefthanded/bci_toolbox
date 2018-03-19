function [] = plot_results_sequenceERP(results, set, paradigm, subject)
%PLOT_RESULTS_SEQUENCEERP Summary of this function goes here
%   Detailed explanation goes here


% created 11-05-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% paradigm
%
%             title: 'P300_ALS'
%       stimulation: 125
%               isi: 125
%        repetition: 10
%     stimuli_count: 12
%              type: 'RC'

%
% results =
%
%      phrase: [10x20 char]
%     correct: [10x1 double]
%
% set =
%
% P300_ALS

figure, plot(results.correct),
xlabel('Number of sequences'),
ylabel('Characters Detection Rate'),
title(['Performance curve in set ' set ' for subject ' subject]),
legend('correct detection');
ylim([0 100])


end

