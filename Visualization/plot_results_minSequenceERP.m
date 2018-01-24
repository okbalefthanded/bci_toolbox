function [] = plot_results_minSequenceERP(min_seq, set)
%PLOT_RESULTS_MINSEQUENCEERP Summary of this function goes here
%   Detailed explanation goes here

% date created 11-14-2017
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
figure,bar(min_seq'),
xlabel('Subjects'),
ylabel('Minimum Sequence to reach Max Recognition rate'),
title(['Minimum Sequence to max rate in Set: ' set]),
legend({'minimum sequence', 'detection rate'});
end

