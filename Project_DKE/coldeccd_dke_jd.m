function waveparam = coldeccd_dke_jd(ne_ref,xne_norm,xzni_norm,zZi,zmi,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
    xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec);
%
% Creates wave parameters for cold plasma ECCD calculations
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
[qe,me,mp,mn,e0] = pc_dke_yp;
%
[nr,nb_ec] = size(xyn_ec);
%
xytest_maskY_ec =  ~isnan(xyY_ec);
xytest_maskomega_ec =  ~isnan(xyomega_ec);
xytest_input_ec = xytest_maskY_ec + xytest_maskomega_ec;
%
if xytest_input_ec ~= ones(nr,nb_ec)
    error('EC frequency input not compatible')
end
%
% when only the ratio n.wce/w is given, the EC frequency is calculated as follows
[xyBb_ec,xyBPb_ec,xyrb_ec,xyRb_ec] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_ec);
xywceb_ec = qe*xyBb_ec/me;
xyomega_ec(xytest_maskY_ec) = xyn_ec(xytest_maskY_ec).*xywceb_ec(xytest_maskY_ec)./xyY_ec(xytest_maskY_ec);%EC wave frequency (GHz)
%
xne = ne_ref*xne_norm;
xzni = ne_ref*xzni_norm;
%
for ib = 1:nb_ec
    for ir=1:nr
        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk]...
            = colddisp_dke_jd(xynpar_ec(ir,ib),xyomega_ec(ir,ib),xne(ir),xzni(:,ir),zZi,zmi,xyBb_ec(ir,ib));
        %
        mask = (xywceb_ec(ir,ib) < xyomega_ec(ir,ib));
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


