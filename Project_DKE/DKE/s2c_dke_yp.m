function [f1,ppar,dppar,pperp,dpperp] = s2c_dke_yp(f0,p,mhu,dp)
%
%	Spherical to cylindrical coordinate transformation with symmetry
%	enforced at abs(mhu) = 1. 
%
%	Input:
%
%		- f0:matrix [np,nmhu]  
%		- p: momentum vector [1,np]
%	    - mhu: cos(theta) vector [1,nmhu]
%		- dp	   
%
%	Output:
%
%		- f1:matrix [2*np_cyl-1,np_cyl]
%		- ppar: parallel momentum [1,np_cyl]
%		- dppar: parallel momentum increment [1,2*np_cyl-1]
%		- pperp: perpendicular momentum [1,np_cyl]
%		- dpperp: perpendicular momentum increment [1,np_cyl]
%		
%by Y.Peysson CEA-DRFC 22/07/2003 <yves.peysson@cea.fr>
%
if nargin < 4,
	error('Wrong number of input arguments for s2c_dke_yp');
	return;
end	
%
ppar0 = p(:)*mhu(:)';
pperp0 = p(:)*sqrt(1-(mhu(:).*mhu(:)))';
sf0 = size(f0,2);
%
%Symmetry at abs(mhu) = 1 enforced. Several point used for the cubic spline
%method, otherwise, the derivative is not correctly enforced (numerical
%noise)
%
nextra = 3;%Change extra point for avoiding bad contour plot with refine mesh
ppar00 = [ppar0(:,nextra:-1:1),ppar0,ppar0(:,sf0:-1:sf0-nextra+1)];
pperp00 = [-pperp0(:,nextra:-1:1),pperp0,-pperp0(:,sf0:-1:sf0-nextra+1)];
f00 = [f0(:,nextra:-1:1),f0,f0(:,sf0:-1:sf0-nextra+1)];
%
pmax = max(p) + max(diff(p));
ppar = [-pmax:dp:pmax];
pperp = [0:dp:pmax];
[ppar1,pperp1] = meshgrid(ppar,pperp);
f1 = griddata(ppar00,pperp00,f00,ppar1,pperp1,'cubic');
%
dppar = dp*ones(size(ppar));
dpperp = dp*ones(size(pperp));

 
 
 
 
 
 
