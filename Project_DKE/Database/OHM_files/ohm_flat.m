function ohm = ohm_flat(equil,epsi)
%LUKE - Create the OHM structure for a given magnetic equilibrium with a fixed reference Dreicer field value. Flat radial profile only.
%
% Create the OHM structure for a given magnetic equilibrium with a fixed reference Dreicer field value. Flat radial profile only.
% norm_ref = 1;%Normalization procedure for the ohmic electric field: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
%by Y.Peysson CEA/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/IRFM (joan.decker@cea.fr)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;%Universal physics constants
%
Te_ref = equil.pTe(1);
ne_ref = equil.pne(1);
%
betath_ref = sqrt(Te_ref/mc2);%Normalized pth_ref/mc as prescribed by Karney
lnc_e_ref = 31.3 - 0.5*log(ne_ref) + log(Te_ref*1000);%Reference Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
nhu_ref = qe^4*ne_ref*lnc_e_ref/(4*pi*e0^2*me^2*(clum*betath_ref)^3);%Reference electron collision frequency (s-1)
%
Edreicer_ref = me*clum*betath_ref*nhu_ref/qe;%MKSA Dreicer field unit (V/m)
%
%********************************************************************************************************************
%
ohm.rho = [0,1];%Arbitrary normalized minor radius
ohm.epsi = epsi*[1,1]*Edreicer_ref;%(V/m)
%


