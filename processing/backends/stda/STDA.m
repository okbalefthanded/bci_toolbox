function [STDAmode error]=STDA(X,label,itrmax)
%%% Spatial-temporal Discriminant Analysis (STDA) for ERP classification %%%
% version for small sample size
% 
% X: data     (point x ch x trial)
% label: class label, 1 or 2
% itrmax: number of iteration
% 
% by Yu Zhang, ECUST & RIKEN, June 2012. Email: yuzhang@ecust.edu.cn
% 
% Reference:
% [1] Y. Zhang, G. Zhou, Q. Zhao, J. Jin, X. Wang, A. Cichocki, "Spatial-temporal 
%       discriminant analysis for ERP-based brain-computer interface," 
%       IEEE Trans. Neural Syst. Rehabil. Eng., vol. 21, no. 2, pp.
%       233-243, Mar. 2013.
% [2] D. Tao, X. Li, X. Wu, and S. Maybank, "General tensor discriminant
%       analysis and gabor features for gait recognition," IEEE Trans. Pattern
%       Anal. Mach. Intell., vol. 29, no. 10, pp. 1700¨C1714, Oct. 2007.
% [3] S. Yan, D. Xu, Q. Yang, L. Zhang, X. Tang, and H. Zhang, "Multilinear
%       discriminant analysis for face recognition," IEEE Trans. Image
%       Process., vol. 16, no. 1, pp. 212¨C220, Jan. 2007.
% 
% Note: This function requires the tensor_toolbox developed by Kolda
% (http://www.sandia.gov/~tgkolda/TensorToolbox/index-2.5.html)
% 
% 

Size=size(X);
X=tensor(X);
y=label;

nclass=2;

n_ord=length(Size)-1;
order=1:n_ord;


%% Initialization for projection matrices
D=[2 2];    % Number of component extracted
for i=1:n_ord
    W{i}=eye(Size(i));
end


%% Run STDA
n_r=1;
for nrp=1:itrmax   % Maximal iteration for solution of projection matrices
    preW=W;
    for i=1:n_ord
        mpy_ord=order;
        mpy_ord(i)=[];
        tns_i=ttm(X,W(mpy_ord),mpy_ord);
        Size=size(tns_i);
        
        % Unfolding each trial tensor into i-mode matrix
        tns_i=tenmat(tns_i,i);
        tns_i=tensor(tns_i.data,[Size(i) prod(Size)/Size(i)/Size(end) Size(end)]);
        tns_i=double(tns_i);
        
        Me_all=mean(tns_i,3);
        Sb=zeros(Size(i),Size(i));
        Sw=zeros(Size(i),Size(i));
        Me=zeros(Size(i),size(tns_i,2),nclass);
        for c=1:nclass
            N(c)=sum(y==c);
            Xw=tns_i(:,:,y==c);
            Me(:,:,c)=mean(Xw,3);
            Sb=Sb+N(c)*(Me(:,:,c)-Me_all)*(Me(:,:,c)-Me_all)';
            for j=1:N(c)
                Sw=Sw+(Xw(:,:,j)-Me(:,:,c))*(Xw(:,:,j)-Me(:,:,c))';
            end
        end
        Sb=Sb./sum(N);
        Sw=Sw./sum(N);
        [v,d]=eig(Sb,Sb+Sw);
        [d,id]=sort(diag(d),'descend');
        midW=v(:,id(1:D(i)));
        
        % Adjust the direction of w
        if nrp>1
            for r=1:D(i)
                midW(:,r)=midW(:,r)*sign(corr(midW(:,r),preW{i}(r,:)'));
            end
        end
        
        W{i}=midW';
    end
    
    n_break=0;
    if nrp>1
        for j=1:n_ord
            error(n_r,j)=norm(abs(W{j})-abs(preW{j}));
            if error(n_r,j)<0.00001
                n_break=n_break+1;
            end
        end
        n_r=n_r+1;
    end
    if n_break==n_ord
        break
    end
end

if nrp>=itrmax
    warning('Not perfectly converged. You may try a larger number of iteration.');
else
    fprintf('Converged at iteration: %f \n',nrp);
end

STDAmode=W;

