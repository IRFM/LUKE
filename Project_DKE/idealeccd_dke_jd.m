function waveparam = idealeccd_dke_jd(xrho,betath_ref,xrbetath,xrnhuth,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xB0);
%
% Creates wave parameters for test mode ECCD calculations
% This function has a benchmarking purpose only
% Aproximations: 
%   - The wave is purely electromagnetic: the power flow is in the direction of the wave vector.
%   - Only one polarization is accounted for (parallel for O mode and -rotating for X mode)
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
qe = 1.6022e-19;%Electron charge (C)
me = 9.1094e-31;%Electron rest mass (Kg)
%
[blist_ec,yY_ec,yomega_ec,ynpar_ec,ydnpar_ec,...
    yD0_in_c_ec,yD0_in_ec_prof,ypeak_ec,ywidth_ec,ythetab_ec,yopt_ec,yepolc_ec,yn_ec] = psim_idealeccd_jd;
%
nr = length(xrho);
nb_ec = length(blist_ec);
if nb_ec == 0, 
    blist_ec=ones(1,nb_ec); %for correct empty matrix size management
end
%
ytest_maskY_ec =  ~isnan(yY_ec(blist_ec));
ytest_maskomega_ec =  ~isnan(yomega_ec(blist_ec));
ytest_input_ec = [ytest_maskY_ec;ytest_maskomega_ec];
%
if sum(ytest_input_ec) ~= ones(1,nb_ec)
    error('EC frequency input not compatible')
end
%
xyY_ec = ones(nr,1)*yY_ec(blist_ec);
xyomega_ec = 2*pi*1e9*ones(nr,1)*yomega_ec(blist_ec);%(Hz - > rad/s)
xynpar_ec = ones(nr,1)*ynpar_ec(blist_ec);
xydnpar_ec = ones(nr,1)*ydnpar_ec(blist_ec);
xyD0_in_c_ec = ones(nr,1)*yD0_in_c_ec(blist_ec);
xypeak_ec = ones(nr,1)*ypeak_ec(blist_ec);
xywidth_ec = ones(nr,1)*ywidth_ec(blist_ec);
xythetab_ec = ones(nr,1)*ythetab_ec(blist_ec)*pi/180;%(deg -> rad)
xyopt_ec = ones(nr,1)*yopt_ec(blist_ec); 
xyepolc_ec = ones(nr,1)*yepolc_ec(blist_ec); 
xyn_ec = ones(nr,1)*yn_ec(blist_ec); 
%
xyrho = repmat(xrho',[1,nb_ec]);
xyrbetath_ec = repmat(xrbetath',[1,nb_ec]);
xyrnhuth_ec = repmat(xrnhuth',[1,nb_ec]);
%
xynparmin_ec = NaN*ones(nr,nb_ec);
xynparmax_ec = NaN*ones(nr,nb_ec);
%
yD0_in_ec_prof = logical(yD0_in_ec_prof(blist_ec));
%
xyD0_in_ec = zeros(nr,nb_ec);
xyD0_in_ec(:,yD0_in_ec_prof) = exp(-(xyrho(:,yD0_in_ec_prof) - xypeak_ec(:,yD0_in_ec_prof)).^2./(xywidth_ec(:,yD0_in_ec_prof)/2/sqrt(log(2))).^2).*xyD0_in_c_ec(:,yD0_in_ec_prof);%Gaussian radial profile on midplane
xyD0_in_ec(:,~yD0_in_ec_prof) = xyD0_in_c_ec(:,~yD0_in_ec_prof);%Uniform radial profile
%
xyD0_ec_ref_in = xyD0_in_ec.*xyrnhuth_ec.*xyrbetath_ec.*xyrbetath_ec;%Normalization when norm_ref = 0
%
% when only the ratio n.wce/w is given, the EC frequency is calculated as follows
xyBb_ec = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_ec);
xywceb_ec = qe*xyBb_ec/me;
xyomega_ec(:,ytest_maskY_ec) = xyn_ec(:,ytest_maskY_ec).*xywceb_ec(:,ytest_maskY_ec)./xyY_ec(:,ytest_maskY_ec);%EC wave frequency (GHz)
%
xynperp_ec = sqrt(1 - xynpar_ec.^2);
%
%Wave polarization (norm must be 1)
%
xyepolp_ec = [0]*ones(nr,nb_ec);%e+
xyepolm_ec = xyepolc_ec/sqrt(2);%e-
xyepolz_ec = ~xyepolc_ec;%e//
%
xwce0 = qe*xB0/me;
xywce0_ec = repmat(xwce0',[1,nb_ec]);
%
%The quasilinear diffusion coefficient xyD0_ec_ref is must be transformed to the general expression
%Normalization of the diffusion coefficient for comparison with old calc. (Karney, Shoucri), see rfdiff_dke_jd
%
xyD0_ec_ref = xyD0_ec_ref_in.*xydnpar_ec*sqrt(pi);%Gaussien power spectrum
xyD0_ec_ref = xyepolc_ec*4.*(fact_dke_jd(xyn_ec - 1)).^2.*xyD0_ec_ref./(xyrbetath_ec.*betath_ref.*xynperp_ec.*xyomega_ec/2./xywce0_ec).^(2*(xyn_ec - 1))...
            + ~xyepolc_ec.*(fact_dke_jd(xyn_ec)).^2.*xyD0_ec_ref./(xyrbetath_ec.*betath_ref.*xynperp_ec.*xyomega_ec/2./xywce0_ec).^(2*xyn_ec);  
%
% old claim that an extra nultiplication by rbetath is needed for the 1/vth factor... but really not sure. 
% verify by making calculations with different reference temperatures and
% densities.
%
waveparam = zeros(nr,nb_ec,13);
%
waveparam(:,:,1) = xyn_ec;%RF resonance harmonic     
waveparam(:,:,2) = xyomega_ec;%RF wave frequency
waveparam(:,:,3) = xyopt_ec;%Options for Larmor radius effects and/or EC calc. 
waveparam(:,:,4) = xythetab_ec;%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
waveparam(:,:,5) = xyD0_ec_ref;%RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
waveparam(:,:,6) = xynparmin_ec;%Square N// spectrum: Lower limit
waveparam(:,:,7) = xynparmax_ec;%Square N// spectrum: Upper limit
waveparam(:,:,8) = xynpar_ec;%Gaussian N// spectrum: peak n//
waveparam(:,:,9) = xydnpar_ec;%Gaussian N// spectrum: width in n//
waveparam(:,:,10) = xynperp_ec;%RF wave : n_perp
waveparam(:,:,11) = xyepolp_ec;%RF wave : polarization plus
waveparam(:,:,12) = xyepolm_ec;%RF wave : polarization minus
waveparam(:,:,13) = xyepolz_ec;%RF wave : polarization parallel


