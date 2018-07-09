function [] = report_analysis_ERP(set, approach, results)
%REPORT_ANALYSIS_ERP Summary of this function goes here
%   Detailed explanation goes here
% created 07-09-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

features_alg = approach.features.alg;
classifier = approach.classifier.learner;
current_day_time = fix(clock);
current_day_time = arrayfun(@num2str, current_day_time, 'UniformOutput', 0);
current_day_time = strjoin(current_day_time,'_');

reportFolder = strcat('reports\ERP\', current_day_time);
mkdir(reportFolder);
reportFileName = strcat(reportFolder,'\',set,'_',features_alg,'_',classifier,'_',current_day_time);
fid = fopen(reportFileName, 'w');
fprintf(fid, 'ERP analysis results on dataset:\n\n%s using: %s %s\n\n', set, features_alg, classifier);
% fprintf(fid, 'Window Length %s seconds\n\n', set);
fprintf(fid, 'Subject | Train Accuracy | Test Accuray | Max correct | N° Trials \n');

for subj = 1:length(results)
    fprintf(fid, 'S0%d  %f  %f  %f  %f \n\n', subj,... 
            results(subj).train_acc, results(subj).test_acc,...
            results(subj).min_subject_sequence(1),... 
            results(subj).min_subject_sequence(2));
end
fprintf(fid, 'mean Train accuracy %f std: %f\n\n', mean([results(:).train_acc]), std([results(:).train_acc]));
fprintf(fid, 'mean Test accuracy %f std: %f\n\n', mean([results(:).test_acc]), std([results(:).test_acc]));
fclose(fid);
end

