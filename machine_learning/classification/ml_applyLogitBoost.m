function [output] = ml_applyLogitBoost(features, model)
%ML_APPLYLOGITBOOST apply logitBoost model for prediction [1]
% % Adapted to this toolbox format from the original Code [1]
% 
% Arguments:
%         features : STRUCT [1x1] feature vector struct
%                 features.x : DOUBLE [NxM] [feature_vector_dim epochs_count]
%                     a matrix of feature vectors.
%                 features.y : DOUBLE [Mx1] [epochs_count 1] vector
%                   of class labels 1/-1 target/non_target.
%                 features.events : DOUBLE | INT16  [Mx1] [epochs_count 1]
%                   a vector of stimuli following each epoch.
%                 features.paradigm : STRUCT [1x1] experimental protocol.
%                    same as Input argument EEG.paradigm.
%                 features.n_channels : DOUBLE number of electrodes used
%                   in the experiment
%         
%      model : STRUCT [1x1] trained LogistBoost classifier 
%     Returns:
%     output : STRUCT 1x1 classification results/performance
%                output.accuracy: DOUBLE correct classification rate
%                output.y: DOUBLE [1xN] [1 epochs_count] classifier
%                           binary classes output.
%                output.score: DOUBLE [1xN] [1 epochs_count] classifier's
%                               decision function output.
%                output.trueClasses: DOUBLE [1xN] [1 epochs_count] true
%                                    target labels.
%                output.confusion: DOUBLE [2x2] confusion matrix.
%                output.sensitivity: DOUBLE classifier's sensitivity.
%                output.specificity: DOUBLE classifier's specificicty.
%                output.fpr: DOUBLE classifier's false positive rate.
%                output.false_detection: DOUBLE classifier's false detection.
%                output. precision: DOUBLE classifier's precision.
%                output.hf_difference: DOUBLE classifier's hf difference.
%                output.kappa: DOUBLE classifier's kappa coefficient.
%                output.subject: STR subject id for the current data.
%                output.alg: STRUCT [1x1]
%                           output.alg.learner : STR classification algorithm
%                           output.alg.regularizer: (optional) STR regularization
%                                                   method for the alg.learner.
%                output.events: DOUBLE | INT16 [Nx1] [epochs_count 1]
%   
% Example :
%     FUNCTIONALITY_TASK_OBJECT_TYPE(ARG_IN1, ARG_IN2)
%     
% Dependencies : 
%   LogitBoost Code [1],folder: machine_learning/classification/@LogitBoost
% See Also : ml_trainLogitBoost.m, ml_trainClassifier.m,
% ml_applyClassifier.m
% References :
% [1] U. Hoffmann, G. Garcia, J. M. Vesin, K. Diserenst, and T. Ebrahimi, 
% “A boosting approach to P300 detection with application to 
% brain-computer interfaces,” 2nd Int. IEEE EMBS Conf. Neural Eng., 
% vol. 2005, pp. 97–100, 2005.

% created 11-06-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% Original code documentation :
% classify is used to classify feature vectors
% INPUT
%   l: An initialized LogitBoost object
%   x: Matrix of feature vectors, columns are feature vectors, number of
%      columns equals number of feature vectors. See xx for format of
%      feature vectors.
%
% OUTPUT
%   p: Matrix containing probabilities p(y=1|x), values at column j
%      correspond to feature vector at column j in x. Values at row i
%      correspond to result after evaluating i weak classifiers
%      (timepoints)
%
% Author: Ulrich Hoffmann - EPFL, 2005
% Copyright: Ulrich Hoffmann - EPFL

nSamples = size(features.x, 1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y;

x = features.x';
for i = 1:size(x,2)
    f = 0;
    for j = 1:length(model.indices)
        k = model.indices(j);
        x_1 = x((k-1)*model.n_channels + 1:k*model.n_channels, i);
        x_1 = [x_1; 1];
        resp = model.regressors((j-1)*(model.n_channels+1)+1:j*(model.n_channels+1))*x_1;
        f = f + model.stepsize*resp;
        p(j,i) = exp(f) / (exp(f) + exp(-f));
    end    
end

output.score = mean(p, 1);
y1 = output.score > 0.5;
y0 = output.score <=0.5;
output.y(y1) = 1;
output.y(y0) = -1;
output.y = output.y';
% est_y = zeros(size(p));
% est_y(y0) = 0;
% est_y(y1) = 1;
% test_y = features.y';
% test_y(test_y==-1) = 0;
% for j = 1:size(est_y,1)
%     n_correct(j) = length(find(est_y(j,:) == test_y));
% end
% output.n_correct = n_correct;
% p_correct = n_correct / size(est_y,2);
% output.correct = [correct ; p_correct];
nMisClassified = sum(output.trueClasses ~= output.y);
output.accuracy = ((nSamples - nMisClassified)/nSamples) * 100;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

