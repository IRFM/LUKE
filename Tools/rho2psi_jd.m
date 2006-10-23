function [psin] = rho2psi_jd(equil,rho,method)
%
% gives the normalized psi grid corresponding to the input normalized rho grid.
%
%   INPUTS:
%
%       - tokamak: identification name of the scenario
%       - rho: normalized radius [1:nr]
%       - method: interpolation method (default: linear)
%
%   OUTPUTS:
%
%       - psin: poloidal flux [1:nr]
%
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) 
%
if nargin < 3
    method = 'linear';%Interpolation method 
end
if nargin < 2
    error('no rho grid specified');
end
%
npsi = length(equil.ppsi);
nr = length(rho);
%
ap =  equil.x(npsi,1);%plasma radius on the LFS midplane 
prho = equil.x(:,1)/ap;
%
psia = equil.ppsi(npsi);%poloidal flux at the edge
ppsin = equil.ppsi/psia;%normalized poloidal flux
%
% Interpolation of calculation grid
%
psin = interp1(prho,ppsin,rho,method);

