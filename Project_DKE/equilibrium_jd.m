function [theta,XR,XZ,XBR,XBZ,XBphi,xB0,xR0,xBT0,xBp0,xrho,xTe,xne,xzTi,xzni,zZi,zmi,xZeff,Rp,Zp,ap,Ncoils,BeLi,psia,xmhu0T2] = equilibrium_jd(tokamak,xpsin,method)
%
%   This function interpolates the equilibrium data on the radial grid.
%   It also calculates several quantities linked to the equilibrium, such
%   as the trapped/passing boundary in momentum space, the plasma minor
%   radius on LFS midplane, and the effective charge. 
%
%   NOTE: The equilibrium data in EQUIL_tokname must follow these
%   conventions:
%
%       - R Z BR BZ BPHI must be given on a (psi,theta) grid [npsi,ntheta].
%       - ppsi(1) = 0 is the magnetic axis.
%       - ppsi(npsi) is the poloidal flux on the last closed flux-surface.
%       It can
%           be either positive or negative depending on the sign of the
%           current
%           with respect to the toroidal angle phi.
%       - theta(1) = 0 and theta(ntheta) = 2pi is required.
%       - both grids can be non-uniform.
%       - other equilibrium parameters (temperatures, densities) are
%       assumed to 
%           be uniform within a flux-surface, because of the fast parallel
%           motion. They are therefore given on the psi grid.
%
%   INPUTS:
%
%       - tokamak: tokamak scenario selected
%       - xpsin: positions for FP calculations on the normalized psi grid
%       - method: interpolation method (linear,cubic,spline,...) 
%           (default: linear)
%
%   OUTPUTS:
%
%       - theta: poloidal angle grid [1,ntheta]
%       - XR: major radius [nr,ntheta]
%       - XZ: elevation [nr,ntheta]
%       - XBR: B-field component in R direction [nr,ntheta]
%       - XBZ: B-field component in Z direction [nr,ntheta]
%       - XBPHI: B-field component in PHI direction [nr,ntheta]
%       - xB0: minimum magnetic field on a flux-surface [1,nr]
%       - xR0: corresponding major radius [1,nr]
%       - xBT0: corresponding toroidal field [1,nr]
%       - xBp0: corresponding poloidal field [1,nr]
%       - xrho: normalized radius on the horizontal LFS midplane [1,nr]
%       - xTe: electron temperature [1,nr]
%       - xne: electron density [1,nr]
%       - xzTi: ion temperatures [ni,nr]
%       - xzni: ion densities [ni,nr]
%       - zZi: ion charges [1,ni]
%       - zmi: ion masses [1,ni]
%       - xZeff: effective charge [1,nr]
%       - Rp: major radius on axis [1,1]
%       - Zp: elevation on axis [1,1]
%       - ap: minor radius on LFS midplane [1,1]
%       - Ncoils: Number of toroidal magnetic field coils [1,1]
%       - BeLi: Beta + li/2 [1,1]
%       - psia: poloidal flux at the edge [1,1]
%       - xmhu0T2: pitch-angle (squared) at the trapped/passing boundary
%       [1,nr]
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson
%   <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
if nargin < 3
    method = 'linear';%Interpolation method 
end
if nargin < 2
    error('no radial grid specified');
end
%
qe = 1.60217733e-19;%Electron charge (C)
me = 9.1093897e-31;%Electron rest mass (Kg)
clum = 299792458;%Speed of light (m/s)
%
filename = ['EQUIL_',tokamak,'.mat'];
%
eval(['load ',filename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi Ncoils BeLi']);
%
[npsi,ntheta] = size(R);
nr = length(xpsin);
%
Rp = R(1,1);%major radius of Magnetic Axis
Zp = Z(1,1);%elevation of Magnetic Axis
%
Rmax = R(npsi,1);%major radius where the last close flux-surface crosses the LFS midplane
ap =  Rmax - Rp;%plasma radius on the LFS midplane 
%
psia = ppsi(npsi);%poloidal flux at the edge
ppsin = ppsi/psia;%normalized poloidal flux
%
pZeff = sum(pzni.*repmat((zZi.^2)',[1,npsi]))./pne;%Effective charge (a.u.)
%
% Interpolation of calculation grid
%
XR = interp1(ppsin,R,xpsin);
XZ = interp1(ppsin,Z,xpsin);
XBR = interp1(ppsin,BR,xpsin);
XBZ = interp1(ppsin,BZ,xpsin);
XBphi = interp1(ppsin,BPHI,xpsin);
%
xrho = (XR(:,1)' - Rp)/ap;%Normalized radius on the horizontal LFS midplane 
%xdrhodpsi =                         
%
xTe = interp1(ppsin,pTe,xpsin);
xne = interp1(ppsin,pne,xpsin);
xzTi = interp1(ppsin,pzTi',xpsin)';
xzni = interp1(ppsin,pzni',xpsin)';
xZeff = interp1(ppsin,pZeff,xpsin);
%
XBT = abs(XBphi);%Toroidal B-field
XBp = sqrt(XBR.^2 + XBZ.^2);;%Poloidal B-field
XB = sqrt(XBphi.^2 + XBR.^2 + XBZ.^2);%Total B-field
%
%index 0 refers to the minimum of the magnetic field
%
[xB0,xiB0] = min(XB'); %Minimum of B on flux surface
xBmax = max(XB'); %Maximum of B on flux surface
%
xmhu0T2 = 1 - xB0./xBmax; %Pitch-angle (squared) at the trapped-passing boundary
%
xiB0 = (xiB0 - 1)*nr + (1:nr);%Indices in (psi,theta) grid corresponding of B=Bmin
xBT0 = XBT(xiB0);%Toroidal field at B=Bmin
xBp0 = XBp(xiB0);%Poroidal field at B=Bmin
xR0 = XR(xiB0);%Major radius at B=Bmin

