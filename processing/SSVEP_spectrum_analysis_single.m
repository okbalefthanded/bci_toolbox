function [] = SSVEP_spectrum_analysis_single(set)
%SSVEP_ Summary of this function goes here
%   Detailed explanation goes here
% created 11-15-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
nSubj = utils_fetch_Set_Folder(set);
for subj = 1:nSubj
    set.subj = subj;
    trainEEG = dataio_read_SSVEP(set,'train');
    disp(['Analyising data from subject:' ' ' trainEEG.subject.id]);
    [samples, channels, trials] = size(trainEEG.epochs.signal);
    nyquist = trainEEG.fs / 2;
    frequencies = linspace(0, nyquist, floor(samples/2)+1);
    fq_count = trainEEG.paradigm.stimuli_count;
%     trials_per_class = trials / fq_count;
    power = zeros(length(frequencies), channels, trials);
    epo = trainEEG.epochs.signal;
    for chidx = 1:channels
        for tr = 1:trials
            f = fft(epo(:, chidx, tr)) / samples;
            f = 2*abs(f);
            f = f(1:length(frequencies));
            power(:, chidx, tr) = f;
        end
    end
    
  
    for tr = 1:trials
        event = cell2mat(trainEEG.classes(trainEEG.epochs.events(tr)));
        if(strcmp(event,'idle'))
            ff = zeros(1,3);
        else
            event = str2double(event);
            ff = [event, 2*event, 3*event];
        end
        f_idx = frequencies == ff(1) | frequencies == ff(2) | frequencies == ff(3);
        for chidx = 1:channels
            figure(tr), subplot(round(sqrt(channels)), ceil(sqrt(channels)), chidx),
            plot(frequencies, power(:, chidx, tr)),
            hold on
            plot(frequencies(f_idx), power(f_idx, chidx, tr),'ro', 'MarkerSize', 10)
            xlim([0 50]);
            xlabel('Frequnecy [HZ]');
            ylabel('Power Spectrum');
            title(['Frequency: ', num2str(ff(1)), ' ', trainEEG.montage.clab{chidx}]);
            
        end
    end
end

end

