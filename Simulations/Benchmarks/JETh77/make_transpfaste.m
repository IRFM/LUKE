%********************************************************************************************************************************
%************************************** FAST ELECTRON TRANSPORT COEFFICIENTS PROFILE ********************************************
%********************************************************************************************************************************
% Create the local file TRANSPFASTE_id_equil.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
id_equil = 'JETh77';%For loading the plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then 
%
vparmin_r = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
norm_ref = 1;%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
Dr0 = 0;%Core radial diffusion coefficient (m^2/s)
pDr = 0;%Coefficient for the Dr radial profile
Vr0 = 0;%Core radial pinch coefficient (m/s)
pVr = 0;%Coefficient for the Vr radial profile
%
Dr_model = 1;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
%
%*****************************************************************************************************************
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' succesfully loaded');
end
%
[theta,ppsin,psia,XR,XZ,XBR,XBZ,XBphi,pB0,pR0,pBT0,pBp0,prho,pTe,pne,pzTi,pzni,zZi,zmi,pZeff,Rp,Zp,ap,pmhu0T2,pdV_dke,pdA_dke] = equilibrium_jd(equil);
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
Te_ref = pTe(1);
ne_ref = pne(1);
%
Ten_ref = Te_ref/mc2;
betath_ref = sqrt(Ten_ref);%Normalized pth_ref/mc as prescribed by Karney
lnc_e_ref = 31.3 - 0.5*log(ne_ref) + log(Te_ref*1000);%Reference Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
nhu_ref = qe^4*ne_ref*lnc_e_ref/(4*pi*e0^2*me^2*(clum*betath_ref)^3);%Reference electron collision frequency (s-1)
%
pTe_norm = pTe/Te_ref;
pzTi_norm = pzTi/Te_ref;
pne_norm = pne/ne_ref;
pzni_norm = pzni/ne_ref;
%
pTen = pTe/mc2;
pzTin = pzTi/mc2;
%
pbetath = sqrt(pTen);%Normalized pth/mc as prescribed by Karney
plnc_e = 31.3 - 0.5*log(pne) + log(pTe*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
pnhu = qe^4*pne.*plnc_e./(4*pi*e0^2*me^2.*(clum*pbetath).^3);%Electron collision frequency (s-1)
%
if norm_ref == 0,
    prbetath = pbetath/betath_ref;
    prnhuth = pnhu/nhu_ref;
else
    prbetath = ones(size(ppsin));
    prnhuth = ones(size(ppsin));
end
%
Edreicer_ref = me*clum*betath_ref*nhu_ref/qe;%MKSA Dreicer field unit (V/m)
%
%********************************************************************************************************************
%
transpfaste.Dr_model = Dr_model;
transpfaste.Vr_model = Vr_model; 
%
transpfaste.rho = psi2rho_jd(equil,ppsin);%Arbitrary normalized minor radius
transpfaste.vparmin_r = vparmin_r*ones(size(transpfaste.rho)).*prbetath*clum*betath_ref;%m/s units
transpfaste.Dr = Dr0*(1 + pDr*transpfaste.rho.^2);
transpfaste.Vr = Vr0*(1 + pDr*transpfaste.rho.^2);
%
% Any type of profile may be enter in the structure. WARNING: profile is always function of a normalized minor radius
%
eval(['save TRANSPFASTE_',id_equil,'.mat transpfaste']);
