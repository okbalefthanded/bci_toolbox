function [ output ] = ml_get_performance(output)
%ML_GET_PERFORMANCE Summary of this function goes here
%   Detailed explanation goes here

% created 11-08-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

% [1] M. Billinger et al. chapter 17: is it significant? Guidlines for Reporting BCI
% Performance


output.confusion = flip(confusionmat(output.trueClasses, output.y));

p0 = sum(dot(output.confusion,output.confusion')) / length(output.y)^2;
tp = output.confusion(1,1);
fn = output.confusion(1,2);
fp = output.confusion(2,1);
tn = output.confusion(2,2);

output.sensitivity = tp / (tp + fn); % TPR, recall, H
output.specificity = tn / (tn + fp); %
output.fpr = 1 - output.specificity; % FPR
output.false_detection = fp / (tp + fp); % False detection rate, F
output.precision = 1 - output.false_detection; % PPV (positive predictive value)
output.hf_difference = output.sensitivity - output.false_detection; % H-F
acc = output.accuracy / 100;
output.kappa = (acc - p0)/(1-p0);
% output.f1 = 2*(output.precision * output.sensitivity) / (output.precision + output.sensitivity);
end

