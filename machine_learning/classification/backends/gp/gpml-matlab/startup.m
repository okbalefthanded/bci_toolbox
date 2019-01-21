% startup script to make Octave/Matlab aware of the GPML package
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch 2018-08-01.

disp ('executing gpml startup script...')
mydir = fileparts (mfilename ('fullpath'));        % where am I located
addpath (mydir);

% core folders
dirs = {'cov','doc','inf','lik','mean','prior','util'};
for d = dirs
  addpath (fullfile (mydir, d{1}))
end

% minfunc folders
dirs = {{'util','minfunc'},{'util','minfunc','compiled'}};
for d = dirs
  addpath (fullfile (mydir, d{1}{:}))
end

addpath([mydir,'/util/sparseinv'])
