function [waveparam,xyprop_dke,xyPinc_in,nb_list,yb] = ...
    rfwave_dke_jd(tokamak,xrho,xpsin,xpsin_dke,xdpsin_dke,xpsin_S_dke,r_dke,...
    betath_ref,ne_ref,lnc_e_ref,xrbetath,xrnhuth,xTe_norm,xne_norm,xzni_norm,...
    zZi,zmi,ap,Rp,Zp,theta,XR,XZ,XBR,XBZ,XBphi,xB0,bounce_mode,rf_list,dke_mode);
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
nr_dke = length(xpsin_dke);
nr = length(xpsin);
waveparam = [];
xyprop_dke = [];
xyPinc_in = [];
yb = [];
ibb = 0;
nb_list = zeros(1,6);
%
if rf_list(1) == 1 % test_mode LHCD, no RT
    waveparam_lh = ideallhcd_dke_jd(xrho,betath_ref,xrbetath,xrnhuth);
    waveparam = [waveparam,waveparam_lh];
    nb_list(1) = size(waveparam_lh,2);
    xyprop_dke = [xyprop_dke,zeros(nr_dke,nb_list(1))];
    xyPinc_in = [xyPinc_in,zeros(nr_dke,nb_list(1))];
    ibb = ibb + nb_list(1);
end
%
if rf_list(2) == 1 % test_mode ECCD, no RT
    waveparam_ec = idealeccd_dke_jd(xrho,betath_ref,xrbetath,xrnhuth,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xB0);
    waveparam = [waveparam,waveparam_ec];
    nb_list(2) = size(waveparam_ec,2);
    xyprop_dke = [xyprop_dke,zeros(nr_dke,nb_list(2))];
    xyPinc_in = [xyPinc_in,zeros(nr_dke,nb_list(2))];
    ibb = ibb + nb_list(2);
end
%
if rf_list(3) == 1 % cold plasma LH
    if rf_list(3) == 1 % no RT calculations
        [xyomega_lh,xyvparmin_lh,xyvparmax_lh,xynparmin_lh,xynparmax_lh,xynpar_lh,xydnpar_lh,...
            xyP0_in_lh,xyfinc_lh,xythetab_lh,xyopt_lh] = psim_coldlhcd_jd(xrho);
        nb_list(3) = size(xyopt_lh,2);
        xyprop_dke = [xyprop_dke,zeros(nr_dke,nb_list(3))];
        xyPinc_in = [xyPinc_in,zeros(nr_dke,nb_list(3))];
        ibb = ibb + nb_list(3);
    elseif rf_list(3) == 2 % RT calculations 
        %***** to be implemented *****
    end
    waveparam_lhc = coldlhcd_dke_jd(ne_ref,xne_norm,xzni_norm,zZi,zmi,betath_ref,xrbetath,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
        xyomega_lh,xyvparmin_lh,xyvparmax_lh,xynparmin_lh,xynparmax_lh,xynpar_lh,xydnpar_lh,xyP0_in_lh,xyfinc_lh,xythetab_lh,xyopt_lh);
    waveparam = [waveparam,waveparam_lhc];    
end
%
if rf_list(4) >= 1 % cold plasma EC
    if rf_list(4) == 1 % no RT calculations
        [xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,...
            xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec] = psim_coldeccd_jd(xrho);
        nb_list(4) = size(xyn_ec,2);
        xyprop_dke = [xyprop_dke,zeros(nr_dke,nb_list(4))];
        xyPinc_in = [xyPinc_in,zeros(nr_dke,nb_list(4))];
        ibb = ibb + nb_list(4);
        waveparam_ecc = coldeccd_dke_jd(ne_ref,xne_norm,xzni_norm,zZi,zmi,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
            xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec);
    elseif rf_list(4) == 2 % RT calculations in wpe << wce limit      
        [xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,...
            xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec,xyprop_dke_ec,yb_ec] = straightray_jd(tokamak,xpsin,xpsin_dke,xdpsin_dke,xpsin_S_dke,r_dke,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,dke_mode);
        waveparam_ecc = coldeccd_dke_jd(ne_ref,xne_norm,xzni_norm,zZi,zmi,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
            xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec);
        %
        % checks for evanescent rays
        %
        xynperp_ec = waveparam_ecc(:,:,10);
        nb_ec = size(waveparam_ecc,2);
        ymask_ec = ones(1,nb_ec);
        for ibb_ec = 1:nb_ec
            ib_ec = max(find(yb_ec <= ibb_ec));
            ir_dke_im_list = find(xyprop_dke_ec(:,ibb_ec) ~= 0 & imag(xynperp_ec(r_dke,ibb_ec)) ~= 0 );
            if isempty(ir_dke_im_list) %the ray is not evanescent
                continue
            else %the ray is evanescent and propagation is stopped
                if max(xyprop_dke_ec(:,ibb_ec)) == 1 %ray portion is propagating outward
                    ir_dke_im = min(ir_dke_im_list); %position of ray start
                    mask_im = r_dke(ir_dke_im):nr;
                    mask_dke_im = ir_dke_im:nr_dke;
        %    
                elseif min(xyprop_dke_ec(:,ibb_ec)) == -1 %ray portion is propagating inward
                    ir_dke_im = max(ir_dke_im_list); %position of ray start
                    mask_im = 1:r_dke(ir_dke_im);
                    mask_dke_im = 1:ir_dke_im;
        %    
                end
                xyP0_in_ec(mask_im,ibb_ec) = 0;
                xyprop_dke_ec(mask_dke_im,ibb_ec) = 0;
        %        
        % next ray subdivisions are removed
        %
                ibp = min(find(yb_ec > ib_ec));
                ymask_ec(ibb+1:ibp-1) = 0;
            end
        end
        waveparam_ecc = waveparam_ecc(:,ymask_ec,:);
        xyprop_dke = [xyprop_dke,xyprop_dke_ec(:,ymask_ec)];
        xyPinc_in = [xyPinc_in,xyP0_in_ec(:,ymask_ec)];
        yb_ec = yb_ec(ymask_ec);
        yb = [yb,ibb + yb_ec];
    end
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
