function [waveparam,nb_list] = rfwave_dke_jd(xrho,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,lnc_e_ref,xrbetath,xrnhuth,xTe_norm,xne_norm,xzni_norm,zZi,zmi,ap,Rp,Zp,theta,XR,XZ,XBR,XBZ,XBphi,xB0,bounce_mode,rf_list);
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
    waveparam_lh = ideallhcd_dke_jd(xrho,betath_ref,xrbetath,xrnhuth);
    waveparam = [waveparam,waveparam_lh];
    nb_list(1) = size(waveparam_lh,2);
end
%
if rf_list(2) == 1 % test_mode ECCD
    waveparam_ec = idealeccd_dke_jd(xrho,betath_ref,xrbetath,xrnhuth,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xB0);
    waveparam = [waveparam,waveparam_ec];
    nb_list(2) = size(waveparam_ec,2);
end
%
if rf_list(3) == 1 % cold plasma LH
    if rf_list(3) == 1 % no RT calculations
        [xyomega_lh,xyvparmin_lh,xyvparmax_lh,xynparmin_lh,xynparmax_lh,xynpar_lh,xydnpar_lh,...
    xyP0_in_lh,xyfinc_lh,xythetab_lh,xyopt_lh] = psim_coldlhcd_jd(xrho);
    elseif rf_list(3) == 2 % RT calculations 
        %***** to be implemented *****
    end
    waveparam_lhc = coldlhcd_dke_jd(ne_ref,xne_norm,xzni_norm,zZi,zmi,betath_ref,xrbetath,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
        xyomega_lh,xyvparmin_lh,xyvparmax_lh,xynparmin_lh,xynparmax_lh,xynpar_lh,xydnpar_lh,xyP0_in_lh,xyfinc_lh,xythetab_lh,xyopt_lh);
    waveparam = [waveparam,waveparam_lhc];
    nb_list(3) = size(waveparam_lhc,2);
end
%
if rf_list(4) >= 1 % cold plasma EC
    if rf_list(4) == 1 % no RT calculations
        [xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,...
            xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec] = psim_coldeccd_jd(xrho);
    elseif rf_list(4) == 2 % RT calculations in wpe << wce limit***** to be implemented *****
        [xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,...
            xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec] = straightray_jd(xrho,xyPabs_tot_rf_fsav_in);
    end
    waveparam_ecc = coldeccd_dke_jd(ne_ref,xne_norm,xzni_norm,zZi,zmi,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
        xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec);
    waveparam = [waveparam,waveparam_ecc];
    nb_list(4) = size(waveparam_ecc,2);
end
%
if rf_list(5) == 1 % hot plasma ECCD***** to be implemented *****
    waveparam_ecw = warmeccd_dke_jd(tokname,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath',xrnhuth',xTe_norm,xne_norm',xzni_norm,zZi',zmi',Rp,ap,bounce_mode);
    waveparam = [waveparam,waveparam_ecw];
    nb_list(5) = size(waveparam_ecw,2);
end
%
if rf_list(6) == 1 % hot plasma EBWCD***** to be implemented *****
    waveparam_ebw = ebw_dke_jd(tokname,xpsin,xpsin_dke,xdpsin_dke,xyPabs_tot_rf_fsav_in,betath_ref,ne_ref,xrbetath',xrnhuth',xTe_norm,xne_norm',xzni_norm,zZi',zmi',Rp,ap,bounce_mode);
    waveparam = [waveparam,waveparam_ebw];
    nb_list(6) = size(waveparam_ebw,2);
end
%
