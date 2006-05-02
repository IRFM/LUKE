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
id_wave = 'LH_linear';
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
blist_lh = [1]; %Index of selected scenarios for the LH wave. [1,n_scenario_lh]
%
omega_lh = [3.7]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1]
%
%Option parameter DQL calculation
%   - (0): full FLR effects with 1/vpar dependence
%	- (1): small FLR expansion with 1/vpar dependence
%	- (2): small FLR expansion without 1/vpar dependence
opt_lh = 1; % [1,1]
%
opt_disp = 1+i;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
                            % as a function of the ray location, the equilibrium and rays_Npar.
  %(0): given by ray-tracing code (requires the three parameters above to be given by RT)
  %(1): solved in DKE, cold plasma model -colddisp_dke_jd-
  %(2): solved in DKE, warm plasma model -warmdisp_dke_jd- (first order thermal corrections)
  %(3): solved in DKE, non-relativistic hot plasma model -R2D2- (Warning: so far, electrons only)
  %(4): solved in DKE, relativistic hot plasma model -R2D2- (Warning: so far, electrons only)
%
% Choose (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
yvparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
yvparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
yNpar_lh = [3.5];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
ydNpar_lh = [0.1];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
yP0_lh = [1e-6]*1e6;% Initial power in the wave(MW) [1,n_scenario_lh]
%
ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%
% -------------------------------------------------------------------------
%
% parameters for makefile
%
ns = 1000;%for sufficient radial resolution (even number)
%
%==========================================================================
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
[equilDKE] = equilibrium_jd(equil);
%
srho = 1:-1/ns:1/ns;%radial position along the rays
%
nb_lh = length(yP0_lh);% number of stored scenarios
%
syNparmin_lh = ones(ns,1)*yNparmin_lh;
syNparmax_lh = ones(ns,1)*yNparmax_lh;
syNpar_lh = ones(ns,1)*yNpar_lh;
sydNpar_lh = ones(ns,1)*ydNpar_lh;
%
ytest_maskNpars_lh =  ~isnan(yNparmin_lh) & ~isnan(yNparmax_lh);
ytest_maskNparg_lh =  ~isnan(yNpar_lh) & ~isnan(ydNpar_lh);
ytest_input_lh = [ytest_maskNpars_lh;ytest_maskNparg_lh];
%
if sum(ytest_input_lh) ~= ones(1,nb_lh)
    error('LH Fourier spectrum input not compatible')
end
%
syNpar_lh(:,ytest_maskNpars_lh) = (syNparmax_lh(:,ytest_maskNpars_lh) + syNparmin_lh(:,ytest_maskNpars_lh))/2;
%
% sydNpar_lh is made imaginary to identify square spectrum type (see rfwave)
sydNpar_lh(:,ytest_maskNpars_lh) = i*(syNparmax_lh(:,ytest_maskNpars_lh) - syNparmin_lh(:,ytest_maskNpars_lh));
%
syrho = srho'*ones(1,nb_lh);
sythetab_lh = ones(ns,1)*ythetab_lh;
%
syR = equilDKE.Rp + equilDKE.ap*syrho.*cos(sythetab_lh);
syZ = equilDKE.Zp + equilDKE.ap*syrho.*sin(sythetab_lh);
syphi = [0]*ones(ns,nb_lh);% so that the calculated finc is 1.
%
syNperp_lh = 1/eps*ones(ns,nb_lh);%to select slow mode
%
for i_lh = blist_lh,
    ray.P0 = yP0_lh(i_lh)';% Power launched in the ray (W) [1,1]
        %
    ray.sR = syR(:,i_lh)';% Ray location (major radius) along the propagation [1,ns]
    ray.sphi = syZ(:,i_lh)';% Ray location (toroidal angle) along the propagation [1,ns]
    ray.sZ = syphi(:,i_lh)';% Ray location (vertical) along the propagation [1,ns]
        %
    ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
    ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
    ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
        %
    ray.skR = [];% Ray wave vector (major radius) along the propagation [1,ns]
    ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
    ray.skZ = [];% Ray wave vector (vertical) along the propagation [1,ns]
        %
    ray.sNpar = syNpar_lh(:,i_lh).';% Ray parallel wave number [1,ns]
    ray.sNperp = syNperp_lh(:,i_lh).';% Ray perpendicular wave number [1,ns]
    ray.sdNpar = sydNpar_lh(:,i_lh).';% Ray spectral width in Npar [1,ns] 
        %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
        %
    ray.sepol_pmz = [];% polarization vector [3,ns] complex
    ray.sphi_xyz = [];% normalized power flow [3,ns]
    %
    ray = rayprocess_jd(ray,equil,opt_disp,omega_lh,0,'spline');
    %
    ray.sphi_xyz(3,:) = 0;% because the parallel propagation is not accounted. 
    %
    rays{i_lh} = ray;
end
%
opt_disp = 0;%calculations for nperp, polarization and energy flow density done in rayprocess
%  
wave.omega_rf = omega_lh;
wave.opt_rf = opt_lh;%option for FLR calculations [1,1]
wave.opt_disp = opt_disp;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
wave.equil_id = id_equil;
wave.rays = rays;
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);

