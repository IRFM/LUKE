function waveparam = coldlhcd_dke_jd(ne_ref,xne_norm,xzni_norm,zZi,zmi,betath_ref,xrbetath,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
    xyomega_lh,xyvparmin_lh,xyvparmax_lh,xynparmin_lh,xynparmax_lh,xynpar_lh,xydnpar_lh,xyP0_in_lh,xyfinc_lh,xythetab_lh,xyopt_lh);
%
% Creates wave parameters for cold plasma LHCD calculations
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
[qe,me,mp,mn,e0] = pc_dke_yp;
%
[nr,nb_lh] = size(xyopt_lh);
%
xytest_maskvpar_lh =  ~isnan(xyvparmin_lh) & ~isnan(xyvparmax_lh);
xytest_masknpars_lh =  ~isnan(xynparmin_lh) & ~isnan(xynparmax_lh);
xytest_masknparg_lh =  ~isnan(xynpar_lh) & ~isnan(xydnpar_lh);
xytest_input_lh = xytest_maskvpar_lh + xytest_masknpars_lh + xytest_masknparg_lh;
%
if xytest_input_lh ~= ones(nr,nb_lh)
    error('LH Fourier spectrum input not compatible')
end
%
xyrbetath_lh = repmat(xrbetath',[1,nb_lh]);
%
xyvparmin_lh_ref = xyvparmin_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
xyvparmax_lh_ref = xyvparmax_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
%
xynparmin_lh(xytest_maskvpar_lh) = 1./xyvparmax_lh_ref(xytest_maskvpar_lh)/betath_ref;%Conversion from vpar representation to npar one (if xyvparmax_lh not a NaN)
xynparmax_lh(xytest_maskvpar_lh) = 1./xyvparmin_lh_ref(xytest_maskvpar_lh)/betath_ref;%Conversion from vpar representation to npar one (if xyvparmin_lh not a NaN)
xytest_masknpars_lh = logical(xytest_masknpars_lh + xytest_maskvpar_lh);
%
xynpar_lh_disp = zeros(nr,nb_lh);% value of Npar used for solving dispersion relation
xynpar_lh_disp(xytest_masknpars_lh) = (xynparmin_lh(xytest_masknpars_lh) + xynparmax_lh(xytest_masknpars_lh))/2;
xynpar_lh_disp(xytest_masknparg_lh) = xynpar_lh(xytest_masknparg_lh);
%
xyn_lh = [0]*ones(nr,nb_lh);%RF resonance harmonic (zero for LH)
%
% when only the ratio n.wce/w is given, the LH frequency is calculated as follows
[xyBb_lh,xyBPb_lh,xyrb_lh,xyRb_lh] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_lh);
%
xne = ne_ref*xne_norm;
xzni = ne_ref*xzni_norm;
%
for ib = 1:nb_lh
    for ir=1:nr
        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk]...
            = colddisp_dke_jd(xynpar_lh_disp(ir,ib),xyomega_lh(ir,ib),xne(ir),xzni(:,ir),zZi,zmi,xyBb_lh(ir,ib));
        %
        % perp. index of refraction
        NperpFW = Nperpm; 
        NperpSW = Nperpp; 
        %
        xynperp_lh(ir,ib) = NperpSW;
        %
        % polarization   
        eFW_pmz = em_pmz; 
        eSW_pmz = ep_pmz; 
        %
        xyepolp_lh(ir,ib) = eSW_pmz(1);
        xyepolm_lh(ir,ib) = eSW_pmz(2);
        xyepolz_lh(ir,ib) = eSW_pmz(3);
        %
        % power flow
        phiFW_pmz = phim_pmz; 
        phiSW_pmz = phip_pmz; 
        %
        xyabsphi_lh(ir,ib) = norm(phiSW_pmz);
    end
end
%
mask_xyfinc = isnan(xyfinc_lh);
xyfinc_lh(mask_xyfinc) = abs(xynperp_lh(mask_xyfinc)./xynpar_lh_disp(mask_xyfinc)); %normal poloidal incidence and ES approximation
%
wpe_ref = sqrt(ne_ref*qe^2/e0/me);
%
xyD0_lh_ref = xyfinc_lh.*xyP0_in_lh./(xyrb_lh.*xyRb_lh*me*lnc_e_ref.*xyomega_lh*wpe_ref^2.*xyabsphi_lh);
%
waveparam = zeros(nr,nb_lh,13);
%
waveparam(:,:,1) = xyn_lh;%RF resonance harmonic     
waveparam(:,:,2) = xyomega_lh;%RF wave frequency
waveparam(:,:,3) = xyopt_lh;%Options for Larmor radius effects and/or LH calc. 
waveparam(:,:,4) = xythetab_lh;%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
waveparam(:,:,5) = xyD0_lh_ref;%RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
waveparam(:,:,6) = xynparmin_lh;%Square N// spectrum: Lower limit
waveparam(:,:,7) = xynparmax_lh;%Square N// spectrum: Upper limit
waveparam(:,:,8) = xynpar_lh;%Gaussian N// spectrum: peak n//
waveparam(:,:,9) = xydnpar_lh;%Gaussian N// spectrum: width in n//
waveparam(:,:,10) = xynperp_lh;%RF wave : n_perp
waveparam(:,:,11) = xyepolp_lh;%RF wave : polarization plus
waveparam(:,:,12) = xyepolm_lh;%RF wave : polarization minus
waveparam(:,:,13) = xyepolz_lh;%RF wave : polarization parallel


