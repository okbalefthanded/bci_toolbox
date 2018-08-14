function [nWorkers, paramsplit, offset] = getRessources(settings, searchSpace)
%GETRESSOURCES Summary of this function goes here
%   Detailed explanation goes here
% created 07-29-2018
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
nWorkers = settings.nWorkers + settings.isWorker;
offset = 0;
if(searchSpace <= nWorkers)
    nWorkers = searchSpace;
    paramsplit = 1;
else if(mod(searchSpace, nWorkers)==0)
        paramsplit = searchSpace / nWorkers;
    else
        paramsplit = floor(searchSpace / nWorkers);
        offset = mod(searchSpace, nWorkers);
    end
end
end

