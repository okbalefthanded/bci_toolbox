function l = LogitBoost(n_steps, stepsize, verboseflag)
% -------------------------------------------------------------------------
% constructor of class LogitBoost
%
% INPUT 
%   n_steps:     number of boosting iterations for training
%   stepsize:    stepsize in boosting algorithm
%   verboseflag: debugging output is enabled if this flag is 1
%
% OUTPUT
%   l:           initialized LogitBoost object 
%
% Author: Ulrich Hoffmann - EPFL, 2005
% Copyright: Ulrich Hoffmann - EPFL
% -------------------------------------------------------------------------

%% set parameters 
l.n_steps = n_steps;                 % number of boosting iterations
l.stepsize = stepsize;               % size of boosting steps (shrinkage) 
l.verboseflag = verboseflag;         % gives verbose output if set to 1

%% define other attributes of object
l.regressors = [];                   % weights for the classifier
l.n_channels = 0;                    % number of electrodes used
l.indices = [];                      % indices of selected features
l.n_features = 0;                    % number of features 

%% initialize class
l = class(l,'LogitBoost');