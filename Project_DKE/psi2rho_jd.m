function [rho] = psi2rho_jd(equil,psin,method)
%
% gives the normalized rho grid corresponding to the input normalized psi
% grid.
%
%   INPUTS:
%
%       - equil: Magnetic equilibrium structure
%       - psin: poloidal flux [1:nr]
%       - method: interpolation method (default: linear)
%
%   OUTPUTS:
%
%       - rho: normalized radius [1:nr]
%
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and  Yves Peysson
% <yves.peysson@cea.fr> (CEA/DRFC) 
%
if nargin < 3
    method = 'linear';%Interpolation method 
end
if nargin < 2
    error('no psi grid specified');
end
%
npsi = size(equil.R,1);
nr = length(psin);
%
Rp = equil.R(1,1);%major radius of Magnetic Axis
%
Rmax = equil.R(npsi,1);%major radius where the last close flux-surface crosses the LFS midplane
ap =  Rmax - Rp;%plasma radius on the LFS midplane 
prho = (equil.R(:,1) - Rp)/ap;
%
psia = equil.ppsi(npsi);%poloidal flux at the edge
ppsin = equil.ppsi/psia;%normalized poloidal flux
%
% Interpolation of calculation grid
%
rho = interp1(ppsin,prho,psin,method);


