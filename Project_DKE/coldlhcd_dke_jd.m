function waveparam = coldlhcd_dke_jd(xrho,lnc_e_ref,betath_ref,xrbetath,ne_ref,xne_norm,xzni_norm,zZi,zmi,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp);
%
% Creates wave parameters for cold plasma LHCD calculations
% Note: these calculations do not include any coupling to ray-tracing 
% and do not bring consistency between propagating and absorbed power densities.
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
qe = 1.6022e-19;%Electron charge (C)
me = 9.1094e-31;%Electron rest mass (Kg)
e0 = 8.8542e-12;%Free space permeability (F/m)
%
[blist_lh,yomega_lh,yvparmin_lh,yvparmax_lh,ynparmin_lh,ynparmax_lh,ynpar_lh,ydnpar_lh,...
    yP0_in_c_lh,yP0_in_lh_prof,ypeak_lh,ywidth_lh,yfinc_lh,ythetab_lh,yopt_lh] = psim_coldlhcd_jd;
%
nr = length(xrho);
nb_lh = length(blist_lh);
if nb_lh == 0, 
    blist_lh=ones(1,nb_lh); %for correct empty matrix size management
end
%
ytest_maskvpar_lh =  ~isnan(yvparmin_lh(blist_lh)) & ~isnan(yvparmax_lh(blist_lh));
ytest_masknpars_lh =  ~isnan(ynparmin_lh(blist_lh)) & ~isnan(ynparmax_lh(blist_lh));
ytest_masknparg_lh =  ~isnan(ynpar_lh(blist_lh)) & ~isnan(ydnpar_lh(blist_lh));
ytest_input_lh = [ytest_maskvpar_lh;ytest_masknpars_lh;ytest_masknparg_lh];
%
if sum(ytest_input_lh) ~= ones(1,nb_lh)
    error('LH Fourier spectrum input not compatible')
end
%
xyvparmin_lh = ones(nr,1)*yvparmin_lh(blist_lh);
xyvparmax_lh = ones(nr,1)*yvparmax_lh(blist_lh);
xynparmin_lh = ones(nr,1)*ynparmin_lh(blist_lh);
xynparmax_lh = ones(nr,1)*ynparmax_lh(blist_lh);
xyomega_lh = 2*pi*1e9*ones(nr,1)*yomega_lh(blist_lh);%(GHz -> rad/s)
xynpar_lh = ones(nr,1)*ynpar_lh(blist_lh);
xydnpar_lh = ones(nr,1)*ydnpar_lh(blist_lh);
xyP0_in_c_lh = ones(nr,1)*yP0_in_c_lh(blist_lh)*1e6;%(MW -> W)
xypeak_lh = ones(nr,1)*ypeak_lh(blist_lh);
xywidth_lh = ones(nr,1)*ywidth_lh(blist_lh);
xyfinc_lh = ones(nr,1)*yfinc_lh(blist_lh);
xythetab_lh = ones(nr,1)*ythetab_lh(blist_lh)*pi/180;%(deg -> rad)
xyopt_lh = ones(nr,1)*yopt_lh(blist_lh); 
%
xyrbetath_lh = repmat(xrbetath',[1,nb_lh]);
xyrho = repmat(xrho',[1,nb_lh]);
%
yP0_in_lh_prof = logical(yP0_in_lh_prof(blist_lh));
%
xyP0_in_lh = zeros(nr,nb_lh);
xyP0_in_lh(:,yP0_in_lh_prof) = exp(-(xyrho(:,yP0_in_lh_prof) - xypeak_lh(:,yP0_in_lh_prof)).^2./(xywidth_lh(:,yP0_in_lh_prof)/2/sqrt(log(2))).^2).*xyP0_in_c_lh(:,yP0_in_lh_prof);%Gaussian radial profile on midplane
xyP0_in_lh(:,~yP0_in_lh_prof) = xyP0_in_c_lh(:,~yP0_in_lh_prof);%Uniform radial profile
%
xyvparmin_lh_ref = xyvparmin_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
xyvparmax_lh_ref = xyvparmax_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
%
xynparmin_lh(:,ytest_maskvpar_lh) = 1./xyvparmax_lh_ref(:,ytest_maskvpar_lh)/betath_ref;%Conversion from vpar representation to npar one (if yvparmax_lh not a NaN)
xynparmax_lh(:,ytest_maskvpar_lh) = 1./xyvparmin_lh_ref(:,ytest_maskvpar_lh)/betath_ref;%Conversion from vpar representation to npar one (if yvparmin_lh not a NaN)
ytest_masknpars_lh = logical(ytest_masknpars_lh + ytest_maskvpar_lh);
%
xynpar_lh_disp = zeros(nr,nb_lh);% value of Npar used for solving dispersion relation
xynpar_lh_disp(:,ytest_masknpars_lh) = (xynparmin_lh(:,ytest_masknpars_lh) + xynparmax_lh(:,ytest_masknpars_lh))/2;
xynpar_lh_disp(:,ytest_masknparg_lh) = xynpar_lh(:,ytest_masknparg_lh);
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
mask_yfinc = isnan(yfinc_lh(blist_lh));
xyfinc_lh(:,mask_yfinc) = abs(xynperp_lh(:,mask_yfinc)./xynpar_lh_disp(:,mask_yfinc)); %normal poloidal incidence and ES approximation
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


