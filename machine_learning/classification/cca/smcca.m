function  [w1,w3,v1] = smcca(refdata, traindata, max_iter, iniw3, n_comp, lmbda)
% L1-regualrized (Sparse) Multiway CCA
% traindata:    channel x time x trial
% refdata:      references by sine-cosine waveforms     
% 
% Rerefence:
% [1] Y. Zhang, G. Zhou, J. Jin, M. Wang, X. Wang, A. Cichocki.
%     L1-regularized multiway canonical correlation analysis for SSVEP-based BCI. 
%     IEEE Trans. Neural Syst. Rehabil. Eng., 21(6): 887-896 (2013)
% [2] T.K. Kim, R. Cipolla. Canonical correlation analysis of video volume tensor for
%     action categorization and detection. IEEE Trans. PAMI, 31(8): 1415-1428 (2009)
% 
% 
% by Yu Zhang, ECUST, 2014.4.29
% 

iter=1;
w3=iniw3;
w3=w3./norm(w3);
traindata=tensor(traindata);
refdata=tensor(refdata);

er=0.00001;     % error for iteration stop

while iter<max_iter
    projx3=ttm(traindata, w3', 3);
    projx3=tenmat(projx3, 1);                        % unfolding each trial tensor into i-mode matrix
    projx3=projx3.data;
    [v1, w1, r1]=cca(refdata.data, projx3);
    v1=v1(:,1:n_comp); w1=w1(:,1:n_comp);
    v1=v1./norm(v1); w1=w1./norm(w1);
    projx1=ttm(traindata,w1',1);
    projx1=tenmat(projx1,3);                        % unfolding each trial tensor into i-mode matrix
    projx1=projx1.data;
    projref1=ttm(refdata,v1',1);
    projref1=projref1.data(:)';
    w3=lasso(projx1',projref1','Lambda',lmbda);
    w3=w3./norm(w3);
    if iter>1
        if all(sign(w1)==-sign(prew1))
            errw(1,iter-1)=norm(w1+prew1);
        else
            errw(1,iter-1)=norm(w1-prew1);
        end
        if all(sign(w3)==-sign(prew3))
            errw(2,iter-1)=norm(w3+prew3);
        else
            errw(2,iter-1)=norm(w3-prew3);
        end
        if all(sign(v1)==-sign(prev1))
            errw(3,iter-1)=norm(v1+prev1);
        else
            errw(3,iter-1)=norm(v1-prev1);
        end
        if errw(1,iter-1)<er && errw(2,iter-1)<er && errw(3,iter-1)<er
            break
        end
    end
    prew1=w1;
    prew3=w3;
    prev1=v1;
    iter=iter+1;
end

fprintf('L1MCCA Iteration is %d \n',iter);
