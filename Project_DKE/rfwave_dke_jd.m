function [waveparam,xyprop_dke_rf,xyP0_in_rf,yb_rf] = ...
    rfwave_dke_jd(equil,waves,xpsin,xpsin_dke,xdpsin_dke,xpsin_S_dke,r_dke,...
    XR,XZ,XBR,XBZ,XBphi,ne_ref,lnc_e_ref,dke_mode,display_mode);
% 
%	RF input parameters for the Drift Kinetic equation solver (dke_4_1yp.m). 
%
%	Input: 
%
%	Output: 
%  
%	Warning: none
%
%by J.Decker MIT/RLE <jodecker@mit.edu> and Y.Peysson CEA/DRFC <yves.peysson@cea.fr> 04/29/2003
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
equil_id = equil.id;
method = 'spline';%interpolation technique in psi
%
nr_dke = length(xpsin_dke);
nr = length(xpsin);
%
% equilibrium data with Fourier-enhanced poloidal precision and original radial grid
%
[theta,ppsin,psia,ptR,ptZ,ptBR,ptBZ,ptBphi,pB0,pR0,pBT0,pBp0,prho,pTe,pne,pzTi,pzni,zZi,zmi,pZeff,Rp,Zp] = equilibrium_jd(equil);
%
ptr = sqrt((ptR - Rp).^2 + (ptZ - Zp).^2); %minor radius on the (psi,stheta) grid
ptBP = sqrt(ptBR.^2 + ptBZ.^2); %poloidal magnetic field on the (psi,stheta) grid
ptB = sqrt(ptBP.^2 + ptBphi.^2); %magnetic field on the (psi,stheta) grid
%
ibw = 0;
vsrays = {};
%
for iw = 1:length(waves),% 
	
    %
    % ======================================================================
    %                       treats each wave individually
    % ======================================================================
    %
    wave = waves{iw};
    %
    if wave.equil_id ~= equil_id
        error('DKE and WAVE equilibria are different')
    end
    %
    omega_rf = wave.omega_rf;% The wave frequency (in rad/s) [1,1]
    rays = wave.rays;%list of rays {1,nb}
    opt_rf = wave.opt_rf;%option for FLR calculations [1,1]
    opt_disp = wave.opt_disp;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
                                % as a function of the ray location, the equilibrium and rays_Npar.
	  %(0): given by ray-tracing code (requires the three parameters above to be given by RT)
	  %(1): solved in DKE, cold plasma model -colddisp_dke_jd-
	  %(2): solved in DKE, warm plasma model -warmdisp_dke_jd- (first order thermal corrections)
	  %(3): solved in DKE, non-relativistic hot plasma model -R2D2- (Warning: so far, electrons only)
	  %(4): solved in DKE, relativistic hot plasma model -R2D2- (Warning: so far, electrons only)
    % 
    for iray = 1:length(rays),% 
        %
        % ======================================================================
        %                       treats each ray individually
        % ======================================================================
        %
        ray = rays{iray};
        %
        % ======================================================================
        %                   calculates missing ray info if needed
        % ======================================================================
        %
        % The following information is necessary for including the
        % contribution of the ray in DKE:
        % - P0: Power launched in the ray (W) [1,1]
        % - ss: Propagation distance parameter for each ray [1,ns]
        % - spsin: Ray location (normalized magnetic flux) along the propagation [1,ns]
        % - stheta: Ray location (poloidal angle) along the propagation [1,ns]
        % - sNpar: Ray parallel wave number [1,ns]
        % - sNperp: Ray perpendicular wave number [1,ns]
        % - sdNpar: Ray spectral width in Npar [1,ns] 
        %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
        % - sepol_pmz: polarization vector [3,ns] complex
        % - sphi_pmz: normalized power flow [3,ns] 
        %
        % if these quantities are not calculated by the ray-tracing code,
        % they will be determined from the other RT output according to the
        % following scheme:
        %
        % - sR, sphi, sZ -> ss
        % - sR, sZ -> spsin, stheta
        % - skR, sn, skZ -> sNpar, sNperp
        % - sNpar -> sdNpar
        % - opt_disp, sNpar, omega_rf, equil -> sepol_pmz, sNperp, sphi_pmz
        %
        ray = rayprocess_jd(ray,equil,opt_disp,omega_rf,method);
        %
        P0 = ray.P0;% Power launched in the ray (W) [1,1]
        %
        sR = ray.sR;% Ray location (major radius) along the propagation [1,ns]
        sphi = ray.sphi;% Ray location (toroidal angle) along the propagation [1,ns]
        sZ = ray.sZ;% Ray location (vertical) along the propagation [1,ns]
        ss = ray.ss;% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
        spsin = ray.spsin;% Ray location (normalized magnetic flux) along the propagation [1,ns]
        stheta = ray.stheta;% Ray location (poloidal angle) along the propagation [1,ns]
        %
        skR = ray.skR;% Ray wave vector (major radius) along the propagation [1,ns]
        sn = ray.sn;% Ray wave number (toroidal) along the propagation [1,ns]
        skZ = ray.skZ;% Ray wave vector (vertical) along the propagation [1,ns]
        %
        sNpar = ray.sNpar;% Ray parallel wave number [1,ns]
        sNperp = ray.sNperp;% Ray perpendicular wave number [1,ns]
        sdNpar = ray.sdNpar;% Ray spectral width in Npar [1,ns] 
        %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
        %
        sepol_pmz = ray.sepol_pmz;% polarization vector [3,ns] complex
        sphi_pmz = ray.sphi_pmz;% normalized power flow [3,ns]
        %
        % Store useful information for DKE in a vsray matrix
        %
        vsray = [ss;spsin;stheta;sNpar;sNperp;sdNpar;sepol_pmz;sphi_pmz];
        %
        % Regroup vsray matrices in a list
        %
        ibw = ibw + 1;
        vsrays{ibw} = vsray;
        yomega_rf(ibw) = omega_rf;
        yopt_rf(ibw) = opt_rf;
        yP0(ibw) = P0;
    end
end
%
% ======================================================================
%           Discretization of the rays on the flux-surfaces
% ======================================================================
%
[xyvray_dke,xyfinc_dke_rf,xyprop_dke_rf,yb] = propagation_jd(vsrays,xpsin_dke,xdpsin_dke,xpsin_S_dke,theta,ppsin,ptR,ptBP,psia,method,display_mode);
disp('-------------------------------------------------------------------------------------------------------------------');
%
nb_rf = size(yb,2);%number of actual rays
nbb_rf = size(xyvray_dke,2);%number of ray subdivisions
%
if nb_rf == 0%no rays
    waveparam = [];
    xyprop_dke_rf = [];
    xyP0_in_rf = [];
    yb_rf = [];
    %    
    return
end
%
yb_rf = yb(1,:);%position of ray starts
ib_old = yb(2,:);%corresponding old ray number
%
% original ray number indices
%
for ibb = 1:nbb_rf
    ib_rf(ibb) = max(find(yb_rf <= ibb));%new ray number
end
ib_rf_old = ib_old(ib_rf);%old ray number (may be different if some rays did not enter the plasma)
%
% parameters that do not vary along the ray
%
xyomega_rf = ones(nr,1)*yomega_rf(ib_rf_old);% wave frequency
xyopt_rf = ones(nr,1)*yopt_rf(ib_rf_old);% FLR option
%
% parameters that vary along the ray and are so far calculated for dke positions only
%
% Note: for positions that are not visited by the ray, we set xyP0_in_rf = 0
%
xymask_prop_dke = xyprop_dke_rf ~= 0;%DKE points visited by the ray
if dke_mode == 1 % interpolation for the FP positions (only necessary if dke_mode == 1)
%    
    xyvray = zeros(nr,nbb_rf,12);
    xyfinc_rf = zeros(nr,nbb_rf);
    xyP0_in_rf = zeros(nr,nbb_rf);
%
    for ibb = 1:nbb_rf
    	dbstop 177
        xmask_prop_fp = [(min(r_dke(xymask_prop_dke(:,ibb))) - 1):(max(r_dke(xymask_prop_dke(:,ibb))) + 1)];%corresponding FP points
%        
        xyvray(xmask_prop_fp,ibb) = interp1(xpsin_dke(xymask_prop_dke(:,ibb)),xyvray_dke(xymask_prop_dke(:,ibb)),xpsin(xmask_prop_fp),method);
        xyfinc_rf(xmask_prop_fp,ibb) = interp1(xpsin_dke(xymask_prop_dke(:,ibb)),xyfinc_dke_rf(xymask_prop_dke(:,ibb)),xpsin(xmask_prop_fp),method);
        xyP0_in_rf(xmask_prop_fp,ibb) = yP0(ib_rf_old(ibb));% initial incident power
%        
    end
else
    xyvray = xyvray_dke;
    xyfinc_rf = xyfinc_dke_rf;
    xyP0_in_rf = xymask_prop_dke.*(ones(nr,1)*yP0(ib_rf_old));% initial incident power
end
%
xythetab_rf = xyvray(:,:,3);
xyNpar_in = xyvray(:,:,4);
xyNperp_rf = xyvray(:,:,5);
xydNpar_in = xyvray(:,:,6);
xyepolp_rf = xyvray(:,:,7);
xyepolm_rf = xyvray(:,:,8);
xyepolz_rf = xyvray(:,:,9);
xyphip_rf = xyvray(:,:,10);
xyphim_rf = xyvray(:,:,11);
xyphiz_rf = xyvray(:,:,12);
%
% Spectral properties
%
xyNparmin_rf = NaN*ones(nr,nbb_rf);
xyNparmax_rf = NaN*ones(nr,nbb_rf);
xyNpar_rf = NaN*ones(nr,nbb_rf);
xydNpar_rf = NaN*ones(nr,nbb_rf);
%
xymaskGauss_rf = find(imag(xydNpar_in) == 0);
xymaskSquare_rf = find(imag(xydNpar_in) ~= 0);
%
xyNpar_rf(xymaskGauss_rf) = xyNpar_in(xymaskGauss_rf);
xydNpar_rf(xymaskGauss_rf) = xydNpar_in(xymaskGauss_rf);
%
xyNparmin_rf(xymaskSquare_rf) = xyNpar_in(xymaskSquare_rf) - imag(xydNpar_in(xymaskSquare_rf))/2;
xyNparmax_rf(xymaskSquare_rf) = xyNpar_in(xymaskSquare_rf) + imag(xydNpar_in(xymaskSquare_rf))/2;
%
wpe_ref = sqrt(ne_ref*qe^2/e0/me);
%
xyabsphi_pmz_rf = sqrt(abs(xyphip_rf).^2 + abs(xyphim_rf).^2 + abs(xyphiz_rf).^2);
%
xyabsphi_pmz_rf(xyabsphi_pmz_rf == 0) = eps;%avoid singularities
xydNpar_rf(xydNpar_rf == 0) = eps;%avoid singularities
%
[xyBb_rf,xyBPb_rf,xyrb_rf,xyRb_rf] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_rf,method);
%
xyD0_rf_ref = xyfinc_rf.*xyP0_in_rf./(xyrb_rf.*xyRb_rf*me*lnc_e_ref.*xyomega_rf*wpe_ref^2.*xyabsphi_pmz_rf);
%
waveparam = zeros(nr,nbb_rf,12);
%
waveparam(:,:,1) = xyomega_rf;%RF wave frequency
waveparam(:,:,2) = xyopt_rf;%Options for Larmor radius effects and/or EBW calc. 
waveparam(:,:,3) = xythetab_rf;%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
waveparam(:,:,4) = xyD0_rf_ref;%RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
waveparam(:,:,5) = xyNparmin_rf;%Square N// spectrum: Lower limit
waveparam(:,:,6) = xyNparmax_rf;%Square N// spectrum: Upper limit
waveparam(:,:,7) = xyNpar_rf;%Gaussian N// spectrum: peak n//
waveparam(:,:,8) = xydNpar_rf;%Gaussian N// spectrum: width in n//
waveparam(:,:,9) = xyNperp_rf;%RF wave : n_perp
waveparam(:,:,10) = xyepolp_rf;%RF wave : polarization plus
waveparam(:,:,11) = xyepolm_rf;%RF wave : polarization minus
waveparam(:,:,12) = xyepolz_rf;%RF wave : polarization parallel
%