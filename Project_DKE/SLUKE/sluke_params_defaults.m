function [sparams,err,status] = sluke_params_defaults
%
% LUKE - Simulation parameters structure for sluke calculations with default values. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structures for modifications (one -> identical output, 2 -> merged structures is created)
%
% OUTPUT :
%
%   - sparams : structure of parameters for sluke calculations with default values
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams = {};
%
sparams.machine = {'WEST'};%Machine name
%
% -----------------------------------------
%
sparams.discharge.shot = {'55025'};%shot number
sparams.discharge.tmin = {8};%minimum time in seconds
sparams.discharge.tmax = {8.1};%maximum time in seconds
sparams.discharge.nt = {1};%number of subtimes
%
% -----------------------------------------
%
sparams.simul.id = {'LHCD'};%general simulation id
sparams.simul.comment = {'LH current drive before collapse'};% comments on the simulations (context, author)
sparams.simul.enable = {1};%simulation enabled
sparams.simul.enforce = {0};%no enforce
sparams.simul.max_simulations = {Inf};%Maximum number of distributed simulations (remote machine dependent). if Inf, no limit.
sparams.simul.log = {0};%generate log file and specific diaries. O : no log file, 1, log files enabled
sparams.simul.output = {1};%(0) or empty : LUKE output structure with all or reduced fields as defined in sparams.kinetics.dkeparam.opt_struct, (1) : processed data and synthetic diagnostics if any, (2) : processed data and synthetic diagnostics if any + LUKE output structure with all or reduced fields as defined in sparams.kinetics.dkeparam.opt_struct, (3) : save LUKE_RESULTS in SLUKE_TEMP
sparams.simul.save.waves = {0}; % (1) save waves at each fluctuation time step (0) do not save in runlukert.m
sparams.simul.save.backup = {0};% (1) save fluctuation time steps (0) do not save in runlukert.m
%
sparams.simul.remote.profile = {'CEA_ANDROMEDE'};%type dispremoteprofiles('','scheduler'); to get the values or names. Local interactive calculations -> (0). May be indexes or names
sparams.simul.remote.mode = {0};%calculation distribution mode -> (-2,-1) : remcomputing on the remote cluster dkepath.remote(-mdce_mode) (0) : sequential calculation (1)  : use of jobcomputing (2) : use of parcomputing (parfor) (3) : remcomputing on the local cluster
sparams.simul.remote.remtimout = {1};% returnmode -> (0): wait for result, (1) : return hand after starting calculation (valid only if profile > 0 (or not empty or not 'local' or mode < 0)
sparams.simul.remote.debugmode = {0};% debug mode (0) off (1) or (2) on 
sparams.simul.remote.cleanmode = {2};% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
sparams.simul.remote.matver = {'mat907'};%Matlab version used on the remote machine (if not exist, the defaut value in remote profile is used). By definition, it should be of the form matxxx, where xxx for the matlab version : type version in matlab, and 9.3 -> xxx = 903 or 9.11 -> xxx = 911
sparams.simul.remote.scheduler = {'pbs'};%type of scheduler : pbs, slurm, htcondor,...
%
sparams.simul.remote.pbs.nodes = {'cephe16'};%number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type 'pbsnodes -a' to get the list of node names
sparams.simul.remote.pbs.ppn = {''};%number of processors requested on the same node. if empty or NaN, default value requested.
sparams.simul.remote.pbs.select = {''};%Number of separate nodes. If empty or NaN, default value. Type 'pbsnodes -a' to get the list of nodesand their charatéristics
sparams.simul.remote.pbs.ncpus = {2};% number of cpus per node (must be even number). If empty or NaN, default value. 
sparams.simul.remote.pbs.memory = {15000};% job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations
sparams.simul.remote.pbs.walltime = {24};% job walltime in hours
%
sparams.simul.mute.load_structures_yp = {1};  
sparams.simul.mute.run_lukert = {1};
sparams.simul.mute.clustermode_luke = {1};
sparams.simul.mute.mdce_clustermode = {1};
sparams.simul.mute.displayrunningjob = {1};
sparams.simul.mute.remote_tsdate = {1};
sparams.simul.mute.bremsstrahlung_dke_yp = {1};
sparams.simul.mute.bremdiag_dke_yp = {1};
sparams.simul.mute.metis2luke = {1};
sparams.simul.mute.equilconsistency_yp = {1};
sparams.simul.mute.make_equil_metis2luke = {1};
sparams.simul.mute.make_sluke_build_launchs = {1};
sparams.simul.mute.lukeschedulerparam = {1};
%
sparams.simul.jprofileconsistency.code = {'METIS' };%selfconsistency between LUKE and equilibrium solver (current density profiles)
sparams.simul.jprofileconsistency.nit = {0};%selfconsistency between LUKE and equilibrium solver for the current density profile (may be METIS). Time-independent calculation
%
sparams.simul.initial_distribution = {0};%Time evolution of the distribution function : (0) -> at each time, initial distribution is a Maxwellian, (-1) -> at each time, initial distribution is the distribution from previous time (except the first that is necessarily Maxwellian)
%
% -----------------------------------------
%
sparams.kinetics.dkeparam.comment = {''};
sparams.kinetics.dkeparam.source = {'preset'};
sparams.kinetics.dkeparam.preset = {'LH_RT'};
%sparams.kinetics.dkeparam.comment = {'from metis'};
%sparams.kinetics.dkeparam.source = {'file'};
%sparams.kinetics.dkeparam.file = {'55025_8_10_pradok_wok_ddnok_xlh023_dlh052_no_oxig_fne0_run17_new_tung_peak_LUKE.mat'};
%sparams.kinetics.dkeparam.path = {'./INPUTS'};
%
%sparams.kinetics.dkeparam.nmhu_S = {101};%enforced value : number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)
%sparams.kinetics.dkeparam.np_S = {151};%enforced value : number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.
%sparams.kinetics.dkeparam.pnmax_S = {30};%enforced value : maximum value of the flux momentum grid (pth_ref)
sparams.kinetics.dkeparam.rho_S = {20};%(1) -> single real value larger than 1 : number of points for radial grid calculation (automatic and optimized for depending the type of RF waves), (2) -> single or multiple real values less than 1 : manual radial flux grid, (3) -> imaginary values : npoints + 1i*normalized_radial_position ([5+0.1*i,12+0.7*i,3+1.0i]
%
sparams.kinetics.dkedisplay.comment = {''};
sparams.kinetics.dkedisplay.source = {'preset'};
sparams.kinetics.dkedisplay.preset = {'NO_DISPLAY'};
%sparams.kinetics.dkedisplay.file = {''};%filename. Used if source is 'file'
%sparams.kinetics.dkedisplay.path = {''};%absolute path to the file. Used if source is 'file'
%
sparams.kinetics.elements.coulog_model =  {1};%Coulomb logarithm model
sparams.kinetics.elements.Zi_ref = {''};%Zi values whose desnity may be modified by the factor density_factor from C3PO/LUKE/R5X2 calculations if exist in equil structure (for tests). May be vector
sparams.kinetics.elements.Zi_density_factor = {NaN};%Ad-hoc multiplication factors of the density of the elements Zi_ref
sparams.kinetics.elements.screening.ADAS = {'ADAS.mat'};%Full path for the full ion screening model ADAS (necessary for screening of partially ionized atoms). If empty, fully ionized impurities are considered. If 'ADAS.mat', default ADAS value in LUKE
sparams.kinetics.elements.screening.partial.elastic = {'Tseng-Pratt-Botto'};%Elastic scattering by partially ionized atoms. List of models : 'DFT', 'Thomas-Fermi', 'Thomas-Fermi-Kirillov', 'Tseng-Pratt-Avdonina-Lamoureux', 'Tseng-Pratt-Botto', 'Tseng-Pratt-Thomas-Fermi'
sparams.kinetics.elements.screening.partial.inelastic = {1};%Inelastic scattering by partially ionized atoms : (0) -> no   (1) -> yes
sparams.kinetics.elements.screening.partial.dftpath = {''};%For specific DFT file path only. Leave empty otherwise and the default calculations will be considered in LUKE
%
sparams.kinetics.fast_electron_anomalous_transport.comment = {''};
sparams.kinetics.fast_electron_anomalous_transport.source = {''};
sparams.kinetics.fast_electron_anomalous_transport.preset = {''};
sparams.kinetics.fast_electron_anomalous_transport.file = {''};
sparams.kinetics.fast_electron_anomalous_transport.path = {''};
sparams.kinetics.fast_electron_anomalous_transport.Dr_type = {'EM'};%Anomalous fast electron radial diffusion type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence, EM-: 1/v|| dependence)
sparams.kinetics.fast_electron_anomalous_transport.Dr0 = {0};%Radial diffusion (m^2/s). Dr0 = Dr_center + i*Dr_edge
sparams.kinetics.fast_electron_anomalous_transport.pDr = {0};%Profile dependence (pDr = pDr0 + i*pDr1) : if pDr is real (flat or parabolic increase from center to the edge): Dr(rho) = Dr_center*(1+pDr0*rho^2). If pDr is imaginary (step size from center to the edge): Dr(rho) = (Dr_center-Dr_edge)/(1+exp((rho-pDr0)/pDr1))+Dr_edge 
sparams.kinetics.fast_electron_anomalous_transport.Vr_type = {'EM'};%Anomalous fast electron radial pinch type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence, EM-: 1/v|| dependence)
sparams.kinetics.fast_electron_anomalous_transport.Vr0 = {0};%Radial pinch (m/s). Vr0 = Vr_center + i*Vr_edge
sparams.kinetics.fast_electron_anomalous_transport.pVr = {0};%Profile dependence (pVr = pVr0 + i*pVr1) : if pVr is real (flat or parabolic increase from center to the edge): Vr(rho) = Vr_center*(1+pVr0*rho^2). If pVr is imaginary (step size from center to the edge): Vr(rho) = (Vr_center-Vr_edge)/(1+exp((rho-pVr0)/pVr1))+Vr_edge 
sparams.kinetics.fast_electron_anomalous_transport.vparmin = {3.5};%Normalized units
sparams.kinetics.fast_electron_anomalous_transport.norm_ref = {1};%Normalization of the velocity threshold: (0) v||/vT (local), (1) v||/vT_ref (central value)
%
% -----------------------------------------
%
sparams.equil.comment = {'metis calculation'};
sparams.equil.source = {'file'};
sparams.equil.code = {''};
sparams.equil.file = {'55025_8_10_pradok_wok_ddnok_xlh023_dlh052_no_oxig_fne0_run17_new_tung_peak_LUKE_correct'};
sparams.equil.path = {'./INPUTS'};
%
sparams.equil.equilconsistency.comment = {''};
sparams.equil.equilconsistency.auto_mode = {1};
sparams.equil.equilconsistency.display_mode = {0};
sparams.equil.equilconsistency.prho = {''};
sparams.equil.equilconsistency.mtheta = {''};
%
sparams.equil.fit.comment = {''};
sparams.equil.fit.mode_equil = {1};
sparams.equil.fit.method = {'spline'};
sparams.equil.fit.nharm = {NaN};%*********'' or NaN to be verified
sparams.equil.fit.ngridresample = {1001};
sparams.equil.fit.opt_load = {0};
%{
sparams.equil.ripple.comment = {''};
sparams.equil.ripple.source = {''};
sparams.equil.ripple.preset = {''};
sparams.equil.ripple.file = {''};
sparams.equil.ripple.path = {''};
sparams.equil.ripple.mode = {0};%(0): non magnetic ripple, (1) with toroidal magnetic ripple. For Tore Supra or WEST tokamaks only yet
%}
%
% -----------------------------------------
%
sparams.ohm.comment = {'metis calculation' };
sparams.ohm.source = {'file'};
sparams.ohm.code = {''};
sparams.ohm.file = {'55025_8_10_pradok_wok_ddnok_xlh023_dlh052_no_oxig_fne0_run17_new_tung_peak_LUKE_correct'};
sparams.ohm.path = {'./INPUTS'};
%
% -----------------------------------------
%
sparams.rfwaves.comment = {''};
sparams.rfwaves.source = {''};
sparams.rfwaves.file = {''};
sparams.rfwaves.path = {''};
sparams.rfwaves.enable = {''};
%
sparams.rfwaves.antenna.type = {{'LH','LH'}};%'LH' lower hybrid wave or 'EC' electron cyclotron waves, or {'LH','EC'} if both waves are launched
sparams.rfwaves.antenna.comment = {{'ne_fixed','ne_optim'}};%comments on the antenna structure calculation
sparams.rfwaves.antenna.source = {{'code','code'}};
sparams.rfwaves.antenna.code = {{'ALOHA','ALOHA'}};
sparams.rfwaves.antenna.file = {{'',''}};
sparams.rfwaves.antenna.path = {{'',''}};
sparams.rfwaves.antenna.LH.ALOHA.port = {{'Q6A','Q6B'}};%antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST
sparams.rfwaves.antenna.LH.ALOHA.remote_profile = {{'CEA_ANDROMEDE','CEA_ANDROMEDE'}};%remote profile number (list available by typing 'dispremoteprofiles' in command window) 
sparams.rfwaves.antenna.LH.ALOHA.display.data.mode = {{[-1],[-1]}};%display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist
sparams.rfwaves.antenna.LH.ALOHA.display.data.save = {{[1],[1]}};%display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist
sparams.rfwaves.antenna.LH.ALOHA.display.results = {{0,0}};%display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)
sparams.rfwaves.antenna.LH.ALOHA.optim.method = {{0,0}};%(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess
sparams.rfwaves.antenna.LH.ALOHA.optim.ne_guess = {{2.0e17,[0.7e17,5.0e17]}};%{[0.7e17,5.0e17]}};%Edge density in front of the grill (initial guess or enforced value) (m-3)
sparams.rfwaves.antenna.LH.ALOHA.optim.tolfun = {{1e-2,1e-2}};%Relative tolerance on targets (if aloha.optim.method = 1)
sparams.rfwaves.antenna.LH.ALOHA.optim.tolx = {{1e-2,1e-2}};%Relative tolerance on inputs (if aloha.optim.method = 1)
sparams.rfwaves.antenna.LH.ALOHA.optim.nitmax = {{10,10}};%Maximum number of iterations (if aloha.optim.method = 1)
%
% See proc_aloha_spec_jd.m for details on input parameters
%
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.dir = {{1,1}};%(0) P + preserve repartition and total power, (1) P/N^2 + preserve directivity and repartition, (2) P/N^2 + preserve directivity and total power (treating positive and negative spectra as blocks. Warning : some transfer of P/N^2 across N=0 necessary in this case), (3) P/N^2 + preserve repartition and total power 
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.mode = {{0,0}};%(0) select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin), (1) assemble peaks fixing Pmax and N, allowing dN to change, (2) assemble peaks allowing Pmax, N and dN to change
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.nlobes = {{10,10}};%number of lobes selected in the power spectrum
%sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.ny = {{0,0}};
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.Pin_in = {{NaN,NaN}}; %corrected initial total power. If NaN take value ALOHA else the value is enforced by Pin_in (W). Consider globalspectrum to get the total LH power. 
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.opt_optim = {{0,0}};%use of function lsqnonlin for gaussian lobe fit (default : 0)
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = {{0,0}};%upper and lower half-antenna modules are considered independently (0) or only half upper module for the whole antenna (1). If sparams.rfwaves.antenna.LH.ALOHA.optim.method == 0, sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = 1 is enforced.
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent = {{1,1}};%the Lower Hybrid wave drive co-current (1) or counter-current (-1)
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.inter = {{0,0}};%interactive mode for selecting parameters
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.mode = {{0,0}};%display (0) none (1) text only (2) text and figures (default : 0)
sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.comparison = {{1,1}};%display comparison between experimental value and calculations (1) yes (0) no
%
sparams.rfwaves.antenna.LH.C3PO.launch.omega_rf = {{2.3248e+10,2.3248e+10}};
sparams.rfwaves.antenna.LH.C3PO.launch.bNpar0 = {{[-1.9149,6.0000],[-1.9149,6.0000]}};
sparams.rfwaves.antenna.LH.C3PO.launch.bdNpar0 = {{[0.2,0.2],[0.2,0.2]}};
sparams.rfwaves.antenna.LH.C3PO.launch.bPlhtot = {{[1950400,835900],[1950400,835900]}};
sparams.rfwaves.antenna.LH.C3PO.launch.mainlobeshift = {{0,0}};% artificial shift of the main lobe of the LH power spectrum : 0 nothing done, < 1 : reduction of the absolute value, > 1 increase of the absolute value
sparams.rfwaves.antenna.LH.C3PO.launch.rZ0 =  {{0,0}};%0+1i to be verified
sparams.rfwaves.antenna.LH.C3PO.launch.m0 = {{0,0}};
sparams.rfwaves.antenna.LH.C3PO.launch.phi0 = {{0,0}};
sparams.rfwaves.antenna.LH.C3PO.launch.i_ref = {{-1,-1}};%100 ou -1 to be verified
sparams.rfwaves.antenna.LH.C3PO.launch.LFS = {{1,1}};
sparams.rfwaves.antenna.LH.C3PO.launch.mmode = {{-1,-1}};
sparams.rfwaves.antenna.LH.C3PO.launch.nparp = {{0,0}};
sparams.rfwaves.antenna.LH.C3PO.launch.a_sdNpar = {{0,0}};
sparams.rfwaves.antenna.LH.C3PO.launch.w0 = {{NaN,NaN}};
sparams.rfwaves.antenna.LH.C3PO.launch.z_L = {{NaN,NaN}};
%{
sparams.rfwaves.antenna.LH.C3PO.launch.ns = {{1000,1000}};
sparams.rfwaves.antenna.LH.C3PO.launch.n0 = {{NaN,NaN}};
sparams.rfwaves.antenna.LH.C3PO.launch.kz0 = {{NaN,NaN}};
sparams.rfwaves.antenna.LH.C3PO.launch.method = {{'pchip','pchip'}};%cubic obsolete
sparams.rfwaves.antenna.LH.C3PO.launch.method1 = {{'pchip','pchip'}};
sparams.rfwaves.antenna.LH.C3PO.launch.method2 = {{'spline','spline'}};
%}
sparams.rfwaves.antenna.LH.C3PO.launch.tail.dtn = {{Inf,Inf}};
sparams.rfwaves.antenna.LH.C3PO.launch.tail.mode = {{3,3}};
sparams.rfwaves.antenna.LH.C3PO.launch.tail.bNparmax_tail = {{0,0}};
sparams.rfwaves.antenna.LH.C3PO.launch.tail.bn_tail = {{0,0}};
sparams.rfwaves.antenna.LH.C3PO.launch.tail.bP_tail = {{0.5,0.5}};
sparams.rfwaves.antenna.LH.C3PO.launch.tail.bopt_tail = {{0.0000 + 1.0000i,0.0000 + 1.0000i}};
%
sparams.rfwaves.solver.type = {{'ray-tracing','ray-tracing'}};
sparams.rfwaves.solver.code = {{'C3PO','C3PO'}};
sparams.rfwaves.solver.enable = {{1,1}};
sparams.rfwaves.solver.remote_profile = {{1,1}};
%
%sparams.rfwaves.solver.C3PO.rayparam.comment = {{'',''}};
%sparams.rfwaves.solver.C3PO.rayparam.source = {{'',''}};
%sparams.rfwaves.solver.C3PO.rayparam.file = {{'',''}};
%sparams.rfwaves.solver.C3PO.rayparam.path = {{'',''}};
sparams.rfwaves.solver.C3PO.rayparam.testmode = {{0,0}};
sparams.rfwaves.solver.C3PO.rayparam.tensortype = {{0,0}};
sparams.rfwaves.solver.C3PO.rayparam.t0 = {{0,0}};
sparams.rfwaves.solver.C3PO.rayparam.tfinal = {{50000,50000}};
sparams.rfwaves.solver.C3PO.rayparam.dt0 = {{1e-4,1e-4}};
sparams.rfwaves.solver.C3PO.rayparam.dS = {{1e-3,1e-3}};
sparams.rfwaves.solver.C3PO.rayparam.tol = {{1e-12,1e-12}};
sparams.rfwaves.solver.C3PO.rayparam.kmax = {{50000,50000}};
sparams.rfwaves.solver.C3PO.rayparam.ncyclharm = {{3,3}};
sparams.rfwaves.solver.C3PO.rayparam.reflection = {{1,1}};
sparams.rfwaves.solver.C3PO.rayparam.rel_opt = {{1,1}};
sparams.rfwaves.solver.C3PO.rayparam.nperp = {{1000,1000}};
sparams.rfwaves.solver.C3PO.rayparam.pperpmax = {{10,10}};
sparams.rfwaves.solver.C3PO.rayparam.tau_lim = {{20,20}};
sparams.rfwaves.solver.C3PO.rayparam.kextra = {{2000,2000}};
%sparams.rfwaves.solver.C3PO.rayparam.metricmode = {{1,1}};
%sparams.rfwaves.solver.C3PO.rayparam.rhoswitch = {{0.1,0.1}};
%sparams.rfwaves.solver.C3PO.rayparam.substitution_method = {{7,7}};
%
%sparams.rfwaves.solver.C3PO.raydisplay.comment = {{'',''}};
%sparams.rfwaves.solver.C3PO.raydisplay.source = {{'',''}};
%sparams.rfwaves.solver.C3PO.raydisplay.file = {{'',''}};
%sparams.rfwaves.solver.C3PO.raydisplay.path = {{'',''}};
sparams.rfwaves.solver.C3PO.raydisplay.ray = {{0,0}};
sparams.rfwaves.solver.C3PO.raydisplay.equilibrium = {{0,0}};
%sparams.rfwaves.solver.C3PO.raydisplay.fluctuations = {{0,0}};
sparams.rfwaves.solver.C3PO.raydisplay.p_opt = {{-1,-1}};
%sparams.rfwaves.solver.C3PO.raydisplay.mdce = {{0,0}};
%
sparams.rfwaves.solver.C3PO.waveparam.mmode = {{-1,-1}};
sparams.rfwaves.solver.C3PO.waveparam.kmode = {{0,0}};
sparams.rfwaves.solver.C3PO.waveparam.opt_rf = {{1,1}};
sparams.rfwaves.solver.C3PO.waveparam.dsmin = {{Inf,Inf}};
%sparams.rfwaves.solver.C3PO.waveparam.nd = {{0,0}};
%sparams.rfwaves.solver.C3PO.waveparam.nchi = {{0,0}};
sparams.rfwaves.solver.C3PO.waveparam.n_rf_list = {{0,0}};
%sparams.rfwaves.solver.C3PO.waveparam.ns = {{0,0}};
%sparams.rfwaves.solver.C3PO.waveparam.rhomin = {{0,0}};
sparams.rfwaves.solver.C3PO.waveparam.a_sdNpar = {{0,0}};
sparams.rfwaves.solver.C3PO.waveparam.cut_fac = {{2,2}};
%
%sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.mode = {{0,0}};
%sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.timeout = {{1000,1000}};
%sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.size = {{12,12}};
%sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.mem = {{500,500}};
sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.mode = {{0,0}};
sparams.rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.memory = {{500,500}};
%
% -----------------------------------------
%
sparams.postprocessing.comment = {''};
sparams.postprocessing.source = {''};
sparams.postprocessing.ir_display = {-1};%no interactive post-processing display
sparams.postprocessing.p_opt = {-1};%no interactive post-processing display
sparams.postprocessing.dp_cyl = {0.1};%no interactive post-processing display
sparams.postprocessing.pnmax = {NaN};%no interactive post-processing display
sparams.postprocessing.peak = {'y'};%no interactive post-processing display
sparams.postprocessing.wave = {'y'};%no interactive post-processing display
sparams.postprocessing.peakmode = {1};%no interactive post-processing display
sparams.postprocessing.rho = {'t'};%no interactive post-processing display
sparams.postprocessing.spec = {0};%no interactive post-processing display
sparams.postprocessing.its_rf = {true};%no interactive post-processing display
sparams.postprocessing.blist = {''};%no interactive post-processing display
sparams.postprocessing.diaryname = {''};%no interactive post-processing display       
%
% -----------------------------------------
%
sparams.diags.DSPX.code = {'R5X2'};%name of the FEB code
sparams.diags.DSPX.remote_calculations = {1};%Synthetic diagnostic calculations done remotely (1) or locally( 0)
sparams.diags.DSPX.enable = {1};%Synthetic diagnostic calculations is enabled (1) or disabled (0) 
%
sparams.diags.DSPX.hxrspec.comment = {''};
sparams.diags.DSPX.hxrspec.source = {''};%source of the data (code, file, value). If empty, obtained from database or script if available.
sparams.diags.DSPX.hxrspec.file = {''};%source of the data (code, file, value)
sparams.diags.DSPX.hxrspec.path = {''};
sparams.diags.DSPX.hxrspec.chordstatus_hxr = {ones(1,38)};% (1) -> active chords, (0) -> inactive chords 
%
sparams.diags.DSPX.R5X2.hxrparam.comment = {''};
sparams.diags.DSPX.R5X2.hxrparam.source = {'value'};%source of the data (code, file, value). If empty, defaults values
sparams.diags.DSPX.R5X2.hxrparam.mfactor = {1};%For the magnetic equilibrium
sparams.diags.DSPX.R5X2.hxrparam.method = {'spline'};%For the magnetic equilibrium in the HXR calculations
sparams.diags.DSPX.R5X2.hxrparam.ns = {3000};%for chord integration
sparams.diags.DSPX.R5X2.hxrparam.n_gauleg = {35};%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
sparams.diags.DSPX.R5X2.hxrparam.epsi_gauleg = {1e-14};%Accuracy of the Legendre projection
sparams.diags.DSPX.R5X2.hxrparam.kmin = {50};%for Tphot calculations
sparams.diags.DSPX.R5X2.hxrparam.kmax = {110};%for Tphot calculations
sparams.diags.DSPX.R5X2.hxrparam.kphot = {[20:10:240]};%Photon energy in keV (important for bremsstrahlung with partial screening effects)
sparams.diags.DSPX.R5X2.hxrparam.full_results = {0};%Save all simulations results (1) or just those that can be compared directly to experimental measurements (0).
%
sparams.diags.DSPX.R5X2.hxrparam.screening.partial.screening_model = {'Tseng-Pratt-Botto'};%screening model for bremsstrahlung
sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nphi = {NaN};%for numerical integration 1BS -> 2BN. If nphi = NaN, formula deduced from analytical integration in phi is used (4-D). Otherwise (5-D)
sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.flag_mem = {1};%Memory management enforcement : 0 -> 5-D block numerical calculations, 1 -> 4-D block numerical calculations
sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.ntheta = {2006};%for numerical integration 1BS -> 2BN
sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.integral = {'simps'};%Numerical integration : trapz (trapeze) or simps (Simpson)
sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.nEc = {300};%keV (number of incoming electron kinetic energies for calculating the BHE cross-section table with partial screening)
sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.Ecmax = {1000};%keV (max incoming electron kinetic energy for calculating the BHE cross-section table with partial screening)
%
sparams.diags.MEHXR = sparams.diags.DSPX;%MEHXR is using R5X2 for signal calculations.
sparams.diags.MEHXR.enable = {0};%Synthetic diagnostic calculations is enabled (1) or disabled (0) 
sparams.diags.MEHXR.hxrspec.chordstatus_hxr = {ones(1,60),};% (1) -> active chords, (0) -> inactive chords 
sparams.diags.MEHXR.R5X2.hxrparam.comment = {''};
sparams.diags.MEHXR.R5X2.hxrparam.kphot = {linspace(10,200,59)};%Photon energy in keV (important for bremsstrahlung with partial screening effects)
%
% -----------------------------------------
%
[err,status] = sluke_params_consistency(sparams);
%