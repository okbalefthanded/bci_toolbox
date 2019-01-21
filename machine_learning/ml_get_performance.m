function [ output ] = ml_get_performance(output)
%ML_GET_PERFORMANCE : returns model's performance [1]
%
% Arguments:
%     In:
%         output : STRUCT [1x1] initial performance measures
%                output.trueClasses: DOUBLE [1xN] [1 epochs_count] true
%                                    target labels.
%                output.y: DOUBLE [1xN] [1 epochs_count] predict labels
%                output.score: DOUBLE [1xN] [1 epochs_count] classifier's
%                               decision function output.
%                output.accuracy: DOUBLE correct classification rate
%                output.subject: STR subject id for the current data.
%                output.alg: STRUCT [1x1]
%                           output.alg.learner : STR classification algorithm
%                           output.alg.regularizer: (optional) STR regularization
%                                                   method for the alg.learner.
%     Returns:
%         output : STRUCT [1x1] add performance metrics as fields:
%                output.confusion: DOUBLE [2x2] confusion matrix.
%                output.sensitivity: DOUBLE classifier's sensitivity.
%                output.specificity: DOUBLE classifier's specificicty.
%                output.fpr: DOUBLE classifier's false positive rate.
%                output.false_detection: DOUBLE classifier's false detection.
%                output. precision: DOUBLE classifier's precision.
%                output.hf_difference: DOUBLE classifier's hf difference.
%                output.kappa: DOUBLE classifier's kappa coefficient.
% Example :
%     call inside ml_applyAAA.m
%     output = ml_get_performance(output);
%
% See Also : ml_applyAAA.m
%
% References :
% [1] M. Billinger et al. chapter 17: is it significant? Guidlines for Reporting BCI
% Performance

% created 11-08-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
num_classes = numel(unique(output.trueClasses));
y_true = output.trueClasses;
y_true(y_true==-1) = 2;
y = output.y;
y(y==-1) = 2;
output.confusion = confusionmat(y_true, y);
% output.confusion = flip(confusionmat(output.trueClasses, output.y));
% output.confusion = confusionmat(output.trueClasses, output.y);
p0 = sum(dot(output.confusion,output.confusion')) / length(output.y)^2;
if(num_classes == 2)
    % binary classes
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
    %     output.f1 = 2*(output.precision * output.sensitivity) / (output.precision + output.sensitivity);
    if(ndims(output.score)> 1)
        sc = output.score(:,1);
    else
        sc = output.score;
    end
    [~,~,~,output.auc] = perfcurve(output.trueClasses', sc, 1);
else
    % multi-class
    acc = output.accuracy / 100;
    output.kappa = (acc - p0)/(1-p0);
end
end

