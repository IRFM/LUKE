function [aBx,aBy,aBz,deltar,deltat,deltaz] = bripfield_circ3_yp(R,Z,N,B0,R0,rn,rx)
%
%	Calculation of the toroidal magnetic field ripple by the Yushmanov
%	model (divB = 0 to the first order of the magnetic ripple perturbation)
%   Reviews of Plasma Physics, p.117-241, "Diffusive Transport Processes Caused by Ripple in Tokamaks" by P.N. Yushmanov, 1990.
%
%	Input:
%
%       - R: Major radius of the point at which magnetic field ripple components are calculated (m) [nrho,mtheta]
%       - Z: Vertical position of the point at which magnetic field ripple components are calculated (m) [nrho,mtheta]
%		- N: Number of toroidal magnetic field coils [1,1]
%       - B0: Vacuum toroidal magnetic field on the toroidal axis, (signed value as BPHI) (T) [1,1]
%       - R0: Toroidal major radius of the toroidal magnetic field windings(m) [1,1]
%       - rn: Inner radius of the toroidal magnetic field windings (m) [1,1]
%       - rx: Outer radius of the toroidal magnetic field windings (m) [1,1]
%
%	Output:
%
%       - aBx: amplitude of the horizontal magnetic ripple field along the major radius direction(T) [nrho,ntheta]
%       - aBy: amplitude of the vertical magnetic ripple field along the vertical radius direction (T) [nrho,ntheta]
%       - aBz: amplitude of the toroidal magnetic ripple field along the toroidal direction (T) [nrho,ntheta] 
%       - deltar: radial component of the magnetic ripple perturbation [nrho,ntheta] 
%       - deltat: poloidal component of the magnetic ripple perturbation [nrho,ntheta]
%       - deltaz: toroidal component of the magnetic ripple perturbation [nrho,ntheta]
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
x = R - R0;
y = Z;
%
r = sqrt(x.^2 + y.^2);
x(x == 0) = - eps;
theta = atan(y./x) + pi*(x < 0) + 2*pi*(x > 0 & y < 0);
%
L0 = (rn + rx).^2./8./R0;%Radial shift of nested iso-ripple surfaces (m)
a = sqrt((r.*r + L0.*L0 + 2.0.*r.*L0.*cos(theta)).*(R0 - L0)./R);%iso-ripple minor radius (m)
L = L0 - 0.5*a.*a./(R0 - L0);
aL = sqrt((r.*r + L.*L + 2.0.*r.*L.*cos(theta)).*(R0 - L0)./R);%iso-ripple minor radius (m)
%
deltan = 1.0./besseli(0,0.5*N.*(rn + rx)./(R0 - L0));
%
b = a.*N./(R0 - L0);
%
deltar = deltan.*besseli(1,b).*(r + L.*cos(theta))./aL;
deltat = deltan.*besseli(1,b).*L.*sin(theta)./aL;
deltaz = deltan.*besseli(0,b);
%
aBx = B0.*R0.*(deltar.*cos(theta) - deltat.*sin(theta))./R;%Major radius direction
aBy = B0.*R0.*(deltar.*sin(theta) + deltat.*cos(theta))./R;%Vertical radius direction
aBz = B0.*R0.*deltaz./R;%Toroidal direction
%

