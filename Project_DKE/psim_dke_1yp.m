function [tokname,snumber,...
grid_uniformity,grid_power,nmhu_S,np_S,pnmax_S,sfac,spfac,snmhu,snp,...
psin_S,psin_display,dpsin_dke,...
ref_mode,norm_ref,...
epsi0,epsia,eepsi,...
rf_list,nit_rf,prec_rf,...
coll_mode,bounce_mode,dke_mode,equil_mode,...
vparmin_r,Dr0,pDr,Dr_model,Vr0,pVr,Vr_model,...
nhuloss,...
norm_mode_f,boundary_mode_f,prec0_f,nit_f,initguess_f,...
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
tokname = 'TS';%Tokamak equilibrium scenario (see ptok_dke_1yp.m) in EQUIL_tokname file)
loadequil = 2;%0: Load already existing equilibrium file, 1: create equilibrium with HELENA (needs mex file), 2: create equilibrium file (with idealequil_f_jd.m function)
qopt = 1;%Option for q profile. (0): constant (default), (1): from qmin and eq (for HELENA, it is used only for the psi grid guess)
%
%Additional specific parameters for ideal cylindrical magnetic equilibrium with circular concentric flux surfaces (used if loadequil = 2 only)
%
npsi = 101;%Size of the psi grid for the magnetic equilibrium (ntheta is fixed for HELENA)
ntheta = 65;%Size of the theta grid for the magnetic equilibrium (ntheta ~= npsi)
%
%Mesh size calculation
%
grid_uniformity = 0;%Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test DKE, transient)
grid_method = 1;%Pitch-angle grid calculation technique: (0): old method, (1) new method
nmhu_S = 101;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
np_S = 101;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run)
pnmax_S = 15;%Maximum value of the flux momentum grid (pth_ref)
%
%Pitch-angle grid
%
sfac0 = 1; % reduction factor for fine grid near mhu = 0
sfac1 = 1; % reduction factor for fine grid near mhu = 1
sfact = 1; % reduction factor for fine grid near mhu = mhut
%
snmhu0 = 3; % number of fine grid points near mhu = 0
snmhu1 = 3; % number of fine grid points near mhu = 1
snmhut = 3; % number of fine grid points near mhu = mhut
%
grid_power = 1.5; % power for mhu grid step varations (grid_power > 1) (Note: for grid_method = 1 only)
%
%Momentum grid
%
snp = 10;%pgridfactor (Uniform grid: pgridfactor << 1, non-uniform grid: pgridfactor >= 1) 
spfac = 20;%reduction factor for the supergrid used in collision integrals
%
%Normalized radii at which the distribution is calculated (DKE or FP)
%The syntax rho='all' may be also used if all mhu values are considered. 
%
%Values of the radial flux grid [1,p] (If one radial value: local calculation only)
%
psin_S = [];%5.286742555900838e-002; %[0.1]%(rho = 0.25 in CMOD)
rho_S = [0.2,0.6];%;0.03322100141578101;0.71365;
%
psin_display = NaN;%Approximate radial value at which results are displayed if display_mode >= 1 [1,1]
rho_display = 0.1;
%
dpsin_dke = 0.01;%maximum difference between two consecutive positions used for radial derivatives
%
ref_mode = 1;%Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized radius (paramater only active for a single radial value, otherwise ref_mode = 0)
norm_ref = 0;%Normalization procedure for the ohmic electric field, LH and EC quasilinear diffusion: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
% Ohmic electric field
%
epsi0 = 0.0;%Flux surface averaged core Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
epsia = 0.0;%Flux surface averaged edge Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
eepsi = 0;%Exponent for Ohmic electric field
%
% RF Waves
%
rf_list(1) = 0;%(1): include LH test calculations (see psim_ideallhcd_jd); (0) do not include
rf_list(2) = 0;%(1): include EC  calculations (see psim_idealeccd_jd); (0) do not include
rf_list(3) = 0;%(1): include cold LHCD calculations (see psim_coldlhcd_jd); (0) do not include
rf_list(4) = 0;%(1): include cold ECCD calculations (see psim_coldeccd_jd); (0) do not include
rf_list(5) = 0;%(1): include hot ECCD calculations (see psim_warmeccd_jd); (0) do not include
rf_list(6) = 0;%(1): include EBW calculations (see psim_ebw_jd); (0) do not include
%
rt_mode = 0;% ray-tracing mode (1): Yes (iterations for self-consistent damping between RT and DKE) (0): No (only one run)
nit_rf = 20;% maximum number of iteration in ray-tracing (only if rt_mode=1)
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
coll_mode = 2;%Relativistic collision operator: (0) Maxwellian, (1) High-velocity limit, (2) Linearized Belaiev-Budker - (3) No relativistic Lorentz model
%
% Run mode
%
bounce_mode = 1;%Bounce averaging option: (0) no bounce averaging, (1) bounce averaging full implicit method with 15 diagonals
dke_mode = 1;%Fokker-Planck equation (0), Drift Kinetic equation (1)
equil_mode = 0;%Equilibrium option: (0) circular concentric flux-surfaces, (1) numerical equilibrium
%
norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes
boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
prec0_f = 1e-10;%Convergence level of the residu
nit_f = 50;%Maximum number of iterations for f
initguess_f = 0;%Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file
%
boundary_mode_g = 1;%Number of points where the first distribution function for the Lorentz model is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
prec0_g = 1e-10;%Convergence level of the residu (if NaN, iterations stop with nit_g)
nit_g = 50;%Maximum number of iterations for g
%
dtn = 1000;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
invproc = [2];%Iterative matrix inversion method: (1) qmr iterative method, (2) bicgstab iterative method, (3) cgs iterative method
param_inv = [2e-5,30];%Parameters for the matrix inversion procedure. Precision of the partial LU decomposition, and maximum number of iteration for iterative methods (param_inv(1) depends of boundary_mode, if param_inv(1)=0, full LU factorization)
%
dp_cyl = 0.1;%Cylindrical momentum step (pth_ref)
display_mode = 1;%Display mode: (0): no, (1): partial, (2): full
nlevel = 30;%Number of level for contour plots
store_mode = 0;%Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) when memory space is tight
diary_mode = 0;%Write in a file named "diary_dke_xx" the output of the code in the MatLab command window: (0) no save, (1) save
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
if rt_mode == 0 | sum(rf_list) == 0,%only one run
    nit_rf = 1;% maximum number of iteration in ray-tracing (only if rt_mode=1)
end
%

