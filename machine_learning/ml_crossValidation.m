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
N = floor(setsize / cv.nfolds) + 1;
switch lower(cv.method)
    case 'kfold'
        folds = bsxfun(@times, repmat(ones(1,N),1,cv.nfolds), ... ,
                               repmat([1:cv.nfolds],1,N));
        folds = sort(folds(1:setsize));
        
    case 'stratifiedkfold'
        Classes = unique(cv.y);
        nClasses = length(Classes);
        syIdx = bsxfun(@eq, cv.y, Classes');
        nSamplesCl = sum(syIdx, 2);
        folds = zeros(1, setsize);        
        for j=1:nClasses
            split = round(nSamplesCl / nClasses);
            off = mod(nSamplesCl, cv.nfolds);
            [~, idx] = sort(syIdx(j,:), 'descend');
            k = 1;
            offset = 0;
            for f = 1:cv.nfolds                
                if(f > off)
                    offset = 1;
                end
                folds(idx(k:k+1))= f;
                k = k+split-offset;
            end
        end
%         folds = folds(1:setsize);        
    case 'shufflesplit'
        % TODO
        % Implement
    case 'leave1out'
        % TODO
        % Implement
%         folds = ;
        
    otherwise
        error('Incorrect Cross Validation method');
end
end

