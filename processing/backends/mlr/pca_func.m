%% pca function
%data : feature x samples
function Proj_W=pca_func(data)
Proj_W=[];
 meanData=mean(data,2);
 data=data-repmat(meanData,1,size(data,2));
% stdVar=std(data')';
% staData=(data-repmat(meanData,1,size(data,2)))./repmat(stdVar,1,size(data,2));
% data=staData;
[V,S]=eig(data'*data);
[sorted_diagS,sorted_rank]=sort(diag(S),'descend');
sorted_S=diag(sorted_diagS);
V=V(:,sorted_rank);
r=rank(sorted_S);
S1=sorted_S(1:r,1:r);
V1=V(:,1:r);
U=data*V1*S1^(-0.5);
%[sorted_S,sorted_rank]=sort(diag(S),'descend');
All_energy=sum(diag(S1));
sorted_energy=diag(S1);
for j=1:r
    if (sum(sorted_energy(1:j))/All_energy)>0.99
        break
    end
end
Proj_W=U(:,1:j);
end