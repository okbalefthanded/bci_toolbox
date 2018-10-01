function [] = plot_roc_curve(output)
%PLOT_ROC_CURVE Summary of this function goes here
%   Detailed explanation goes here
% date created 09-26-2016
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

pred = output.score;
y = output.trueClasses';
classifier = output.alg.learner;
[X,Y] = perfcurve(y,pred,1);
n = length(Y);
random_guess = linspace(0,1,n);
figure,
plot(random_guess, random_guess, 'r--');hold on,
plot(X,Y)
xlabel('False positive rate'); ylabel('True positive rate')
title(['ROC for classification by ',classifier,' AUC = ',num2str(output.auc)])
end

