function [ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI] = equildipole_fxd(ap,Rp,M,npsi,ntheta);
%
% Create dipole magnetic equilibrium
%
% by F.-X Duthoit (CEA/DSM/IRFM, francois-xavier.duthoit@cea.fr)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB] = pc_dke_yp;
%
prho = linspace(0,1,npsi);%Initial grid
theta = linspace(0,2*pi,ntheta);%Initial grid
%
Xrho = repmat(prho',[1,ntheta]);
Xtheta = repmat(theta,[npsi,1]);
%
x = ap*Xrho.*cos(Xtheta);
y = ap*Xrho.*sin(Xtheta);
%
XBpp = mu0*M/(4*pi*((x+Rp).^2+y.^2).^(5/2));
%
Bx = 3*XBpp.*(x+Rp).*y;
By = XBpp.*(2*y.^2-(x+Rp).^2);
BPHI = zeros(npsi,ntheta);
%
ppsi = mu0*M/(4*pi)*(cos(Xtheta).^2./sqrt((x+Rp).^2+y.^2+2*Rp*x.*cos(Xtheta)));
ppsi_apRp = ppsi*ap/Rp;
ppsin = ppsi_apRp/max(ppsi_apRp);
%
