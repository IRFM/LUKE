%******************************************************************************************************************
%************************************************ OHMIC EFIELD PROFILE ********************************************
%******************************************************************************************************************
% Create the local file OHM_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
%
id_ohm = 'Efield_p005_flat';
%
id_equil = 'TScirc_flatprof_e1';%For loading the plasma equilibrium
path_equil = '../EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Normlized Ohmic electric field profile calculation
% (WARNING: norm_ref = 0 by default when multiple radial positions are studied simultaneously, whatever the value in this file 
% -> normalization with pth_ref*nhuth_ref/e)
% 
epsi0 = 0.05;%Flux surface averaged core Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e) 
epsia = 0.05;%Flux surface averaged edge Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
eepsi = 0;%Exponent for Ohmic electric field (WARNING: psi coordinate and not rho)
%
norm_ref = 1;%Normalization procedure for the ohmic electric field: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
%*****************************************************************************************************************
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
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
%
eval(['save OHM_',id_equil,'_',id_ohm,'.mat ohm']);


