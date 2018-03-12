function [folds] = ml_crossValidation(cv, setsize)
%ML_CROSSVALIDATION select cross-validation technique and create 
%  train/validation folds splits.                     
% Arguments:
%     In:
%         cv : STRUCT [1x1] cross-validation settings
%            cv.method : STR cross-validation technique to be used from 
%                        the set of available methods.
%            cv.nfolds : DOUBLE number of folds for train/validation split.
%         
%         setsize : DOUBLE number of feature vector examples
%       
%     Returns:
%         folds : indices of feature vectors belonging to folds #
% 
% Example :
%    call inside ml_trainMODEL.m
%    folds = ml_crossValidation(cv, size(features.x, 1));
%     
% See Also : ml_trainClassifier.m 

% created : 10-07-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

switch lower(cv.method)    
    case 'kfold'
        N = floor(setsize / cv.nfolds) + 1;
        folds = bsxfun(@times, repmat(ones(1,N),1,cv.nfolds), ... ,
                        repmat([1:cv.nfolds],1,N));
        folds = sort(folds(1:setsize));
    
    case 'stratifiedkfold'
        % TODO
        % Implement        
    
    case 'shufflesplit'
        % TODO
        % Implement
    
    otherwise
        error('Incorrect Cross Validation method');
end
end

