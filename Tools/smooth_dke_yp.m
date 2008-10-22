function y = smooth_dke_yp(x,width,typ)
% LUKE - Columnwise data smoothing
%
%	Columnwise data smoothing. Output data are not normalized to input ones
%
%	Input:
%
%		- x: data matrix [n,m]
%		- width: smoothing width (number of points, must be positive and integer) [1,1]
%		- typ: 'gauss'ian or 'rect'angular (string) [1,p]
%		  (default = 'gaus')
%
%	Output:
%	
%		- y: smoothed data [n,m]
%
%by Y.PEYSSON CEA/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/IRFM <joan.decker@cea.fr>
%
if nargin < 1,
	infoyp(2,'Wrong number of input arguments for smooth_dke_yp');
	return;
end
if nargin == 1,
    y = x;
    return;
end
if nargin == 2,
	typ = 'gaus'; 
end
%
width = round(abs(width));%must be positive integer and not null
%
if  ~width,
    y = x;
    return;
end
%
if typ=='gaus'
    width = width*2;
    w = (-width:width)/width*2;
    w = exp(-w.^2);
else
    w = ones(-width:width);
end
%
w = w/sum(w);
%
n = size(x);
if n(1,1)==1, x = x(:); end
%
for i = 1:n(1,2)
    xf = conv(x(:,i),w);
    y(:,i) = xf(width+1:n(1,1)+width);
end      
                                  
