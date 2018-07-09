function [features] = extractSSVEP_mlr(EEG, opt)
%EXTRACTSSVE Summary of this function goes here
%   Detailed explanation goes here
% created 03-26-2017
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>

[samples, channels, epochs] = size(EEG.signal);
if (strcmp(opt.mode, 'estimate'))    
    train_rawData = reshape(EEG.signal, [samples*channels epochs]);
    MeanTrainData = mean(train_rawData, 2);
    train_rawData = train_rawData - repmat(MeanTrainData, 1, epochs);
%     train_Y(max(EEG.events), epochs) = 0;
    train_Y(max(EEG.y), epochs) = 0;
    for ep = 1:epochs
%         train_Y(EEG.events(ep),ep) = 1;
         train_Y(EEG.y(ep),ep) = 1;
    end
    
    PCA_W=pca_func(train_rawData);
    train_Data=PCA_W'*train_rawData;
    train_Data=[ones(1,epochs); train_Data];
    
    W_mlr=MultiLR(train_Data, train_Y);
    features.x = train_Data'*W_mlr;
    features.y = EEG.y';
    features.events = EEG.events;
    features.af.W = W_mlr;
    features.af.pc = PCA_W;
    features.af.mu = MeanTrainData;
else
    test_rawData = reshape(EEG.signal, [samples*channels epochs]);
    test_rawData = test_rawData - repmat(opt.mu, 1, epochs);
    test_Data = opt.pc'*test_rawData;
    test_Data = [ones(1,epochs);test_Data];
    features.x = test_Data'*opt.W;
    features.y = EEG.y';
    features.events = EEG.events;
end

end

