%************************************** DRIFT KINETIC CODE PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file DKEPARAM_dkeparam_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
dkeparam_id = 'BOUNCE3D_MUMPS';%Set here the name (identifier) of the drift kinetic code parameters
%
%Mesh size calculation
%
dkeparam.grid_uniformity = 0;%Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test for DKE, transient and pitch-angle grid only)
dkeparam.grid_method = 1;%Pitch-angle grid calculation technique: (0): old method, (1) new method
dkeparam.nmhu_S = 101;%Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
dkeparam.np_S = 101;%Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.
dkeparam.pnmax_S = 20;%Maximum value of the flux momentum grid (pth_ref)
%
%Pitch-angle grid
%
dkeparam.sfac0 = 1; % reduction factor for fine grid near mhu = 0
dkeparam.sfac1 = 1; % reduction factor for fine grid near abs(mhu) = 1
dkeparam.sfact = 1; % reduction factor for fine grid near abs(mhu) = mhut
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
dkeparam.snp = 1;%pgridfactor (Uniform grid: pgridfactor = 1, non-uniform grid: pgridfactor > 1) 
dkeparam.spfac = 20;%reduction factor for the momentum supergrid used in collision integrals
%
%Normalized radii at which the distribution is calculated (DKE or FP)
%The syntax rho='all' may be also used if all mhu values are considered. 
%
dkeparam.dpsin_dke = 0.001;%maximum difference between two consecutive positions used for radial derivatives
%
dkeparam.ref_mode = 0;%Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized radius (paramater only active for a single radial value, otherwise ref_mode = 0)
%
% Dql and collision operator
%
dkeparam.coll_mode = 2;%No collision operator (space plasmas): (-1), Relativistic collision operator: (0), Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
%
% Ray-tracing and RF waves
%
dkeparam.rt_mode = 0;%RT-DKE power consistency
dkeparam.abs_lim = 0.95;%Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)
dkeparam.nit_rf = 20;%Maximum number of iteration in ray-tracing. Works only if rt_mode = 1 and more than one radial point (default = 1)
dkeparam.prec_rf = 1e-4;%relative precision in RT-DKE iterations
dkeparam.n_rf_list = [0];%Vector of selected harmonics in the Dql calculations [1,n_rf]
dkeparam.delta_rt = 0;%smoothering parameter of quasilinear iterations
dkeparam.nk_abs = 1;%maximum number of iterations on a_sdNpar for full absorption (%%%%%%TODO%%%%%%% for what ?)
%dkeparam.w_mask = ;%%%%%%TODO%%%%%%%
%dkeparam.rho0 = ;%%%%%%TODO%%%%%%%
%dkeparam.seekparam.submode = ;%%%%%%TODO%%%%%%%
%dkeparam.seekparam.f_sdNpar_in = ;%%%%%%TODO%%%%%%%
%dkeparam.seekparam.f_step = ;%%%%%%TODO%%%%%%%
%dkeparam.seekparam.a_sdNpar_in = ;%%%%%%TODO%%%%%%%
%dkeparam.seekparam.a_step = ;%%%%%%TODO%%%%%%%
%
% Run mode
%
dkeparam.bounce_mode = 1;%Bounce averaging option: (0) no bounce averaging, (1) bounce averaging full implicit method with 15 diagonals
dkeparam.dke_mode = 0;%Fokker-Planck equation (0), Drift Kinetic equation (1)
dkeparam.equil_mode = 1;%Equilibrium option: (0) circular concentric flux-surfaces, (1) numerical equilibrium
dkeparam.syn_mode = 0;%Synergy calculation: (0) none, (1) yes: the code runs twice, including once without RF or electric fields. (only if dke_mode = 1)
%
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes
dkeparam.boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.prec0_f = 1e-11;%Convergence level of the residu. If NaN, dkeparam.nit_f calculations are performed, whatever the level of the residu.
dkeparam.nit_f = 50;%Maximum number of iterations for f (> 1)
dkeparam.initguess_f = 0;%Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file
dkeparam.initfile_f = '';%If initguess_f = 2. The file must be in the directory Project_DKE, and created by dke_4_1yp.m 
%
dkeparam.boundary_mode_g = 0;%Number of points where the first distribution function for the Lorentz model is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.prec0_g = 1e-11;%Convergence level of the residu (if NaN, iterations stop with nit_g)
dkeparam.nit_g = 50;%Maximum number of iterations for g
%
dkeparam.tn = 100000;%LUKE time step (1/nhuth_ref)
dkeparam.dtn = NaN;%Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)
dkeparam.opsplit = 0;%Operator splitting between momentum and radial dynamics (for tests only) (opsplit = 0: no operator splitting , opsplit = 1: operator splitting). If this field does not exist, it is equivalent to dkeparam.opsplit = 0.
%
dkeparam.invproc = -1;%Iterative matrix inversion methods
% (3) Matlab built-in qmr iterative method (MatLab built-in partial LU factorization used)
% (2) Matlab built-in bicg iterative method (MatLab built-in partial LU factorization used) 
% (1) Matlab built-in cgs iterative method (MatLab built-in partial LU factorizsation used)
% (0) Matlab built-in direct inversion without any LU factorization (NOT RECOMMANDED !)
% (-1): MUMPS parallel (or sequential) fortran 95 direct inversion (LU matrix factorization done for each time a matrix inversion is called)
% (-2): MUMPSMEX sequential fortran 95 inversion using MUMPS LU matrix factorization
% (-3): SUPERLUMEX sequential direct matrix inversion (LU matrix factorization done for each time a matrix inversion is called)
% (-4) PETSc interface (see data structure below) 
dkeparam.ludroptol = 1e-5;%Drop tolerance for the built-in MatLab partial LU decomposition (recipes: droptol = max(1/dtn/nr,param_inv(1)))
dkeparam.mlmaxitinv = 4;%Maximum number of iterations for iterative built-in MatLab matrix inversion method (between 1 and 20 usualy, if empty, mlmaxitinv = min(matrixdim,20). See matlab documentation.
dkeparam.mlprecinv = 1e-5;%Accuracy for the MatLab build-in matrix inversion.
dkeparam.MUMPSparam.nproc = 1;%number of processor used by MUMPS (depends of the computer framework). Default is 1
dkeparam.MUMPSparam.thresholdpivoting = '';%Relative threshold for numerical pivoting in the MUMPS partial LU decomposition (default MUMPS = 1e-2: NaN or empty or field not existing). Increasing this parameter will reduce sparcity. Less than 1.
dkeparam.MUMPSparam.precinv = '';%Accuracy for the MUMPS matrix inversion.(default MUMPS: NaN or empty or field not existing). Only for the solve phase.
dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
dkeparam.PETScparam.matrixtype = ' ';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = ' ';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = ' ';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
%
dkeparam.clustermode.coll_dke_jd.scheduler.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
dkeparam.clustermode.coll_dke_jd.scheduler.timeout = 200;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
dkeparam.clustermode.coll_dke_jd.scheduler.size = 2;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
dkeparam.clustermode.eecoll_dke_yp.scheduler.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
dkeparam.clustermode.eecoll_dke_yp.scheduler.timeout = 200;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
dkeparam.clustermode.eecoll_dke_yp.scheduler.size = 2;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
dkeparam.clustermode.wave_solver_yp.scheduler.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
dkeparam.clustermode.wave_solver_yp.scheduler.timeout = 200;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
dkeparam.clustermode.wave_solver_yp.scheduler.size = 2;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
dkeparam.clustermode.wave_random_yp.scheduler.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
dkeparam.clustermode.wave_random_yp.scheduler.timeout = 200;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
dkeparam.clustermode.wave_random_yp.scheduler.size = 2;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
%
dkeparam.opt_struct = 0;% (0) select only main fields from output structures (1) select all fields except ZXYD_rf and gridindex_rf (2) also select ZXYD_rf and gridindex_rf 
dkeparam.store_mode = 0;%Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) when memory space is tight
dkeparam.opt_save = 0;%Save intermediate calculations
dkeparam.opt_load = 0;%Load intermediate calculations
dkeparam.timevol = 0;% save results at intermediate times
%
dkeparam.method = 'spline';%For the pitch-angle interpolation in the prjectioon of the electron velocity distribution on the Legendre polynomial basis
dkeparam.n_gauleg = 35;%Number of Legendre polynomials for projections of the electron velocity distribution
dkeparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
eval(['save DKEPARAM_',dkeparam_id,'.mat dkeparam']);