function [waveparam,nb_list] = rfwave_dke_jd(tokname,xrho,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath,xrnhuth,xTe_norm,xne_norm,xzni_norm,zZi,zmi,Rp,ap,bounce_mode,rf_list);
% 
%	RF input parameters for the Drift Kinetic equation solver (dke_4_1yp.m). Manual method, or with the cold plasma dispersion relation
% 
%	Input: 
%
%	Output: 
%  
%	Warning: none
%	  
%Last Update: 08/06/03
%
%by J.Decker MIT/RLE <jodecker@mit.edu> and Y.Peysson CEA/DRFC <yves.peysson@cea.fr> 04/29/2003
%
waveparam = [];
nb_list = zeros(1,6);
if rf_list(1) == 1 % test_mode LHCD
    waveparam_lh = ideallhcd_dke_jd(tokname,xrho,betath_ref,xrbetath,xrnhuth);
    waveparam = [waveparam;waveparam_lh];
    nb_list(1) = size(waveparam_lh,2);
end
%
if rf_list(2) == 1 % test_mode ECCD
    waveparam_ec = idealeccd_dke_jd(tokname,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath',xrnhuth',xTe_norm,xne_norm',xzni_norm,zZi',zmi',Rp,ap,bounce_mode);
    waveparam = [waveparam;waveparam_ec];
    nb_list(2) = size(waveparam_ec,2);
end
%
if rf_list(3) == 1 % cold plasma LH
    waveparam_lhc = coldlhcd_dke_jd(tokname,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath',xrnhuth',xTe_norm,xne_norm',xzni_norm,zZi',zmi',Rp,ap,bounce_mode);
    waveparam = [waveparam;waveparam_lhc];
    nb_list(3) = size(waveparam_lhc,2);
end
%
if rf_list(4) == 1 % cold plasma EC
    waveparam_ecc = coldeccd_dke_jd(tokname,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath',xrnhuth',xTe_norm,xne_norm',xzni_norm,zZi',zmi',Rp,ap,bounce_mode);
    waveparam = [waveparam;waveparam_ecc];
    nb_list(4) = size(waveparam_ecc,2);
end
%
if rf_list(5) == 1 % hot plasma ECCD
    waveparam_ecw = warmeccd_dke_jd(tokname,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath',xrnhuth',xTe_norm,xne_norm',xzni_norm,zZi',zmi',Rp,ap,bounce_mode);
    waveparam = [waveparam;waveparam_ecw];
    nb_list(5) = size(waveparam_ecw,2);
end
%
if rf_list(6) == 1 % hot plasma EBWCD
    waveparam_ebw = ebw_dke_jd(tokname,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath',xrnhuth',xTe_norm,xne_norm',xzni_norm,zZi',zmi',Rp,ap,bounce_mode);
    waveparam = [waveparam;waveparam_ebw];
    nb_list(6) = size(waveparam_ebw,2);
end
%
