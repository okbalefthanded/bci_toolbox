function n2 = L2_distance_2(x,c,df)
%   D2  = L2_distance_2(a, b, df)
%
%   Get the square of L2_distance of two sets of samples. It is useful when
%   you only need square of L2_distance, for example, in Guassian Kernel.
%   This function is faster and lower memory requirement compared with the
%   funtion L2_distance by Roland Bunschoten et al.
%
%   Input:
%       a   -- d-by-m matrix, i.e. m samples of d-dimension.
%       b   -- d-by-n matrix;
%       df  -- df = 1, force diagnal to zero, otherwise not.
%
%   Output:
%       D2  -- m-by-n matrix, the square of L2_distance.
%
%   Code from CHEN Lin, comment by LI Wen.
%

if nargin < 3
    df = 0;
end
[dimx, ndata] = size(x);
[dimc, ncentres] = size(c);
if dimx ~= dimc
	error('Data dimension does not match dimension of centres')
end

n2 = (ones(ncentres, 1) * sum((x.^2), 1))' + ...
  		ones(ndata, 1) * sum((c.^2),1) - ...
  		2.*(x'*(c));
% make sure result is all real
n2 = real(full(n2)); 
n2(n2<0) = 0;
% force 0 on the diagonal? 
if (df==1)
  n2 = n2.*(1-eye(size(n2)));
end