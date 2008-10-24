function [AMRcfg,antennacfg] = default_cfg_AMR()
%
% Creates a structure containing all cfg entries with their default values
%

AMRcfg.input.device = 'tokamak';
AMRcfg.input.experiment = '';
AMRcfg.input.shot_number = 0;
AMRcfg.input.start_time = 0;
AMRcfg.input.end_time = 0;
AMRcfg.input.ts_times = false;
AMRcfg.input.time_samples = 0;
AMRcfg.input.run_IDL = false;

AMRcfg.output.central_ray_only = true;
AMRcfg.output.ray_details = true;
AMRcfg.output.power_deposition = true;
AMRcfg.output.current_density = 'none';
AMRcfg.output.conv_eff = true;
AMRcfg.output.temperature = true;
AMRcfg.output.test_profiles = true;
AMRcfg.output.run_code = true;
AMRcfg.output.postprocess = true;
AMRcfg.output.sum_antennas = false;
AMRcfg.output.luke = true;

AMRcfg.cluster.use_cluster = false;
AMRcfg.cluster.job = 'optimum';
AMRcfg.cluster.que = 'sque';
AMRcfg.cluster.ncpu = 5;
AMRcfg.cluster.check_int = 1;
AMRcfg.cluster.priority = 0;
AMRcfg.cluster.master_priority = 0;

AMRcfg.adaptive.coll_freq = 0.0005;
AMRcfg.adaptive.n_init = 350;
AMRcfg.adaptive.accuracy = 0.001;
AMRcfg.adaptive.extension_xend_search = 1.0;

AMRcfg.ray_tracing.Zeff = 1.0;
AMRcfg.ray_tracing.Nperp = 1;
AMRcfg.ray_tracing.accuracy = 1.e-5;
AMRcfg.ray_tracing.power_limit = 1.e-8;

AMRcfg.test_profiles.R_min = 0.0;
AMRcfg.test_profiles.R_max = 0.0;
AMRcfg.test_profiles.Z_min = 0.0;
AMRcfg.test_profiles.Z_max = 0.0;
AMRcfg.test_profiles.phi_test = 0.0;
AMRcfg.test_profiles.phi_min = 0.0;
AMRcfg.test_profiles.phi_max = 360.0;
AMRcfg.test_profiles.R_dim = 0;
AMRcfg.test_profiles.Z_dim = 0;
AMRcfg.test_profiles.phi_dim = 1;
AMRcfg.test_profiles.wkb_curve_ray = 1;
AMRcfg.test_profiles.shot_time_test = 0;
AMRcfg.test_profiles.Nparal_above = 1.0;
AMRcfg.test_profiles.Nparal_below = 1.0;

AMRcfg.profiles.equil_ver = 'efit';
AMRcfg.profiles.input_type = 'default';
AMRcfg.profiles.export = 'matlab';
AMRcfg.profiles.export_nR = 100;
AMRcfg.profiles.export_nZ = 100;
AMRcfg.profiles.export_npsi = 100;
% -- stellarators (mclib) only --
AMRcfg.profiles.B_axis = 0.0;
AMRcfg.profiles.phi0 = 0.0;
AMRcfg.profiles.s_max = 1.0;
AMRcfg.profiles.s_LCFS = 1.0;
AMRcfg.profiles.epsTrunc = 1.0e-8;
AMRcfg.profiles.epsA = 1.0e-6;
AMRcfg.profiles.compute_mesh = false;
% -- end stellarators --
AMRcfg.profiles.ts_data = 'ruby';
AMRcfg.profiles.n_components = 1;
AMRcfg.profiles.ims = 4;
AMRcfg.profiles.monotonize = false;
AMRcfg.profiles.monotonize_freq = 0.0;
AMRcfg.profiles.errorToleranceDen = 1.0;
AMRcfg.profiles.errorToleranceTe = 1.0;
AMRcfg.profiles.averageProfilesDen = 'none';
AMRcfg.profiles.averageProfilesTe = 'none';
AMRcfg.profiles.averageDistanceDen = 0.0;
AMRcfg.profiles.averageDistanceTe = 0.0;
AMRcfg.profiles.extendProfilesDen = 'exp';
AMRcfg.profiles.extendProfilesTe = 'exp';
AMRcfg.profiles.extendDistanceDen = 0.0;
AMRcfg.profiles.extendDistanceTe = 0.0;
AMRcfg.profiles.extDataPoints = 5;
AMRcfg.profiles.LSOL_den = 0.1;
AMRcfg.profiles.LSOL_Te = 0.1;
AMRcfg.profiles.LSOL = 0.0;
AMRcfg.profiles.ne_jump_LCFS = false;
AMRcfg.profiles.analytical_profiles = false;

AMRcfg.analytical_profiles.type = 'compass';
AMRcfg.analytical_profiles.phi = 0.0;
AMRcfg.analytical_profiles.nGrid = 100;
AMRcfg.analytical_profiles.den_parameters = '[[5.0,0.002,2,4]]';
AMRcfg.analytical_profiles.Te_parameters =  '[[1.0,0.02,2,4]]';

AMRcfg.antenna.cfg_file = 'antenna.cfg';
AMRcfg.antenna.ids = 'antenna_0';

AMRcfg.integration.type = 'power';
AMRcfg.integration.R_min = 0.0;
AMRcfg.integration.R_max = 0.0;
AMRcfg.integration.r_eff_min = 0;
AMRcfg.integration.r_eff_max = 0.0;
AMRcfg.integration.tabdim = 20;

% antenna cgf
antennacfg.general.noOfCircles = 4;
antennacfg.general.raysPerCircle = 6;
antennacfg.general.turnCircles = false;
antennacfg.general.n_window_points = 30;

antennacfg.antenna_0.model = 'gaussian';
antennacfg.antenna_0.power = 1.0;
antennacfg.antenna_0.toroidal_angles = [0.0];
antennacfg.antenna_0.poloidal_angles = [0.0];
antennacfg.antenna_0.angles_E_equatorial = [0.0];
antennacfg.antenna_0.angle_scan = 'none';
antennacfg.antenna_0.n_tor_angles = 13;
antennacfg.antenna_0.n_pol_angles = 8;
antennacfg.antenna_0.n_E_eq_angles = 1;
antennacfg.antenna_0.polarization = 'linear';
antennacfg.antenna_0.frequencies = [33.0];
antennacfg.antenna_0.IRealTest = 0;
antennacfg.antenna_0.vacuum_window = false;

antennacfg.antenna_0.x_waist = 0.83;
antennacfg.antenna_0.y_waist = 0;
antennacfg.antenna_0.z_waist = 0;
antennacfg.antenna_0.waist_radius = 0.025;
antennacfg.antenna_0.fix_divergence = false;
antennacfg.antenna_0.fixed_divergence = 0;
antennacfg.antenna_0.gauss_assymetry = 0;
antennacfg.antenna_0.gauss_radius_enlargement = 1;
antennacfg.antenna_0.gauss_width = 1;

