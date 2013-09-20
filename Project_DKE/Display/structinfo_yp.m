function [info,expert,values] = structinfo_yp(struct,field)
%
% This function paste up to date informations for a field of any defined structure or sub-structure used by C3PO/LUKE.
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
info = '';
expert = 1;
values = [];
%
switch struct
    case 'dkeparam',
        %
        switch field
            %
            case 'id',expert = 0;values = '';info = 'Provide an id for this structure';
            case 'grid_uniformity',expert = 1;values = -1:1;info = 'Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test for DKE, transient and pitch-angle grid only)';
            case 'grid_method',expert = 1;values = [0,1];info = 'Pitch-angle grid calculation technique: (0): old method, (1) new method';
            case 'nmhu_S',expert = 0;values = 11:10:401;info = 'Number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)';
            case 'np_S',expert = 0;values = 11:10:401;info = 'Number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.';
            case 'pnmax_S',expert = 0;values = [-Inf;Inf];info = 'Maximum value of the flux momentum grid (pth_ref)';
            case 'rho_S',expert = 0;values = 1:41;info = 'Number of points for radial grid calculation';
            case 'sfac0',expert = 1;values = 1:10;info = 'Reduction factor for fine grid near mhu = 0';
            case 'sfac1',expert = 1;values = 1:10;info = 'Reduction factor for fine grid near abs(mhu) = 1';
            case 'sfact',expert = 1;values = 1:10;info = 'Reduction factor for fine grid near abs(mhu) = mhut';
            case 'snmhu0',expert = 1;values = 1:5;info = 'Number of fine grid points near mhu = 0';
            case 'snmhu1',expert = 1;values = 1:5;info = 'Number of fine grid points near abs(mhu) = 1';
            case 'snmhut',expert = 1;values = 1:5;info = 'Number of fine grid points near abs(mhu) = mhut';
            case 'grid_power',expert = 1;values = [1;Inf];info = 'Power for mhu grid step varations (grid_power > 1) (Note: for grid_method = 1 only)';
            case 'np_S_ref',expert = 1;values = 2:2:100;info = 'Position in the momentum grid where dpn_S is twice the minimum value (must be ajusted with snp parameter)';
            case 'snp',expert = 1;values = [1;Inf];info = 'pgridfactor (Uniform grid: pgridfactor = 1, non-uniform grid: pgridfactor > 1) ';
            case 'spfac',expert = 1;values = [1;Inf];info = 'Reduction factor for the momentum supergrid used in collision integrals';
            case 'dpsin_dke',expert = 1;values = [0;1];info = 'maximum difference between two consecutive positions used for radial derivatives';
            case 'ref_mode',expert = 1;values = [0,1];info = 'Reference values: (0) from core Te and ne, (1) from Te and ne at the normalized radius (paramater only active for a single radial value, otherwise ref_mode = 0)';
            case 'coll_mode',expert = 0;values = 0:4;info = '%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background';
            case 'rt_mode',expert = 0;values = 0:5;info = 'RT-DKE power consistency';
            case 'abs_lim',expert = 0;values = [0;1];info = 'Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)';
            case 'nit_rf',expert = 0;values = [1,5:5:100];info = 'Maximum number of iteration in ray-tracing. Works only if rt_mode = 1 and more than one radial point (default = 1)';
            case 'prec_rf',expert = 1;values = [0;1];info = 'Relative precision in RT-DKE iterations';
            case 'n_rf_list',expert = 0;values = [0;Inf];info = 'List of harmonics in the Dql calculations';
            case 'delta_rt',expert = 1;values = [0;1];info = 'Smoothering parameter of quasilinear iterations';
            case 'Dparparmax',expert = 1;values = [0;Inf];info = 'Upper limit of the quasilinear diffusion coefficient. Important for low temperature plasmas et high power level for stability of the code';
            case 'npresmin',expert = 1;values = 0:10;info = 'Minimum number of resonant points for each ray and position';
            case 'bounce_mode',expert = 0;values = {true,false};info = 'Bounce averaging option: (0) no bounce averaging, (1) bounce averaging full implicit method with 15 diagonals';
            case 'dke_mode',expert = 1;values = {true,false};info = 'Fokker-Planck equation (0), Drift Kinetic equation (1)';
            case 'equil_mode',expert = 1;values = [0,1];info = 'Equilibrium option: (0) circular concentric flux-surfaces, (1) numerical equilibrium';
            case 'syn_mode',expert = 1;values = {true,false};info = 'Synergy calculation: (0) none, (1) yes: the code runs twice, including once without RF or electric fields. (only if dke_mode = 1)';
            case 'norm_mode_f',expert = 0;values = {true,false};info = 'Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes';
            case 'boundary_mode_f',expert = 0;values = 0:5;info = 'Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)';
            case 'prec0_f',expert = 0;values = [0;1];info = 'Convergence level of the residu';
            case 'nit_f',expert = 0;values = [1;Inf];info = 'Maximum number of iterations for f (> 1)';
            case 'initguess_f',expert = 1;values = 0:2;info = 'Initial guess for the distribution function: (0) Maxwellian, (1) Fuchs model with Tperp for LH current drive only, (2) from a file';
            case 'initfile_f',expert = 1;values = '';info = 'If initguess_f = 2. The file must be in the working directory';
            case 'boundary_mode_g',expert = 1;values = 0:5;info = 'Number of points where the first distribution function for the Lorentz model is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)';
            case 'prec0_g',expert = 1;values = [0;1];info = 'Convergence level of the residu (if NaN, iterations stop with nit_g)';
            case 'nit_g',expert = 1;values = [1;Inf];info = 'Maximum number of iterations for g';
            case 'dtn',expert = 0;values = [0;Inf];info = 'Integration time step (1/nhuth_ref) (dtn > 0: fully implicit time differencing scheme , dtn < 0: Crank-Nicholson time differencing scheme) (WARNING: dtn less than 1 when fast electron radial transport is considered)';
            case 'opsplit',expert = 1;values = {true,false};info = 'Operator splitting between momentum and radial dynamics (for tests only) (opsplit = 0: no operator splitting , opsplit = 1: operator splitting). If this field does not exist, it is equivalent to dkeparam.opsplit = 0.';
            case 'invproc',expert = 0;values = -4:3;info = 'Iterative matrix inversion methods:\n(3) Matlab built-in qmr iterative method (MatLab built-in partial LU factorization used)\n(2) Matlab built-in bicg iterative method (MatLab built-in partial LU factorization used)\n (1) Matlab built-in cgs iterative method (MatLab built-in partial LU factorizsation used)\n(0) Matlab built-in direct inversion without any LU factorization (NOT RECOMMANDED !)\n(-1): MUMPS parallel (or sequential) fortran 95 direct inversion (LU matrix factorization done for each time a matrix inversion is called)\n(-2): MUMPSMEX sequential fortran 95 inversion using MUMPS LU matrix factorization\n(-3): SUPERLUMEX sequential direct matrix inversion (LU matrix factorization done for each time a matrix inversion is called)\n(-30) PETSc interface (see data structure below)';
            case 'ludroptol',expert = 1;values = [0;1];info = 'Drop tolerance for the built-in MatLab partial LU decomposition (recipes: droptol = max(1/dtn/nr,param_inv(1)))';
            case 'mlmaxitinv',expert = 1;values = 1:20;info = 'Maximum number of iterations for iterative built-in MatLab matrix inversion method (between 1 and 20 usualy, if empty, mlmaxitinv = min(matrixdim,20). See matlab documentation.';
            case 'mlprecinv',expert = 1;values = [0;1];info = 'Accuracy for the MatLab build-in matrix inversion.';
            case 'MUMPSparam',expert = 1;info = 'MUMPS matrix solver';
            case 'PETScparam',expert = 1;info = 'PETSc matrix solver';
            case 'store_mode',expert = 1;values = {true,false};info = 'Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1) when memory space is tight';
            case 'opt_load',expert = 1;values = {true,false};info = 'Load intermediate calculations';
            case 'opt_save',expert = 1;values = {true,false};info = 'Save intermediate calculations';
            case 'clustermode',expert = 0;info = 'Distributed calculation parameters';
            otherwise,
            %
        end 
        %
    case 'MUMPSparam',
        %
        switch field
            %
            case 'nproc',expert = 0;info = 'Number of processor used by MUMPS solver (depends of the computer framework). Default is 1';
            case 'thresholdpivoting',expert = 1;info = 'Relative threshold for numerical pivoting in the MUMPS partial LU decomposition (default MUMPS = 1e-2: NaN or empty or field not existing). Increasing this parameter will reduce sparcity. Less than 1.';
            case 'precinv',expert = 1;info = 'Accuracy for the MUMPS matrix inversion.(default MUMPS: NaN or empty or field not existing). Only for the solve phase.';
            otherwise,
            %
        end
        %
    case 'PETScparam',
        %
        switch field 
            %
            case 'nproc',expert = 0;info = 'Number of processors used by PETSc (depends of the computer framework). Default is 1';
            case 'matrixtype',expert = 1;info = 'Matrix type used by PETSc. For SUPERLU use ''-matload_type superlu_dist'' otherwise '' ''. See PETSc documentation';
            case 'kspmethod',expert = 1;info = 'KSP method used by PETSc. ''-ksp_type preonly'': no iteration, direct matrix solve. Otherwise ''-ksp_type bicg'' or ''-ksp_type bcgs''  for example. See PETSc documentation';
            case 'pcmethod',expert = 1;info = 'Preconditioning method used by PETSc. ''-pc_type lu'' for SUPERLU or ''-pc-type hypre'' for HYPRE.  See PETSc documentation';
            case 'cloop',expert = 0;info = 'First order collision selfconsistency is done internaly in C (1) or in MatLab (0)';
            otherwise,
            %
        end
		%
        %
    case 'rtparam',
        %
        switch field 
            case 'rayparam',expert = 0;info = 'ray parameters';
            case 'waveparam',expert = 0;info = 'wave parameters';
            case 'fitparam',expert = 0;info = 'interpolation parameters';
            case 'C3POparam',expert = 0;info = 'distributed computing parameters';
            case 'C3POdisplay',expert = 0;info = 'display parameters';
            otherwise,
        end
		%
    case 'rayparam',
        %
        switch field 
            case 'testmode',expert = 1;values = {true,false};info = 'test mode';
            case 'tensortype',expert = 0;values = 0:4;info = 'type of dielectric tensor (0:cold, 1:warm, 2:hot, 3:weakly relativistic, 4:fully relativistic)';
            case 't0',expert = 1;values = [0;Inf];info = 'initial time';
            case 'tfinal',expert = 1;values = [0;Inf];info = 'final time';
            case 'dt0',expert = 1;values = [0;Inf];info = 'initial time step';
            case 'dS',expert = 1;values = [0;Inf];info = 'minimum recorded ray length step';
            case 'tol',expert = 1;values = [0;Inf];info = 'tolerance on dispersion relation';
            case 'kmax',expert = 1;values = [0;Inf];info = 'maximum number of recorded steps';
            case 'ncyclharm',expert = 1;values = 0:50;info = 'number of cyclotron harmonics in kinetic dielectric tensor (only for tensortype > 1)';
            case 'reflection',expert = 0;values = -10:1;info = 'negative n: n reflections enforced on vessel; (1) reflection enforced on LCFS';
            case 'rel_opt',expert = 0;values = {true,false};info = '(0) non relativistic, or (1) relativistic absorption calculation';
            case 'nperp',expert = 1;values = 00:100:5000;info = 'number of pperp points in absorption calculation';
            case 'pperpmax',expert = 1;values = 1:20;info = 'maximum value of pperp in absorption calculation';
            case 'tau_lim',expert = 0;values = [0;Inf];info = 'value of optical depth for which absorption is considered complete';
            case 'kextra',expert = 0;values = 0:100:10000;info = 'optional additional number of recorded steps after tau_lim is reached ';
            otherwise,
        end
		%
    case 'fitparam',
        %
        switch field 
            case 'method',expert = 0;values = {'linear','nearest','spline','pchip','cubic'};info = 'Method for radial interpolation';
            case 'nharm',expert = 0;values = [0;Inf];info = 'Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)';
            case 'ngridresample',expert = 1;values = [0;Inf];info = 'Number of grid points for resampling the radial profile of magnetic equilibrium parameters';
            case 'opt_load',expert = 0;values = {true,false};info = 'Reload existing vectorial magnetic equilibrium (1) or overwrite it (0)';
            case 'mode_equil',expert = 1;values = [1,2];info = 'Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)';
            otherwise,
        end
		%
    case 'clustermode',
        %
        switch field 
            case 'coll_dke_jd',expert = 0;info = 'Distributed calculation of collision operator';
            case 'eecoll_dke_yp',expert = 0;info = 'Distributed calculation of electron collision integrals';
            case 'wave_solver_yp',expert = 0;info = 'Distributed calculation of RF antennas';
            case 'rfdiff_dke_jd',expert = 0;info = 'Distributed calculation of quasilinear operator';
            otherwise,
        end
        %
    case 'coll_dke_jd',
        %
        switch field 
            case 'scheduler',expert = 0;info = 'Scheduler parameters for distributed calculation';
            otherwise,
        end
		%
    case 'eecoll_dke_yp',
        %
        switch field 
            case 'scheduler',expert = 0;info = 'Scheduler parameters for distributed calculation';
            otherwise,
        end
		%
    case 'wave_solver_yp',
        %
        switch field 
            case 'scheduler',expert = 0;info = 'Scheduler parameters for distributed calculation';
            otherwise,
        end
		%
    case 'rfdiff_dke_jd',
        %
        switch field 
            case 'scheduler',expert = 0;info = 'Scheduler parameters for distributed calculation';
            otherwise,
        end
		%
    case 'scheduler',
        %
        switch field 
            case 'mode',expert = 0;values = [-Inf;3];info = 'MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2)';
            case 'memory',expert = 0;values = [0;Inf];info = 'Allocated memory (in mb)';
            case 'timeout',expert = 1;values = 50:50:500;info = 'MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor';
            case 'clustersize',expert = 0;values = [0;Inf];info = '%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations';
            otherwise,
        end
		%
    case 'waveparam',
        %
        switch field 
            case 'mmode',expert = 0;values = [-1,1];info = 'Polarization : (1) m (-1) p, (slow/fast LH wave: -1/+1, O/X mode: -1/+1)';
            case 'kmode',expert = 0;values = [0,1];info = 'Plasma model for wave propagation : (0:cold, 1:kinetic)';
            case 'opt_rf',expert = 0;values = [0,1];info = 'FLR effects : (0:all, 1:small)';
            case 'dsmin',expert = 1;values = [0;Inf];info = 'Minimum length of ray fragments';
            case 'nd',expert = 0;values = 1:10;info = 'Number of transverse distance positions for beamlets';
            case 'nchi',expert = 0;values = 1:10;info = 'Number of angular positions for beamlets';
            case 'n_rf_list',expert = 0;values = [];info = 'List of cyclotron harmonics to consider in wave power deposition';
            case 'ns',expert = 1;values = 1:100;info = 'Ray smoothing parameter';
            otherwise,
        end
		%
    case 'launch',
        %
        switch field 
            case 'id',expert = 0;values = '';info = 'Provide an id for this launching structure';
            case 'omega_rf',expert = 0;values = [0;Inf];info = 'Wave angular frequency (rad/s)';
            case 'frequency_GHz',expert = 0;values =[0;Inf];info = 'Wave frequency (GHz)';
            % LH    
            case 'LFS',expert = 0;values = [-1,1];info = 'Launching side : (-1) high field side, (1) low field side';
            case 'm0',expert = 0;values = [-Inf;Inf];info = 'Initial poloidal mode number (enter ''NaN'' to use toroidal mode number)';
            case 'n0',expert = 1;values = [-Inf;Inf];info = 'Initial toroidal mode number (enter ''NaN'' to use poloidal mode number)';
            case 'phi0',expert = 0;values = [-pi;pi];info = 'Initial toroidal angle (in rad.)';
            case 'phi0_deg',expert = 0;values = [-180;180];info = 'Initial toroidal angle (in deg.)';
            case 'bPlhtot',expert = 0;values = [0;Inf];info = 'Initial power in each lobe (W)';
            case 'bPlhtot_MW',expert = 0;values = [0;Inf];info = 'Initial power in each lobe (MW)';
            case 'bNpar0',expert = 0;values = [-Inf;Inf];info = 'Initial Npar in each lobe';
            case 'bdNpar0',expert = 0;values = [0;Inf];info = 'Spectral width in each lobe : specify fixed value, or type ''0'' if minimum width within numerical constraints';
            case 'rZ0',expert = 0;values = [-Inf;Inf];info = 'Vertical launching positions (m)';
            % EC
            case 'yP_L',expert = 0;values = [0;Inf];info = 'Ray initial power (W)';
            case 'yP_L_kW',expert = 0;values = [0;Inf];info = 'Ray initial power (kW)';
            case 'yR_L',expert = 0;values = [0;Inf];info = 'Ray initial major radius (m)';
            case 'yZ_L',expert = 0;values = [-Inf;Inf];info = 'Ray initial vertical position (m)';
            case 'yphi_L',expert = 0;values = [-pi;pi];info = 'Ray initial toroidal position (in rad.)';
            case 'yphi_L_deg',expert = 0;values = [-180;180];info = 'Ray initial toroidal position (in deg.)';
            case 'yalpha_L',expert = 0;values = [-pi;pi];info = 'Ray initial toroidal angle (with resp. to R) (in rad.)';
            case 'yalpha_L_deg',expert = 0;values = [-180;180];info = 'Ray initial toroidal angle (with resp. to R) (in deg.)';
            case 'ybeta_L',expert = 0;values = [-pi/2;pi/2];info = 'Ray initial poloidal angle (with resp. to Z) (in rad.)';
            case 'ybeta_L_deg',expert = 0;values = [-90;90];info = 'Ray initial poloidal angle (with resp. to Z) (in deg.)';
            case 'w0',expert = 1;values = [0;Inf];info = 'Beam waist (m)';
            case 'z_L',expert = 1;values = [-Inf;Inf];info = 'Distance from last mirror to focal point (m)';            
            case 'dNpar0',expert = 1;values = [0;Inf];info = 'Beam dNpar : (0) minimal, (0->Inf) specify, (NaN) calculate from beam size';
            otherwise,
        end
        %
    case 'angles',
        %
        switch field 
            case 'id',expert = 0;values = '';info = 'Provide an id for this angles structure';
            case 'freq',expert = 0;values = [0;Inf];info = 'Wave frequency (Hz)';
            case 'frequency_GHz',expert = 0;values =[0;Inf];info = 'Wave frequency (GHz)';
            case 'P0',expert = 0;values = [0;Inf];info = 'Launched power (W)';
            case 'P0_kW',expert = 0;values = [0;Inf];info = 'Launched power (kW)';
            case 'theta',expert = 0;values = [-pi/2;pi/2];info = 'Launcher tilt angle (in rad.)';
            case 'theta_deg',expert = 0;values = [-90;90];info = 'Launcher tilt angle (in deg.)';
            case 'phi',expert = 0;values = [-pi;pi];info = 'Launcher rotation angle (in rad.)';
            case 'phi_deg',expert = 0;values = [-180;180];info = 'Launcher rotation angle (in deg.)';
            case 'w0',expert = 1;values = [0;Inf];info = 'Beam waist (m)';
            case 'z_L',expert = 1;values = [-Inf;Inf];info = 'Distance from last mirror to focal point (m)';
            case 'P1_R',expert = 1;values = [0;Inf];info = 'First mirror major radius (m)';
            case 'P1_Z',expert = 1;values = [-Inf;Inf];info = 'First mirror vertical position (m)';
            case 'P1_theta',expert = 1;values = [-pi/2;pi/2];info = 'First mirror angle (in rad.)';
            case 'P1_theta_deg',expert = 1;values = [-90;90];info = 'First mirror angle (in deg.)';
            case 'P2_R',expert = 1;values = [0;Inf];info = 'Second mirror major radius (m)';
            case 'P2_Z',expert = 1;values = [-Inf;Inf];info = 'Second mirror vertical position (m)';
            case 'P2_d',expert = 1;values = [0;Inf];info = 'Second mirror thickness (m)';
            case 'P3_Z',expert = 1;values = [-Inf;Inf];info = 'Third mirror vertical position (m)';
            otherwise,
        end
        %
    case 'transpfaste',
        %
        switch field 
            case 'id',expert = 0;values = '';info = 'Provide an id for this transpfaste structure';
            case 'Dr0',expert = 0;values = [0;Inf];info = 'Core radial diffusion coefficient (m^2/s)';
            case 'Dr_model',expert = 0;values = 0:2;info = 'Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth)';
            case 'pDr',expert = 0;values = [-Inf;Inf];info = 'Coefficient for the Dr radial profile';
            case 'Vr0',expert = 0;values = [-Inf;Inf];info = 'Core radial pinch coefficient (m/s)';
            case 'Vr_model',expert = 0;values = 0:2;info = 'Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth)';
            case 'pVr',expert = 0;values = [-Inf;Inf];info = 'Coefficient for the Vr radial profile';
            case 'vparmin',expert = 0;values = [0;Inf];info = 'Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)';
            case 'norm_ref',expert = 0;values = [0,1];info = 'Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref';
            otherwise,
        end
        %
    case 'external',
        %
        switch field 
            case 'basestr',expert = 0;values = '';info = 'Name of the tokamak';
            case 'shotnum',expert = 0;values = '';info = 'Shot number';
            case 't1',expert = 0;values = [0;Inf];info = 'Minimum time for data averaging (s)';
            case 't2',expert = 0;values = [0;Inf];info = 'Maximum time for data averaging (s)';
            otherwise,
        end        
		%
        % -------------------------- AMR structures -----------------------
        %
    case 'AMRcfg',
        %
        switch field 
            case 'input',expert = 0;info = 'input structure';
            case 'output',expert = 0;info = 'output structure';
            case 'cluster',expert = 0;info = 'cluster structure';
            case 'ray_tracing',expert = 0;info = 'ray_tracing structure';
            case 'test_profiles',expert = 0;info = 'test_profiles structure';
            case 'profiles',expert = 0;info = 'profiles structure';
            case 'integration',expert = 0;info = 'integration structure';
            otherwise,
        end
		%
    case 'input',
        %
        switch field 
            case 'experiment',expert = 0;info = 'experiment name';
            case 'shot_number',expert = 0;info = 'shot number';
            case 'start_time',expert = 0;info = 'start time of the simulation';
            case 'end_time',expert = 0;info = 'end time of the simulation';
            case 'time_samples',expert = 0;info = 'no. of time steps';
            otherwise,
        end
		%
    case 'output',
        %
        switch field 
            case 'central_ray_only',expert = 0;info = 'calculate the central rays only';
            case 'luke',expert = 0;info = 'generate LUKE output';
            otherwise,
        end
		%
    case 'cluster',
        %
        switch field 
            case 'master_priority',expert = 0;info = 'priority of the master process, i.e. the program itself if run locally 0 = lowest (nice 19), 1 = medium (nice 10), 2 = standard (nice 0)';
            otherwise,
        end
		%
    case 'ray_tracing',
        %
        switch field 
            case 'Zeff',expert = 0;info = 'Zeff (constant)';
            case 'accuracy',expert = 0;info = 'Runge-Kutta accuracy';
            case 'power_limit',expert = 0;info = 'stopping power value (1-power_limit damped)';
            otherwise,
        end
 		%
   case 'test_profiles',
        %
        switch field 
            case 'R_min',expert = 0;info = 'R_min';
            case 'R_max',expert = 0;info = 'R_max';
            case 'Z_min',expert = 0;info = 'Z_min';
            case 'Z_max',expert = 0;info = 'Z_max';
            case 'R_dim',expert = 0;info = 'R_dim';
            case 'Z_dim',expert = 0;info = 'Z_dim';
            otherwise,
        end
		%
    case 'profiles',
        %
        switch field 
            case 'input_type',expert = 0;info = 'equilibriuam and ne,Te profiles input type (matlab for LUKE)';
            case 'export',expert = 0;info = 'equilibriuam and ne,Te profiles input type (matlab for LUKE)';
            case 'export_nR',expert = 0;info = 'no. of datapoints in R';
            case 'export_nZ',expert = 0;info = 'no. of datapoints in Z';
            case 'export_npsi',expert = 0;info = 'no. of datapoints in psi';
            case 'extendProfilesDen',expert = 0;info = 'profiles extension behind the last data point';
            case 'extendProfilesTe',expert = 0;info = 'profiles extension behind the last data point';
            case 'extDataPoints',expert = 0;info = 'profiles extension behind the last data point';
            case 'LSOL_den',expert = 0;info = 'profiles extension behind the last data point';
            case 'LSOL_Te',expert = 0;info = 'profiles extension behind the last data point';
            case 'LSOL',expert = 0;info = 'SOL width, increase for low frequencies with mode conversion close to or out of LCFS';
            otherwise,
        end
		%
    case 'antenna',
        %
        switch field 
            case 'cfg_file',expert = 0;info = 'name of the antenna cfg file';
            case 'ids',expert = 0;info = 'name of the antenna cfg file';
            otherwise,
        end
 		%
   case 'integration',
        %
        switch field 
            case 'R_min',expert = 0;info = 'min, max in R and r_eff for profiles (deposition, current) integration r_eff = a0*sqrt(psi_normalized)';
            case 'R_max',expert = 0;info = 'min, max in R and r_eff for profiles (deposition, current) integration r_eff = a0*sqrt(psi_normalized)';
            case 'r_eff_min',expert = 0;info = 'min, max in R and r_eff for profiles (deposition, current) integration r_eff = a0*sqrt(psi_normalized)';
            case 'r_eff_max',expert = 0;info = 'min, max in R and r_eff for profiles (deposition, current) integration r_eff = a0*sqrt(psi_normalized)';
            case 'tabdim',expert = 0;info = 'no. of datapoints';
            otherwise,
        end
		%
    case 'antennacfg',
        %
        switch field 
            case 'general',expert = 0;info = 'general';
            case 'antenna_0',expert = 0;info = 'antenna_0';
            otherwise,
        end
		%
    case 'general',
        %
        switch field 
            case 'noOfCircles',expert = 0;info = 'noOfCircles';
            case 'raysPerCircle',expert = 0;info = 'raysPerCircle';
            otherwise,
        end
		%
    case 'general',
        %
        switch field 
            case 'model',expert = 0;info = 'antenna model';
            case 'power',expert = 0;info = 'power in kW';
            case 'toroidal_angles',expert = 0;info = 'array of toroidal angles (single value for no angle scan)';
            case 'poloidal_angles',expert = 0;info = 'array of poloidal angles (single value for no angle scan)';
            case 'angles_E_equatorial',expert = 0;info = 'array of polarization angles (single value for no angle scan)';
            case 'popolarizationwer',expert = 0;info = 'select polarization(s) (linear | linear_complementary | circular)';
            case 'frequencies',expert = 0;info = 'array of frequencies';
            otherwise,
        end
		%
        % -------------------------- METIS coupling structures -----------------------
        %
    case 'lukeparam',
        %
        switch field 
            case 'luke_mode',expert = 0;values = 0:2;info = '(0) run LUKE, (1) run LUKE then save output (2) save input then exit';
            case 'batch_mode',expert = 0;values = 0:1;info = 'run LUKE in (0) interactive mode, (1) batch mode';                
            case 'display_mode',expert = 0;values = 0:2;info = '(0) none, (1) limited (2) full display';
            case 'rho_display',expert = 1;values = [0;1];info = 'radial position for display [0;1]';
            case 'dkeparam',expert = 1;info = 'LUKE run parameters';
            case 'equilparam',expert = 1;info = 'equilibrium parameters';
            case 'lhparam',expert = 0;info = 'LH parameters';
            case 'ecparam',expert = 0;info = 'EC parameters';
            case 'transpfaste',expert = 0;info = 'radial transport parameters';
            otherwise,
        end
    case 'equilparam',
        %
        switch field 
            case 'nbpx',expert = 0;values = [0,11:10:201];info = 'number of points in interpolated radial grid (enter 0 if no interpolation required)';
            case 'mode',expert = 0;values = {'standard','sqrt(psi)','psi'};info = 'interpolation mode : linear in "standard" (xli), "sqrt(psi)", or "psi"';                
            case 'expo',expert = 0;values = [-Inf;Inf];info = 'morphing function exponent';
            case 'comp',expert = 0;values = {true,false};info = 'control of equilibrium moments reconstructed from LUKE';
            otherwise,
        end
    case 'lhparam',
        %
        switch field 
            case 'freqlh',expert = 0;values = [0;Inf];info = 'Wave frequency (GHz)';
            case 'plh',expert = 0;values = [0;Inf];info = 'Wave initial power (W)';
            case 'npar0',expert = 0;values = [-Inf;Inf];info = 'Wave initial index of refraction';
            case 'mode',expert = 0;values = 0:2;info = 'LUKE LH mode : (0) simple v1, v2, D model, (1) C3PO with ideal antenna, (2) C3PO with prescribed antenna';
            case 'plhmin',expert = 1;values = [0;Inf];info = 'Minimum power level to use wave in LUKE (W)';
            case 'directivity',expert = 0;values = [0;1];info = 'Spectrum directivity';
            case 'lob',expert = 0;values = {true,false};info = 'Include opposite lobe';
            case 'dnpar0',expert = 1;values = [0;Inf];info = 'Wave initial spectral width';
            case 'z0',expert = 0;values = [-Inf;Inf];info = 'Vertical launching positions (m)';
            case 'm0',expert = 1;values = [-Inf;Inf];info = 'Initial poloidal mode number';
            case 'phi0',expert = 1;values = [-pi;pi];info = 'Initial toroidal angle (rad)';
            case 'i_ref',expert = 1;values = -10:0;info = 'Initial radial position index (relative from edge)';
            case 'LFS',expert = 1;values = [-1,1];info = 'Launching side : (-1) high field side, (1) low field side';
            case 'mmode',expert = 0;values = [-1,1];info = 'Polarization : (1) m (-1) p, (slow/fast LH wave: -1/+1, O/X mode: -1/+1)';
            case 'a_sdNpar',expert = 1;values = [0;Inf];info = 'Spectral broadening factor (m^-1)';
            case 'nparp',expert = 1;values = [-Inf;Inf];info = 'Initial additional upshift';
            otherwise,
        end
    case 'ecparam',
        %
        switch field 
            case 'freqec',expert = 0;values = [-Inf;Inf];info = 'Wave frequency (GHz); if negative integer = harmonic number, determined from alpha, xec and polec';
            case 'pec',expert = 0;values = [0;Inf];info = 'Wave initial power (W)';
            case 'alpha_L',expert = 0;values = [-pi;pi];info = 'Toroidal launching angle (degrees); if NaN, determined from freqec, xec and polec, or from option.sens if freqec=NaN';
            case 'mode',expert = 0;values = 0:2;info = 'LUKE LH mode : (0) simple v1, v2, D model, (1) C3PO with ideal antenna, (2) C3PO with prescribed antenna';
            case 'pecmin',expert = 1;values = [0;Inf];info = 'Minimum power level to use wave in LUKE (W)';
            case 'xec',expert = 0;values = [0;Inf];info = 'Radial location of ECRH deposition (normalized METIS grid)';
            case 'polec',expert = 0;values = [0;1];info = 'Poloidal location of ECRH deposition, (degrees); if NaN, determined from freqec, xec and alpha_L';
            case 'pabs',expert = 1;values = [0;Inf];info = 'momentum at absorption (for Doppler shift)';
            case 'dnpar0',expert = 1;values = [0;Inf];info = 'Wave initial spectral width';
            case 'phi0',expert = 1;values = [-pi;pi];info = 'Initial toroidal angle (rad)';
            case 'mmode',expert = 0;values = [-1,1];info = 'Polarization : (1) m (-1) p, (O/X mode: -1/+1)';
            case 'ns',expert = 1;values = 200:200:5000;info = 'Number of points for stright line calculations';
            case 'method',expert = 1;values = {'linear','nearest','spline','pchip'};info = 'Interpolation method';
            otherwise,
        end
    %
    %%%% MIKE fields %%%%
    %
    case 'simul',
        switch field
            case 'mhd', expert = 0; info = 'Structure for MHD_DATA source file';
            case 'opt', expert = 0; info = 'Options for the MIKE simulation';
            case 'param', expert = 0; info = 'Parameters for the MIKE simulation';
            case 'davies', expert = 1; info = 'Parameters for the Davies root finding method';
        end
    case 'mhd',
        switch field
            case 'path',expert = 0; values = ''; info = 'path to MHD_DATA file';
            case 'filename',expert = 0; values = ''; info = 'name of MHD_DATA file';
            case 'machine',expert = 1; values = ''; info = 'name of the tokamak for the simulation';
            case 'shot',expert = 1; values = [0;Inf]; info = 'shot number for the simulation';
            case 'time',expert = 1; values = [0;Inf]; info = 'time of the simulation';
            case 'defname',expert = 1; values = ''; info = 'default prefix for the MIKE simulation filename';
            case 'luke_simul',expert = 1; info = 'luke_simul struct of the associated LUKE simulation';
        end
    case 'opt',
        switch field
            case 'phmode',expert = 1; values = ''; info = 'Method for dWk calculation (kinetic & fluid, fast & thermal)';
            case 'intE',expert = 1; values = 1:2; info = 'Energy integral method (main distribution) \n(1) Zfunction \n(2) Logarithm';
            case 'pnmax',expert = 1;values = [0;Inf]; info = 'Maximum value for the momentum grid (NaN for value of LUKE simulation)';
            case 'T',expert = 1; values = {true,false}; info = 'Trapped particles only';
            case 'bounce',expert = 1; values = 0:1; info = 'Expression for bounce period \n(0) Zonca \n(1) White';
            case 'drift',expert = 1; values = 0:1; info = 'Expression for drift frequency \n(0) Zonca \n(1) White';
            case 'beta',expert = 1; values = 0:1; info = 'Expression for poloidal beta \n(0) White \n(1) Zonca';
            case 'inertia',expert = 1; values = 0:1; info = 'Convention for the inertia term \n(0) Chen \n(1) Zonca';
            case 'dWcInp',expert = 0; values = {true,false}; info = 'Enforced dWc';
            case 'resistive',expert = 1; values = 0:1; info = 'Inertia term \n(0) Ideal \n(1) Resistive';
            case 'mdce',expert = 1; values = 1:3; info = 'Distributed comuting mode \n(1) Sequential computing \n(2) Matlab routine \n(3) LUKE routine';
            case 'test',expert = 1; values = {true,false}; info = 'Test/Ideal case';
            case 'F',expert = 1; values = 1:6; info = 'Type of analytical distribution (test) \n(1) slowing down \n(2) Maxwellian distribution \n(3) bi-Maxwellian \n(4) BiMaxwellian + slowing-down \n(5) BiMaxwellian + maxwellian';
            case 'E',expert = 1; values = {true,false}; info = 'Analytical energy integration (test)';
            case 'mhu',expert = 1; values = {true,false}; info = 'Analytical pitch-angle integration (test)';
            case 'rho',expert = 1; values = {true,false}; info = 'Analytical radial integration (test)';
            case 'k',expert = 1; values = 1:3; info = '(1) constant lambda, (2) constant kappa, (3) constant mhu distribution';
            case 'C',expert = 1; values = {true,false}; info = 'Locally normalized distribution';
            case 'a',expert = 1; values = {true,false}; info = 'Approximate radial dependences';
            case 'b',expert = 1; values = {true,false}; info = 'Neglect the energy derivative term';
        end
    case 'phmode',
        switch field
            case 'dist',expert = 1; values = [-1;3]; info = 'Distribution chosen for calculation \n(1) fast -1->0, 0->myFEHM, 1->XFEH, 2->myFEHP, 3->XFM-XF0 \n(2) th e- -1->0, 0->myFE, 1->XFE, 2->XFM, \n(3) th ions -1->0, 0->myFI, 1->XFI';
            case 'dWk',expert = 1; values = [0;1]; info = 'Components for dWk\n (1) fast (2) th e- (3) th ions';
            case 'dWgp',expert = 1; values = [0;1]; info = 'Components for dWgp\n (1) fast (2) th e- (3) th ions';
        end
    case 'param',
        switch field
            case 'action',expert = 0; values = 1:8; info = 'Action for MIKE simulation \n(1) Calculation for given frequency \n(2) Frequency scan \n(3) Growth rate scan \n(4) 2D Scan \n(5) Root search \n(6) Parameter Scan \n(7) Hybrid Scan (frequency) \n(8) Hybrid Scan (growth rate)';
            case 'nTor',expert = 1; values = [0;Inf]; info = 'Toroidal mode number';
            case 'nh',expert = 1; values = [-Inf;Inf]; info = 'Fast particle fraction';
            case 'S',expert = 1; values = [0;Inf]; info = 'Conductivity factor (Inf) for ideal';
            case 'dWc',expert = 0; values = [-Inf;Inf]; info = 'Value of dWc when it is enforced';
            case 'nz',expert = 1; values = [0;Inf]; info = 'Number of points for energy calc-grid (NaN for no interpolation)';
            case 'nm',expert = 1; values = [0;Inf]; info = 'Number of points for pitch-angle calc-grid (NaN for no interpolation)';
            case 'ny',expert = 1; values = [0;Inf]; info = 'Number of points for radial calc-grid (NaN for no interpolation)';
            case 'q',expert = 0; values = 0:3; info = 'Shape of the q-profile \n(0) CRONOS profile \n(1) Parabolic \n(2) Inverted \n(3) Flat then parabolic';
            case 'qpar',expert = 0; values = [-Inf;Inf]; info = 'q-profile parameters \n qfac, qtrs, qmin, qmax, rhos, rhos1, rhos2';
            case 'romega',expert = 0; values = [-Inf;Inf]; info = 'Frequency values (kHz) \n(start,end,numpts)';
            case 'iomega',expert = 0; values = [-Inf;Inf]; info = 'Growth rate values (kHz) \n(start,end,numpts)';
            case 'ScanPar',expert = 0; values = {'dWc','nh','S','qfac','qtrs','qmin','qmax','rhos','rhos1','rhos2'}; info = 'Scan parameter';
            case 'parVal',expert = 0; values = [-Inf;Inf]; info = 'Scan parameter values \n(start,end,numpts)';
            case 'omega0',expert = 0; values = [-Inf;Inf]; info = 'Starting frequency for root search method (kHz)';
            case 'domega',expert = 0; values = [0;Inf]; info = 'Starting radius for root search method (kHz)';
            case 'np',expert = 1; values = [0;Inf]; info = 'Number of points for energy original-grid (test)';
            case 'nmhu',expert = 1; values = [0;Inf]; info = 'Number of points for pitch-angle original-grid (test)';
            case 'nrho',expert = 1; values = [0;Inf]; info = 'Number of points for radial original-grid (test)';
            case 'Rp',expert = 1; values = [0;Inf]; info = 'Major radius in meters (test)';
            case 'ap',expert = 1; values = [0;Inf]; info = 'Minor radius in meters (test)';
            case 'Bt',expert = 1; values = [0;Inf]; info = 'Toroidal magnetic field in teslas (test)';
            case 'qpar_t',expert = 1; values = [-Inf;Inf]; info = 'q-profile parameters (test) \n qfac, qtrs, qmin, qmax, rhos, rhos1, rhos2';
            case 'Emin',expert = 1; values = [0;Inf]; info = 'SD distribution : lower frequency (test)';
            case 'Emax',expert = 1; values = [0;Inf]; info = 'SD distribution : upper frequency (test)';
            case 'T',expert = 1; values = [0;Inf]; info = 'Maxwellian distribution : temperature in keV (test)';
            case 'Eref',expert = 1; values = [0;Inf]; info = 'Reference energy (test)';
            case 'nref',expert = 1; values = [0;Inf]; info = 'Reference density (test)';
            case 'mhu0s',expert = 1; values = [-1;1]; info = 'Pitch-angle (mhu), NaN for isotropic (test)';
            case 'dmhu',expert = 1; values = [0;Inf]; info = 'Width of pitch-angle distribution (test)';
        end
    case 'davies',
        switch field,
            case 'immin',expert = 1; values = [2;Inf]; info = 'minimun number of points (log2) for function evaluation';
            case 'immax',expert = 1; values = [3;Inf]; info = 'maximum number of points (log2) for function evaluation';
            case 'rapmax',expert = 1; values = [0;Inf]; info = 'tolerance for change in module between neighboring points';
            case 'phimax',expert = 1; values = [0;Inf]; info = 'tolerance for change in argument between neighboring points';
            case 'convlim',expert = 1; values = [0;Inf]; info = 'precision for root evaluation';
            case 'nconv',expert = 1; values = [0;Inf]; info = 'maximum number of iterations';
            case 'display_mode',expert = 1; values = [0:2]; info = 'display mode \n(0) only final result \n(1) each iteration results \n(2) all output';
        end
    case 'luke_simul',
        switch field,
            % TODO : imod_struct_jd always looks at info, expert, values in substructures
            case 'id', expert = 1; info = '';
            case 'timeid', expert = 1; info = '';
            case 'userid', expert = 1; values = ''; info = '';
            case 'LUKEversion', expert = 1; values = ''; info = '';
        end
   otherwise,
end
%

