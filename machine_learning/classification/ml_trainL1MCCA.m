function [model] = ml_trainL1MCCA(features, alg)
%ML_TRAINL1MCCA Summary of this function goes here
%   Detailed explanation goes here


% created 03-21-2016
% last modification -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
[samples,~,epochs] = size(features.signal);
stimuli_count = length(features.stimuli_frequencies);
reference_signals = cell(1, stimuli_count);

iniw3 = ones(epochs,1);
w1 = cell(stimuli_count);
w3 = cell(stimuli_count);
op_refer = cell(stimuli_count);
stimuli_count = max(features.events);
eeg = permute(features.x, [2 1 3]);
if (cv.nfolds == 0)
    %     learn projections
    for stimulus=1:stimuli_count
        reference_signals{stimulus} = refsig(features.stimuli_frequencies(stimulus),...
                                             features.fs, samples, ...
                                             alg.options.harmonics);
        [w1{stimulus}, w3{stimulus}] = smcca(reference_signals{stimulus}, ...
                                             eeg, alg.options.max_iter, iniw3,...
                                             alg.options.n_comp, ...
                                             alg.options.lambda);
        op_refer{stimulus} = ttm(tensor(eeg), w3{stimulus}', 3); 
        op_refer{stimulus} = tenmat(op_refer{stimulus}, 1);
        op_refer{stimulus} = op_refer{stimulus}.data;
        op_refer{stimulus} = w1{stimulus}'*op_refer{stimulus};
        
    end
else
    %     TODO
end
model.ref = op_refer;
% % run L1MCCA to learn projections
% 
% [w11,w13,v11]=smcca(sc1(:,1:TW_p(tw_length)),SSVEPdata(:,1:TW_p(tw_length),idx_traindata,1),max_iter,iniw3,n_comp,lambda);
% [w21,w23,v21]=smcca(sc2(:,1:TW_p(tw_length)),SSVEPdata(:,1:TW_p(tw_length),idx_traindata,2),max_iter,iniw3,n_comp,lambda);
% [w31,w33,v31]=smcca(sc3(:,1:TW_p(tw_length)),SSVEPdata(:,1:TW_p(tw_length),idx_traindata,3),max_iter,iniw3,n_comp,lambda);
% [w41,w43,v41]=smcca(sc4(:,1:TW_p(tw_length)),SSVEPdata(:,1:TW_p(tw_length),idx_traindata,4),max_iter,iniw3,n_comp,lambda);
% % compute the optimal reference signals
% % op_reference 1
% op_refer1=ttm(tensor(SSVEPdata(:,1:TW_p(tw_length),idx_traindata,1)),w13',3);
% op_refer1=tenmat(op_refer1,1);
% op_refer1=op_refer1.data;
% op_refer1=w11'*op_refer1;
% % op_reference 2
% op_refer2=ttm(tensor(SSVEPdata(:,1:TW_p(tw_length),idx_traindata,2)),w23',3);
% op_refer2=tenmat(op_refer2,1);
% op_refer2=op_refer2.data;
% op_refer2=w21'*op_refer2;
% % op_reference 3
% op_refer3=ttm(tensor(SSVEPdata(:,1:TW_p(tw_length),idx_traindata,3)),w33',3);
% op_refer3=tenmat(op_refer3,1);
% op_refer3=op_refer3.data;
% op_refer3=w31'*op_refer3;
% % op_reference 4
% op_refer4=ttm(tensor(SSVEPdata(:,1:TW_p(tw_length),idx_traindata,4)),w43',3);
% op_refer4=tenmat(op_refer4,1);
% op_refer4=op_refer4.data;
% op_refer4=w41'*op_refer4;
end

