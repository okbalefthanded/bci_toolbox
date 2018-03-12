function [output] = ml_applyDA(features, model)
%ML_APPLYDA apply (linear) discriminant analysis [1]
%                            
% Arguments:
%     In:
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
%      model : STRUCT [1x1] trained classifier (linear) discriminant
%      analysis classifier 
%            model.lambda (optional) : DOUBLE [1x2] regularization
%            parameter for each class.
%            model.alg : STRUCT [1x1]
%                      model.alg.learner : STR discriminant analysis type
%                      (LDA, Shrinkage LDA (RLDA), SWLDA)
%                      model.alg.regularizer (optional): regularization
%                      paramater estimator.  
%            model.w : DOUBLE [Nx1] [feature_vector_dimension 1] classifier
%            weights.
%            model.b : DOUBLE classifier bias.
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
%     call inside run_analysis_ERP.m
%     output = ml_applyClassifier(test_features, model);
%     
% See Also : ml_trainLDA.m, ml_trainRLDA.m, ml_trainSWLDA,
% ml_trainClassifier.m, ml_applyClassifier.m
% References :
% [1] B. Blankertz, S. Lemm, M. Treder, S. Haufe, and K. R. Müller, 
% “Single-trial analysis and classification of ERP components -
%  A tutorial,” Neuroimage, vol. 56, no. 2, pp. 814–825, 2011.

% created 05-12-2016
% last modification 14-02-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>


nSamples = size(features.x,1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
output.score = zeros(1,nSamples);
output.trueClasses = features.y';
classes_output = unique(output.trueClasses);

for smp=1:nSamples  
    output.score(smp) = model.w'*features.x(smp,:)' + model.b;
    if (output.score(smp) >= 0)
        output.y(smp) = classes_output(2);
    else
        output.y(smp) = classes_output(1);
    end
end
nMisClassified = sum(output.trueClasses ~= output.y);
output.accuracy = ((nSamples - nMisClassified)/nSamples) *100;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

