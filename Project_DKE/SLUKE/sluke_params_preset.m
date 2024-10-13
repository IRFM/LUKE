function [preset_list,sparams] = sluke_params_preset(preset_name,save_mode)
%
% LUKE - Generator of parameters structure for sluke calculations from a preset name. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT : 
%  
%   - preset_name : name of the preset (string)
%     (if empty or not defined, only the available list of preset names is output)
%   - save_mode : (1) : in addition, data are save in a matlab script file whose name is make_sparams_PRESET_NAME.m, (0) or not existing : no script automatic output -> type sluke_params_script(sparams)
%
% OUTPUT :
%
%   - preset_list : list of available preset names
%   - sparams : structure of parameters for sluke calculations.
%
% by Y.Savoye-Peysson (CEA/DSM/IRFM) <yves.savoye-peysson@cea.fr>
%
sparams = struct([]);
%
preset_list0 = {'LOCAL';'REMOTE'};
%
preset_list = ['List of available presets : ''',preset_list0{1},''''];
%
for ii = 2:length(preset_list0)
    %
    preset_list = [preset_list,', ''',preset_list0{ii},''''];
    %
end
%
if nargin == 0
    %
    preset_name = '';
    save_mode = 0;
    return
    %
elseif nargin == 1
    %
    save_mode = 0;
    %
end
%
if strcmpi(preset_name,'LOCAL')
    %
    sparams = make_preset_LOCAL;
    filename = 'LOCAL';
    %
elseif strcmpi(preset_name,'REMOTE')
    %
    sparams = make_preset_REMOTE;
    filename = 'REMOTE';
    %
else
    %
    error(['ERROR : The preset ',upper(preset_name), ' is not existing. Type sluke_params_preset to get the list of available presets.'])
    %
end
%
if save_mode && ~isempty(sparams)
    %
    sluke_params_script(sparams,filename)
    %
end
%
end
%
function sparams = make_preset_LOCAL
    %
    sparams.machine = {'TS','TS','TS'};%Name of tokamaks
    %
    % discharge parameters  
    %
    sparams.discharge.shot = {'41114','41114','41114'};%Discharge number or index
    sparams.discharge.tmin = {14.5,14.5,14.5};%Minimum of the considered time interval (s)
    sparams.discharge.tmax = {15.5,15.5,15.5};%Maximum of the considered time interval (s)
    sparams.discharge.nt = {1,1,1};%Number of sub-intervals between tmin and tmax (n>=1). If none, n = 1 is considered in the calculations. Use sluke_params_time to expand the params structure before calculations
    %
    % simulation parameters  
    %
    sparams.simul.id = {'simul_id_1' 'simul_id_2' 'simul_id_3'};%Simulation identifier
    sparams.simul.signature = {'' '' ''};%The first and last names of the person doing these simulations
    sparams.simul.comment = {'' '' ''};%Some general comments to explain the simulation
    sparams.simul.enable = {1,1,1};%Enable (1) or not (0) the simulations
    sparams.simul.enforce = {0,0,0};%(2) : enforce new simulation and erase all files of previous simulations, (1) : enforce new simulation but erase only necessary files of previous simulations (check the different folders), (0) : simulation is not enforced (but may be canceled : file LUKE_DATA_*** can be deleted in case of problem),  -1 : simulation is not enforced and not canceled
    sparams.simul.log = {1,1,1};%Generate log file (diary)
    sparams.simul.output = {1,1,1};%(0) : LUKE processed data and available synthetic diagnostics + full LUKE output (WARNING : very large *.mat file), (1) : LUKE processed data only and available synthetic diagnostics
    %
    sparams.simul.remote.profile = {'local' 'local' 'local'};%Calculation profile. Local interactive calculations -> '0' or 'local'. Remote calculations : type first dispremoteprofiles('','scheduler'); to get by values and names the available remote machines on which LUKE calculations can be performed. Profiles in MatRemote toolboxes must be defined first, then incorporated in the local LUKE path file.
    sparams.simul.remote.mode = {0,0,0};%Distributed remote calculation mode -> (-2,-1) : remcomputing on the remote cluster dkepath.remote(-mdce_mode) (0) : sequential calculation (1)  : use of jobcomputing (2) : use of parcomputing (parfor) (3) : remcomputing on the local cluster
    sparams.simul.remote.remtimout = {1,1,1};%Return mode (0): wait for result, (1) : return hand after starting calculation (valid only if profile > 0 (or not empty or not 'local' or mode < 0)
    sparams.simul.remote.debugmode = {0,0,0};%Debug mode (0) off (1) or (2) on (highest debug mode with '2')
    sparams.simul.remote.cleanmode = {2,2,2};%Cleaning mode of job files/folders : both on remote and local (2), only on remote (1) or not at all (0). The latest is for debug only. 
    sparams.simul.remote.matver = {'','',''};%Matlab version used on the remote machine (if not exist, the defaut value in the remote profile is used). By definition, it should be of the form matxxx, where xxx for the matlab version : type version in matlab, and 9.3 -> xxx = 903 or 9.11 -> xxx = 911
    sparams.simul.remote.max_simulations = {Inf,Inf,Inf};%Maximum number of distributed simulations launched in parallel (remote machine dependent). if Inf, no limit.
    %
    sparams.simul.remote.git.projects = {{'MatRemote','MatHelp','MatTools','LUKE_CEA'},{'MatRemote','MatHelp','MatTools','LUKE_CEA'},{'MatRemote','MatHelp','MatTools','LUKE_CEA'}};%List of projects under git control that may be updated remotely from repository (git pull) prior a simulation. (git branch dependent).
    sparams.simul.remote.git.pull = {1,1,1};%Git pull remote projects before running the simulation (1), no remote git pull (0).
    sparams.simul.git.branch.luke = {'time','time','time'};%LUKE git branches. If empty, no git checkout to a specific LUKE branch is enforced. The current active LUKE branch is used either locally and remotely (WARNING : may lead to calculation inconsistencies)
    sparams.simul.remote.git.display = {1,1,1};%Display git status in the command window (0) : no display, (1) : display results
    %
    sparams.simul.remote.scheduler.pbs.nodes = {'','',''};%PBS scheduler : number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type 'pbsnodes -a' to get the list of node names
    sparams.simul.remote.scheduler.pbs.ppn = {'','',''};%PBS scheduler : number of processors requested on the same node. if empty or NaN, default value requested.
    sparams.simul.remote.scheduler.pbs.select = {'','',''};%PBS scheduler : number of separate nodes. If empty or NaN, default value. Type 'pbsnodes -a' to get the list of nodesand their characteristics
    sparams.simul.remote.scheduler.pbs.ncpus = {2,2,2};%PBS scheduler : number of cpus per node (must be even number). If empty or NaN, default value. 
    sparams.simul.remote.scheduler.pbs.memory = {15000,15000,15000};%PBS scheduler : job memory in Mbytes (should be increased for large calculation grids, in particular when radial transport is non-zero). See the cluster limitations
    sparams.simul.remote.scheduler.pbs.walltime = {24,24,24};%PBS scheduler : job walltime in hours
    %
    sparams.simul.remote.scheduler.torque.nodes = {'','',''};%TORQUE scheduler : number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type 'pbsnodes -a' to get the list of node names
    sparams.simul.remote.scheduler.torque.ppn = {'','',''};%TORQUE scheduler : number of processors requested on the same node. if empty or NaN, default value requested.
    sparams.simul.remote.scheduler.torque.select = {'','',''};%TORQUE scheduler : number of separate nodes. If empty or NaN, default value. Type 'pbsnodes -a' to get the list of nodesand their characteristics
    sparams.simul.remote.scheduler.torque.ncpus = {2,2,2};%TORQUE scheduler : number of cpus per node (must be even number). If empty or NaN, default value. 
    sparams.simul.remote.scheduler.torque.memory = {15000,15000,15000};%TORQUE scheduler : job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations
    sparams.simul.remote.scheduler.torque.walltime = {24,24,24};%TORQUE scheduler : job walltime in hours
    %
    sparams.simul.remote.scheduler.slurm.ncores = {'','',''};%SLURM scheduler : number of cores. If empty or NaN, default value. 
    sparams.simul.remote.scheduler.slurm.memory = {15000,15000,15000};%SLURM scheduler : job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations
    sparams.simul.remote.scheduler.slurm.walltime = {24,24,24};%SLURM scheduler : job walltime in hours
    %
    sparams.simul.jprofileconsistency.code = {'METIS' 'METIS' 'METIS'};%Name of the tokamak code for current density profile selfconsistency with LUKE calculations. If empty, no selfconsistency is performed. 
    sparams.simul.jprofileconsistency.nit = {[0] [0] [0]};
    sparams.simul.jprofileconsistency.toll = {[0] [0] [0]};
    sparams.simul.jprofileconsistency.log = {[1] [1] [1]};
    sparams.simul.jprofileconsistency.stepsavedata = {[1:8] [1:8] [1:8]};
    sparams.simul.jprofileconsistency.tprofonoff = {[true] [true] [true]};
    sparams.simul.jprofileconsistency.datapath = {[pwd] [pwd] [pwd]};
    sparams.simul.jprofileconsistency.sourceoutside.use = {[1] [1] [1]};
    sparams.simul.jprofileconsistency.sourceoutside.file = {['SLUKE_RESULTS/PROC_LUKE_DATA_TS_41114_14.5_15.5_1_control_#0.mat'] ['SLUKE_RESULTS/PROC_LUKE_DATA_TS_41114_14.5_15.5_1_control_#0.mat'] ['SLUKE_RESULTS/PROC_LUKE_DATA_TS_41114_14.5_15.5_1_control_#0.mat']};
    sparams.simul.jprofileconsistency.sourceoutside.condition = {['jit==1'] ['jit==1'] ['jit==1']};
    %
    sparams.simul.initial_distribution = {0,0,0};%Time evolution of the distribution function : (0) -> at each time, initial distribution is a Maxwellian, (-1) -> at each time, initial distribution is the distribution from previous time (except the first that is necessarily Maxwellian)
    %
    sparams.simul.mute.load_structures_yp = {[1] [1] [1]};%No display of messages from load_structures_yp.m script if '1', full display if '0'
    sparams.simul.mute.run_lukert = {[1] [1] [1]};%No display of messages from run_lukert.m script if '1', full display if '0'
    sparams.simul.mute.clustermode_luke = {[1] [1] [1]};%No display of messages from clustermode_luke.m script if '1', full display if '0'
    sparams.simul.mute.mdce_clustermode = {[1] [1] [1]};%No display of messages from mdce_clustermode.m script if '1', full display if '0'
    sparams.simul.mute.displayrunningjob = {[1] [1] [1]};%No display of messages from displayrunningjob.m script if '1', full display if '0'
    sparams.simul.mute.remote_tsdate = {[1] [1] [1]};%No display of messages from remote_tsdate.m script if '1', full display if '0'
    sparams.simul.mute.bremsstrahlung_dke_yp = {[1] [0] [1]};%No display of messages from bremsstrahlung_dke_yp.m script if '1', full display if '0'
    sparams.simul.mute.bremdiag_dke_yp = {[1] [0] [1]};%No display of messages from bremdiag_dke_yp.m script if '1', full display if '0'
    sparams.simul.mute.metis2luke = {[1] [1] [1]};%No display of messages from metis2luke.m script if '1', full display if '0'
    sparams.simul.mute.equilconsistency_yp = {[1] [1] [1]};%No display of messages from equilconsistency_yp.m script if '1', full display if '0'
    sparams.simul.mute.make_equil_metis2luke = {[1] [1] [1]};%No display of messages from make_equil_metis2luke.m script if '1', full display if '0'
    sparams.simul.mute.make_sluke_build_launchs = {[1] [1] [1]};%No display of messages from make_sluke_build_launchs.m script if '1', full display if '0'
    sparams.simul.mute.lukeschedulerparam = {[1] [1] [1]};%No display of messages from lukeschedulerparam.m script if '1', full display if '0'
    %
    sparams.simul.save.backup = {0,0,0};% (1) save fluctuation time steps (0) do not save in runlukert.m
    sparams.simul.save.waves = {0,0,0}; %LUKE simulations with plasma fluctuations : (1) save waves at each fluctuation time step (0) do not save in runlukert.m
    %
    % kinetic calculations parameters  
    %
    sparams.kinetics.dkeparam.comment = {'' '' ''};%Some general comments to justify the kinetics parameters for the simulations in 'dkeparam' structure
    sparams.kinetics.dkeparam.source = {'preset' 'preset' 'preset'};%Source of the LUKE 'dkeparam' structure : 'preset' or 'file'
    sparams.kinetics.dkeparam.preset = {'LH_RT' 'LH_RT' 'LH_RT'};%Preset 'dkeparam' value if the source is 'preset'. Available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/DKEPARAM_files/ 
    sparams.kinetics.dkeparam.file = {'' '' ''};%Name of the file that contains the 'dkeparam' structure if the source is 'file'
    sparams.kinetics.dkeparam.path = {'' '' ''};%Path of the file that contains the 'dkeparam' structure if the source is 'file'
    sparams.kinetics.dkeparam.clustermode.coll_dke_jd.scheduler.mode = {0,0,0};%MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
    sparams.kinetics.dkeparam.clustermode.eecoll_dke_yp.scheduler.mode = {0,0,0};%MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function eecoll_dke_yp.m (MDC toolbox must be installed for option 1)
    sparams.kinetics.dkeparam.clustermode.wave_solver_yp.scheduler.mode = {0,0,0};%MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function wave_solver_yp.m (MDC toolbox must be installed for option 1)
    sparams.kinetics.dkeparam.clustermode.rfdiff_dke_jd.scheduler.mode = {0,0,0};%MatLab distributed computing environment: disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function rfdiff_dke_jd.m (MDC toolbox must be installed for option 1)
    %
    sparams.kinetics.dkeparam.nmhu_S = {101*NaN,101*NaN,101*NaN};%Enforced cosine of pitch-angle flux grid : number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run). If NaN or empty, the default value in 'dkeparam' structure is considered.
    sparams.kinetics.dkeparam.np_S = {151*NaN,151*NaN,151*NaN};%Enforced momentum flux grid : number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than the pitch-angle one. If NaN or empty, the default value in 'dkeparam' structure is considered.
    sparams.kinetics.dkeparam.pnmax_S = {30*NaN,30*NaN,30*NaN};%Enforced upper limit of the momentum flux grid : maximum value of the flux momentum grid (pth_ref). If NaN or empty, the default value in 'dkeparam' structure is considered.
    sparams.kinetics.dkeparam.rho_S = {20*NaN,20*NaN,20*NaN};%Enforced radial flux grid : if single real value larger than 1 : number of points for radial flux grid calculation (automatic and optimized for depending the type of RF waves); if single or list of multiple real values less than 1 : manual radial flux grid; if list of imaginary values : custom radial flux grid with [npoints + 1i*normalized_radial_position] (example : [5+0.1*i,12+0.7*i,3+1.0i]). Radial points are unique. If NaN or empty, the default value in 'dkeparam' structure is considered.
    %
    sparams.kinetics.dkedisplay.comment = {'' '' ''};%Some general comments to justify the kinetics parameters for the simulations in 'dkedisplay' structure
    sparams.kinetics.dkedisplay.source = {'preset' 'preset' 'preset'};%Source of the LUKE 'dkedisplay' structure : 'preset' or 'file'
    sparams.kinetics.dkedisplay.preset = {'NO_DISPLAY' 'NO_DISPLAY' 'NO_DISPLAY'};%Preset 'dkedisplay' value if the source is 'preset' : NO_DISPLAY: does nothing, VISUAL: prints out equilibrium profiles (Te,ne) if SLUKE is run locally only. Available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/DISPLAY_files/ 
    %
    sparams.kinetics.elements.coulog_model =  {1,1,1};%Coulomb logarithm model
    sparams.kinetics.elements.Zi_ref = {'','',''};%Zi values whose density may be modified by the factor density_factor from C3PO/LUKE/R5X2 calculations if exist in equil structure (for tests). May be vector
    sparams.kinetics.elements.Zi_density_factor = {NaN,NaN,NaN};%Ad-hoc multiplication factors of the density of the elements Zi_ref
    sparams.kinetics.elements.screening.ADAS = {'ADAS.mat','ADAS.mat','ADAS.mat'};%Full path for the full ion screening model ADAS (necessary for screening of partially ionized atoms). If empty, fully ionized impurities are considered. If 'ADAS.mat', default ADAS value in LUKE.
    sparams.kinetics.elements.screening.partial.elastic = {'Tseng-Pratt-Botto','Tseng-Pratt-Botto','Tseng-Pratt-Botto'};%Elastic scattering by partially ionized atoms. List of models : 'DFT', 'Thomas-Fermi', 'Thomas-Fermi-Kirillov', 'Tseng-Pratt-Avdonina-Lamoureux', 'Tseng-Pratt-Botto', 'Tseng-Pratt-Thomas-Fermi'
    sparams.kinetics.elements.screening.partial.inelastic = {1,1,1};%Inelastic scattering by partially ionized atoms : (0) -> no   (1) -> yes
    sparams.kinetics.elements.screening.partial.dftpath = {'','',''};%For specific DFT file path only. Leave empty otherwise and the default calculations will be considered in LUKE
    %
    sparams.kinetics.fast_electron_anomalous_transport.comment = {'','',''};%Some general comments to justify the kinetics parameters for the simulations concerning fast electron anomalous transport
    sparams.kinetics.fast_electron_anomalous_transport.source = {'','',''};%Source of the LUKE 'transpfaste' structure : 'preset' or 'file'
    sparams.kinetics.fast_electron_anomalous_transport.preset = {'','',''};%Preset 'transpfaste' value if the source is 'preset'. Available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/TRANSP_files/ 
    sparams.kinetics.fast_electron_anomalous_transport.file = {'','',''};%Name of the file that contains the 'transpfaste' structure if the source is 'file'
    sparams.kinetics.fast_electron_anomalous_transport.path = {'','',''};%Path of the file that contains the 'transpfaste' structure if the source is 'file'
    sparams.kinetics.fast_electron_anomalous_transport.Dr_type = {'EM','EM','EM'};%Anomalous fast electron radial diffusion type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM-: v|| dependence (Dr(r)*vpar_ref/vth_ref), EM-: 1/v|| dependence)
    sparams.kinetics.fast_electron_anomalous_transport.Dr0 = {0,0,0};%Radial diffusion (m^2/s). Dr0 = Dr_center + i*Dr_edge
    sparams.kinetics.fast_electron_anomalous_transport.pDr = {0,0,0};%Profile dependence (pDr = pDr0 + i*pDr1) : if pDr is real (flat or parabolic increase from center to the edge): Dr(rho) = Dr_center*(1+pDr0*rho^2). If pDr is imaginary (step size from center to the edge): Dr(rho) = (Dr_center-Dr_edge)/(1+exp((rho-pDr0)/pDr1))+Dr_edge 
    sparams.kinetics.fast_electron_anomalous_transport.Vr_type = {'EM','EM','EM'};%Anomalous fast electron radial pinch type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence (Vr(r) = Vr0(r)*vpar_ref/vth_ref), EM-: 1/v|| dependence)
    sparams.kinetics.fast_electron_anomalous_transport.Vr0 = {0,0,0};%Radial pinch (m/s). Vr0 = Vr_center + i*Vr_edge
    sparams.kinetics.fast_electron_anomalous_transport.pVr = {0,0,0};%Profile dependence (pVr = pVr0 + i*pVr1) : if pVr is real (flat or parabolic increase from center to the edge): Vr(rho) = Vr_center*(1+pVr0*rho^2). If pVr is imaginary (step size from center to the edge): Vr(rho) = (Vr_center-Vr_edge)/(1+exp((rho-pVr0)/pVr1))+Vr_edge 
    sparams.kinetics.fast_electron_anomalous_transport.vparmin = {3.5,3.5,3.5};%Normalized units
    sparams.kinetics.fast_electron_anomalous_transport.norm_ref = {1,1,1};%Normalization of the velocity threshold: (0) v||/vT (local), (1) v||/vT_ref (central value)
    %
    % toroidal MHD calculations parameters  
    %
    sparams.equil.comment = {'metis' 'metis' 'metis'};%Some general comments on the toroidal MHD equilibrium calculations
    sparams.equil.source = {'file' 'file' 'file'};%Source of the toroidal MHD structure : 'preset' or 'file' or 'code'
    sparams.equil.preset = {'','',''};%Preset value of the toroidal MHD structure if the source is 'preset'. Available presets are in the LUKE folder ~/LUKE_CEA/Project_DKE/Database/EQUIL_files/ 
    sparams.equil.file = {'' '' ''};%Name of the file that contains the 'equil' structure if the source is 'file'
    sparams.equil.path = {'./INPUTS' './INPUTS' './INPUTS'};%Path of the file that contains the 'equil' structure if the source is 'file'
    sparams.equil.code = {'' '' ''};%Code name of the toroidal MHD structure if the source is 'code'.
    %
    sparams.equil.equilconsistency.comment = {'','',''};%Some general comments on the toroidal MHD equilibrium calculations
    sparams.equil.equilconsistency.auto_mode = {1,1,1};%
    sparams.equil.equilconsistency.display_mode = {0,0,0};%
    sparams.equil.equilconsistency.prho = {'','',''};%
    sparams.equil.equilconsistency.mtheta = {'','',''};%
    %
    sparams.equil.fit.comment = {'','',''};%Some general comments on the vectorial toroidal MHD equilibrium calculations
    sparams.equil.fit.mode_equil = {1,1,1};%
    sparams.equil.fit.method = {'spline','spline','spline'};%
    sparams.equil.fit.nharm = {NaN,NaN,NaN};%
    sparams.equil.fit.ngridresample = {1001,1001,1001};%
    sparams.equil.fit.opt_load = {0,0,0};%
    %
    sparams.equil.ripple.comment = {'','',''};%Some general comments on the toroidal magnetic ripple calculations
    sparams.equil.ripple.source = {'','',''};%
    sparams.equil.ripple.preset = {'','',''};%
    sparams.equil.ripple.file = {'','',''};%
    sparams.equil.ripple.path = {'','',''};%
    sparams.equil.ripple.mode = {0,0,0};%Magnetic ripple model incorporated in LUKE code : (0): non magnetic ripple, (1) with toroidal magnetic ripple. For Tore Supra or WEST tokamaks only yet
    %
    % ohmic electric field calculations parameters  
    %
    sparams.ohm.comment = {'' '' ''};%Some general comments on the Ohmic electric calculations
    sparams.ohm.source = {'file' 'file' 'file'};%Source of the 'ohm' structure : 'preset' or 'file' or 'code'
    sparams.ohm.code = {'' '' ''};%Code name of the 'ohm' structure  for the Ohmic electric field if the source is 'code'.
    sparams.ohm.file = {'' '' ''};%Name of the file that contains the 'ohm' structure if the source is 'file'
    sparams.ohm.path = {'./INPUTS' './INPUTS' './INPUTS'};%Path of the file that contains the 'ohm' structure if the source is 'file'
    %
    % rf waves calculations parameters  
    %
    sparams.rfwaves.comment = {'','',''};%Some general comments on the RF waves calculations
    sparams.rfwaves.source = {'','',''};%Source of the 'wavestructs' structure : 'preset' or 'file'
    sparams.rfwaves.file = {'','',''};%Name of the file that contains the 'wavestructs' structure if the source is 'file'
    sparams.rfwaves.path = {'','',''};%Path of the file that contains the 'wavestructs' structure if the source is 'file'
    sparams.rfwaves.enable = {1,1,1};%Enabling RF wave calculations or use of an external wavestructs structure (1) or not (0). 
    %
    sparams.rfwaves.antenna.type = {{},{'LH','LH'},{'LH','LH'}};%'LH' lower hybrid wave, 'EC' electron cyclotron waves, 'EBW' for electron Bernstein wave, or {'LH','LH'} if the LH wave is launched by two different antennas. As many antennas as necessary may be added. Empty corresponds to RF wave.
    sparams.rfwaves.antenna.comment = {{} {'ne_fixed','ne_fixed'} {'ne_fixed','ne_optim'}};%General comments on the antenna structure calculation
    sparams.rfwaves.antenna.source = {{},{'code','code'},{'code','code'}};%Source of the 'antennas' structure : 'code' or 'file'
    sparams.rfwaves.antenna.code = {{},{'ALOHA','ALOHA'},{'ALOHA','ALOHA'}};%Code name of the 'antennas' structure  if the source is 'code'.
    sparams.rfwaves.antenna.file = {{},{'',''},{'',''}};%Name of the file that contains the 'antennas' structure if the source is 'file'
    sparams.rfwaves.antenna.path = {{},{'',''},{'',''}};%Path of the file that contains the 'antennas' structure if the source is 'file'
    %
    sparams.rfwaves.antenna.LH.ALOHA.port = {{},{'Q6A','Q6B'},{'Q6A','Q6B'}};%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
    sparams.rfwaves.antenna.LH.ALOHA.remote_profile = {{},{'local','local'},{'local','local'}};%%Calculation profile. Local interactive calculations -> '0' or 'local'. Remote calculations : type first dispremoteprofiles('','scheduler'); to get by values and names the available remote machines on which LUKE calculations can be performed. Profiles in MatRemote toolboxes must be defined first, then incorporated in the local LUKE path file.
    sparams.rfwaves.antenna.LH.ALOHA.display.data.mode = {{},{[-1],[-1]},{[-1],[-1]}};%Display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if figure exist
    sparams.rfwaves.antenna.LH.ALOHA.display.data.save = {{},{[1],[1]},{[1],[1]}};%Display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist
    sparams.rfwaves.antenna.LH.ALOHA.display.results = {{},{0,0},{0,0}};%Display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
    sparams.rfwaves.antenna.LH.ALOHA.optim.method = {{},{0,0},{1,1}};%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
    sparams.rfwaves.antenna.LH.ALOHA.optim.ne_guess = {{},{2.0e17,2.0e17},{[0.7e17,5.0e17],[0.7e17,5.0e17]}};%%Edge density in front of the grill (initial guess or enforced value) (m-3)
    sparams.rfwaves.antenna.LH.ALOHA.optim.tolfun = {{},{1e-2,1e-2},{1e-2,1e-2}};%Relative tolerance on targets (if aloha.optim.method = 1)
    sparams.rfwaves.antenna.LH.ALOHA.optim.tolx = {{},{1e-2,1e-2},{1e-2,1e-2}};%Relative tolerance on inputs (if aloha.optim.method = 1)
    sparams.rfwaves.antenna.LH.ALOHA.optim.nitmax = {{},{10,10},{10,10}};%Maximum number of iterations (if aloha.optim.method = 1)
    %
    % See proc_aloha_spec_jd.m for details on the input parameters
    %
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.dir = {{},{1,1},{1,1}};%(0) P + preserve repartition and total power, (1) P/N^2 + preserve directivity and repartition, (2) P/N^2 + preserve directivity and total power (treating positive and negative spectra as blocks. Warning : some transfer of P/N^2 across N=0 necessary in this case), (3) P/N^2 + preserve repartition and total power 
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.mode = {{},{0,0},{0,0}};%(0) select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin), (1) assemble peaks fixing Pmax and N, allowing dN to change, (2) assemble peaks allowing Pmax, N and dN to change
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.nlobes = {{},{10,10},{10,10}};%number of lobes selected in the power spectrum
    %sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.ny = {{},{0,0},{0,0}};
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.Pin_in = {{},{NaN,NaN},{NaN,NaN}}; %corrected initial total power. If NaN take value ALOHA else the value is enforced by Pin_in (W). Consider globalspectrum to get the total LH power. 
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.opt_optim = {{},{0,0},{0,0}};%use of function lsqnonlin for gaussian lobe fit (default : 0)
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = {{},{0,0},{0,0}};%upper and lower half-antenna modules are considered independently (0) or only half upper module for the whole antenna (1). If sparams.rfwaves.antenna.LH.ALOHA.optim.method == 0, sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = 1 is enforced.
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent = {{},{1,1},{1,1}};%the Lower Hybrid wave drive co-current (1) or counter-current (-1)
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.inter = {{},{0,0},{0,0}};%interactive mode for selecting parameters
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.mode = {{},{0,0},{0,0}};%display (0) none (1) text only (2) text and figures (default : 0)
    sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.comparison = {{},{1,1},{1,1}};%display comparison between experimental value and calculations (1) yes (0) no
    %
    sparams.rfwaves.antenna.LH.C3PO.launch.omega_rf = {{},{2.3248e+10,2.3248e+10},{2.3248e+10,2.3248e+10}};
    sparams.rfwaves.antenna.LH.C3PO.launch.bNpar0 = {{},{[-1.9149,6.0000],[-1.9149,6.0000]},{[-1.9149,6.0000],[-1.9149,6.0000]}};
    sparams.rfwaves.antenna.LH.C3PO.launch.bdNpar0 = {{},{[0.2,0.2],[0.2,0.2]},{[0.2,0.2],[0.2,0.2]}};
    sparams.rfwaves.antenna.LH.C3PO.launch.bPlhtot = {{},{[1950400,835900],[1950400,835900]},{[1950400,835900],[1950400,835900]}};
    sparams.rfwaves.antenna.LH.C3PO.launch.mainlobeshift = {{},{0,0},{0,0}};% artificial shift of the main lobe of the LH power spectrum : 0 nothing done, < 1 : reduction of the absolute value, > 1 increase of the absolute value
    sparams.rfwaves.antenna.LH.C3PO.launch.rZ0 =  {{},{0,0},{0,0}};%0+1i to be verified
    sparams.rfwaves.antenna.LH.C3PO.launch.m0 = {{},{0,0},{0,0}};
    sparams.rfwaves.antenna.LH.C3PO.launch.phi0 = {{},{0,0},{0,0}};
    sparams.rfwaves.antenna.LH.C3PO.launch.i_ref = {{},{-1,-1},{-1,-1}};%100 ou -1 to be verified
    sparams.rfwaves.antenna.LH.C3PO.launch.LFS = {{},{1,1},{1,1}};
    sparams.rfwaves.antenna.LH.C3PO.launch.mmode = {{},{-1,-1},{-1,-1}};
    sparams.rfwaves.antenna.LH.C3PO.launch.nparp = {{},{0,0},{0,0}};
    sparams.rfwaves.antenna.LH.C3PO.launch.a_sdNpar = {{},{0,0},{0,0}};
    sparams.rfwaves.antenna.LH.C3PO.launch.w0 = {{},{NaN,NaN},{NaN,NaN}};
    sparams.rfwaves.antenna.LH.C3PO.launch.z_L = {{},{NaN,NaN},{NaN,NaN}};
    %{
    sparams.rfwaves.antenna.LH.C3PO.launch.ns = {{},{1000,1000},{1000,1000}};
    sparams.rfwaves.antenna.LH.C3PO.launch.n0 = {{},{NaN,NaN},{NaN,NaN}};
    sparams.rfwaves.antenna.LH.C3PO.launch.kz0 = {{},{NaN,NaN},{NaN,NaN}};
    sparams.rfwaves.antenna.LH.C3PO.launch.method = {{},{'pchip','pchip'},{'pchip','pchip'}};%cubic obsolete
    sparams.rfwaves.antenna.LH.C3PO.launch.method1 = {{},{'pchip','pchip'},{'pchip','pchip'}};
    sparams.rfwaves.antenna.LH.C3PO.launch.method2 = {{},{'spline','spline'},{'spline','spline'}};
    %}
    sparams.rfwaves.antenna.LH.C3PO.launch.tail.dtn = {{},{Inf,Inf},{Inf,Inf}};
    sparams.rfwaves.antenna.LH.C3PO.launch.tail.mode = {{},{3,3},{3,3}};
    sparams.rfwaves.antenna.LH.C3PO.launch.tail.bNparmax_tail = {{},{0,0},{0,0}};
    sparams.rfwaves.antenna.LH.C3PO.launch.tail.bn_tail = {{},{0,0},{0,0}};
    sparams.rfwaves.antenna.LH.C3PO.launch.tail.bP_tail = {{},{0.5,0.5},{0.5,0.5}};
    sparams.rfwaves.antenna.LH.C3PO.launch.tail.bopt_tail = {{},{0.0000 + 1.0000i,0.0000 + 1.0000i},{0.0000 + 1.0000i,0.0000 + 1.0000i}};
    %
    sparams.rfwaves.solver.type = {{},{'ray-tracing','ray-tracing'},{'ray-tracing','ray-tracing'}};
    sparams.rfwaves.solver.code = {{},{'C3PO','C3PO'},{'C3PO','C3PO'}};
    sparams.rfwaves.solver.enable = {{},{1,1},{1,1}};
    sparams.rfwaves.solver.remote_profile = {{},{1,1},{1,1}};
    %
    %sparams.rfwaves.solver.C3PO.rayparam.comment = {{},{'',''},{'',''}};
    %sparams.rfwaves.solver.C3PO.rayparam.source = {{},{'',''},{'',''}};
    %sparams.rfwaves.solver.C3PO.rayparam.file = {{},{'',''},{'',''}};
    %sparams.rfwaves.solver.C3PO.rayparam.path = {{},{'',''},{'',''}};
    sparams.rfwaves.solver.C3PO.rayparam.testmode = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.rayparam.tensortype = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.rayparam.t0 = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.rayparam.tfinal = {{},{50000,50000},{50000,50000}};
    sparams.rfwaves.solver.C3PO.rayparam.dt0 = {{},{1e-4,1e-4},{1e-4,1e-4}};
    sparams.rfwaves.solver.C3PO.rayparam.dS = {{},{1e-3,1e-3},{1e-3,1e-3}};
    sparams.rfwaves.solver.C3PO.rayparam.tol = {{},{1e-12,1e-12},{1e-12,1e-12}};
    sparams.rfwaves.solver.C3PO.rayparam.kmax = {{},{50000,50000},{50000,50000}};
    sparams.rfwaves.solver.C3PO.rayparam.ncyclharm = {{},{3,3},{3,3}};
    sparams.rfwaves.solver.C3PO.rayparam.reflection = {{},{1,1},{1,1}};
    sparams.rfwaves.solver.C3PO.rayparam.rel_opt = {{},{1,1},{1,1}};
    sparams.rfwaves.solver.C3PO.rayparam.nperp = {{},{1000,1000},{1000,1000}};
    sparams.rfwaves.solver.C3PO.rayparam.pperpmax = {{},{10,10},{10,10}};
    sparams.rfwaves.solver.C3PO.rayparam.tau_lim = {{},{20,20},{20,20}};
    sparams.rfwaves.solver.C3PO.rayparam.kextra = {{},{2000,2000},{2000,2000}};
    sparams.rfwaves.solver.C3PO.rayparam.colldamp = {{},{1,1},{1,1}};
    %sparams.rfwaves.solver.C3PO.rayparam.metricmode = {{},{1,1},{1,1}};
    %sparams.rfwaves.solver.C3PO.rayparam.rhoswitch = {{},{0.1,0.1},{0.1,0.1}};
    %sparams.rfwaves.solver.C3PO.rayparam.substitution_method = {{},{7,7},{7,7}};
    %
    %sparams.rfwaves.solver.C3PO.raydisplay.comment = {{},{'',''},{'',''}};
    %sparams.rfwaves.solver.C3PO.raydisplay.source = {{},{'',''},{'',''}};
    %sparams.rfwaves.solver.C3PO.raydisplay.file = {{},{'',''},{'',''}};
    %sparams.rfwaves.solver.C3PO.raydisplay.path = {{},{'',''},{'',''}};
    sparams.rfwaves.solver.C3PO.raydisplay.ray = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.raydisplay.equilibrium = {{},{0,0},{0,0}};
    %sparams.rfwaves.solver.C3PO.raydisplay.fluctuations = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.raydisplay.p_opt = {{},{-1,-1},{-1,-1}};
    %sparams.rfwaves.solver.C3PO.raydisplay.mdce = {{},{0,0},{0,0}};
    %
    sparams.rfwaves.solver.C3PO.waveparam.mmode = {{},{-1,-1},{-1,-1}};
    sparams.rfwaves.solver.C3PO.waveparam.kmode = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.waveparam.opt_rf = {{},{1,1},{1,1}};
    sparams.rfwaves.solver.C3PO.waveparam.dsmin = {{},{Inf,Inf},{Inf,Inf}};
    %sparams.rfwaves.solver.C3PO.waveparam.nd = {{},{0,0},{0,0}};
    %sparams.rfwaves.solver.C3PO.waveparam.nchi = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.waveparam.n_rf_list = {{},{0,0},{0,0}};
    %sparams.rfwaves.solver.C3PO.waveparam.ns = {{},{0,0},{0,0}};
    %sparams.rfwaves.solver.C3PO.waveparam.rhomin = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.waveparam.a_sdNpar = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.waveparam.cut_fac = {{},{2,2},{2,2}};
    %
    %sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.mode = {{},{0,0},{0,0}};
    %sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.timeout = {{},{1000,1000},{1000,1000}};
    %sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.size = {{},{12,12},{12,12}};
    %sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.mem = {{},{500,500},{500,500}};
    sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.mode = {{},{0,0},{0,0}};
    sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.memory = {{},{500,500},{500,500}};
    %
    % post-processing calculations parameters  
    %
    sparams.postprocessing.comment = {'','',''};
    sparams.postprocessing.source = {'','',''};
    sparams.postprocessing.ir_display = {-1,-1,-1};%(-1) no interactive post-processing display, (0) interactive post-processing display
    sparams.postprocessing.p_opt = {-1,-1,-1};%printing and saving options : (-1) do nothing, (0) print figures, (1) print figures and save figures, (2) save figures
    sparams.postprocessing.dp_cyl = {0.1,0.1,0.1};%no interactive post-processing display
    sparams.postprocessing.pnmax = {NaN,NaN,NaN};%no interactive post-processing display
    sparams.postprocessing.peak = {'y','y','y'};%no interactive post-processing display
    sparams.postprocessing.wave = {'y','y','y'};%no interactive post-processing display
    sparams.postprocessing.peakmode = {1,1,1};%no interactive post-processing display
    sparams.postprocessing.rho = {'t','t','t'};%no interactive post-processing display
    sparams.postprocessing.spec = {0,0,0};%no interactive post-processing display
    sparams.postprocessing.its_rf = {true,true,true};%no interactive post-processing display
    sparams.postprocessing.blist = {'','',''};%no interactive post-processing display
    sparams.postprocessing.diaryname = {'','',''};%no interactive post-processing display       
    %
    % synthetic diagnostics calculations parameters  
    %
    sparams.diags.DSPX.id = {'DSPX','DSPX','DSPX'};
    sparams.diags.DSPX.code = {'R5X2','R5X2','R5X2'};%name of the FEB code
    sparams.diags.DSPX.remote_calculations = {1,1,1};%Synthetic diagnostic calculations done remotely (1) or locally( 0)
    sparams.diags.DSPX.enable = {1,1,1};%Synthetic diagnostic calculations is enabled (1) or disabled (0) 
    sparams.diags.DSPX.exp = {1,1,1};%Load experimental data enabled (1) or disabled (0) 
    %
    sparams.diags.DSPX.hxrspec.comment = {'','',''};
    sparams.diags.DSPX.hxrspec.source = {'','',''};%source of the data (code, file, value). If empty, obtained from database or script if available.
    sparams.diags.DSPX.hxrspec.file = {'','',''};%file name
    sparams.diags.DSPX.hxrspec.path = {'','',''};%path
    sparams.diags.DSPX.hxrspec.chordstatus_hxr = {[0,0,0,0,0,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1],...
                                                  [0,0,0,0,0,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1],...
                                                  [0,0,0,0,0,1,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1]};% (1) -> active chords, (0) -> inactive chords %
    %
    sparams.diags.DSPX.R5X2.hxrparam.comment = {'','',''};
    sparams.diags.DSPX.R5X2.hxrparam.source = {'value','value','value'};%source of the data (code, file, value). If empty, defaults values
    sparams.diags.DSPX.R5X2.hxrparam.file = {'','',''};%file name
    sparams.diags.DSPX.R5X2.hxrparam.path = {'','',''};%path
    sparams.diags.DSPX.R5X2.hxrparam.mfactor = {1,1,1};%For the magnetic equilibrium
    sparams.diags.DSPX.R5X2.hxrparam.method = {'spline','spline','spline'};%For the magnetic equilibrium in the HXR calculations
    sparams.diags.DSPX.R5X2.hxrparam.ns = {3000,3000,3000};%for chord integration
    sparams.diags.DSPX.R5X2.hxrparam.n_gauleg = {35,35,35};%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
    sparams.diags.DSPX.R5X2.hxrparam.epsi_gauleg = {1e-14,1e-14,1e-14};%Accuracy of the Legendre projection
    sparams.diags.DSPX.R5X2.hxrparam.kmin = {50,50,50};%for Tphot calculations
    sparams.diags.DSPX.R5X2.hxrparam.kmax = {110,110,110};%for Tphot calculations
    sparams.diags.DSPX.R5X2.hxrparam.kphot = {[20:10:240],[20:10:240],[20:10:240]};%Photon energy in keV (important for bremsstrahlung with partial screening effects)
    sparams.diags.DSPX.R5X2.hxrparam.full_results = {0,0,0};%Save all simulations results (1) or just those that can be compared directly to experimental measurements (0).
    %
    sparams.diags.MEHXR.id = {'MEHXR','MEHXR','MEHXR'};
    sparams.diags.MEHXR.code = {'R5X2','R5X2','R5X2'};%name of the FEB code
    sparams.diags.MEHXR.remote_calculations = {1,1,1};%Synthetic diagnostic calculations done remotely (1) or locally( 0)
    sparams.diags.MEHXR.enable = {1,1,1};%Synthetic diagnostic calculations is enabled (1) or disabled (0) 
    sparams.diags.MEHXR.exp = {1,1,1};%Load experimental data enabled (1) or disabled (0)
    %
    sparams.diags.MEHXR.hxrspec.comment = {'from Tullio Barbui','from Tullio Barbui','from Tullio Barbui'};
    sparams.diags.MEHXR.hxrspec.source = {'file','file','file'};%source of the data (code, file, value). If empty, obtained from database or script if available.
    sparams.diags.MEHXR.hxrspec.file = {'HXR_MEHXR.mat','HXR_MEHXR.mat','HXR_MEHXR.mat'};%source of the data (code, file, value)
    sparams.diags.MEHXR.hxrspec.path = {'','',''};
    sparams.diags.MEHXR.hxrspec.chordstatus_hxr = {ones(1,60),ones(1,60),ones(1,60)};% (1) -> active chords, (0) -> inactive chords 
    %
    sparams.diags.MEHXR.R5X2.hxrparam = sparams.diags.DSPX.R5X2.hxrparam; 
    %
    sparams.diags.MEHXR.R5X2.hxrparam.comment = {'from Tullio Barbui','from Tullio Barbui','from Tullio Barbui'};
    sparams.diags.MEHXR.R5X2.hxrparam.kmin = {30,30,30};%for Tphot calculations
    sparams.diags.MEHXR.R5X2.hxrparam.kmax = {100,100,100};%for Tphot calculations
    sparams.diags.MEHXR.R5X2.hxrparam.kphot = {[10:5:200],[10:5:200],[10:5:200]};%Photon energy in keV (important for bremsstrahlung with partial screening effects)
    sparams.diags.MEHXR.R5X2.hxrparam.full_results = {0,0,0};%Save all simulations results (1) or just those that can be compared directly to experimental measurements (0).
    %
    sparams.diags.DSPX.R5X2.hxrparam.screening.partial.screening_model = {'Tseng-Pratt-Botto','Tseng-Pratt-Botto','Tseng-Pratt-Botto'};%screening model for bremsstrahlung
    sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nphi = {NaN,NaN,NaN};%for numerical integration 1BS -> 2BN. If nphi = NaN, formula deduced from analytical integration in phi is used (4-D). Otherwise (5-D)
    sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.flag_mem = {1,1,1};%Memory management enforcement : 0 -> 5-D block numerical calculations, 1 -> 4-D block numerical calculations
    sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.ntheta = {2006,2006,2006};%for numerical integration 1BS -> 2BN
    sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.integral = {'simps','simps','simps'};%Numerical integration : trapz (trapeze) or simps (Simpson)
    sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nEc = {300,300,300};%keV (number of incoming electron kinetic energies for calculating the BHE cross-section table with partial screening)
    sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.Ecmax = {1000,1000,1000};%keV (max incoming electron kinetic energy for calculating the BHE cross-section table with partial screening)
    %

end
%
function sparams = make_preset_REMOTE
    %
    [~,~,index_value,profile_value] = dispremoteprofiles('','scheduler',1,1);
    %
    sparams = make_preset_LOCAL;
    %
    for jj = 1:length(sparams.simul.remote.profile)
        %
        sparams.simul.remote.profile{jj} = profile_value;
        %
    end
    %
end
