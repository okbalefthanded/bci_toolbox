function [folds] = ml_crossValidation(cv, setsize)
%ML_CROSSVALIDATION Summary of this function goes here
%   Detailed explanation goes here

% created : 10-07-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

switch lower(cv.method)
    
    case 'kfold'
        N = floor(setsize / cv.nfolds) + 1;
        folds = bsxfun(@times, repmat(ones(1,N),1,cv.nfolds), repmat([1:cv.nfolds],1,N));
        folds = sort(folds(1:setsize));
    
    case 'stratifiedkfold'
        %         TODO
    
    case 'shufflesplit'
        %         TODO
    
    otherwise
        error('Incorrect Cross Validation method');
end

end

