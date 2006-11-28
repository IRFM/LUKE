% script make_wave_TScirc_LHtest
%
% Parameters for test mode LHCD calculations
% This function has a benchmarking purpose only
% Approximations: 
%   - Circular equilibrium required
%   - The polarization is purely electrostatic: in that case, only the parallel polarization term is non-zero.
%   - Small FLR limit: J0(z) -> 1. 
%
% by J. Decker (RLE/MIT) <jodecker@mit.edu> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
clear all
%
id_wave = 'LH_karney_offaxis_1';
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '../EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
opt_lh = 2; % [1,1]
%
%
blist_lh = [1]; %Index of selected scenarios for the LH wave. [1,n_scenario_lh]
%
% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
yvparmin_lh = [3.5];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
yvparmax_lh = [6];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
yD0_in_c_lh = [1];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
yD0_in_lh_prof = [0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
ypeak_lh = [0.1];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
ywidth_lh = [0.6];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%
% -------------------------------------------------------------------------
%
% parameters for makefile
%
ns = 1000;%for sufficient radial resolution (even number)
method = 'spline';
%
%==========================================================================
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
[equilDKE] = equilibrium_jd(equil);
%
srho = 1:-1/ns:1/ns;%radial position along the rays
%
Te0 = equilDKE.xTe(1);
ne0 = equilDKE.xne(1);
lnc_e_ref = 31.3 - 0.5*log(ne0) + log(Te0*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
betath_ref = sqrt(Te0/mc2);
nhuth_ref = qe^4*ne0.*lnc_e_ref./(4*pi*e0^2*me^2.*(clum*betath_ref).^3);%Electron collision frequency (s-1)
%
sTe = interp1(equilDKE.xrho,equilDKE.xTe,srho,method);
sne = interp1(equilDKE.xrho,equilDKE.xne,srho,method);
slnc_e = 31.3 - 0.5*log(sne) + log(sTe*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
sbetath = sqrt(sTe/mc2);
snhuth = qe^4*sne.*slnc_e./(4*pi*e0^2*me^2.*(clum*sbetath).^3);%Electron collision frequency (s-1)
swpe = sqrt(qe^2*sne/me/e0);
%
if norm_ref == 0,
    srbetath = ones(1,ns);
    srnhuth = ones(1,ns);
else
    srbetath = sbetath/betath_ref;
    srnhuth = snhuth/nhuth_ref;
end
%
nb_lh = length(yD0_in_c_lh);% number of stored scenarios
%
sythetab_lh = ones(ns,1)*ythetab_lh;
%
syvparmin_lh = ones(ns,1)*yvparmin_lh;
syvparmax_lh = ones(ns,1)*yvparmax_lh;
syNparmin_lh = ones(ns,1)*yNparmin_lh;
syNparmax_lh = ones(ns,1)*yNparmax_lh;
syNpar_lh = ones(ns,1)*yNpar_lh;
sydNpar_lh = ones(ns,1)*ydNpar_lh;
syD0_in_c_lh = ones(ns,1)*yD0_in_c_lh;
sypeak_lh = ones(ns,1)*ypeak_lh;
sywidth_lh = ones(ns,1)*ywidth_lh;
%
syrbetath_lh = repmat(srbetath',[1,nb_lh]);
syrnhuth_lh = repmat(srnhuth',[1,nb_lh]);
sybetath_loc =  repmat(sbetath',[1,nb_lh]);
%
ytest_maskvpar_lh =  ~isnan(yvparmin_lh) & ~isnan(yvparmax_lh);
ytest_maskNpars_lh =  ~isnan(yNparmin_lh) & ~isnan(yNparmax_lh);
ytest_maskNparg_lh =  ~isnan(yNpar_lh) & ~isnan(ydNpar_lh);
ytest_input_lh = [ytest_maskvpar_lh;ytest_maskNpars_lh;ytest_maskNparg_lh];
%
if sum(ytest_input_lh) ~= ones(1,nb_lh)
    error('LH Fourier spectrum input not compatible')
end
%
syvparmin_lh_loc = syvparmin_lh./syrbetath_lh;%Local Normalization (when norm_ref = 1)
syvparmax_lh_loc = syvparmax_lh./syrbetath_lh;%Local Normalization (when norm_ref = 1)
%
syNparmin_lh(:,ytest_maskvpar_lh) = 1./syvparmax_lh_loc(:,ytest_maskvpar_lh)./sybetath_loc(:,ytest_maskvpar_lh);%Conversion from vpar representation to Npar one (if yvparmax_lh not a NaN)
syNparmax_lh(:,ytest_maskvpar_lh) = 1./syvparmin_lh_loc(:,ytest_maskvpar_lh)./sybetath_loc(:,ytest_maskvpar_lh);%Conversion from vpar representation to Npar one (if yvparmin_lh not a NaN)
ytest_maskNpars_lh = logical(ytest_maskNpars_lh + ytest_maskvpar_lh);
%
syNpar_lh(:,ytest_maskNpars_lh) = (syNparmax_lh(:,ytest_maskvpar_lh) + syNparmin_lh(:,ytest_maskvpar_lh))/2;
%
% sydNpar_lh is made imaginary to identify square spectrum type (see rfwave)
sydNpar_lh(:,ytest_maskNpars_lh) = i*(syNparmax_lh(:,ytest_maskvpar_lh) - syNparmin_lh(:,ytest_maskvpar_lh));
%
yD0_in_lh_prof = logical(yD0_in_lh_prof);
%
syrho = srho'*ones(1,nb_lh);
%
syD0_in_lh = zeros(ns,nb_lh);
syD0_in_lh(:,yD0_in_lh_prof) = 2*sqrt(log(2))*exp(-(syrho(:,yD0_in_lh_prof) - sypeak_lh(:,yD0_in_lh_prof)).^2./(sywidth_lh(:,yD0_in_lh_prof)/2/sqrt(log(2))).^2).*syD0_in_c_lh(:,yD0_in_lh_prof)/sqrt(pi);%Gaussian radial profile on midplane
syD0_in_lh(:,~yD0_in_lh_prof) = syD0_in_c_lh(:,~yD0_in_lh_prof);%Uniform radial profile
%
syD0_lh = syD0_in_lh./(syrbetath_lh.*syrbetath_lh.*syrnhuth_lh);%Local Normalization
%
% Approximate values for relevant polarization and normalized power flow
% (Note: These eventually cancel out, but are useful for correct equivalent power scaling)
%
syepol_z_lh = 1./swpe'*omega_lh*ones(1,nb_lh);%approx Kperp=1, cancel out anyway
syphi_z_lh = 1./syNpar_lh;%approx Kperp=1, cancel out anyway
%
syepol_p_lh = [0]*ones(ns,nb_lh);%Not relevant in small FLR limit
syepol_m_lh = [0]*ones(ns,nb_lh);%Not relevant in small FLR limit
syphi_x_lh = [0]*ones(ns,nb_lh);%Not relevant
syphi_y_lh = [0]*ones(ns,nb_lh);%Not relevant
%
%Normalization of the diffusion coefficient for comparison with old calc. (Karney, Shoucri), see rfdiff_dke_jd
%
synorm_lh = (srho*equilDKE.ap*equilDKE.Rp*me.*slnc_e.*swpe.^2*omega_lh)'*ones(1,nb_lh).*abs(syphi_z_lh)./syepol_z_lh.^2;
%
syP0_lh = zeros(ns,nb_lh);
syP0_lh(:,ytest_maskNpars_lh) = synorm_lh(:,ytest_maskNpars_lh).*syD0_lh(:,ytest_maskNpars_lh).*(syNparmax_lh(:,ytest_maskNpars_lh) - syNparmin_lh(:,ytest_maskNpars_lh));%Square power spectrum
syP0_lh(:,ytest_maskNparg_lh) = synorm_lh(:,ytest_maskNparg_lh).*syD0_lh(:,ytest_maskNparg_lh).*sydNpar_lh(:,ytest_maskNparg_lh)*sqrt(pi);%Gaussien power spectrum
%
% Note: The initial power in the ray is a scalar. In order to take into
% account the location dependence calculated above, and which results from
% D0 normalization, profiles and dnpar, we include this dependence in phi,
% while P0 is taken to be its maximum value along the ray. 
% (since Dql ~ P/|phi|)
%
yP0_lh = max(syP0_lh);
syphi_z_lh = syphi_z_lh.*(ones(ns,1)*yP0_lh)./(syP0_lh+eps);
%
%
syNperp_lh = syNpar_lh./syepol_z_lh;%Electrostatic limit. Indicative, not relevant in small FLR limit
%
syR = equilDKE.Rp + equilDKE.ap*syrho.*cos(sythetab_lh);
syZ = equilDKE.Zp + equilDKE.ap*syrho.*sin(sythetab_lh);
syphi = [0]*ones(ns,nb_lh);% so that the calculated finc is 1.
%
for i_lh = blist_lh,
    ray.P0_2piRp = yP0_lh(i_lh)'/(2*pi*equilDKE.Rp);% Power launched in the ray (W) [1,1]
        %
    ray.sx = syR(:,i_lh)' - equil.Rp;% Ray location (major radius) along the propagation [1,ns]
    ray.sphi = syZ(:,i_lh)';% Ray location (toroidal angle) along the propagation [1,ns]
    ray.sy = syphi(:,i_lh)'- equil.Zp;% Ray location (vertical) along the propagation [1,ns]
        %
    ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
    ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
    ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
        %
    ray.skx = [];% Ray wave vector (major radius) along the propagation [1,ns]
    ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
    ray.sky = [];% Ray wave vector (vertical) along the propagation [1,ns]
        %
    ray.sNpar = syNpar_lh(:,i_lh)';% Ray parallel wave number [1,ns]
    ray.sNperp = syNperp_lh(:,i_lh)';% Ray perpendicular wave number [1,ns]
    ray.sdNpar = reshape(sydNpar_lh(:,i_lh),[1,ns]);% Ray spectral width in Npar [1,ns] 
        %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
        %
    syepol_pmz_lh = [syepol_p_lh(:,i_lh)';syepol_m_lh(:,i_lh)';syepol_z_lh(:,i_lh)'];
    syphi_xyz_lh = [syphi_x_lh(:,i_lh)';syphi_y_lh(:,i_lh)';syphi_z_lh(:,i_lh)'];
        %
    ray.sepol_pmz = syepol_pmz_lh;% polarization vector [3,ns] complex
    ray.sphi_xyz = syphi_xyz_lh;% normalized power flow [3,ns]
    %
    rays{i_lh} = ray;
end
%  
wave.omega_rf = omega_lh;
wave.opt_rf = opt_lh;%option for FLR calculations [1,1]
wave.opt_disp = 0;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
wave.equil_id = id_equil;
wave.rays = rays;
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);