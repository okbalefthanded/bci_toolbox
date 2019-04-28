function [] = utils_get_time(t)
%UTILS_GET_TIME return time elapsed for an operation in real time units
% input : t
%           elapsed time from stopwatch (toc)
% returns:
%
% created : 28-04-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
if(t <60)
    disp(['Time elapsed for computing: ' num2str(t) ' seconds']);
else if(t <= 3600)
        t = t/60;
        disp(['Time elapsed for computing: ' num2str(t) ' minutes']);        
    else
        t = t/3600;
        disp(['Time elapsed for computing: ' num2str(t) ' hours']);
    end
end

