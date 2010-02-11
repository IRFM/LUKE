function [AMRcfg_file,launch] = make_input_AMR(basestr,equil,launch,AMR_script_path,AMR_simul_path,opt_gui)
%
experiment = basestr;
%
if isfield(equil,'info') && isfield(equil.info,'shotnum'),
    shotnum = str2num(equil.info.shotnum);
else
    shotnum = 0;
end
%
if isfield(equil,'info') && isfield(equil.info,'shotime'),
    shotime = str2num(equil.info.shotime);
else
    shotime = 0;
end
%
Zeff = mean(sum(equil.pzni.*repmat(equil.zZi.',[1,length(equil.pne)]).^2,1)./equil.pne);
dlognedrm1 = -(equil.pne(end) + equil.pne(end-1))/2/(equil.pne(end) - equil.pne(end-1))*(equil.ptx(end,1) - equil.ptx(end-1,1));
dlogTedrm1 = -(equil.pTe(end) + equil.pTe(end-1))/2/(equil.pTe(end) - equil.pTe(end-1))*(equil.ptx(end,1) - equil.ptx(end-1,1));
%
% Create input (config) files for AMR
%
%
% Creates a structure containing all cfg entries with their default values
%
AMRcfg = cfg2mat([AMR_script_path,'ebe6_defaults.cfg']);
antennacfg = cfg2mat([AMR_script_path,'antenna_template.cfg']);
%
% optional read of existing config and antenna files
%
filename_AMRcfg = 'ebe6*.cfg';
filename_antennacfg = 'antenna*.cfg';
%
[AMRcfg_file,AMRcfg_path] = igetfile_jd(opt_gui,filename_AMRcfg,...
'You may overwrite defaults with an existing ebe6.cfg file (cancel to skip)',AMR_simul_path);
%
if AMRcfg_file ~= 0,
    AMRcfg = cfg2mat([AMRcfg_path,AMRcfg_file],AMRcfg);
end
%
[antennacfg_file,antennacfg_path] = igetfile_jd(opt_gui,filename_antennacfg,...
'You may overwrite defaults with an existing antenna.cfg file (cancel to skip)',AMR_simul_path);
%
if antennacfg_file ~= 0,
    antennacfg = cfg2mat([antennacfg_path,antennacfg_file],antennacfg);
end
%
if ~isempty(launch) % Ask for modification of the cfg files with the external database if it exists
    m_sim_opt = input_dke_yp('Do you want the simulation cfg file to be modified with the shot parameters [y/n]','y',{'y','n'},'',[1,1]);
    m_ant_opt = input_dke_yp('Do you want the antenna cfg file to be modified with the shot parameters [y/n]','y',{'y','n'},'',[1,1]);
else
    m_sim_opt = 'n';
    m_ant_opt = 'n';
end
% Default save name
AMRcfg_file = 'ebe6_LUKE.cfg';
% Modify save name
AMRcfg_file = input_dke_yp('Simulation configuration file save name',AMRcfg_file,'');
% Default save name
AMRcfg.antenna.cfg_file = 'antenna_LUKE.cfg';
% Modify save name
AMRcfg.antenna.cfg_file = input_dke_yp('Antenna configuration file save name',AMRcfg.antenna.cfg_file,'');
%
% === S I M U L A T I O N   F I L E ===
%
if (strcmp(m_sim_opt,'y') & strcmp(experiment,'TCV')) % Modify the simulation configuration file for TCV
    %
    % == Input section ==
    %
    AMRcfg.input.device = 'tokamak';
    AMRcfg.input.experiment = experiment;
    AMRcfg.input.shot_number = shotnum;
    AMRcfg.input.start_time = shotime;
    AMRcfg.input.end_time = shotime;
    AMRcfg.input.ts_times = 'no';
    AMRcfg.input.time_samples = 1;
    AMRcfg.input.run_IDL = 'no';
    %
    % == Output section ==
    %
    AMRcfg.output.central_ray_only = 'no';
    AMRcfg.output.ray_details = 'yes';
    AMRcfg.output.power_deposition = 'yes';
    AMRcfg.output.current_density = 'hansen';
    AMRcfg.output.conv_eff = 'yes';
    AMRcfg.output.temperature = 'yes';
    AMRcfg.output.test_profiles = 'yes';
    AMRcfg.output.run_code = 'yes';
    AMRcfg.output.postprocess = 'yes';
    AMRcfg.output.sum_antennas = 'yes';
    AMRcfg.output.run_luke = 'no';
    %
    % == Cluster section ==
    %
    % Priority of the master process, i.e. the program itself if run locally
    % 0 = lowest (nice 19), 1 = medium (nice 10), 2 = standard (nice 0)
    AMRcfg.cluster.use_cluster = 'no';
    AMRcfg.cluster.job = 'optimum';
    AMRcfg.cluster.que = 'sque'; % sunfire, sque, kestrel
    AMRcfg.cluster.ncpu = 5;
    AMRcfg.cluster.check_int = 1;
    AMRcfg.cluster.priority = 0;
    AMRcfg.cluster.master_priority = 2;
    %
    % == General section ==
    %
    % Spot of plasma-beam intersection
    spot_type = input_dke_yp('Which spot type do you want to use ? 0 (PCO), 1 (LCFS), ',0,0:1,'',[1,1]);
    if spot_type == 0
    	AMRcfg.general.beam_spot_type = 'PCO';
    elseif spot_type == 1
    	AMRcfg.general.beam_spot_type = 'LCFS';
    end
    AMRcfg.general.m_interpreter = 'matlab';
    %
    % == Adaptive section ==
    %
    AMRcfg.adaptive.method = 'adaptive';
    AMRcfg.adaptive.coll_freq = 0.0005;
    AMRcfg.adaptive.n_init = 350;
    AMRcfg.adaptive.accuracy = 0.001;
    AMRcfg.adaptive.extension_xend_search = 1;
    %
    % == Ray tracing section ==
    %
    AMRcfg.ray_tracing.Zeff = Zeff; % Zeff (flat profile)
    AMRcfg.ray_tracing.Nperp = 1; % small root, makes a U-turn on EBW path (i.e., this is already electrostatic X-mode)
    AMRcfg.ray_tracing.accuracy = 1e-05;
    % Stopping power value (1-power_limit damped)
    AMRcfg.ray_tracing.power_limit = 1.e-15; % For longer wave propagation
    AMRcfg.ray_tracing.rt_check_harmonic = 'no';
    AMRcfg.ray_tracing.rt_check_harmonic_n = 2;
    AMRcfg.ray_tracing.resonant_damping_model = 'weakly-relativistic';
    AMRcfg.ray_tracing.collisional_damping_model = 'Ginzburg-Ruchadze';  
    %
    % == Luke section ==
    %
    AMRcfg.luke.outputs = 'yes';
    % The following parameters are used only if AMRcfg.output.run_luke = 'yes'.
    AMRcfg.luke.dsmin = 0; % minimum ray fragment length [m]
    AMRcfg.luke.kmode = 4; % electrostatic dispersion relation
    AMRcfg.luke.np = 101; % psi grid size
    AMRcfg.luke.nt = 65; % theta grid size
    AMRcfg.luke.equilibrium = 'R-Z'; % equilibrium export type (R-Z or psi-theta)
    %
    % == Test profiles section ==
    %
    % equilibrium and profiles are output on a [R_min;R_max] x [Z_min,Z_max]
    % rectangle with R_dim and Z_dim datapoint in R,Z directions
    AMRcfg.test_profiles.R_min = 0;
    AMRcfg.test_profiles.R_max = 0;
    AMRcfg.test_profiles.Z_min = 0;
    AMRcfg.test_profiles.Z_max = 0;
    AMRcfg.test_profiles.phi_test = 0;
    AMRcfg.test_profiles.phi_min = 0;
    AMRcfg.test_profiles.phi_max = 0;
    AMRcfg.test_profiles.R_dim = 101;
    AMRcfg.test_profiles.Z_dim = 101;
    AMRcfg.test_profiles.phi_dim = 1;
    AMRcfg.test_profiles.wkb_curve_ray = 1;
    AMRcfg.test_profiles.shot_time_test = 0;
    AMRcfg.test_profiles.Nparal_above = 0;
    AMRcfg.test_profiles.Nparal_below = 0;
    %
    % == Profiles section ==
    %
    % equilibrium and ne,Te profiles input type (matlab for LUKE)
    AMRcfg.profiles.equil_ver = 'default';
    AMRcfg.profiles.input_type = 'matlab';
    AMRcfg.profiles.eq_input_path = 'input';
    AMRcfg.profiles.psiSurfDim = 20;
    AMRcfg.profiles.fluxTraceDLcoeff = 0.05;
    AMRcfg.profiles.equilSplineOrder = 5;
    AMRcfg.profiles.FluxFnSplineOrder = 3;
    AMRcfg.profiles.export = 'none';
    AMRcfg.profiles.export_nR = 201;
    AMRcfg.profiles.export_nZ = 201;
    AMRcfg.profiles.export_npsi = 101;
    % Remove the stellarator fields
    if strcmp(experiment,'TCV')
    	AMRcfg.profiles = rmfield(AMRcfg.profiles,{'B_axis','phi0','s_max',...
    	's_LCFS','epsTrunc','epsA','compute_mesh'});
    end
    AMRcfg.profiles.ts_data = 'default';
    AMRcfg.profiles.n_components = 1;
    AMRcfg.profiles.ims = 4;
    AMRcfg.profiles.monotonize = 'no';
    AMRcfg.profiles.monotonize_freq = 0;
    AMRcfg.profiles.errorToleranceDen = 1;
    AMRcfg.profiles.errorToleranceTe = 1;
    % profiles averaging
    AMRcfg.profiles.averageProfilesDen = 'none';
    AMRcfg.profiles.averageProfilesTe = 'none';
    AMRcfg.profiles.averageDistanceDen = 0.2;
    AMRcfg.profiles.averageDistanceTe = 0.1;
    % profiles extension behind the last data point
    AMRcfg.profiles.extendProfilesDen = 'exp';
    AMRcfg.profiles.extendProfilesTe = 'exp';
    AMRcfg.profiles.extDataPoints = 5;
    AMRcfg.profiles.LSOL_den = dlognedrm1;
    AMRcfg.profiles.LSOL_Te = dlogTedrm1;
    % SOL width, increase for low frequencies with mode conversion close to or
    % out of LCFS
    LSOL = input_dke_yp('SOL width, ',0.01,[0;1],'',[1,1]);
    AMRcfg.profiles.LSOL = LSOL;
    AMRcfg.profiles.analytical_profiles = 'no';
    AMRcfg.profiles.LCFS_scale_break = 0.7225;
    AMRcfg.profiles.LCFS_scale_den_factor = 1;
    AMRcfg.profiles.LCFS_scale_Te_factor = 1;
    AMRcfg.profiles.Bpol_scale = 1;
    AMRcfg.profiles.Btor_scale = 1;
    %
    % == Analytical profiles section ==
    %
    AMRcfg.analytical_profiles.type = '';
    AMRcfg.analytical_profiles.phi = [];
    AMRcfg.analytical_profiles.nGrid = 50;
    AMRcfg.analytical_profiles.variable = 'R';
    AMRcfg.analytical_profiles.den_parameters = [];
    AMRcfg.analytical_profiles.Te_parameters = [];
    %
    % == Collisions section ==
    %
    AMRcfg.collisions.n_sigma_ei_nonelastic = 0;
    AMRcfg.collisions.n_sigma_en = 0;
    AMRcfg.collisions.neutral_concentration = 0;
    AMRcfg.collisions.datafile = '';
    %
    % == Antenna section
    %
    % See below.
    %
    % == Integration section ==
    %
    AMRcfg.integration.type = 'power';
    AMRcfg.integration.integrate_R = 'no';
    AMRcfg.integration.R_min = [];
    AMRcfg.integration.R_max = [];
    AMRcfg.integration.integrate_flux = 'yes';
    AMRcfg.integration.flux_coordinate = 'rho';
    AMRcfg.integration.flux_min = 0;
    AMRcfg.integration.flux_max = 1;
    AMRcfg.integration.tabdim = 20;
    %
    % == Figures section ==
    %
    AMRcfg.figures.create = 'no';
    AMRcfg.figures.luke_results = 'no';
    AMRcfg.figures.ext = 'pdf';
    AMRcfg.figures.use_latex = 'yes';
    AMRcfg.figures.plot_bw = 'no';
    AMRcfg.figures.experimental_data = 'yes';
    AMRcfg.figures.error_bars = 'yes';
    AMRcfg.figures.test_profiles = 'yes';
    AMRcfg.figures.rho_LCFS = 1;
    AMRcfg.figures.conv_eff_angular_ray = 'yes';
    AMRcfg.figures.ray_tracing_details = 'yes';
    AMRcfg.figures.ray_tracing_details_individual = 'yes';
    AMRcfg.figures.plot_waists = 'yes';
    AMRcfg.figures.power_deposition = 'yes';
    AMRcfg.figures.power_deposition_spectra = 'yes';
    AMRcfg.figures.power_deposition_individual = 'yes';
    AMRcfg.figures.power_deposition_comp = 'yes';
    AMRcfg.figures.wkb_curves = 'all';
    AMRcfg.figures.ebe_Trad_time = 'yes';
elseif (strcmp(m_sim_opt,'y') & ~strcmp(experiment,'TCV'))
    disp('-----> Modification of the ebe6.cfg files with external database implemented only for TCV.')
    return
end
%
% === A N T E N N A   F I L E ===
% 
ang_scan = input_dke_yp('Do you want to perform an angle scan [y/n]','y',{'y','n'},'',[1,1]);
model_opt = input_dke_yp('Do you want to use (0) Gaussian antenna model (1) TCV antenna model',0,{0,1},'Invalid selection');
launch.AMR.Lnum = str2num(launch.id(end));
launch.AMR.ang_scan = ang_scan;
launch.AMR.model_opt = model_opt;
scan.Lnum = str2num(launch.id(end));
scan.ang_scan = ang_scan;
scan.model_opt = model_opt;
%
% Subroutine for the angle and waist position calculation.
% Should be moved to CRPP SVN server soon.
%
addpath /home/goodman/psitbx_develop/; % For launch_point.m
addpath /home/curchod/matlab/ECRH/;	% For angle_launch_to_AMR.m
%
% NO ANGLE SCAN
%
if (strcmp(m_ant_opt,'y') & strcmp(ang_scan,'n') & strcmp(experiment,'TCV'))
    % Launcher angles
    theta_L = input_dke_yp('Confirm the POLOIDAL LAUNCHER angle in degrees',[launch.angles.theta/pi*180],[7;55],'',[1,1]);
    phi_L = input_dke_yp('Confirm the TOROIDAL LAUNCHER angle in degrees',[launch.angles.phi/pi*180],[-180;180],'',[1,1]);
    launch.AMR.theta_L = theta_L;
    launch.AMR.phi_L = phi_L;
    % Beam waist radius
    Wradius = 0.0188;
    launch.AMR.Wradius = Wradius;
    %
    % == General section ==
    %
    antennacfg.general.noOfCircles = input_dke_yp('How many circles of rays around the central ray?',[2],[0;10],'',[1,1]);
    antennacfg.general.raysPerCircle = input_dke_yp('How many rays per circle?',[3],[0;10],'',[1,1]);
    antennacfg.general.turnCircles = 'yes';
    antennacfg.general.n_window_points = 30;
    %
    % == Remove the default antenna section ==
    %
    if isfield(antennacfg,'antenna_id_00')
	antennacfg = rmfield(antennacfg,'antenna_id_00');
    end
    %
    % == Add the TCV antenna section ==
    % 
    if ~model_opt
    	disp('Use Gaussian antenna model.');
    	disp('AMR angles and waist position calculated using angle_launch_to_AMR.m (calling launchpoint.m).');
    	[theta_AMR,phi_AMR,xW,yW,zW] = angle_launch_to_AMR(1,theta_L,phi_L,[],[],[],str2num(launch.id(end)),0);
    	launch.AMR.theta_AMR = theta_AMR;
    	launch.AMR.phi_AMR = phi_AMR;
    	launch.AMR.xW = xW;
    	launch.AMR.yW = yW;
   	launch.AMR.zW = zW;
    	%
    	antennacfg.(launch.id).model = 'gaussian';
    	antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
    	antennacfg.(launch.id).toroidal_angles = phi_AMR;
    	antennacfg.(launch.id).poloidal_angles = theta_AMR;
    	antennacfg.(launch.id).angles_E_equatorial = 0;
    	antennacfg.(launch.id).angle_scan = 'none';
    	antennacfg.(launch.id).n_tor_angles = 1;
    	antennacfg.(launch.id).n_pol_angles = 1;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	antennacfg.(launch.id).x_waist = xW;
    	antennacfg.(launch.id).y_waist = yW;
    	antennacfg.(launch.id).z_waist = zW;
    	antennacfg.(launch.id).waist_radius = Wradius;
    	antennacfg.(launch.id).fix_divergence = 'no';
    	antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    else
    	disp('Use TCV model antenna.');
    	disp('Wave vector and waist position calculated using tcv_beam.m (calling launchpoint.m).');
    	antennacfg.(launch.id).model = 'tcv';
    	antennacfg.(launch.id).launcher_no = str2num(launch.id(end));
    	antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
    	antennacfg.(launch.id).toroidal_angles = phi_L;
    	antennacfg.(launch.id).poloidal_angles = theta_L;
    	antennacfg.(launch.id).angles_E_equatorial = 0;
    	antennacfg.(launch.id).angle_scan = 'none';
    	antennacfg.(launch.id).n_tor_angles = 1;
    	antennacfg.(launch.id).n_pol_angles = 1;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	%antennacfg.(launch.id).x_waist = xW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).y_waist = yW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).z_waist = zW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).waist_radius = Wradius;	% Now specified in tcv_beam.m
    	%antennacfg.(launch.id).fix_divergence = 'no';	% Now specified in tcv_beam.m
    	antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    end
elseif (strcmp(m_ant_opt,'y') & ~strcmp(experiment,'TCV'))
    disp('-----> Modification of the antenna.cfg files with external database implemented only for TCV.')
    return
end
%
% ANGLE SCAN
%
if (strcmp(ang_scan,'y') & strcmp(experiment,'TCV'))
    %
    % Launcher angles
    %
    theta_L = input_dke_yp('Give the minimum and maximum POLOIDAL LAUNCHER angles in degrees',[],[7;55],'',[1,2]);
    n_theta_L = input_dke_yp('Give the number of POLOIDAL LAUNCHER angles in the scan',5,[1;21],'',[1,1]);
    phi_L = input_dke_yp('Give the minimum and maximum TOROIDAL LAUNCHER angles in degrees',[],[-180;180],'',[1,2]);
    n_phi_L = input_dke_yp('Give the number of TOROIDAL LAUNCHER angles',5,[1;21],'',[1,1]);
    theta_L_list = linspace(theta_L(1),theta_L(2),n_theta_L);
    phi_L_list = linspace(phi_L(1),phi_L(2),n_phi_L);
    launch.AMR.theta_L = theta_L;
    launch.AMR.n_theta_L = n_theta_L;
    launch.AMR.theta_L_list = theta_L_list;
    launch.AMR.phi_L = phi_L;
    launch.AMR.n_phi_L = n_phi_L;
    launch.AMR.phi_L_list = phi_L_list;
    scan.theta_L = theta_L;
    scan.n_theta_L = n_theta_L;
    scan.theta_L_list = theta_L_list;
    scan.phi_L = phi_L;
    scan.n_phi_L = n_phi_L;
    scan.phi_L_list = phi_L_list;
    % Beam waist radius
    Wradius = 0.0188;
    launch.AMR.Wradius = Wradius;
    scan.Wradius = Wradius;
    %
    % === Modify SIMULATION file ===
    % Less detailed outputs + conversion efficiency calculation method
    %
    % == Output and LUKE sections ==
    AMRcfg.output.central_ray_only = 'yes';
    AMRcfg.output.ray_details = 'no';
    AMRcfg.output.power_deposition = 'no';
    AMRcfg.output.current_density = 'none';
    AMRcfg.output.conv_eff = 'yes';
    AMRcfg.output.temperature = 'yes';
    AMRcfg.output.test_profiles = 'yes';
    AMRcfg.output.run_code = 'yes';
    AMRcfg.output.postprocess = 'yes';
    AMRcfg.output.sum_antennas = 'yes';
    AMRcfg.output.run_luke = 'no';
    AMRcfg.luke.outputs = 'no';
    %
    % == Adaptive section ==
    %
    method = input_dke_yp('Which method do you want to use ? 0 (Adaptive), 1 (Preinhaelter), ',0,0:1,'',[1,1]);
    if method==0
    	AMRcfg.adaptive.method = 'adaptive';
	scan.method = 'adaptive';
    elseif method==1
    	AMRcfg.adaptive.method = 'preinh';
	scan.method = 'preinh';
    end
    %
    % === Modify ANTENNA file ===
    %
    % == General section ==
    %
    antennacfg.general.noOfCircles = 1;
    antennacfg.general.raysPerCircle = 1;
    antennacfg.general.turnCircles = 'no';
    antennacfg.general.n_window_points = 30;
    %
    % == Remove the default antenna section ==
    %
    if isfield(antennacfg,'antenna_id_00')
	antennacfg = rmfield(antennacfg,'antenna_id_00');
    end
    %
    % == Add the TCV antenna section ==
    % 
    if ~model_opt
    	disp('Use Gaussian antenna model.');
    	disp('AMR angles and waist position calculated using angle_launch_to_AMR.m (calling launchpoint.m).');
    	%
    	% Create all angle pairs and transform launcher angles into AMR angles
    	% Calculate the waist position for the central pair of angles pair
    	%
	ang_E_equ_list = zeros(1,n_theta_L*n_phi_L);
   	% Angles grids
   	[theta_L_grid phi_L_grid] = meshgrid(theta_L_list,phi_L_list);
    	launch.AMR.theta_L_grid = theta_L_grid;
    	launch.AMR.phi_L_grid = phi_L_grid;
    	scan.theta_L_grid = theta_L_grid;
    	scan.phi_L_grid = phi_L_grid;
    	% Angles pair for the waist position calculation
    	itheta_L = ceil(n_theta_L/2);
    	iphi_L = ceil(n_phi_L/2);
   	theta_L_waist = input_dke_yp('Confirm the poloidal LAUNCHER angle (degrees) for which the waist position is calculated',...
   	theta_L_list(itheta_L),[7;55],'',[1,1]);
   	phi_L_waist = input_dke_yp('Confirm the toroidal LAUNCHER angle (degrees) for which the waist position is calculated',...
    	phi_L_list(iphi_L),[-180;180],'',[1,1]);
	% Angles conversion
	[theta_AMR_grid,phi_AMR_grid,xW_grid,yW_grid,zW_grid] =...
    	angle_launch_to_AMR(1,theta_L_grid,phi_L_grid,[],[],[],str2num(launch.id(end)),0);
    	theta_AMR_list = reshape(theta_AMR_grid,1,n_theta_L*n_phi_L);
    	phi_AMR_list = reshape(phi_AMR_grid,1,n_theta_L*n_phi_L);
    	launch.AMR.theta_AMR_grid = theta_AMR_grid;
    	launch.AMR.phi_AMR_grid = phi_AMR_grid;
    	launch.AMR.theta_AMR_list = theta_AMR_list;
    	launch.AMR.phi_AMR_list = phi_AMR_list;
    	scan.theta_AMR_grid = theta_AMR_grid;
    	scan.phi_AMR_grid = phi_AMR_grid;
    	scan.theta_AMR_list = theta_AMR_list;
    	scan.phi_AMR_list = phi_AMR_list;
    	% Calculate the waist position for the chosen launcher angles pair
    	[theta_AMR_waist,phi_AMR_waist,xW,yW,zW] = angle_launch_to_AMR(1,theta_L_waist,phi_L_waist,[],[],[],str2num(launch.id(end)),0);
    	launch.AMR.theta_L_waist = theta_L_waist;
    	launch.AMR.phi_L_waist = phi_L_waist;
    	launch.AMR.theta_AMR_waist = theta_AMR_waist;
    	launch.AMR.phi_AMR_waist = phi_AMR_waist;
    	launch.AMR.xW = xW;
    	launch.AMR.yW = yW;
   	launch.AMR.zW = zW;
   	scan.theta_L_waist = theta_L_waist;
    	scan.phi_L_waist = phi_L_waist;
    	scan.theta_AMR_waist = theta_AMR_waist;
    	scan.phi_AMR_waist = phi_AMR_waist;
    	scan.xW = xW;
    	scan.yW = yW;
   	scan.zW = zW;
    	%
    	antennacfg.(launch.id).model = 'gaussian';
   	antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
   	antennacfg.(launch.id).toroidal_angles = phi_AMR_list;
    	antennacfg.(launch.id).poloidal_angles = theta_AMR_list;
    	antennacfg.(launch.id).angles_E_equatorial = ang_E_equ_list;
    	antennacfg.(launch.id).angle_scan = 'coupled';
    	antennacfg.(launch.id).n_tor_angles = n_phi_L;
    	antennacfg.(launch.id).n_pol_angles = n_theta_L;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	antennacfg.(launch.id).x_waist = xW;	
    	antennacfg.(launch.id).y_waist = yW;	
    	antennacfg.(launch.id).z_waist = zW;	
    	antennacfg.(launch.id).waist_radius = Wradius;
    	antennacfg.(launch.id).fix_divergence = 'no';
    	antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    else
    	disp('Use TCV model antenna.');
    	disp('Wave vector and waist position calculated using tcv_beam.m (calling launchpoint.m).');
    	antennacfg.(launch.id).model = 'tcv';
    	antennacfg.(launch.id).launcher_no = str2num(launch.id(end));
    	antennacfg.(launch.id).power = [num2str(launch.angles.P0/1000),' kW'];
    	antennacfg.(launch.id).toroidal_angles = phi_L;
    	antennacfg.(launch.id).poloidal_angles = theta_L;
    	antennacfg.(launch.id).angles_E_equatorial = 0;
    	antennacfg.(launch.id).angle_scan = 'all';
    	antennacfg.(launch.id).n_tor_angles = n_phi_L;
    	antennacfg.(launch.id).n_pol_angles = n_theta_L;
    	antennacfg.(launch.id).n_E_eq_angles = 1;
    	antennacfg.(launch.id).polarization = 'both';
    	antennacfg.(launch.id).frequencies = launch.angles.freq/1e9;
    	antennacfg.(launch.id).vacuum_window = 'no';
    	%antennacfg.(launch.id).x_waist = xW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).y_waist = yW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).z_waist = zW;	% Now calculated in tcv_beam.m
    	%antennacfg.(launch.id).waist_radius = Wradius; % Now specified in tcv_beam.m
    	%antennacfg.(launch.id).fix_divergence = 'no';	% Now specified in tcv_beam.m
   	antennacfg.(launch.id).gauss_assymetry = 0;
    	antennacfg.(launch.id).gauss_radius_enlargement = 1;
    	antennacfg.(launch.id).gauss_width = 1;
    end
    savename = [AMR_simul_path 'scan_info.mat'];
    save(savename,'scan');
    %
elseif ~strcmp(experiment,'TCV')
    disp('-----> Angle scan implemented only for TCV.')
    return
end
%
[AMRcfg] = imod_struct_jd(AMRcfg,'AMRcfg');
[antennacfg] = imod_struct_jd(antennacfg,'antennacfg');
%
AMRcfg = rminfo(AMRcfg);
antennacfg = rminfo(antennacfg);
%
antenna_ids = fieldnames(rmfield(antennacfg,'general'));
%
AMRcfg.antenna = rmfield(AMRcfg.antenna,'ids');
AMRcfg.antenna.ids = '';
%
for ifield = 1:length(antenna_ids),
    keep = input_dke_yp(['Do you want to include the antenna ',antenna_ids{ifield}],'y',{'y','n'});
    if keep == 'y',
        AMRcfg.antenna.ids = [AMRcfg.antenna.ids,' ',antenna_ids{ifield}];
    end
end
%
sections = fieldnames(AMRcfg);
fid = fopen([AMR_simul_path,AMRcfg_file],'w');
for sec=1:length(sections)
    fprintf(fid,['[',sections{sec},']\n']);
    keys = fieldnames(AMRcfg.(sections{sec}));
    for k=1:length(keys)
        fprintf_key(fid,keys{k},AMRcfg.(sections{sec}).(keys{k}));
    end
    fprintf(fid,'\n');
end
fclose(fid);

sections = fieldnames(antennacfg);
fid = fopen([AMR_simul_path,AMRcfg.antenna.cfg_file],'w');
for sec=1:length(sections)
    fprintf(fid,['[',sections{sec},']\n']);
    keys = fieldnames(antennacfg.(sections{sec}));
    for k=1:length(keys)
        fprintf_key(fid,keys{k},antennacfg.(sections{sec}).(keys{k}));
    end
    fprintf(fid,'\n');
end
fclose(fid);

end

function fprintf_key(fid,key,val)
    if isstr(val)
        keystr = [key,' = ',val,'\n'];
    elseif islogical(val)
        if val
            keystr = [key,' = yes\n'];
        else
            keystr = [key,' = no\n'];
        end
    elseif isinteger(val)
        keystr = [key,' ='];
        for i=1:length(val)
            valstr = sprintf(' %i',val(i));
            keystr = [keystr,valstr];
        end
        keystr = [keystr,'\n'];
    else
        keystr = [key,' ='];
        for i=1:length(val)
            valstr = sprintf(' %g',val(i));
            keystr = [keystr,valstr];
        end
        keystr = [keystr,'\n'];
    end
    fprintf(fid,keystr);
end

function s = rminfo(s)
    fnames = fieldnames(s);
    for iname = 1:length(fnames);
        if strcmp(fnames{iname},'info') || strcmp(fnames{iname},'expert'),
            s = rmfield(s,fnames{iname});
        elseif isstruct(s.(fnames{iname})),
            s.(fnames{iname}) = rminfo(s.(fnames{iname}));
        end
    end
end
