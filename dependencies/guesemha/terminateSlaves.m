function  terminateSlaves
% Close slaves processes by PID
% date created 06-14-2018
% last modified -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
pids = getWorkersPids();
for proc = 1:length(pids)
    jsystem(['taskkill -f -PID ' pids{proc}]);
end
end

