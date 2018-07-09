function [output] = ml_applyFBCCA(features, model)
%ML_APPLYFBCCA Summary of this function goes here
%   Detailed explanation goes here
% created 07-01-2018
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

[~,~,epochs] = size(features.signal);
% stimuli_count = max(features.events);
% simuli_count = max(features.y);
stimuli_count = length(model.ref);
output.y = zeros(1, epochs);
output.score = zeros(1, epochs);
% apply CCA
for epo=1:epochs
    r = zeros(model.nrFbs, stimuli_count);
    for fb = 1:model.nrFbs
         % filterbank
         featuresBanks = filterbank(features.signal(:,:,epo)',...
                                    model.fs,...
                                    fb...
                                    );
        for stimulus=1:stimuli_count
            [~,~,tmp_r] = cca(featuresBanks, ...
                              model.ref{stimulus}...
                              );
            r(fb, stimulus) = tmp_r(1,1);
        end
    end
    rho = model.fbCoefs*r;
    [output.score(epo), output.y(epo)] = max(rho);
end

output.accuracy = ((sum(features.y == output.y)) / epochs)*100;
output.trueClasses = features.y;
output = ml_get_performance(output);
output.subject = '';
output.alg = model.alg;
end

