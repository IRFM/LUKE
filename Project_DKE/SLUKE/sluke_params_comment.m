function str_o = sluke_params_comment(str_i)
%
switch str_i
    %
    case 'machine'
        str_o = 'Name of tokamaks';
    %
    % discharge parameters  
    %
    case 'discharge.shot'
        str_o = 'Discharge number or index';
    %
    case 'discharge.tmin'
        str_o = 'Minimum of the considered time interval (s)';
    %
    case 'discharge.tmax'
        str_o = 'Maximum of the considered time interval (s)';
    %
    case 'discharge.nt'
        str_o = 'Number of sub-intervals between tmin and tmax (n>=1). If none, n = 1 is considered in the calculations. Use sluke_params_time to expand the params structure before calculations';
    %
    % simulation parameters  
    %
    case 'simul.id'
        str_o = 'Simulation identifier';
    %
    case 'simul.signature'
        str_o = 'The first and last names of the person doing these simulations';
    %
    case 'simul.comment'
        str_o = 'Some general comments to explain the simulation';
    %
    case 'simul.enable'
        str_o = 'Enable (1) or not (0) the simulations';
    %
    case 'simul.enforce'
        str_o = '(2) : enforce new simulation and erase all files of previous simulations, (1) : enforce new simulation but erase only necessary files of previous simulations (check the different folders), (0) : simulation is not enforced (but may be canceled : file LUKE_DATA_*** can be deleted in case of problem),  -1 : simulation is not enforced and not canceled';
    %
    case 'simul.log'
        str_o = 'Generate log file (diary)';
    %
    case 'simul.output'
        str_o = '(0) : LUKE processed data and available synthetic diagnostics + full LUKE output (WARNING : very large *.mat file), (1) : LUKE processed data only and available synthetic diagnostics';
    %
    case 'simul.remote.profile'
        str_o = 'Calculation profile. Local interactive calculations -> ''0'' or ''local''. Remote calculations : type first dispremoteprofiles('''',''scheduler''); to get by values and names the available remote machines on which LUKE calculations can be performed. Profiles in MatRemote toolboxes must be defined first, then incorporated in the local LUKE path file.';
    %
    case 'simul.remote.mode'
        str_o = 'Distributed remote calculation mode -> (-2,-1) : remcomputing on the remote cluster dkepath.remote(-mdce_mode) (0) : sequential calculation (1)  : use of jobcomputing (2) : use of parcomputing (parfor) (3) : remcomputing on the local cluster';
    %
    case 'simul.remote.remtimout'
        str_o = 'Return mode (0): wait for result, (1) : return hand after starting calculation (valid only if profile > 0 (or not empty or not ''local'' or mode < 0)';
    %
    case 'simul.remote.debugmode'
        str_o = 'Debug mode (0) off (1) or (2) on (highest debug mode with ''2'')';
    %
    case 'simul.remote.cleanmode'
        str_o = 'Cleaning mode of job files/folders : both on remote and local (2), only on remote (1) or not at all (0). The latest is for debug only.';
    %
    case 'simul.remote.matver'
        str_o = 'Matlab version used on the remote machine (if not exist, the defaut value in the remote profile is used). By definition, it should be of the form matxxx, where xxx for the matlab version : type version in matlab, and 9.3 -> xxx = 903 or 9.11 -> xxx = 911';
    %
    case 'simul.remote.max_simulations'
        str_o = 'Maximum number of distributed simulations launched in parallel (remote machine dependent). if Inf, no limit.';
    %
    case 'simul.remote.git.projects'
        str_o = 'List of projects under git control that may be updated remotely from repository (git pull) prior a simulation. (git branch dependent).';
    %
    case 'simul.remote.git.pull'
        str_o = 'Git pull remote projects before running the simulation (1), no remote git pull (0).';
    %
    case 'simul.git.branch.luke'
        str_o = 'LUKE git branches. If empty, no git checkout to a specific LUKE branch is enforced. The current active LUKE branch is used either locally and remotely (WARNING : may lead to calculation inconsistencies)';
    %
    case 'simul.remote.git.display'
        str_o = 'Display git status in the command window (0) : no display, (1) : display results';
    %
    case 'simul.remote.scheduler.pbs.nodes'
        str_o = 'PBS scheduler : number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type ''pbsnodes -a'' to get the list of node names';
    %
    case 'simul.remote.scheduler.pbs.ppn'
        str_o = 'PBS scheduler : number of processors requested on the same node. if empty or NaN, default value requested.';
    %
    case 'simul.remote.scheduler.pbs.select'
        str_o = 'PBS scheduler : number of separate nodes. If empty or NaN, default value. Type ''pbsnodes -a'' to get the list of nodesand their characteristics';
    %
    case 'simul.remote.scheduler.pbs.ncpus'
        str_o = 'PBS scheduler : number of cpus per node (must be even number). If empty or NaN, default value. ';
    %
    case 'simul.remote.scheduler.pbs.memory'
        str_o = 'PBS scheduler : job memory in Mbytes (should be increased for large calculation grids, in particular when radial transport is non-zero). See the cluster limitations';
    %
    case 'simul.remote.scheduler.pbs.walltime'
        str_o = 'PBS scheduler : job walltime in hours';
    %
    case 'simul.remote.scheduler.torque.nodes'
        str_o = 'TORQUE scheduler : number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type ''pbsnodes -a'' to get the list of node names';
    %
    case 'simul.remote.scheduler.torque.ppn'
        str_o = 'TORQUE scheduler : number of processors requested on the same node. if empty or NaN, default value requested.';
    %
    case 'simul.remote.scheduler.torque.select'
        str_o = 'TORQUE scheduler : number of separate nodes. If empty or NaN, default value. Type ''pbsnodes -a'' to get the list of nodes and their characteristics';
    %
    case 'simul.remote.scheduler.torque.ncpus'
        str_o = 'TORQUE scheduler : number of cpus per node (must be even number). If empty or NaN, default value.';
    %
    case 'simul.remote.scheduler.torque.memory'
        str_o = 'TORQUE scheduler : job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations';
    %
    case 'simul.remote.scheduler.torque.walltime'
        str_o = 'TORQUE scheduler : job walltime in hours';
    %
    case 'simul.remote.scheduler.slurm.ncores'
        str_o = 'SLURM scheduler : number of cores. If empty or NaN, default value.';
    %
    case 'simul.remote.scheduler.slurm.memory'
        str_o = 'SLURM scheduler : job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations';
    %
    case 'simul.remote.scheduler.slurm.walltime'
        str_o = 'SLURM scheduler : job walltime in hours';
    %
    case 'simul.jprofileconsistency.code'
        str_o = 'Name of the tokamak code for current density profile selfconsistency with LUKE calculations. If empty, no selfconsistency is performed.'; 
    %
    case 'simul.jprofileconsistency.nit'
        str_o = '';
    %
    case 'simul.jprofileconsistency.toll'
        str_o = '';
    %
    case 'simul.jprofileconsistency.log'
        str_o = '';
    %
    case 'simul.jprofileconsistency.stepsavedata'
        str_o = '';
    %
    case 'simul.jprofileconsistency.tprofonoff'
        str_o = '';
    %
    case 'simul.jprofileconsistency.datapath'
        str_o = '';
    %
    case 'simul.jprofileconsistency.sourceoutside.use'
        str_o = '';
    %
    case 'simul.jprofileconsistency.sourceoutside.file'
        str_o = '';
    %
    case 'simul.jprofileconsistency.sourceoutside.condition'
        str_o = '';
    %
    case 'simul.initial_distribution'
        str_o = 'Time evolution of the distribution function : (0) -> at each time, initial distribution is a Maxwellian, (-1) -> at each time, initial distribution is the distribution from previous time (except the first that is necessarily Maxwellian)';
    %
    case 'simul.mute.load_structures_yp'
        str_o = 'No display of messages from load_structures_yp.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.run_lukert'
        str_o = 'No display of messages from run_lukert.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.clustermode_luke'
        str_o = 'No display of messages from clustermode_luke.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.mdce_clustermode'
        str_o = 'No display of messages from mdce_clustermode.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.displayrunningjob'
        str_o = 'No display of messages from displayrunningjob.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.remote_tsdate'
        str_o = 'No display of messages from remote_tsdate.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.bremsstrahlung_dke_yp'
        str_o = 'No display of messages from bremsstrahlung_dke_yp.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.bremdiag_dke_yp'
        str_o = 'No display of messages from bremdiag_dke_yp.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.metis2luke'
        str_o = 'No display of messages from metis2luke.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.equilconsistency_yp'
        str_o = 'No display of messages from equilconsistency_yp.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.make_equil_metis2luke'
        str_o = 'No display of messages from make_equil_metis2luke.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.make_sluke_build_launchs'
        str_o = 'No display of messages from make_sluke_build_launchs.m script if ''1'', full display if ''0''';
    %
    case 'simul.mute.lukeschedulerparam'
        str_o = 'No display of messages from lukeschedulerparam.m script if ''1'', full display if ''0''';
    %
    case 'simul.save.backup'
        str_o = '(1) save fluctuation time steps (0) do not save in runlukert.m';
    %
    case 'simul.save.waves'
        str_o = 'LUKE simulations with plasma fluctuations : (1) save waves at each fluctuation time step (0) do not save in runlukert.m';
    %
    % toroidal MHD equilibrium calculations parameters  
    %
    case  'equil.comment'
         str_o = 'Some general comments on the toroidal MHD equilibrium calculations';
    %
    case  'equil.source'
         str_o = 'Source of the toroidal MHD structure : ''preset'' or ''file'' or ''code''';
    %
    case  'equil.preset'
         str_o = 'Preset value of the toroidal MHD structure if the source is available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/EQUIL_files/ ';
    %
    case 'equil.file'
         str_o = 'Name of the file that contains the ''equil'' structure if the source is ''file''';
    %
    case 'equil.path'
        str_o = 'Path of the file that contains the ''equil'' structure if the source is ''file''';
    %
    case 'equil.code'
        str_o = 'Code name of the toroidal MHD structure if the source is ''code''.';
    %
    case 'equil.equilconsistency.comment'
        str_o = 'Some general comments on the toroidal MHD equilibrium calculations';
    %
    case 'equil.equilconsistency.auto_mode'
        str_o = '';
    %
    case 'equil.equilconsistency.display_mode'
       str_o = '';
    %
    case 'equil.equilconsistency.prho'
        str_o = '';
    %
    case 'equil.equilconsistency.mtheta'
        str_o = '';
    %
    case 'equil.fit.comment'
        str_o = 'Some general comments on the vectorial toroidal MHD equilibrium calculations';
    %
    case 'equil.fit.mode_equil'
        str_o = '';
    %
    case 'equil.fit.method'
        str_o = '';
    %
    case 'equil.fit.nharm'
        str_o = '';
    %
    case 'equil.fit.ngridresample'
        str_o = '';
    %
    case 'equil.fit.opt_load'
        str_o = '';
    %
    case 'equil.ripple.comment'
        str_o = 'Some general comments on the toroidal magnetic ripple calculations';
    %
    case 'equil.ripple.source'
        str_o = '';
    %
    case 'equil.ripple.preset'
        str_o = '';
    %
    case 'equil.ripple.file'
        str_o = '';
    %
    case 'equil.ripple.path'
        str_o = '';
    %
    case 'equil.ripple.mode'
        str_o = 'Magnetic ripple model incorporated in LUKE code : (0): non magnetic ripple, (1) with toroidal magnetic ripple. For Tore Supra or WEST tokamaks only yet';
    %
    % ohmic electric field calculations parameters  
    %
    case 'ohm.comment'
        str_o = 'Some general comments on the Ohmic electric calculations';
    %
    case 'ohm.source'
        str_o = 'Source of the ''ohm'' structure : ''preset'' or ''file'' or ''code''';
    %
    case 'ohm.preset'
        str_o = '';
    %
    case 'ohm.file'
        str_o = 'Name of the file that contains the ''ohm''structure if the source is ''file''';
    %
    case 'ohm.path'
        str_o = 'Path of the file that contains the ''ohm'' structure if the source is ''file''';
    %
    case 'ohm.code'
       str_o = 'Code name of the ''ohm'' structure  for the Ohmic electric field if the source is ''code''.';
    %
    % kinetic calculations parameters  
    %
    case 'kinetics.dkeparam.comment'
        str_o = 'Some general comments to justify the kinetics parameters for the simulations in ''dkeparam'' structure';
    %
    case 'kinetics.dkeparam.source'
        str_o = 'Source of the LUKE ''dkeparam'' structure : ''preset'' or ''file''';
    %
    case 'kinetics.dkeparam.preset'
        str_o = 'Preset ''dkeparam'' value if the source is ''preset''. Available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/DKEPARAM_files/';
    %
    case 'kinetics.dkeparam.file'
        str_o = 'Name of the file that contains the ''dkeparam'' structure if the source is ''file''';
    %
    case 'kinetics.dkeparam.path'
        str_o = 'Path of the file that contains the ''dkeparam'' structure if the source is ''file''';
    %
    case 'kinetics.dkeparam.clustermode.coll_dke_jd.scheduler.mode'
        str_o = 'MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)';
    %
    case 'kinetics.dkeparam.clustermode.eecoll_dke_yp.scheduler.mode'
        str_o = 'MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function eecoll_dke_yp.m (MDC toolbox must be installed for option 1)';
    %
    case 'kinetics.dkeparam.clustermode.wave_solver_yp.scheduler.mode'
        str_o = 'MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function wave_solver_yp.m (MDC toolbox must be installed for option 1)';
    %
    case 'kinetics.dkeparam.clustermode.rfdiff_dke_jd.scheduler.mode'
        str_o = 'MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function rfdiff_dke_jd.m (MDC toolbox must be installed for option 1)';
    %
    case 'kinetics.dkeparam.nmhu_S'
        str_o = 'Enforced cosine of pitch-angle flux grid : number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run). If NaN or empty, the default value in ''dkeparam'' structure is considered.';
    %
    case 'kinetics.dkeparam.np_S'
        str_o = 'Enforced momentum flux grid : number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than the pitch-angle one. If NaN or empty, the default value in ''dkeparam'' structure is considered.';
    %
    case 'kinetics.dkeparam.pnmax_S'
        str_o = 'Enforced upper limit of the momentum flux grid : maximum value of the flux momentum grid (pth_ref). If NaN or empty, the default value in ''dkeparam'' structure is considered.';
    %
    case 'kinetics.dkeparam.rho_S'
        str_o = 'Enforced radial flux grid : if single real value larger than 1 : number of points for radial flux grid calculation (automatic and optimized for depending the type of RF waves); if single or list of multiple real values less than 1 : manual radial flux grid; if list of imaginary values : custom radial flux grid with [npoints + 1i*normalized_radial_position] (example : [5+0.1*i,12+0.7*i,3+1.0i]). Radial points are unique. If NaN or empty, the default value in ''dkeparam'' structure is considered.';
    %
    case 'kinetics.dkedisplay.comment'
        str_o = 'Some general comments to justify the kinetics parameters for the simulations in ''dkedisplay'' structure';
    %
    case 'kinetics.dkedisplay.source'
        str_o = 'Source of the LUKE ''dkedisplay'' structure : ''preset'' or ''file''';
    %
    case 'kinetics.dkedisplay.preset'
        str_o = 'Preset ''dkedisplay'' value if the source is ''preset'' : NO_DISPLAY: does nothing, VISUAL: prints out equilibrium profiles (Te,ne) if SLUKE is run locally only. Available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/DISPLAY_files/ ';
    %
    case 'kinetics.elements.coulog_model'
        str_o = 'Coulomb logarithm model';
    %
    case 'kinetics.elements.Zi_ref'
        str_o = 'Zi values whose density may be modified by the factor density_factor from C3PO/LUKE/R5X2 calculations if exist in equil structure (for tests). May be vector';
    %
    case 'kinetics.elements.Zi_density_factor'
        str_o = 'Ad-hoc multiplication factors of the density of the elements Zi_ref';
    %
    case 'kinetics.elements.screening.ADAS'
        str_o = 'Full path for the full ion screening model ADAS (necessary for screening of partially ionized atoms). If empty, fully ionized impurities are considered. If ''ADAS.mat'', default ADAS value in LUKE.';
    %
    case 'kinetics.elements.screening.partial.elastic'
        str_o = 'Elastic scattering by partially ionized atoms. List of models : ''Multi-Yukawa'', DFT'', ''Thomas-Fermi'', ''Thomas-Fermi-Kirillov'', ''Tseng-Pratt-Avdonina-Lamoureux'', ''Tseng-Pratt-Botto'', ''Tseng-Pratt-Thomas-Fermi''';
    %
    case 'kinetics.elements.screening.partial.inelastic'
        str_o = 'Inelastic scattering by partially ionized atoms : (0) -> no   (1) -> yes';
    %
    case 'kinetics.elements.screening.partial.dftpath'
        str_o = 'or specific DFT file path only. Leave empty otherwise and the default calculations will be considered in LUKE';
    %
    case 'kinetics.fast_electron_anomalous_transport.comment'
        str_o = 'Some general comments to justify the kinetics parameters for the simulations concerning fast electron anomalous transport';
    %
    case 'kinetics.fast_electron_anomalous_transport.source'
        str_o = 'Source of the LUKE ''transpfaste'' structure : ''preset'' or ''file''';
    %
    case 'kinetics.fast_electron_anomalous_transport.preset'
        str_o = 'Preset ''transpfaste'' value if the source is ''preset''. Available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/TRANSP_files/ ';
    %
    case 'kinetics.fast_electron_anomalous_transport.file'
        str_o = 'Name of the file that contains the ''transpfaste'' structure if the source is ''file''';
    %
    case 'kinetics.fast_electron_anomalous_transport.path'
        str_o = 'Path of the file that contains the ''transpfaste'' structure if the source is ''file''';
    %
    case 'kinetics.fast_electron_anomalous_transport.Dr_type'
        str_o = 'Anomalous fast electron radial diffusion type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM-: v|| dependence (Dr(r)*vpar_ref/vth_ref), EM-: 1/v|| dependence)';
    %
    case 'kinetics.fast_electron_anomalous_transport.Dr0'
        str_o = 'Radial diffusion (m^2/s). Dr0 = Dr_center + i*Dr_edge';
    %
    case 'kinetics.fast_electron_anomalous_transport.pDr'
        str_o = 'Profile dependence (pDr = pDr0 + i*pDr1) : if pDr is real (flat or parabolic increase from center to the edge): Dr(rho) = Dr_center*(1+pDr0*rho^2). If pDr is imaginary (step size from center to the edge): Dr(rho) = (Dr_center-Dr_edge)/(1+exp((rho-pDr0)/pDr1))+Dr_edge';
    %
    case 'kinetics.fast_electron_anomalous_transport.Vr_type'
        str_o = 'Anomalous fast electron radial pinch type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence (Vr(r) = Vr0(r)*vpar_ref/vth_ref), EM-: 1/v|| dependence)';
    %
    case 'kinetics.fast_electron_anomalous_transport.Vr0'
        str_o = 'Radial pinch (m/s). Vr0 = Vr_center + i*Vr_edge';
    %
    case 'kinetics.fast_electron_anomalous_transport.pVr'
        str_o = 'Profile dependence (pVr = pVr0 + i*pVr1) : if pVr is real (flat or parabolic increase from center to the edge): Vr(rho) = Vr_center*(1+pVr0*rho^2). If pVr is imaginary (step size from center to the edge): Vr(rho) = (Vr_center-Vr_edge)/(1+exp((rho-pVr0)/pVr1))+Vr_edge';
    %
    case 'kinetics.fast_electron_anomalous_transport.vparmin'
        str_o = 'Normalized units';
    %
    case 'kinetics.fast_electron_anomalous_transport.norm_ref'
        str_o = 'Normalization of the velocity threshold: (0) v||/vT (local), (1) v||/vT_ref (central value)';
    %
    % rf waves calculations parameters  
    %
    case 'rfwaves.comment'
        str_o = 'Some general comments on the RF waves calculations';
    %
    case 'rfwaves.source'
        str_o = 'Source of the ''wavestructs'' structure : ''preset'' or ''file''';
    %
    case 'rfwaves.file'
        str_o = 'Name of the file that contains the ''wavestructs'' structure if the source is ''file''';
    %
    case 'rfwaves.path'
        str_o = 'Path of the file that contains the ''wavestructs'' structure if the source is ''file''';
    %
    case 'rfwaves.enable'
        str_o = 'Enabling RF wave calculations or use of an external wavestructs structure (1) or not (0).'; 
    %
    case 'rfwaves.antenna.type'
        str_o = '''LH'' lower hybrid wave, ''EC'' electron cyclotron waves, ''EBW'' for electron Bernstein wave, or {''LH'',''LH''} if the LH wave is launched by two different antennas. As many antennas as necessary may be added. Empty corresponds to RF wave.';
    %
    case 'rfwaves.antenna.comment'
        str_o = 'General comments on the antenna structure calculation';
    %
    case 'rfwaves.antenna.source'
        str_o = 'Source of the ''antennas'' structure : ''code'' or ''file''';
    %
    case 'rfwaves.antenna.code'
        str_o = 'Code name of the ''antennas'' structure  if the source is ''code''.';
    %
    case 'rfwaves.antenna.file'
        str_o = 'Name of the file that contains the ''antennas'' structure if the source is ''file''';
    %
    case 'rfwaves.antenna.path'
        str_o = 'Path of the file that contains the ''antennas'' structure if the source is ''file''';
    %
    case 'rfwaves.antenna.LH.ALOHA.port'
        str_o = 'antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST';
    %
    case 'rfwaves.antenna.LH.ALOHA.remote_profile'
        str_o = 'Calculation profile. Local interactive calculations -> ''0'' or ''local''. Remote calculations : type first dispremoteprofiles('',''scheduler''); to get by values and names the available remote machines on which LUKE calculations can be performed. Profiles in MatRemote toolboxes must be defined first, then incorporated in the local LUKE path file.';
    %
    case 'rfwaves.antenna.LH.ALOHA.display.data.mode'
        str_o = 'Display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if figure exist';
    %
    case 'rfwaves.antenna.LH.ALOHA.display.data.save'
        str_o = 'Display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist';
    %
    case 'rfwaves.antenna.LH.ALOHA.display.results'
        str_o = 'Display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.method'
        str_o = '(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.ne_guess'
        str_o = 'Edge density in front of the grill (initial guess or enforced value) (m-3)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.tolfun'
        str_o = 'Relative tolerance on targets (if aloha.optim.method = 1)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.tolx'
        str_o = 'Relative tolerance on inputs (if aloha.optim.method = 1)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.nitmax'
        str_o = 'Maximum number of iterations (if aloha.optim.method = 1)';
    %
    % See proc_aloha_spec_jd.m for details on the input parameters
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.dir'
        str_o = '(0) P + preserve repartition and total power, (1) P/N^2 + preserve directivity and repartition, (2) P/N^2 + preserve directivity and total power (treating positive and negative spectra as blocks. Warning : some transfer of P/N^2 across N=0 necessary in this case), (3) P/N^2 + preserve repartition and total power';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.mode'
        str_o = '(0) select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin), (1) assemble peaks fixing Pmax and N, allowing dN to change, (2) assemble peaks allowing Pmax, N and dN to change';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.nlobes'
        str_o = 'number of lobes selected in the power spectrum';
    %
    %case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.ny = {{},{0,0},{0,0}};
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.Pin_in'
        str_o = 'corrected initial total power. If NaN take value ALOHA else the value is enforced by Pin_in (W). Consider globalspectrum to get the total LH power.';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.opt_optim'
        str_o = 'use of function lsqnonlin for gaussian lobe fit (default : 0)';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum'
        str_o = 'upper and lower half-antenna modules are considered independently (0) or only half upper module for the whole antenna (1). If case ''rfwaves.antenna.LH.ALOHA.optim.method == 0'', case ''rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = 1'' is enforced.';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent'
        str_o = 'the Lower Hybrid wave drive co-current (1) or counter-current (-1)';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.inter'
        str_o = 'interactive mode for selecting parameters';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.mode'
        str_o = 'display (0) none (1) text only (2) text and figures (default : 0)';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.comparison'
        str_o = 'display comparison between experimental value and calculations (1) yes (0) no';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.omega_rf'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.bNpar0'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.bdNpar0'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.bPlhtot'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.mainlobeshift'
        str_o = 'artificial shift of the main lobe of the LH power spectrum : 0 nothing done, < 1 : reduction of the absolute value, > 1 increase of the absolute value';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.rZ0'
        str_o = '0+1i to be verified';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.m0'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.phi0'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.i_ref'
        str_o = '100 ou -1 to be verified';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.LFS'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.mmode'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.nparp'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.a_sdNpar'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.w0'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.z_L'
        str_o = '';
    %
    %{
    case 'rfwaves.antenna.LH.C3PO.launch.ns = {{},{1000,1000},{1000,1000}};
    case 'rfwaves.antenna.LH.C3PO.launch.n0 = {{},{NaN,NaN},{NaN,NaN}};
    case 'rfwaves.antenna.LH.C3PO.launch.kz0 = {{},{NaN,NaN},{NaN,NaN}};
    case 'rfwaves.antenna.LH.C3PO.launch.method = {{},{'pchip','pchip'},{'pchip','pchip'}};%cubic obsolete
    case 'rfwaves.antenna.LH.C3PO.launch.method1 = {{},{'pchip','pchip'},{'pchip','pchip'}};
    case 'rfwaves.antenna.LH.C3PO.launch.method2 = {{},{'spline','spline'},{'spline','spline'}};
    %}
    case 'rfwaves.antenna.LH.C3PO.launch.tail.dtn'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.tail.mode'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.tail.bNparmax_tail'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.tail.bn_tail'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.tail.bP_tail'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.tail.bopt_tail'
        str_o = '';
    %
    case 'rfwaves.solver.type'
        str_o = '';
    %
    case 'rfwaves.solver.code'
        str_o = '';
    %
    case 'rfwaves.solver.enable'
        str_o = '';
    %
    case 'rfwaves.solver.remote_profile'
        str_o = '';
    %
    %case 'rfwaves.solver.C3PO.rayparam.comment = {{},{'',''},{'',''}};
    %case 'rfwaves.solver.C3PO.rayparam.source = {{},{'',''},{'',''}};
    %case 'rfwaves.solver.C3PO.rayparam.file = {{},{'',''},{'',''}};
    %case 'rfwaves.solver.C3PO.rayparam.path = {{},{'',''},{'',''}};
    %
    case 'rfwaves.solver.C3PO.rayparam.testmode'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.tensortype'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.t0'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.tfinal'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.dt0'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.dS'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.tol'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.kmax'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.ncyclharm'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.reflection'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.rel_opt'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.nperp'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.pperpmax'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.tau_lim'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.kextra'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.rayparam.colldamp'
        str_o = '';
    %
    %case 'rfwaves.solver.C3PO.rayparam.metricmode = {{},{1,1},{1,1}};
    %case 'rfwaves.solver.C3PO.rayparam.rhoswitch = {{},{0.1,0.1},{0.1,0.1}};
    %case 'rfwaves.solver.C3PO.rayparam.substitution_method = {{},{7,7},{7,7}};
    %
    %case 'rfwaves.solver.C3PO.raydisplay.comment = {{},{'',''},{'',''}};
    %case 'rfwaves.solver.C3PO.raydisplay.source = {{},{'',''},{'',''}};
    %case 'rfwaves.solver.C3PO.raydisplay.file = {{},{'',''},{'',''}};
    %case 'rfwaves.solver.C3PO.raydisplay.path = {{},{'',''},{'',''}};
    case 'rfwaves.solver.C3PO.raydisplay.ray'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.raydisplay.equilibrium'
        str_o = '';
    %
    %case 'rfwaves.solver.C3PO.raydisplay.fluctuations';
    case 'rfwaves.solver.C3PO.raydisplay.p_opt'
        str_o = '';
    %
    %case 'rfwaves.solver.C3PO.raydisplay.mdce = {{},{0,0},{0,0}};
    %
    case 'rfwaves.solver.C3PO.waveparam.mmode'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.waveparam.kmode'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.waveparam.opt_rf'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.waveparam.dsmin'
        str_o = '';
    %
    %case 'rfwaves.solver.C3PO.waveparam.nd';
    %case 'rfwaves.solver.C3PO.waveparam.nchi = {{},{0,0},{0,0}};
    %
    case 'rfwaves.solver.C3PO.waveparam.n_rf_list'
        str_o = '';
    %
    %case 'rfwaves.solver.C3PO.waveparam.ns = {{},{0,0},{0,0}};
    %case 'rfwaves.solver.C3PO.waveparam.rhomin = {{},{0,0},{0,0}};
    %
    case 'rfwaves.solver.C3PO.waveparam.a_sdNpar'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.waveparam.cut_fac'
        str_o = '';
    %
    %case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.mode = {{},{0,0},{0,0}};
    %case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.timeout = {{},{1000,1000},{1000,1000}};
    %case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.size = {{},{12,12},{12,12}};
    %case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.mem = {{},{500,500},{500,500}};
    %
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.mode'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.memory'
        str_o = '';
    %
    % postprocessing calculations parameters  
    %
    case 'postprocessing.comment'
        str_o = '';
    %
    case 'postprocessing.source'
        str_o = '';
    %
    case 'postprocessing.ir_display'
        str_o = '(-1) no interactive post-processing display, (0) interactive post-processing display';
    %        
    case 'postprocessing.p_opt'
        str_o = 'printing and saving options : (-1) do nothing, (0) print figures, (1) print figures and save figures, (2) save figures';
    %
    case 'postprocessing.dp_cyl'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.pnmax'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.peak'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.wave'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.peakmode'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.rho'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.spec'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.its_rf'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.blist'
        str_o = 'no interactive post-processing display';
    %
    case 'postprocessing.diaryname'
        str_o = 'no interactive post-processing display';     
    %
    % synthetic diagnostic calculations parameters  
    %
    case 'diags.DSPX.id'
        str_o = '';
    %
    case 'diags.DSPX.code'
        str_o = '';
    %
    case 'diags.DSPX.remote_calculations'
        str_o = 'Synthetic diagnostic calculations done remotely (1) or locally(0)';
    %
    case 'diags.DSPX.enable'
        str_o = 'Synthetic diagnostic calculations is enabled (1) or disabled (0)';
    %
    case 'diags.DSPX.exp'
        str_o = 'Load experimental data enabled (1) or disabled (0)';
    %
    case 'diags.DSPX.hxrspec.comment'
        str_o = '';
    %
    case 'diags.DSPX.hxrspec.source'
        str_o = 'source of the data (code, file, value). If empty, obtained from database or script if available.';
    %
    case 'diags.DSPX.hxrspec.file'
        str_o = 'file name';
    %
    case 'diags.DSPX.hxrspec.path'
        str_o = 'path';
    %
    case 'diags.DSPX.hxrspec.chordstatus_hxr'
        str_o = '(1) -> active chords, (0) -> inactive chords';
    %
    case 'diags.DSPX.R5X2.hxrparam.comment'
        str_o = '';
    %
    case 'diags.DSPX.R5X2.hxrparam.source'
        str_o = 'source of the data (code, file, value). If empty, defaults values';
    %
    case 'diags.DSPX.R5X2.hxrparam.file'
        str_o = '';
    %
    case 'diags.DSPX.R5X2.hxrparam.path'
        str_o = 'path';
    %
    case 'diags.DSPX.R5X2.hxrparam.mfactor'
        str_o = 'For the magnetic equilibrium';
    %
    case 'diags.DSPX.R5X2.hxrparam.method'
        str_o = 'For the magnetic equilibrium in the HXR calculations';
    %
    case 'diags.DSPX.R5X2.hxrparam.ns'
        str_o = 'for chord integration';
    %
    case 'diags.DSPX.R5X2.hxrparam.n_gauleg'
        str_o = 'Number of Legendre polynomials for projections of cross-section and electron velocity distribution';
    %
    case 'diags.DSPX.R5X2.hxrparam.epsi_gauleg'
        str_o = 'Accuracy of the Legendre projection';
    %
    case 'diags.DSPX.R5X2.hxrparam.kmin'
        str_o = 'for Tphot calculations';
    %
    case 'diags.DSPX.R5X2.hxrparam.kmax'
        str_o = 'for Tphot calculations';
    %
    case 'diags.DSPX.R5X2.hxrparam.kphot'
        str_o = 'Photon energy in keV (important for bremsstrahlung with partial screening effects)';
    %
    case 'diags.DSPX.R5X2.hxrparam.full_results'
        str_o = 'Save all simulations results (1) or just those that can be compared directly to experimental measurements (0).';
    %
    
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.screening_model'
        str_o = 'screening model for bremsstrahlung';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nphi'
        str_o = 'for numerical integration 1BS -> 2BN. If nphi = NaN, formula deduced from analytical integration in phi is used (4-D). Otherwise (5-D)';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.flag_mem'
        str_o = 'Memory management enforcement : 0 -> 5-D block numerical calculations, 1 -> 4-D block numerical calculations';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.ntheta'
        str_o = 'for numerical integration 1BS -> 2BN';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.integral'
        str_o = '%Numerical integration : trapz (trapeze) or simps (Simpson)';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nEc'
        str_o = 'keV (number of incoming electron kinetic energies for calculating the BHE cross-section table with partial screening)';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.Ecmax'
        str_o = 'keV (max incoming electron kinetic energy for calculating the BHE cross-section table with partial screening)';
    %
    %------------------------------------------------------------------------
    %
    case 'diags.MEHXR.id'
        str_o = '';
    %
    case 'diags.MEHXR.code'
        str_o = 'name of the FEB code';
    %
    case 'diags.MEHXR.remote_calculations'
        str_o = 'Synthetic diagnostic calculations done remotely (1) or locally(0)';
    %
    case 'diags.MEHXR.enable'
        str_o = 'Synthetic diagnostic calculations is enabled (1) or disabled (0) ';
    %
    case 'diags.MEHXR.exp'
        str_o = 'Load experimental data enabled (1) or disabled (0)';
    %
    
    case 'diags.MEHXR.hxrspec.comment'
        str_o = '';
    %
    case 'diags.MEHXR.hxrspec.source'
        str_o = 'source of the data (code, file, value). If empty, obtained from database or script if available.';
    %
    case 'diags.MEHXR.hxrspec.file'
        str_o = 'source of the data (code, file, value)';
    %
    case 'diags.MEHXR.hxrspec.path'
        str_o = '';
    %
    case 'diags.MEHXR.hxrspec.chordstatus_hxr'
        str_o = '(1) -> active chords, (0) -> inactive chords';
    %
    case 'diags.MEHXR.R5X2.hxrparam.source'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.file'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.path'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.mfactor'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.method'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.ns'
        str_o = '';
    %

    %
    case 'diags.MEHXR.R5X2.hxrparam.n_gauleg'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.epsi_gauleg'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.comment'
        str_o = '';
    %
    case 'diags.MEHXR.R5X2.hxrparam.kmin'
        str_o = 'for Tphot calculations';
    %
    case 'diags.MEHXR.R5X2.hxrparam.kmax'
        str_o = 'for Tphot calculations';
    %
    case 'diags.MEHXR.R5X2.hxrparam.kphot'
        str_o = 'Photon energy in keV (important for bremsstrahlung with partial screening effects)';
    %
    case 'diags.MEHXR.R5X2.hxrparam.full_results'
        str_o = 'Save all simulations results (1) or just those that can be compared directly to experimental measurements (0).';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.screening_model'
        str_o = 'screening model for bremsstrahlung';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nphi'
        str_o = 'for numerical integration 1BS -> 2BN. If nphi = NaN, formula deduced from analytical integration in phi is used (4-D). Otherwise (5-D)';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.flag_mem'
        str_o = 'Memory management enforcement : 0 -> 5-D block numerical calculations, 1 -> 4-D block numerical calculations';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.ntheta'
        str_o = 'for numerical integration 1BS -> 2BN';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.integral'
        str_o = 'Numerical integration : trapz (trapeze) or simps (Simpson)';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nEc'
        str_o = 'keV (number of incoming electron kinetic energies for calculating the BHE cross-section table with partial screening)';
    %
    case 'diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.Ecmax'
        str_o = 'keV (max incoming electron kinetic energy for calculating the BHE cross-section table with partial screening)';
    %
    otherwise 
        cprintf([1,0.5,0],['WARNING : field ',str_i,' has no help']);disp(' ')
        str_o = '';
    %
end


