function [features] = extractERP_epfl(EEG, opt)
%EXTRACTERP_EPFL Implements EPFL P300 approach [1]
%
% created 07-02-2019
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% References:
% [1] U. Hoffmann, J.M. Vesin, T. Ebrahimi, K. Diserens, An efficient
%     P300-based brain-computer interface for disabled subjects, J. Neurosci.
%     Methods. 167 (2008) 115–125. doi:10.1016/j.jneumeth.2007.03.005.

if(isempty(opt) || ~isfield(opt,'p') || ~isfield(opt,'decimation_factor') )
    p = 0.1;
    decimation = 12;
else
    p = opt.p;
    decimation = opt.decimation_factor;
end

[nSamples, nChannels, nEpochs, nTrials] = size(EEG.epochs.signal);
nInstance = nEpochs*nTrials;

x = reshape(EEG.epochs.signal, [nSamples, nChannels, nEpochs*nTrials]);
x = x(1:decimation:end,:,:);
nSamples = size(x,1);
if(strcmp(opt.mode, 'estimate'))
    %
    w = estimate_windsor(x, p);
    x = apply_windsor(x, w);
    x = permute(reshape(x,[nSamples*nChannels nInstance]), [2 1]);
    norml = utils_estimate_normalize(x, 'ZSCORE');
    x = utils_apply_normalize(x, norml);
    features.af.w = w;
    features.af.norml = norml;
    
else if(strcmp(opt.mode, 'transform'))
        %
        x = apply_winsor(x, opt.w);
        x = permute(reshape(x,[nSamples*nChannels nInstance]), [2 1]);
        x = utils_apply_normalize(x, opt.norml);
    end
end
%
features.x = x;
features.y =  reshape(EEG.epochs.y,[nInstance 1]);
features.events = reshape(EEG.epochs.events,[nInstance 1]);
features.paradigm = EEG.paradigm;
features.n_channels = nChannels;
end
%
function [w] = estimate_windsor(x,p)
w.limit_l = [];
w.limit_h = [];
[nSamples, nChannels, nTrials] = size(x);
nClip = round(nSamples*nTrials*p/2);
x = permute(x, [2 1 3]);
x = reshape(x, nChannels, nSamples*nTrials);
for ch = 1:nChannels
    tmp = sort(x(ch,:));
    w.limit_l(ch) = tmp(nClip);
    w.limit_h(ch) = tmp(end-nClip+1);
end
end
%
function [x] = apply_windsor(x,w)
[nSamples, nChannels, nTrials] = size(x);
x = permute(x, [2 1 3]);
x = reshape(x, nChannels, nSamples*nTrials);
l = repmat(w.limit_l', 1, nSamples*nTrials);
h = repmat(w.limit_h', 1, nSamples*nTrials);
i_l = x < l;
i_h = x > h;
x(i_l) = l(i_l);
x(i_h) = h(i_h);
x = reshape(x, nChannels, nSamples, nTrials);
x = permute(x, [2 1 3]);
end

