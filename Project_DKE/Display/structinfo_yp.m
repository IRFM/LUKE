function [info,expert] = structinfo_yp(struct,field)
%
% This function paste up to date informations for a field of any defined structure or sub-structure used by C3PO/LUKE.
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
info = '';
%
if strcmp(struct,'dkeparam'),
    if strcmp(field,'grid_uniformity'),expert = 1;info = 'Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test for DKE, transient and pitch-angle grid only)';return;end
    if strcmp(field,'grid_method'),expert = 1;info = 'Pitch-angle grid calculation technique: (0): old method, (1) new method';return;end
    if strcmp(field,'nmhu_S'),expert = 0;info = 'Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)';return;end
    if strcmp(field,'np_S'),expert = 0;info = 'Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.';return;end
    if strcmp(field,'pnmax_S'),expert = 0;info = 'Maximum value of the flux momentum grid (pth_ref)';return;end
    if strcmp(field,'sfac0'),expert = 1;info = 'Reduction factor for fine grid near mhu = 0';return;end
    if strcmp(field,'sfac1'),expert = 1;info = 'Reduction factor for fine grid near abs(mhu) = 1';return;end
    if strcmp(field,'sfact'),expert = 1;info = 'Reduction factor for fine grid near abs(mhu) = mhut';return;end
    if strcmp(field,'snmhu0'),expert = 1;info = 'Number of fine grid points near mhu = 0';return;end
    if strcmp(field,'snmhu1'),expert = 1;info = 'Number of fine grid points near abs(mhu) = 1';return;end
    if strcmp(field,'snmhut'),expert = 1;info = 'Number of fine grid points near abs(mhu) = mhut';return;end
    if strcmp(field,'grid_power'),expert = 1;info = 'Power for mhu grid step varations (grid_power > 1) (Note: for grid_method = 1 only)';return;end
    if strcmp(field,'np_S_ref'),expert = 1;info = 'Position in the momentum grid where dpn_S is twice the minimum value (must be ajusted with snp parameter)';return;end
    if strcmp(field,'snp'),expert = 1;info = 'pgridfactor (Uniform grid: pgridfactor = 1, non-uniform grid: pgridfactor > 1) ';return;end
    if strcmp(field,'spfac'),expert = 1;info = 'Reduction factor for the momentum supergrid used in collision integrals';return;end
    if strcmp(field,'dpsin_dke'),expert = 1;info = 'maximum difference between two consecutive positions used for radial derivatives';return;end
    if strcmp(field,'ref_mode'),expert = 0;info = 'Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized radius (paramater only active for a single radial value, otherwise ref_mode = 0)';return;end
    if strcmp(field,'coll_mode'),expert = 0;info = '%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background';return;end
    if strcmp(field,'rt_mode'),expert = 0;info = 'RT-DKE power consistency';return;end
    if strcmp(field,'abs_lim'),expert = 0;info = 'Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)';return;end
    if strcmp(field,'nit_rf'),expert = 0;info = 'Maximum number of iteration in ray-tracing. Works only if rt_mode = 1 and more than one radial point (default = 1)';return;end
    if strcmp(field,'prec_rf'),expert = 1;info = 'Relative precision in RT-DKE iterations';return;end
    if strcmp(field,'n_rf_list'),expert = 0;info = 'List of harmonics in the Dql calculations';return;end
    if strcmp(field,'delta_rt'),expert = 1;info = 'Smoothering parameter of quasilinear iterations';return;end
    if strcmp(field,'Dparparmax'),expert = 1;info = 'Upper limit of the quasilinear diffusion coefficient. Important for low temperature plasmas et high power level for stability of the code';return;end
    if strcmp(field,'bounce_mode'),expert = 0;info = 'Bounce averaging option: (0) no bounce averaging, (1) bounce averaging full implicit method with 15 diagonals';return;end
    if strcmp(field,'dke_mode'),expert = 0;info = 'Fokker-Planck equation (0), Drift Kinetic equation (1)';return;end
    if strcmp(field,'equil_mode'),expert = 0;info = 'Equilibrium option: (0) circular concentric flux-surfaces, (1) numerical equilibrium';return;end
    if strcmp(field,'syn_mode'),expert = 0;info = 'Synergy calculation: (0) none, (1) yes: the code runs twice, including once without RF or electric fields. (only if dke_mode = 1)';return;end
    if strcmp(field,'norm_mode_f'),expert = 0;info = 'Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes';return;end
    if strcmp(field,'boundary_mode_f'),expert = 0;info = 'Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)';return;end
    if strcmp(field,'prec0_f'),expert = 0;info = 'Convergence level of the residu';return;end
    if strcmp(field,'nit_f'),expert = 0;info = 'Maximum number of iterations for f (> 1)';return;end
    if strcmp(field,'initguess_f'),expert = 0;info = 'Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file';return;end
    if strcmp(field,'initfile_f'),expert = 0;info = 'If initguess_f = 2. The file must be in the working directory';return;end
    if strcmp(field,'boundary_mode_g'),expert = 0;info = 'Number of points where the first distribution function for the Lorentz model is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)';return;end
    if strcmp(field,'prec0_g'),expert = 0;info = 'Convergence level of the residu (if NaN, iterations stop with nit_g)';return;end
    if strcmp(field,'nit_g'),expert = 0;info = 'Maximum number of iterations for g';return;end
    if strcmp(field,'dtn'),expert = 0;info = 'Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)';return;end
    if strcmp(field,'invproc'),expert = 0;info = 'Iterative matrix inversion methods:\n(3) Matlab built-in qmr iterative method (MatLab built-in partial LU factorization used)\n(2) Matlab built-in bicg iterative method (MatLab built-in partial LU factorization used)\n (1) Matlab built-in cgs iterative method (MatLab built-in partial LU factorizsation used)\n(0) Matlab built-in direct inversion without any LU factorization (NOT RECOMMANDED !)\n(-1): MUMPS parallel (or sequential) fortran 95 direct inversion (LU matrix factorization done for each time a matrix inversion is called)\n(-2): MUMPSMEX sequential fortran 95 inversion using MUMPS LU matrix factorization\n(-3): SUPERLUMEX sequential direct matrix inversion (LU matrix factorization done for each time a matrix inversion is called)\n(-30) PETSc interface (see data structure below)';return;end
    if strcmp(field,'ludroptol'),expert = 1;info = 'Drop tolerance for the built-in MatLab partial LU decomposition (recipes: droptol = max(1/dtn/nr,param_inv(1)))';return;end
    if strcmp(field,'mlmaxitinv'),expert = 1;info = 'Maximum number of iterations for iterative built-in MatLab matrix inversion method (between 1 and 20 usualy, if empty, mlmaxitinv = min(matrixdim,20). See matlab documentation.';return;end
    if strcmp(field,'mlprecinv'),expert = 1;info = 'Accuracy for the MatLab build-in matrix inversion.';return;end
    if strcmp(field,'MUMPSparam'),expert = 0;info = 'MUMPS matrix solver';return;end
    if strcmp(field,'PETScparam'),expert = 0;info = 'PETSc matrix solver';return;end
    if strcmp(field,'store_mode'),expert = 1;info = 'Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) when memory space is tight';return;end
    if strcmp(field,'opt_load'),expert = 1;info = 'Load intermediate calculations';return;end
    if strcmp(field,'opt_save'),expert = 1;info = 'Save intermediate calculations';return;end
%  
    info = '';
    return;
end
if strcmp(struct,'MUMPSparam'),
	if strcmp(field,'nproc'),expert = 0;info = 'Number of processor used by MUMPS solver (depends of the computer framework). Default is 1';return;end
    if strcmp(field,'thresholdpivoting'),expert = 1;info = 'Relative threshold for numerical pivoting in the MUMPS partial LU decomposition (default MUMPS = 1e-2: NaN or empty or field not existing). Increasing this parameter will reduce sparcity. Less than 1.';return;end
    if strcmp(field,'precinv'),expert = 1;info = 'Accuracy for the MUMPS matrix inversion.(default MUMPS: NaN or empty or field not existing). Only for the solve phase.';return;end
%
    info = '';
    return;
end
if strcmp(struct,'PETScparam'),
	if strcmp(field,'nproc'),expert = 0;info = 'Number of processors used by PETSc (depends of the computer framework). Default is 1';return;end
	if strcmp(field,'matrixtype'),expert = 1;info = 'Matrix type used by PETSc. For SUPERLU use ''-matload_type superlu_dist'' otherwise '' ''. See PETSc documentation';return;end
	if strcmp(field,'kspmethod'),expert = 1;info = 'KSP method used by PETSc. ''-ksp_type preonly'': no iteration, direct matrix solve. Otherwise ''-ksp_type bicg'' or ''-ksp_type bcgs''  for example. See PETSc documentation';return;end
	if strcmp(field,'pcmethod'),expert = 1;info = 'Preconditioning method used by PETSc. ''-pc_type lu'' for SUPERLU or ''-pc-type hypre'' for HYPRE.  See PETSc documentation';return;end
	if strcmp(field,'cloop'),expert = 0;info = 'First order collision selfconsistency is done internaly in C (1) or in MatLab (0)';return;end
%
    info = ''; 
    return;
end
%

