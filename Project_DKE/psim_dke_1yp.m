function [tokname,snumber,...
grid_uniformity,grid_power,nmhu_S,np_S,pnmax_S,sfac,spfac,snmhu,snp,np_S_ref,...
psin_S,psin_display,dpsin_dke,...
ref_mode,norm_ref,...
epsi0,epsia,eepsi,...
rf_list,nit_rf,prec_rf,...
coll_mode,bounce_mode,dke_mode,equil_mode,...
vparmin_r,Dr0,pDr,Dr_model,Vr0,pVr,Vr_model,...
nhuloss,...
norm_mode_f,boundary_mode_f,prec0_f,nit_f,initguess_f,initfile_f,...
boundary_mode_g,prec0_g,nit_g,...
dtn,invproc,param_inv,...
dp_cyl,display_mode,nlevel,store_mode,diary_mode,auto_mode] = psim_dke_1yp;
% 
%Simulation parameters for script_dke_1yp (Drift Kinetic equation solver)
% 
%	Input: None
%
%	Output: See the comments
%  
%	Warning: none
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
snumber = 1;%Simulation number
tokname = 'CQL3D_LH';%Tokamak equilibrium scenario (see ptok_dke_1yp.m) in EQUIL_tokname file)
loadequil = 2;%0: Load already existing equilibrium file, 1: create equilibrium with HELENA (needs mex file), 2: create equilibrium file (with idealequil_f_jd.m function)
qopt = 0;%Option for q profile. (0): constant (default), (1): from qmin and eq (for HELENA, it is used only for the psi grid guess)
%
%Additional specific parameters for ideal cylindrical magnetic equilibrium with circular concentric flux surfaces (used if loadequil = 2 only)
%
npsi = 101;%Size of the psi grid for the magnetic equilibrium (ntheta is fixed for HELENA)
ntheta = 65;%Size of the theta grid for the magnetic equilibrium (ntheta ~= npsi)
%
%Mesh size calculation
%
grid_uniformity = 0;%Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test for DKE, transient and pitch-angle grid only)
grid_method = 1;%Pitch-angle grid calculation technique: (0): old method, (1) new method
nmhu_S = 201;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
np_S = 201;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.
pnmax_S = 30;%Maximum value of the flux momentum grid (pth_ref)
%
%Pitch-angle grid
%
sfac0 = 1; % reduction factor for fine grid near mhu = 0
sfac1 = 3; % reduction factor for fine grid near abs(mhu) = 1
sfact = 3; % reduction factor for fine grid near abs(mhu) = mhut
%
snmhu0 = 3; % number of fine grid points near mhu = 0
snmhu1 = 3; % number of fine grid points near abs(mhu) = 1
snmhut = 3; % number of fine grid points near abs(mhu) = mhut
%
grid_power = 1.5; % power for mhu grid step varations (grid_power > 1) (Note: for grid_method = 1 only)
%
%Momentum grid
%
np_S_ref = 20;%position in the mpomentum grid where dpn_S is twice the minimum value(must be ajusted with snp parameter)
snp = 2;%pgridfactor (Uniform grid: pgridfactor = 1, non-uniform grid: pgridfactor >= 1) 
spfac = 20;%reduction factor for the momentum supergrid used in collision integrals
%
%Normalized radii at which the distribution is calculated (DKE or FP)
%The syntax rho='all' may be also used if all mhu values are considered. 
%
%Values of the radial flux grid [1,p] (If one radial value: local calculation only)
%
psin_S = [];%5.286742555900838e-002; %[0.1]%(rho = 0.25 in CMOD)
rho_S = [0.2,0.4,0.6,0.8];%[0.05:0.07:0.9];%;0.03322100141578101;0.71365;
%
psin_display = NaN;%Approximate radial value at which results are displayed if display_mode >= 1 [1,1]
rho_display = 0.4;
%
dpsin_dke = 0.01;%maximum difference between two consecutive positions used for radial derivatives
%
ref_mode = 0;%Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized radius (paramater only active for a single radial value, otherwise ref_mode = 0)
norm_ref = 1;%Normalization procedure for the ohmic electric field, LH and EC quasilinear diffusion: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
% Ohmic electric field
%
epsi0 = 0.0;%Flux surface averaged core Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e) (WARNING: ref_mode = 0 by default when multiple radial positions are studied simultaneously, whatever the value in this file)
epsia = 0.0;%Flux surface averaged edge Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
eepsi = 0;%Exponent for Ohmic electric field
%
% RF Waves: For each of the following calculations:
% (0) do not include, (1): include without ray-tracing (RT) mode, 
% (2+): include with RT mode (iterations for self-consistent damping between
% RT and DKE) See below for details
%
rf_list(1) = 1;%[0 or 1] LH test calculations (see psim_ideallhcd_jd) 
rf_list(2) = 0;%[0 or 1] EC test calculations (see psim_idealeccd_jd) 
rf_list(3) = 0;%[0 or 1] Cold plasma LHCD calculations (see psim_coldlhcd_jd); 
rf_list(4) = 0;%[0,1 or 2] Cold plasma ECCD calculations (see psim_coldeccd_jd); (2): RT calculations in wpe << wce limit (see psim_straightray_jd) 
rf_list(5) = 0;%*** to be implemented *** Hot plasma ECCD calculations (see psim_warmeccd_jd)
rf_list(6) = 0;%*** to be implemented *** (1): EBW calculations (see psim_ebw_jd)
%
nit_rf = 20;% maximum number of iteration in ray-tracing (only in RT mode)
prec_rf = 1e-4;%relative precision in RT-DKE iterations
%
% Fast electron radial transport
%
vparmin_r = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
Dr0 = 0;%Core  radial diffusion coefficient (m^2/s)
pDr = 0;%Coefficient for the Dr radial profile
Dr_model = 1;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
Vr0 = 0;%Core radial pinch coefficient (m/s)
pVr = 0;%Coefficient for the Vr radial profile
Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
%
% Magnetic ripple losses
%
nhuloss = NaN;%Magnetic ripple loss frequency, nhuloss > 1000 (or NaN if no ripple losses) (nhu_th) (WARNING: only valid for TORE SUPRA)
%
% Collision operator
%
coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
%
% Run mode
%
bounce_mode = 1;%Bounce averaging option: (0) no bounce averaging, (1) bounce averaging full implicit method with 15 diagonals
dke_mode = 0;%Fokker-Planck equation (0), Drift Kinetic equation (1)
equil_mode = 0;%Equilibrium option: (0) circular concentric flux-surfaces, (1) numerical equilibrium
%
norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes
boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
prec0_f = 1e-11;%Convergence level of the residu
nit_f = 50;%Maximum number of iterations for f (> 1)
initguess_f = 0;%Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file
initfile_f = 'RESULTS_TS_S1.mat';%If initguess_f = 2. The file must be in the directory Project_DKE, and created by dke_4_1yp.m 
%
boundary_mode_g = 0;%Number of points where the first distribution function for the Lorentz model is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
prec0_g = 1e-11;%Convergence level of the residu (if NaN, iterations stop with nit_g)
nit_g = 100;%Maximum number of iterations for g
%
%WARNING: param_inv must evolve like [1e-5,<2-3],[1e-4,<4-5],[1e-3,<9-10],[1e-2,<19-20] when RF waves are applied. Otherwise, density is not conserved !
%Values may have to be adjusted regarding the matrix size 
%Quite all inversion methods here proposed are equivalent in term of rate of convergence. 
%If matrix preconditionning is ill-conditionned, try to reduce param_inv(1) and param_inv(2) accordingly
%
dtn = 10000;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
invproc = 1;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
param_inv = [1e-4,4];%Parameters for the matrix inversion procedure. Minimum value of the drop tolerance for the partial LU decomposition (drop tol = max(1/dtn/nr,param_inv(1))), and maximum number of iteration for iterative method< 20 (param_inv(1) depends of boundary_mode, if param_inv(1)=0, full LU factorization)
dp_cyl = 0.1;%Cylindrical momentum step (pth_ref)
nlevel = 30;%Number of level for contour plots
%
display_mode = 0;%Display mode: (0): no, (1): partial, (2): full
store_mode = 0;%Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) when memory space is tight
diary_mode = 1;%Write in a file named "diary_dke_xx" the output of the code in the MatLab command window: (0) no save, (1) save
auto_mode = 0;%(0): Interactive mode for multiple radius output display, (1): automatic mode for one output display at rho_display
%
sfac = [sfac0,sfac1,sfact];
snmhu = [snmhu0,snmhu1,snmhut];
%
if grid_method == 0
    grid_power = 0;
end
%
if coll_mode == 3 & strcmp(tokname,'TEST_LORENTZ')==0,
	tokname = 'TEST_LORENTZ';
	loadequil = 2;
	epsi0 = 0.0;
	epsia = 0.0;
	rf_list(1) = 0;
	rf_list(2) = 0;
	rf_list(3) = 0;
	rf_list(4) = 0;
	rf_list(5) = 0;
	rf_list(6) = 0;
	rt_mode = 0;
	Dr0 = 0;
	Vr0 = 0;
	nhuloss = NaN;
	info_dke_yp(2,'WARNING: Lorentz model enforced !')
end
if strcmp(tokname,'TEST_LORENTZ')==1 & coll_mode ~= 3;
	coll_mode = 3;
	loadequil = 2;
	epsi0 = 0.0;
	epsia = 0.0;
	rf_list(1) = 0;
	rf_list(2) = 0;
	rf_list(3) = 0;
	rf_list(4) = 0;
	rf_list(5) = 0;
	rf_list(6) = 0;
	rt_mode = 0;
	Dr0 = 0;
	Vr0 = 0;
	nhuloss = NaN;
	info_dke_yp(2,'WARNING: Lorentz model enforced with cylindrical magnetic equilibrium and circular magnetic flux surfaces !')	
end
%
[s,dossier,machine] = comput_dke_yp;
if loadequil == 0,%Already existing magnetic equilibrium file
	filename = ['EQUIL_',tokname,'.mat'];
	if exist([dossier,s,filename]) == 2,
		info_dke_yp(2,['Equilibrium file ',filename,' is well found.']);
	elseif exist(filename) == 2,
		copyfile(filename,[dossier,s,filename]);
		info_dke_yp(2,['Equilibrium file ',filename,' is well found.']);
	else
		error('Equilibrium file is not found !')
	end
elseif loadequil == 1,%Create magnetic equilibrium file with HELENA
	equil_mode = 1;%Numerical bounce integral calculation enforced
	filename = helenaequil_f_jd(tokname,qopt);%Calculate the equibrium parameters if tokamak name exists
	info_dke_yp(2,['HELENA magnetic equilibrium file ',filename,' has been created.']);
elseif loadequil == 2,%Create ideal cylindrical magnetic equilibrium
	filename = idealequil_f_jd(tokname,qopt,npsi,ntheta);%Calculate the equibrium parameters if tokamak name exists
	info_dke_yp(2,['Ideal magnetic equilibrium file ',filename,' has been created.']);
end
%
psin_S = sort([psin_S,rho2psi_jd(tokname,rho_S)]);
if isnan(psin_display), 
    psin_display=rho2psi_jd(tokname,rho_display);
end
%
if max(rf_list) < 2,%only one run
    nit_rf = 1;% maximum number of iteration in ray-tracing 
end
%

