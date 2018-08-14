function [pids] = launchWorkers(max_instances, debugMode)
%LAUNCHWORKERS Summary of this function goes here
%   Detailed explanation goes here
% created 06-20-2018
% last modification 07-30-2018
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
matlabPath = ['"' findMatlabPath '"'];
opts = ' -nodisplay -nosplash -nodesktop -noawt -r';
scriptToRun =  [' run(''startSlave(',sprintf('%d',debugMode),')'');" '];
cmdToRun = [matlabPath, opts, scriptToRun];
for i = 1:(max_instances)
    jsystem(cmdToRun, 'noshell');
end
pids = getWorkersPids();
end

