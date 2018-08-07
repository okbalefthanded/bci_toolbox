function [classMode, nModels, classPart] = ml_get_classMode(nClasses)
%ML_GET_CLASSMODE Summary of this function goes here
%   Detailed explanation goes here
% created : 08-06-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
classPart = 0;
if(nClasses == 2)
    classMode = 'Bin';
    nModels = 1;
else if(nClasses <=3)
        classMode = 'OvA';
        nModels = 3;
    else
        classMode = 'OvO';
        nModels = (nClasses * (nClasses-1)) / 2;
        classPart = nchoosek(1:nClasses, 2);
    end
    
end
end

