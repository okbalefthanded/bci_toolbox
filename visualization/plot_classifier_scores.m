function [] = plot_classifier_scores(output)
%PLOT_CLASSIFIER_SCORES Summary of this function goes here
%   Detailed explanation goes here
% date created 10-02-2016
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
colors = ['y', 'm', 'c', 'r', 'g', 'b', 'k'];
y = output.trueClasses;
classes = unique(y);
nClasses = length(classes);
classifier = output.alg.learner;
x = 1:length(y);
figure,
for c = 1:nClasses    
    id = y==classes(c); 
    bar(x(id), output.score(id), colors(c));
    hold on
end
xlabel('Trials'); ylabel('Classifier Score')
title(['Scores for classification by ',classifier])
end

