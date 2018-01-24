function [sigma,rho] = shrinkage_cov(X,est)
%
% <The Shrinkage covariance algorithms>
%     Copyright (C) 2016  Okba BEKHELIFI
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%compute a covariance matrix estimation using shrinkage estimators: RBLW or
% OAS describer in:
%     [1] "Shrinkage Algorithms for MMSE Covariance Estimation"
%     Chen et al., IEEE Trans. on Sign. Proc., Volume 58, Issue 10, October 2010.
%Input:
%X: data NxP : N : samples P: features
%est: shrinkage estimator
%     'rblw' : Rao-Blackwell estimator
%     'oas'  : oracle approximating shrinkage estimator
%     default estimator is OAS.
%
%Output:
%sigma: estimated covariance matrix
%by Okba BEKHELIFI (okba.bekhelifi@univ-usto.dz)
%created: 02/05/2016
%last revised:

% disp(['Shrinkage algorithm: ' est])
[n,p] = size(X);
% sample covariance, formula (2) in the paper [1]
X = bsxfun(@minus,X,mean(X));
S = X'*X/n;
% structured estimator, formula (3) in the paper [1]
mu = trace(S)/p;
T = mu*eye(p);


if (nargin < 2) est = 'oas';
end
switch lower(est)
    
    case 'oas'

        rho = (1-(2/p)*trace(S^2)+trace(S)^2)/((n+1-2/p)*(trace(S^2)-1/p*trace(S)^2));
        
    case 'rblw'

        c1 = (n-2)/n;
        c2 = n+2;
        rho = ( c1*trace(S^2)+trace(S)^2 )/( c2*( trace(S^2)-(trace(S)^2/p) ) );
        
    otherwise
           error('Shrinkage estimator not provided correctly');
        
end

% regularization, formula (4) in the paper [1]
sigma = (1-rho)*S + rho*T;

end

