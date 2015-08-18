function [XXf0,ZP0,Zcurr,Znorm,ZXXS,XxRR_fsav,xMRR_flux,xMRR_tau,xMRR_power_flux,xMRR_power_tau,xRRm_fsav,xRRp_fsav,xTe_norm_out,Zmom] = ...
    renorm_fmoments_jd(xnorm_fac,equilDKE,mksa,...
          XXf0,ZP0,Zcurr,Znorm,ZXXS,XxRR_fsav,xMRR_flux,xMRR_tau,xMRR_power_flux,xMRR_power_tau,xRRm_fsav,xRRp_fsav,xTe_norm_out,Zmom)
%
[npn,nmhu,nr] = size(XXf0);
%
XXnorm_fac = repmat(reshape(xnorm_fac,[1,1,nr]),[npn,nmhu,1]);
%
% distribution
%
XXf0 = XXf0./XXnorm_fac;
%
% power
%
ny = size(ZP0.xyn_rf_fsav,2);
nn_rf = size(ZP0.xyn_rf_fsav,3);
%
ZP0.xyn_rf_fsav = ZP0.xyn_rf_fsav./repmat(xnorm_fac.',[1,ny,nn_rf]);
ZP0.xy_rf_fsav = ZP0.xy_rf_fsav./repmat(xnorm_fac.',[1,ny]);
ZP0.x_rf_fsav = ZP0.x_rf_fsav./xnorm_fac.';
ZP0.x_c_fsav = ZP0.x_c_fsav./xnorm_fac.';
ZP0.x_e_fsav = ZP0.x_e_fsav./xnorm_fac.';
%
ZP0.P_rf_2piRp = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
ZP0.P_ohm_2piRp = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
%
% Current
%
Zcurr.x_0 = Zcurr.x_0./xnorm_fac;
Zcurr.x_tp = Zcurr.x_tp./xnorm_fac;
Zcurr.x_g = Zcurr.x_g./xnorm_fac;
Zcurr.x_tot = Zcurr.x_tot./xnorm_fac;
Zcurr.x_0_fsav = Zcurr.x_0_fsav./xnorm_fac;
Zcurr.x_0_vfsav = Zcurr.x_0_vfsav./xnorm_fac;
Zcurr.x_0_vcfsav = Zcurr.x_0_vcfsav./xnorm_fac;
Zcurr.x_tp_fsav = Zcurr.x_tp_fsav./xnorm_fac;
Zcurr.x_tp_vfsav = Zcurr.x_tp_vfsav./xnorm_fac;
Zcurr.x_tp_vcfsav = Zcurr.x_tp_vcfsav./xnorm_fac;
Zcurr.x_g_fsav = Zcurr.x_g_fsav./xnorm_fac;
Zcurr.x_g_vfsav = Zcurr.x_g_vfsav./xnorm_fac;
Zcurr.x_g_vcfsav = Zcurr.x_g_vcfsav./xnorm_fac;
Zcurr.x_tot_fsav = Zcurr.x_tot_fsav./xnorm_fac;
Zcurr.x_tot_vfsav = Zcurr.x_tot_vfsav./xnorm_fac;
Zcurr.x_tot_vcfsav = Zcurr.x_tot_vcfsav./xnorm_fac;
Zcurr.x_B_fsav = Zcurr.x_B_fsav./xnorm_fac;
Zcurr.x_Rfrac_0 = Zcurr.x_Rfrac_0./xnorm_fac;
Zcurr.x_Rfrac_0_fsav = Zcurr.x_Rfrac_0_fsav./xnorm_fac;
%
Zcurr.I_tot = sum(Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
Zcurr.I_Rfrac_tot = sum(Zcurr.x_Rfrac_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
%
% Normalization
%
Znorm.x_0 = Znorm.x_0./xnorm_fac;
Znorm.x_tp = Znorm.x_tp./xnorm_fac;
Znorm.x_g = Znorm.x_g./xnorm_fac;
Znorm.x_0_fsav = Znorm.x_0_fsav./xnorm_fac;
Znorm.x_tp_fsav = Znorm.x_tp_fsav./xnorm_fac;
Znorm.x_g_fsav = Znorm.x_g_fsav./xnorm_fac;
Znorm.x_Rfrac_0 = Znorm.x_Rfrac_0./xnorm_fac;
Znorm.x_Rfrac_0_fsav = Znorm.x_Rfrac_0_fsav./xnorm_fac;
%
% Fluxes
%
ZXXS.p0_rf_imj = ZXXS.p0_rf_imj./XXnorm_fac;
ZXXS.p0_rf_ipj = ZXXS.p0_rf_ipj./XXnorm_fac;
ZXXS.m0_rf_ijm = ZXXS.m0_rf_ijm./XXnorm_fac;
ZXXS.m0_rf_ijp = ZXXS.m0_rf_ijp./XXnorm_fac;
ZXXS.p0_c_imj = ZXXS.p0_c_imj./XXnorm_fac;
ZXXS.p0_c_ipj = ZXXS.p0_c_ipj./XXnorm_fac;
ZXXS.m0_c_ijm = ZXXS.m0_c_ijm./XXnorm_fac;
ZXXS.m0_c_ijp = ZXXS.m0_c_ijp./XXnorm_fac;
ZXXS.p0_e_imj = ZXXS.p0_e_imj./XXnorm_fac;
ZXXS.p0_e_ipj = ZXXS.p0_e_ipj./XXnorm_fac;
ZXXS.m0_e_ijm = ZXXS.m0_e_ijm./XXnorm_fac;
ZXXS.m0_e_ijp = ZXXS.m0_e_ijp./XXnorm_fac;
%
% Runaways
%
Xxnorm_fac = repmat(xnorm_fac,[npn,1]);
%
XxRR_fsav = XxRR_fsav./Xxnorm_fac;
xRRm_fsav = xRRm_fsav./xnorm_fac;
xRRp_fsav = xRRp_fsav./xnorm_fac;
%
% Ripple losses
%
xMRR_flux = xMRR_flux./xnorm_fac;
xMRR_tau = xMRR_tau./xnorm_fac;
xMRR_power_flux = xMRR_power_flux./xnorm_fac;
xMRR_power_tau = xMRR_power_tau./xnorm_fac;
%
% Apparent temperature
%
xTe_norm_out = xTe_norm_out./xnorm_fac;
%
% Momentum transfer rate
%
Zmom.x_rf = Zmom.x_rf./xnorm_fac;
%


