function [rho] = psi2rho_jd(tokamak,psin,method)
%
% gives the normalized rho grid corresponding to the input normalized psi grid.
%
%   INPUTS:
%
%       - tokamak: identification name of the scenario
%       - psin: poloidal flux [1:nr]
%       - method: interpolation method (default: linear)
%
%   OUTPUTS:
%
%       - rho: normalized radius [1:nr]
%
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) 
%
if nargin < 3
    method = 'linear';%Interpolation method 
end
if nargin < 2
    error('no psi grid specified');
end
%
filename = ['EQUIL_',tokamak,'.mat'];
%
eval(['load ',filename,' ppsi R Z BR BZ BPHI']);
%
npsi = size(R,1);
nr = length(psin);
%
Rp = R(1,1);%major radius of Magnetic Axis
%
Rmax = R(npsi,1);%major radius where the last close flux-surface crosses the LFS midplane
ap =  Rmax - Rp;%plasma radius on the LFS midplane 
prho = (R(:,1) - Rp)/ap;
%
psia = ppsi(npsi);%poloidal flux at the edge
ppsin = ppsi/psia;%normalized poloidal flux
%
% Interpolation of calculation grid
%
rho = interp1(ppsin,prho,psin,method);


