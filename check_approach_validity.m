function [approach] = check_approach_validity(set, approach)
%CHECK_APPROACH_VALIDITY Summary of this function goes here
%   Detailed explanation goes here
% created : 01-25-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
%%
datasets = {'LARESI_FACE_SPELLER_150', 'LARESI_FACE_SPELLER_120',...
    'III_CH', 'EPFL_IMAGE_SPELLER', 'P300_ALS'};
normalizations = {'ZSCORE', 'MIN_MAX', 'L1NORM'};
features = {'DOWNSAMPLE'};
privileged_features = {'DOWNSAMPLE'};
classifiers = {'LDA', 'RLDA', 'SWLDA', 'LR', 'SVM', 'GBOOST',...
    'RF', 'SVM+'};
cross_validation = {'KFOLD'};
%% Check Dataset
assert( utils_check_field_validity(datasets, set), 'Incorrect Data set');

%% Feature extraction
if(isfield(approach,'features'))
    assert( utils_check_field_validity(approach.features.alg, features),...
        'Incorrect Features extraction method');
else
    error('No Feature extraction method was specified');
end

%% Privileged information
if(isfield(approach, 'privileged'))
    assert( utils_check_field_validity(approach.privileged.features.alg, privileged_features),...
        'Incorrect Features extraction method');
end

%% classifiers
if(isfield(approach,'classifier'))
    if(isfield(approach.classifier, 'normalization'))
        assert(...
        utils_check_field_validity(approach.classifier.normalization, normalizations),...
            'Incorrect norm');
    end
    assert(utils_check_field_validity(approach.classifier.learner, classifiers),...
        'Incorrect classifiers');
else
    error('No Classifier was specified');
end
%% cross_validation
if(isfield(approach,'cv'))
    assert(utils_check_field_validity(approach.cv.method, cross_validation),...
        'Incorrect Cross validation method');
else
    approach.cv.method = 'KFOLD';
    approach.cv.nfolds = 0;
end


end

