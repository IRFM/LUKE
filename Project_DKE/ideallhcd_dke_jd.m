function waveparam = ideallhcd_dke_jd(xrho,betath_ref,xrbetath,xrnhuth);
%
% Creates wave parameters for test mode LHCD calculations
% This function has a benchmarking purpose only
% Aproximations: 
%   - The polarization is purely electrostatic: in that case, only the parallel polarization term is non-zero.
%   - Small FLR limit: J0(z) -> 1. 
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
[blist_lh,yvparmin_lh,yvparmax_lh,ynparmin_lh,ynparmax_lh,ynpar_lh,ydnpar_lh,...
    yD0_in_c_lh,yD0_in_lh_prof,ypeak_lh,ywidth_lh,ythetab_lh,yopt_lh] = psim_ideallhcd_jd;
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
xynpar_lh = ones(nr,1)*ynpar_lh(blist_lh);
xydnpar_lh = ones(nr,1)*ydnpar_lh(blist_lh);
xyD0_in_c_lh = ones(nr,1)*yD0_in_c_lh(blist_lh);
xypeak_lh = ones(nr,1)*ypeak_lh(blist_lh);
xywidth_lh = ones(nr,1)*ywidth_lh(blist_lh);
xythetab_lh = ones(nr,1)*ythetab_lh(blist_lh)*pi/180;%(deg -> rad)
xyopt_lh = ones(nr,1)*yopt_lh(blist_lh); 
%
xyrho = repmat(xrho',[1,nb_lh]);
xyrbetath_lh = repmat(xrbetath',[1,nb_lh]);
xyrnhuth_lh = repmat(xrnhuth',[1,nb_lh]);
%
yD0_in_lh_prof = logical(yD0_in_lh_prof(blist_lh));
%
xyD0_in_lh = zeros(nr,nb_lh);
xyD0_in_lh(:,yD0_in_lh_prof) = exp(-(xyrho(:,yD0_in_lh_prof) - xypeak_lh(:,yD0_in_lh_prof)).^2./(xywidth_lh(:,yD0_in_lh_prof)/2/sqrt(log(2))).^2).*xyD0_in_c_lh(:,yD0_in_lh_prof);%Gaussian radial profile on midplane
xyD0_in_lh(:,~yD0_in_lh_prof) = xyD0_in_c_lh(:,~yD0_in_lh_prof);%Uniform radial profile
%
xyvparmin_lh_ref = xyvparmin_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
xyvparmax_lh_ref = xyvparmax_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
%
xyD0_lh_ref_in = xyD0_in_lh.*xyrnhuth_lh.*xyrbetath_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
%
xynparmin_lh(:,ytest_maskvpar_lh) = 1./xyvparmax_lh_ref(:,ytest_maskvpar_lh)/betath_ref;%Conversion from vpar representation to npar one (if yvparmax_lh not a NaN)
xynparmax_lh(:,ytest_maskvpar_lh) = 1./xyvparmin_lh_ref(:,ytest_maskvpar_lh)/betath_ref;%Conversion from vpar representation to npar one (if yvparmin_lh not a NaN)
ytest_masknpars_lh = logical(ytest_masknpars_lh + ytest_maskvpar_lh);
%
%The quasilinear diffusion coefficient xyD0_lh_ref is must be transformed to the general expression
%Normalization of the diffusion coefficient for comparison with old calc. (Karney, Shoucri), see rfdiff_dke_jd
%
xyD0_lh_ref = zeros(nr,nb_lh);
xyD0_lh_ref(:,ytest_masknpars_lh) = xyD0_lh_ref_in(:,ytest_masknpars_lh).*(xynparmax_lh(:,ytest_masknpars_lh) - xynparmin_lh(:,ytest_masknpars_lh));%Square power spectrum
xyD0_lh_ref(:,ytest_masknparg_lh) = xyD0_lh_ref_in(:,ytest_masknparg_lh).*xydnpar_lh(:,ytest_masknparg_lh)*sqrt(pi);%Gaussien power spectrum
%
xyn_lh = [0]*ones(nr,nb_lh);%RF resonance harmonic (zero for LH)
%
xyomega_lh = [1]*ones(nr,nb_lh);%LH wave frequency (GHz). Not relevant in small FLR limit
xynperp_lh = [0]*ones(nr,nb_lh);%Not relevant in small FLR limit
%
%Wave polarization (norm must be 1)
%
xyepolp_lh = [0]*ones(nr,nb_lh);%Not relevant in small FLR limit
xyepolm_lh = [0]*ones(nr,nb_lh);%Not relevant in small FLR limit
xyepolz_lh = [1]*ones(nr,nb_lh);%Only relevant polarization in small FLR limit
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




