function [tokname,snumber,...
grid_uniformity,grid_power,nmhu_S,np_S,pnmax_S,sfac,snmhu,snp,...
psin_S,psin_display,dpsin_dke,...
ref_mode,norm_ref,...
epsi0,epsia,eepsi,...
coll_mode,bounce_mode,dke_mode,...
vparmin_r,Dr0,pDr,Dr_model,Vr0,pVr,Vr_model,...
nhuloss,...
prec0_f,nit_f,dtn,prec0_g,nit_g,initguess,invproc,param_inv,dp_cyl,display_mode,nlevel,store_mode,diary_mode,auto_mode] = psim_dke_1yp;
% 
%Simulation parameters for script_dke_1yp (Drift Kinetic equation solver)
% 
%	Input: None
%
%	Output: See the comments
%  
%	Warning: none
%
%by Y.Peysson CEA-DRFC 15/10/2002 <yves.peysson@cea.fr>
%
tokname = 'CMOD';%Tokamak equilibrium scenario (in EQUIL_tokname file)
snumber = 1;%Simulation number
%
%Mesh size calculation
%
grid_uniformity = -1;%Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test DKE, transient)
grid_method = 1;%Pitch-angle grid calculation technique: (0): old method, (1) new method
nmhu_S = 120;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
np_S = 109;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run)
pnmax_S = 15;%Maximum value of the flux momentum grid (pth_ref)
%
%Pitch-angle grid
%
sfac0 = 1; % reduction factor for fine grid near mhu = 0
sfac1 = 2; % reduction factor for fine grid near mhu = 1
sfact = 3; % reduction factor for fine grid near mhu = mhut
%
snmhu0 = 5; % number of fine grid points near mhu = 0
snmhu1 = 2; % number of fine grid points near mhu = 1
snmhut = 3; % number of fine grid points near mhu = mhut
%
grid_power = 1.5; % power for mhu grid step varations (grid_power > 1) (Note: for grid_method = 1 only)
%
%Momentum Grid
%
snp = eps;%pgridfactor (Uniform grid: pgridfactor << 1, non-uniform grid: pgridfactor >= 1) 
%
%Normalized radii at which the distribution is calculated (DKE or FP)
%The syntax rho='all' may be also used if all mhu values are considered. 
%
%Values of the radial flux grid [1,p] (If one radial value: local calculation only)
%
psin_S = [];
rho_S = [0.71365];
%
psin_display = NaN;%Approximate radial value at which results are displayed if display_mode >= 1 [1,1]
rho_display = 0.7;
%
dpsin_dke = 0.02;%maximum difference between two consecutive positions used for radial derivatives
%
ref_mode = 0;%Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized radius (paramater only active for a single radial value, otherwise ref_mode = 0)
norm_ref = 1;%Normalization procedure for the ohmic electric field, LH and EC quasilinear diffusion: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
%
% WARNING: Not yet implemented. (see test_dke_yp)
%
epsi0 = 0.00;%Flux surface averaged core Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
epsia = 0.00;%Flux surface averaged edge Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
eepsi = 0;%Exponent for Ohmic electric field
%
% WARNING: Not yet implemented. (see test_dke_yp)
%
vparmin_r = 4;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
Dr0 = 0;%Core  radial diffusion coefficient (m^2/s)
pDr = 0;%Coefficient for the Dr radial profile
Dr_model = 0;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
Vr0 = 0;%Core radial pinch coefficient (m/s)
pVr = 0;%Coefficient for the Vr radial profile
Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), 
%
nhuloss = NaN;%Magnetic ripple loss frequency, nhuloss > 1000 (or NaN if no ripple losses)  (nhu_th) (WARNING: only valid for TORE SUPRA)
%
coll_mode = 2;%Relativistic electron-electron collision operator: (0) Maxwellian, (1) High-velocity limit, (2) Linearizeded Belaiev-Budker 
%
bounce_mode = 1;%Bounce averaging option: (0) no bounce averaging, (1) bounce averaging full implicit method with 15 diagonals
dke_mode = 1;%Fokker-Planck equation (0), Drift Kinetic equation (1)
%
prec0_f = 1e-10;%Convergence level of the residu
nit_f = 50;%Maximum number of iterations for f
dtn = 1000;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
prec0_g = 1e-10;%Convergence level of the residu (if NaN, iterations stop with nit_g)
nit_g = 50;%Maximum number of iterations for g
%
initguess = 0;%Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file
invproc = [3];%Matrix inversion method: (1) Full LU factorization, (2) qmr iterative method, (3) bicgstab iterative method, (4) cgs iterative method
param_inv = [2e-3,30];%Parameters for the matrix inversion procedure when invproc > 1. Precision of the partial LU decomposition, and maximum number of iteration for iterative methods
dp_cyl = 0.1;%Cylindrical momentum step (pth_ref)
display_mode = 2;%Display mode: (0): no, (1): partial, (2): full
nlevel = 30;%Number of level for contour plots
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
psin_S = sort([psin_S,rho2psi_jd(tokname,rho_S)]);
if isnan(psin_display), 
    psin_display=rho2psi_jd(tokname,rho_display);
end
%

