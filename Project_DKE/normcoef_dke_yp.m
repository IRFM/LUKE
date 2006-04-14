function [xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE)
%
%   Calculate normalized profile parameters for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
xTe_norm = equilDKE.xTe/mksa.Te_ref;
xzTi_norm = equilDKE.xzTi/mksa.Te_ref;
xne_norm = equilDKE.xne/mksa.ne_ref;
xzni_norm = equilDKE.xzni/mksa.ne_ref;
%xnloss_norm = xnloss/mksa.ne_ref;
xnloss_norm = [];
%
xTen = equilDKE.xTe/mc2;
xzTin = equilDKE.xzTi/mc2;
%
xbetath = sqrt(xTen);%Normalized pth/mc as prescribed by Karney
xlnc_e = 31.3 - 0.5*log(equilDKE.xne) + log(equilDKE.xTe*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
xnhu = qe^4*equilDKE.xne.*xlnc_e./(4*pi*e0^2*me^2.*(clum*xbetath).^3);%Electron collision frequency (s-1)
xrnhuth = xnhu./mksa.nhu_ref;


