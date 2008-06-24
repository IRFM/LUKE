function [ohm] = ohm_profile_yp(equil,epsi0,epsia,eepsi,norm_ref)
%LUKE - Create the OHM structure for a given magnetic equilibrium with a local or a fixed reference Dreicer field value
%
% Create the OHM structure for a given magnetic equilibrium with a local or a fixed reference Dreicer field value
%
%by Y.Peysson CEA/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/IRFM (joan.decker@cea.fr)
%
if nargin < 2 | (nargin > 2 & nargin < 5),
	error('Wrong number of input arguments in ohm_profile_yp');
end
if nargin == 2,
	ohm = ohm_flat(equil,epsi);
	return
end
%
[equilDKE] = equilibrium_jd(equil);
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
Te_ref = equilDKE.xTe(1);
ne_ref = equilDKE.xne(1);
%
Ten_ref = Te_ref/mc2;
betath_ref = sqrt(Ten_ref);%Normalized pth_ref/mc as prescribed by Karney
lnc_e_ref = 31.3 - 0.5*log(ne_ref) + log(Te_ref*1000);%Reference Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
nhu_ref = qe^4*ne_ref*lnc_e_ref/(4*pi*e0^2*me^2*(clum*betath_ref)^3);%Reference electron collision frequency (s-1)
%
pTe_norm = equilDKE.xTe/Te_ref;
pzTi_norm = equilDKE.xzTi/Te_ref;
pne_norm = equilDKE.xne/ne_ref;
pzni_norm = equilDKE.xzni/ne_ref;
%
pTen = equilDKE.xTe/mc2;
pzTin = equilDKE.xzTi/mc2;
%
pbetath = sqrt(pTen);%Normalized pth/mc as prescribed by Karney
plnc_e = 31.3 - 0.5*log(equilDKE.xne) + log(equilDKE.xTe*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
pnhu = qe^4*equilDKE.xne.*plnc_e./(4*pi*e0^2*me^2.*(clum*pbetath).^3);%Electron collision frequency (s-1)
%
if norm_ref == 0,
    prbetath = pbetath/betath_ref;
    prnhuth = pnhu/nhu_ref;
else
    prbetath = ones(size(equilDKE.xpsin));
    prnhuth = ones(size(equilDKE.xpsin));
end
%
Edreicer_ref = me*clum*betath_ref*nhu_ref/qe;%MKSA Dreicer field unit (V/m)
%
%********************************************************************************************************************
%
ohm.rho = psi2rho_jd(equil,equilDKE.xpsin);%Arbitrary normalized minor radius
ohm.epsi = ((epsi0 - epsia)*(1.0-ohm.rho.^2).^eepsi + epsia).*prbetath.*prnhuth*Edreicer_ref;%(V/m)
%
% Any type of profile may be entered in the structure on any non-uniform radial grid.
% WARNING: profile is always function of a normalized minor radius
