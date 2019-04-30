function [] = SSVEP_spectrum_analysis_average(set, subj)
%SSVEP_SPETRUM_ANALYSIS_AVERAGE Summary of this function goes here
%   Detailed explanation goes here
% created 11-18-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% nSubj = utils_fetch_Set_Folder(set);
% for subj = 1:nSubj
set.subj = subj;
trainEEG = dataio_read_SSVEP(set,'train');
disp(['Analyising data from subject:' ' ' trainEEG.subject.id]);
[samples, channels, trials] = size(trainEEG.epochs.signal);
nyquist = trainEEG.fs / 2;
frequencies = linspace(0, nyquist, floor(samples/2)+1);
fq_count = trainEEG.paradigm.stimuli_count;
trials_per_class = round(trials / fq_count);

fourierCoefs = cell(1, fq_count);
epo = trainEEG.epochs.signal;
poz = find(strcmp(trainEEG.montage.clab,'POz'));
% power = zeros(length(frequencies), trials);
power = zeros(length(frequencies), trials_per_class);
for frq = 1:fq_count
    epo_frq = squeeze(epo(:,poz,trainEEG.epochs.y == frq));
    %     trials_per_class = round(sum(trainEEG.epochs.y == frq) / fq_count);
    trials_per_class = sum(trainEEG.epochs.y == frq) ;
    %     for chidx = 1:channels
    for tr = 1:trials_per_class
        f = fft(epo_frq(:,tr)) / samples;
        f = 2*abs(f);
        f = f(1:length(frequencies));
        power(:, tr) = f;
    end
    %     end
    %     fourierCoefs{frq} = mean(power, 3);
    fourierCoefs{frq} = mean(power, 2);
end

for fq = 1: fq_count
    %     event = cell2mat(trainEEG.classes(fq));
    event = trainEEG.paradigm.stimuli(fq);
    if (iscell(event))
        event = str2double(event);
    end
    if(strcmp(event,'idle'))
        ff = zeros(1,3);
    else
        %         event = str2double(event);
        ff = [event, 2*event, 3*event];
    end
    f_idx = frequencies == ff(1) | frequencies == ff(2) | frequencies == ff(3);
    %     for chidx = 1:channels
    %         figure(fq), subplot(round(sqrt(channels)), ceil(sqrt(channels)), poz),
    figure(fq),
    %         plot(frequencies, fourierCoefs{fq}(:, poz)),
    plot(frequencies, fourierCoefs{fq}),
    hold on
    plot(frequencies(f_idx), fourierCoefs{fq}(f_idx),'ro', 'MarkerSize', 10)
    xlim([0 50]);
    xlabel('Frequnecy [HZ]');
    ylabel('Power Spectrum');
    %     title(['Frequency: ', num2str(ff(1)), ' ', trainEEG.montage.clab{chidx}]);
    title(['Frequency: ', num2str(ff(1)), ' ', trainEEG.montage.clab{poz}]);
    
    %     end
end
% end
end

