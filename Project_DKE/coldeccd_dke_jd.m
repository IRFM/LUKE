function waveparam = coldeccd_dke_jd(xrho,lnc_e_ref,ne_ref,xne_norm,xzni_norm,zZi,zmi,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp);
%
% Creates wave parameters for cold plasma ECCD calculations
% Note: these calculations do not include any coupling to ray-tracing 
% and do not bring consistency between propagating and absorbed power densities.
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
qe = 1.6022e-19;%Electron charge (C)
me = 9.1094e-31;%Electron rest mass (Kg)
e0 = 8.8542e-12;%Free space permeability (F/m)
%
[blist_ec,yY_ec,yomega_ec,ynpar_ec,ydnpar_ec,...
    yP0_in_c_ec,yP0_in_ec_prof,ypeak_ec,ywidth_ec,yfinc_ec,ythetab_ec,yopt_ec,yepolc_ec,yn_ec] = psim_coldeccd_jd;
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
xyomega_ec = 2*pi*1e9*ones(nr,1)*yomega_ec(blist_ec);%(Hz -> rad/s)
xynpar_ec = ones(nr,1)*ynpar_ec(blist_ec);
xydnpar_ec = ones(nr,1)*ydnpar_ec(blist_ec);
xyP0_in_c_ec = ones(nr,1)*yP0_in_c_ec(blist_ec)*1e6;%(MW -> W)
xypeak_ec = ones(nr,1)*ypeak_ec(blist_ec);
xywidth_ec = ones(nr,1)*ywidth_ec(blist_ec);
xyfinc_ec = ones(nr,1)*yfinc_ec(blist_ec);
xythetab_ec = ones(nr,1)*ythetab_ec(blist_ec)*pi/180;%(deg -> rad)
xyopt_ec = ones(nr,1)*yopt_ec(blist_ec); 
xyepolc_ec = ones(nr,1)*yepolc_ec(blist_ec); 
xyn_ec = ones(nr,1)*yn_ec(blist_ec); 
%
xyrho = repmat(xrho',[1,nb_ec]);
%
xynparmin_ec = NaN*ones(nr,nb_ec);
xynparmax_ec = NaN*ones(nr,nb_ec);
%
yP0_in_ec_prof = logical(yP0_in_ec_prof(blist_ec));
%
xyP0_in_ec = zeros(nr,nb_ec);
xyP0_in_ec(:,yP0_in_ec_prof) = exp(-(xyrho(:,yP0_in_ec_prof) - xypeak_ec(:,yP0_in_ec_prof)).^2./(xywidth_ec(:,yP0_in_ec_prof)/2/sqrt(log(2))).^2).*xyP0_in_c_ec(:,yP0_in_ec_prof);%Gaussian radial profile on midplane
xyP0_in_ec(:,~yP0_in_ec_prof) = xyP0_in_c_ec(:,~yP0_in_ec_prof);%Uniform radial profile
%
% when only the ratio n.wce/w is given, the EC frequency is calculated as follows
[xyBb_ec,xyBPb_ec,xyrb_ec,xyRb_ec] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_ec);
xywceb_ec = qe*xyBb_ec/me;
xyomega_ec(:,ytest_maskY_ec) = xyn_ec(:,ytest_maskY_ec).*xywceb_ec(:,ytest_maskY_ec)./xyY_ec(:,ytest_maskY_ec);%EC wave frequency (GHz)
%
xne = ne_ref*xne_norm;
xzni = ne_ref*xzni_norm;
%
for ib = 1:nb_ec
    for ir=1:nr
        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk]...
            = colddisp_dke_jd(xynpar_ec(ir,ib),xyomega_ec(ir,ib),xne(ir),xzni(:,ir),zZi,zmi,xyBb_ec(ir,ib));
        %
        mask = (xywceb_ec < xyomega_ec(ir,ib));
        % perp. index of refraction
        NperpO = Nperpp*mask + Nperpm*~mask; 
        NperpX = Nperpp*~mask + Nperpm*mask; 
        %
        xynperp_ec(ir,ib) = NperpX*xyepolc_ec(ir,ib) + NperpO*~xyepolc_ec(ir,ib);
        %
        % polarization   
        eO_pmz = ep_pmz*mask + em_pmz*~mask; 
        eX_pmz = ep_pmz*~mask + em_pmz*mask; 
        %
        xyepolp_ec(ir,ib) = eX_pmz(1)*xyepolc_ec(ir,ib) + eO_pmz(1)*~xyepolc_ec(ir,ib);
        xyepolm_ec(ir,ib) = eX_pmz(2)*xyepolc_ec(ir,ib) + eO_pmz(2)*~xyepolc_ec(ir,ib);
        xyepolz_ec(ir,ib) = eX_pmz(3)*xyepolc_ec(ir,ib) + eO_pmz(3)*~xyepolc_ec(ir,ib);
        %
        % power flow
        phiO_pmz = phip_pmz*mask + phim_pmz*~mask; 
        phiX_pmz = phip_pmz*~mask + phim_pmz*mask; 
        %
        xyabsphi_ec(ir,ib) = norm(phiX_pmz)*xyepolc_ec(ir,ib) + norm(phiO_pmz)*~xyepolc_ec(ir,ib);
    end
end
%
wpe_ref = sqrt(ne_ref*qe^2/e0/me);
%
xyD0_ec_ref = xyfinc_ec.*xyP0_in_ec./(xyrb_ec.*xyRb_ec*me*lnc_e_ref.*xyomega_ec*wpe_ref^2.*xyabsphi_ec);
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


