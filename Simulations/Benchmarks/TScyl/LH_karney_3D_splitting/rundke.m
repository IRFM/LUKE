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
Dr0 = 1;
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = ['LH_karney_3D_splitting_',num2str(Dr0)];%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
%rho_S = [0,0.05:0.02:0.2,0.22:0.03:0.6,0.62:0.05:0.95,1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0:0.025:0.65,0.7:0.1:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
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
id_transpfaste = 'nomagneticturbulence';%For fast electron radial transport
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
%
%betath = 0.001;
%
%[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
%equil.pTe = betath^2*mc2*ones(size(equil.pTe));
%equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
dkeparam.prec0_f = -1;
dkedisplay.display_mode = 0;%If -1, only the radius at which the residu is the largest is displayed
%
tfinal = 5000;
dtn_list = [1,10,100,1000];
nit_f = tfinal./dtn_list;
coll_mode_list = 0;%[0,2];
optsplit_list = [0,1];
%
ncoll = length(coll_mode_list);
nopt = length(optsplit_list);
ndtn = length(dtn_list);
nit_max = max(nit_f);
nr = length(rho_S) - 1;
%
normf0_0 = NaN(nr,nit_max + 1,ndtn,nopt,ncoll);
curr0_0 = NaN(nr,nit_max + 1,ndtn,nopt,ncoll);
residu_0 = NaN(nr,nit_max,ndtn,nopt,ncoll);
%
normf0_Dr0 = NaN(nr,nit_max + 1,ndtn,nopt,ncoll);
curr0_Dr0 = NaN(nr,nit_max + 1,ndtn,nopt,ncoll);
residu_Dr0 = NaN(nr,nit_max,ndtn,nopt,ncoll);
%
for icoll = 1:ncoll,
	for iopt = 1:nopt,
    	for idtn = ndtn:-1:1,
    		%
    		dkeparam.coll_mode = coll_mode_list(icoll);
        	dkeparam.opsplit = optsplit_list(iopt);
        	dkeparam.nit_f = nit_f(idtn);
        	dkeparam.dtn = dtn_list(idtn);
        	%
        	%transpfaste.Dr0 = 0;
        	%[Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        	%
        	%normf0_0(:,1:nit_f(idtn) + 1,idtn,iopt,icoll) = dke_out.normf0;
        	%curr0_0(:,1:nit_f(idtn) + 1,idtn,iopt,icoll) = dke_out.curr0;
        	%residu_0(:,1:nit_f(idtn),idtn,iopt,icoll) = dke_out.residu_f;
        	%
        	transpfaste.Dr0 = Dr0;
        	[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        	%
        	normf0_Dr0(:,1:nit_f(idtn) + 1,idtn,iopt,icoll) = dke_out.normf0;
        	curr0_Dr0(:,1:nit_f(idtn) + 1,idtn,iopt,icoll) = dke_out.curr0;
        	residu_Dr0(:,1:nit_f(idtn),idtn,iopt,icoll) = dke_out.residu_f;
      		%
        	disp(['- collmode: ',int2str(dkeparam.coll_mode),',- opsplit: ',int2str(dkeparam.opsplit),',dtn: ',int2str(dtn_list(idtn)),' done.'])
    	end
	end
end
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
%
proc_rundke_splitting
