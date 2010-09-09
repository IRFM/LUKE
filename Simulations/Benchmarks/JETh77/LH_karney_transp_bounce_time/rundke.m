%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
%
opt_proc = 0;%test for numerical performance test with number of processors 
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_transp_bounce_time';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
%rho_S = [0,0.05:0.02:0.2,0.22:0.03:0.6,0.62:0.05:0.95,1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0:0.025:0.65,0.7:0.1:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'JETh77';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = 'magneticturbulence';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
wavestruct.omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit opt_lh > 0
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
wavestruct.opt_lh = 2; % [1,1]
%
% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
wavestruct.norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
%
wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
wavestruct.yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
wavestruct.yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
wavestruct.yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
wavestruct.ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
wavestruct.yD0_in_c_lh = [2];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
wavestruct.yD0_in_lh_prof = [1];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
wavestruct.ypeak_lh = [0.4];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
wavestruct.ywidth_lh = [0.1];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
wavestruct.ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.dtn = 10;%Normalized integration time step
dkeparam.nit_f = 1;%Maximum number of internal iterations for f (>= 1)
%
transpfaste.Dr0 = 0;
ntime_step = 3;
%
% Magnetic equilibrium is independent of time
%
equil_init = equil;
%
waves{1} = make_idealLHwave_jd(equil_init,wavestruct);
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil_init,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
j_fe(:,1) = Zcurr.x_0;
P_fe(:,1) = ZP0.x_rf_fsav;
Itot_fe(1) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
Ptot_2piRp_fe(1) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
%
for it = 2:ntime_step,
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil_init,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out.Zf0_interp,[]);
    %
    j_fe(:,it) = Zcurr.x_0;
    P_fe(:,it) = ZP0.x_rf_fsav;
    Itot_fe(it) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
    Ptot_2piRp_fe(it) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
end
%
% Magnetic equilibrium evolves with time
%
waves{1} = make_idealLHwave_jd(equil_init,wavestruct);
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
Rp(1) = equil.Rp;
j_ve(:,1) = Zcurr.x_0;
P_ve(:,1) = ZP0.x_rf_fsav;
Itot_ve(1) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
Ptot_2piRp_ve(1) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
%
% Other time steps
% 
for it = 2:ntime_step,
    equil.Rp = equil.Rp/1.3;
    %equil.pTe = equil.pTe*1.1;
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out.Zf0_interp,[]);
    %
    Rp(it) = equil.Rp;
    j_ve(:,it) = Zcurr.x_0;
    P_ve(:,it) = ZP0.x_rf_fsav;
    Itot_ve(it) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
    Ptot_2piRp_ve(it) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
end
%
Eta_fe = equilDKE.xne(1)*Itot_fe./Ptot_2piRp_fe/(2*pi)/1e19;
Eta_ve = equilDKE.xne(1)*Itot_ve./Ptot_2piRp_fe/(2*pi)/1e19;
%
figure(1),plot(equilDKE.xrho,j_fe)
figure(2),plot(equilDKE.xrho,j_ve)
figure(3),plot([1:ntime_step],Itot_fe,'b',[1:ntime_step],Itot_ve,'r')
figure(4),plot([1:ntime_step],Ptot_2piRp_fe,'b',[1:ntime_step],Ptot_2piRp_ve,'r')
figure(5),plot([1:ntime_step],Eta_fe,'b',[1:ntime_step],Eta_ve,'r')


%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
