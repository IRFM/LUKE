%************************************** DRIFT KINETIC CODE PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file DKEPARAM_dkeparam_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
dkeparam_id = 'TScirc';%Set here the name (identifier) of the drift kinetic code parameters
%
%Mesh size calculation
%
dkeparam.grid_uniformity = 0;%Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test for DKE, transient and pitch-angle grid only)
dkeparam.grid_method = 1;%Pitch-angle grid calculation technique: (0): old method, (1) new method
dkeparam.nmhu_S = 151;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
dkeparam.np_S = 151;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.
dkeparam.pnmax_S = 30;%Maximum value of the flux momentum grid (pth_ref)
%
%Pitch-angle grid
%
dkeparam.sfac0 = 1; % reduction factor for fine grid near mhu = 0
dkeparam.sfac1 = 2; % reduction factor for fine grid near abs(mhu) = 1
dkeparam.sfact = 2; % reduction factor for fine grid near abs(mhu) = mhut
%
dkeparam.snmhu0 = 1; % number of fine grid points near mhu = 0
dkeparam.snmhu1 = 1; % number of fine grid points near abs(mhu) = 1
dkeparam.snmhut = 1; % number of fine grid points near abs(mhu) = mhut
%
dkeparam.grid_power = 1.5; % power for mhu grid step varations (grid_power > 1) (Note: for grid_method = 1 only)
%
%Momentum grid
%
dkeparam.np_S_ref = 20;%position in the mpomentum grid where dpn_S is twice the minimum value(must be ajusted with snp parameter)
dkeparam.snp = 2;%pgridfactor (Uniform grid: pgridfactor = 1, non-uniform grid: pgridfactor > 1) 
dkeparam.spfac = 20;%reduction factor for the momentum supergrid used in collision integrals
%
%Normalized radii at which the distribution is calculated (DKE or FP)
%The syntax rho='all' may be also used if all mhu values are considered. 
%
dkeparam.dpsin_dke = 0.01;%maximum difference between two consecutive positions used for radial derivatives
%
dkeparam.ref_mode = 0;%Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized radius (paramater only active for a single radial value, otherwise ref_mode = 0)
%
% Collision operator
%
dkeparam.coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
%
% Ray-tracing and RF waves
%
dkeparam.rt_mode = 0;%RT-DKE power consistency
dkeparam.nit_rf = 20;%Maximum number of iteration in ray-tracing. Works only if rt_mode = 1 and more than one radial point (default = 1)
dkeparam.prec_rf = 1e-4;%relative precision in RT-DKE iterations
dkeparam.nmax_rf = 10;%Maximum number of harmonics in the Dql calculations
%
% Run mode
%
dkeparam.bounce_mode = 1;%Bounce averaging option: (0) no bounce averaging, (1) bounce averaging full implicit method with 15 diagonals
dkeparam.dke_mode = 1;%Fokker-Planck equation (0), Drift Kinetic equation (1)
dkeparam.equil_mode = 1;%Equilibrium option: (0) circular concentric flux-surfaces, (1) numerical equilibrium
dkeparam.syn_mode = 0;%Synergy calculation: (0) none, (1) yes: the code runs twice, including once without RF or electric fields. (only if dke_mode = 1)
%
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.prec0_f = 1e-11;%Convergence level of the residu
dkeparam.nit_f = 500;%Maximum number of iterations for f (> 1)
dkeparam.initguess_f = 0;%Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file
dkeparam.initfile_f = '';%If initguess_f = 2. The file must be in the directory Project_DKE, and created by dke_4_1yp.m 
%
dkeparam.boundary_mode_g = 0;%Number of points where the first distribution function for the Lorentz model is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.prec0_g = 1e-11;%Convergence level of the residu (if NaN, iterations stop with nit_g)
dkeparam.nit_g = 100;%Maximum number of iterations for g
%
%WARNING: param_inv must evolve like [1e-5,<2-3],[1e-4,<4-5],[1e-3,<9-10],[1e-2,<19-20] when RF waves are applied. Otherwise, density is not conserved !
%Values may have to be adjusted regarding the matrix size 
%Quite all inversion methods here proposed are equivalent in term of rate of convergence. 
%If matrix preconditionning is ill-conditionned, try to reduce param_inv(1) and param_inv(2) accordingly
%
dkeparam.dtn = 10000;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
dkeparam.invproc = 1;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
dkeparam.param1_inv = 1e-4;%Parameters for the matrix inversion procedure. Minimum value of the drop tolerance for the partial LU decomposition (drop tol = max(1/dtn/nr,param_inv(1)))
dkeparam.param2_inv = 4;%Parameters for the matrix inversion procedure. Maximum number of iteration for iterative method< 20 (param_inv(1) depends of boundary_mode, if param_inv(1)=0, full LU factorization)
dkeparam.store_mode = 0;%Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) when memory space is tight
%
eval(['save DKEPARAM_',dkeparam_id,'.mat dkeparam']);