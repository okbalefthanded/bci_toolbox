function [] = report_analysis_SSVEP(set, approach, results)
%REPORT_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here
% created 07-09-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

if(~isfield(approach,'features'))
    approach_title = approach.classifier.learner;
else
    approach_title = strcat(approach.features.alg, approach.classifier.learner);
end

current_day_time = fix(clock);
current_day_time = arrayfun(@num2str, current_day_time, 'UniformOutput', 0);
current_day_time = strjoin(current_day_time,'_');

reportFolder = strcat('reports\SSVEP', current_day_time);
mkdir(reportFolder);
reportFileName = strcat(reportFolder,'\',set.title,'_',approach_title,'_',current_day_time);
fid = fopen(reportFileName, 'w');
fprintf(fid,'SSVEP analysis results on dataset:\n\n%s using: %s\n\n', set.title, approach_title);
fprintf(fid, 'Window Length %s seconds\n\n', set.windowLength);
fprintf(fid, 'Subject | Accuracy \n');

for i=1:2
    if (i==1)
        fprintf(fid, 'Results on Training set\n');
    else
        fprintf(fid, 'Results on Test set\n');
    end
    for subj = 1:length(results)
        fprintf(fid, 'S0%d  %f\n', subj, results(i, subj));
    end
    fprintf(fid, 'mean accuracy %f std: %f\n\n', mean(results(i, :)), std(results(i, :)));
end
fclose(fid);
end

