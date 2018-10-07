function [output] = ml_applyBLDA(features, model)
%ML_APPLYBLDA Summary of this function goes here
%   Detailed explanation goes here
% created 10-07-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% Adapted to the ERP_ClASSIFICATION_BENCHMARK from the original Code
%%
% prediction procedure for bayeslda
% INPUT:
%    b          - object of type bayeslda
%    x          - m*n matrix containing n feature vectors of size m*1
%
% OUTPUT:
%    varargout  - if classify is called with one output argument an array
%                 containing the mean value of the predictive distribution 
%                 for each example in x is returned 
%               - if classify is called with two output arguments the 
%                 mean value and the variance of the predictive
%                 distribution are returned
%
% Author: Ulrich Hoffmann - EPFL, 2006
% Copyright: Ulrich Hoffmann - EPFL
%
% The algorithm implemented here was originally described by 
% MacKay, D. J. C., 1992. Bayesian interpolation.
% Neural Computation 4 (3), pp. 415-447.

nSamples = size(features.x,1);
output.accuracy = 0;
output.y = zeros(1,nSamples);
% output.score = zeros(1,nSamples);
output.trueClasses = features.y';
% classes_output = unique(output.trueClasses);
%% add feature that is constantly one (bias term)
x = features.x';
x = [x; ones(1,size(x,2))];    


%% compute mean of predictive distributions
output.score = model.w'*x;
% nMisClassified = sum(output.trueClasses ~= output.y);
% output.accuracy = ((nSamples - nMisClassified)/nSamples) *100;
% output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;

%% if one output argument return mean only
% if nargout == 1
%     varargout(1) = {m};    
% end
%% if two output arguments compute and return variance also
% if nargout == 2
%     s = zeros(1,size(x,2));
%     for i = 1:size(x,2);
%         s(i) = features.x(:,i)'*model.p*x(:,i) + (1/model.beta);
%     end
%     varargout(1) = {m};
%     varargout(2) = {s};
% end
% 
% if nargout > 2
%     fprintf('Too many output arguments!\n');
% end
end

