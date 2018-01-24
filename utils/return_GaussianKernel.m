function [K, param] = return_GaussianKernel(featuresA, featuresB, param)

[dA nA] = size(featuresA);
[dB nB] = size(featuresB);

assert(dA == dB);

sq_dist = L2_distance_2(featuresA, featuresB);

if(~isfield(param, 'ratio') || param.ratio == 0)
    param.ratio = 1;
end

if(~isfield(param, 'gamma') || param.gamma == 0)    
    if (~isfield(param, 'sigma') || param.sigma == 0)
        % use default sigma
        tmp = mean(mean(sq_dist))*0.5;
        param.sigma = sqrt(tmp);
    end
    % compute gamma according to param.ratio and param.sigma
    if(param.sigma == 0)
        param.gamma     = 0;
    else
        param.gamma     = 1/(2*param.ratio*param.sigma^2);
    end
else
    % already specify gamma, then sigma and ratio set to 0.
    if(~isfield(param, 'sigma'))
        param.sigma = 0;
    end
    if(~isfield(param, 'ratio'))
        param.ratio = 0;
    end
end

K = exp(-sq_dist*param.gamma);

