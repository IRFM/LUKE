function [tooltip] = slukeGUITooltip(address,field)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%



if ~isempty(address)
    if length(address) >= 2 && strcmp(address{1},'diags')
        address(2) = [];
    elseif length(address) >= 4 && strcmp(address{3},'scheduler')
        address(4) = [];
    elseif length(address) >= 4 && strcmp(address{3},'LH')
        address(3) = [];
    elseif length(address) >= 4 && strcmp(address{3},'EC')
        address(3) = [];
    end
    
    key = address{1};
    for i = 2:length(address)
        key = [key '.' address{i}];
    end
    key = [key '.' field];
else
    key = field;
end

switch key
    case 'machine'
        tooltip = "Name of tokamak. WARNING: It is used to access to database if needed. If wrong could lead to not operate part of the code.  (WEST --> WEST, TORE SUPRA --> TS, ...)";
    
    case 'discharge'
        tooltip = 'TO DO';
    
    case 'discharge.shot'
        tooltip = "Discharge number or index";
    
    case 'discharge.tmin'
        tooltip = "Minimum of the considered time interval (s)";
    
    case 'discharge.tmax'
        tooltip = "Maximum of the considered time interval (s)";
    
    case 'discharge.nt'
        tooltip = "Number of sub-intervals between tmin and tmax (n>=1). If none, n = 1 is considered in the calculations. Use sluke_params_time to expand the params structure before calculations";
    
    case 'simul'
        tooltip = "TO DO";
    
    case 'simul.id'
        tooltip = "Simulation identifier";
    
    case 'simul.comment'
        tooltip = "Comments on the simulation";
    
    case 'simul.enable'
        tooltip = "Enable (1) or not (0) the simulations";
    
    case 'simul.enforce'
        tooltip = "(2) -> TO DO, (1) -> enforce new simulation (erase all corresponding files), (0) -> simulation is not enforced,  (-1) -> simulation is not enforced and not cancelled";
    
    case 'simul.max_simulations'
        tooltip = "Maximum number of simulation launched in parallel";
    
    case 'simul.log'
        tooltip = "Enable (1) or not (0) log file generation";
    
    case 'simul.output'
        tooltip = "0 or empty : LUKE output structure with all or reduced fields as defined in sparams.kinetics.dkeparam.opt_struct, (1) : processed data and synthetic diagnostics if any, (2) : processed data and synthetic diagnostics if any + LUKE output structure with all or reduced fields as defined in sparams.kinetics.dkeparam.opt_struct, (3) : save LUKE_RESULTS in SLUKE_TEMP ";
    
    case 'simul.save'
        tooltip = "TO DO";
    
    case 'simul.save.waves'
        tooltip = "TO DO";
    
    case 'simul.save.backup'
        tooltip = "TO DO";
    
    case 'simul.remote'
        tooltip = "TO DO";
    
    case 'simul.remote.profile'
        tooltip = "TO DO";
    
    case 'simul.remote.mode'
        tooltip = "TO DO";
    
    case 'simul.remote.remtimout'
        tooltip = "TO DO";
    
    case 'simul.remote.debugmode'
        tooltip = "";
    
    case 'simul.remote.cleanmode'
        tooltip = "";
    
    case 'simul.remote.matver'
        tooltip = "";
    
    case 'simul.remote.git'
        tooltip = "";
    
    case 'simul.remote.git.projects'
        tooltip = "Git list of projects that may be updated remotely from repository (git pull) prior a simulation.";
    
    case 'simul.remote.git.pull'
        tooltip = "Git pull remote projects (1), no git pull (0).";
    
    case 'simul.remote.git.display'
        tooltip = "";
    
    case 'simul.remote.scheduler.nodes'
        tooltip = "number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type 'pbsnodes -a' to get the list of node names";
    
    case 'simul.remote.scheduler.ppn'
        tooltip = "number of processors requested on the same node. if empty or NaN, default value requested.";
    
    case 'simul.remote.scheduler.select'
        tooltip = "number of separate nodes. If empty or NaN, default value. Type 'pbsnodes -a' to get the list of nodesand their charateristics";
    
    case 'sparams.simul.remote.scheduler.ncpus'
        tooltip = "number of cpus per node (must be even number). If empty or NaN, default value.";
    
    case 'sparams.simul.remote.scheduler.memory'
        tooltip = "job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations";
    
    case 'sparams.simul.remote.scheduler.walltime'
        tooltip = "job walltime in hours";
    
    case 'sparams.simul.remote.scheduler.ncores'
        tooltip = "number of cores. If empty or NaN, default value";
    
    case 'simul.remote.scheduler'
        tooltip = "selected scheduler. E.g. pbs, torque";
    
    case 'simul.remote.pbs'
        tooltip = "pbs scheduler properties";
    
    case 'simul.remote.pbs.nodes'
        tooltip = "number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type 'pbsnodes -a' to get the list of node names";
    
    case 'simul.remote.pbs.ppn'
        tooltip = "number of processors requested on the same node. if empty or NaN, default value requested.";
    
    case 'simul.remote.pbs.select'
        tooltip = "number of separate nodes. If empty or NaN, default value. Type 'pbsnodes -a' to get the list of nodesand their charateristics";
    
    case 'simul.remote.pbs.ncpus'
        tooltip = "number of cpus per node (must be even number). If empty or NaN, default value.";
    
    case 'simul.remote.pbs.memory'
        tooltip = "job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations";
    
    case 'simul.remote.pbs.walltime'
        tooltip = "job walltime in hours";
    
    case 'simul.mute.load_structures_yp'
        tooltip = "(0) enable or (1) disable display of the function load_structure_yp if any";
    
    case 'simul.mute.run_lukert'
        tooltip = "(0) enable or (1) disable display of the function run_lukert if any";
    
    case 'simul.mute.clustermode_luke'
        tooltip = "(0) enable or (1) disable display of the function clustermode_luke if any";
    
    case 'simul.mute.mdce_clustermode'
        tooltip = "(0) enable or (1) disable display of the function mdce_clustermode if any";
    
    case 'simul.mute.displayrunningjob'
        tooltip = "(0) enable or (1) disable display of the function displayrunningjob if any";
    
    case 'simul.mute.remote_tsdate'
        tooltip = "(0) enable or (1) disable display of the function remote_tsdate if any";
    
    case 'simul.mute.bremsstrahlung_dke_yp'
        tooltip = "(0) enable or (1) disable display of the function bremsstrahlung_dke_yp if any";
    
    case 'simul.mute.bremdiag_dke_yp'
        tooltip = "(0) enable or (1) disable display of the function bremdiag_dke_yp if any";
    
    case 'simul.mute.metis2luke'
        tooltip = "(0) enable or (1) disable display of the function metis2luke if any";
    
    case 'simul.mute.equilconsistency_yp'
        tooltip = "(0) enable or (1) disable display of the function equilconsistency_yp if any";
    
    case 'simul.mute.make_equil_metis2luke'
        tooltip = "(0) enable or (1) disable display of the function make_equil_metis2luke if any";
    
    case 'simul.mute.make_sluke_build_launchs'
        tooltip = "(0) enable or (1) disable display of the function make_sluke_build_launchs if any";
    
    case 'simul.mute.lukeschedulerparam'
        tooltip = "(0) enable or (1) disable display of the function lukeschedulerparam if any";
    
    case 'simul.jprofileconsistency.code'
        tooltip = "";
    
    case 'simul.jprofileconsistency.nit'
        tooltip = "";
    
    case 'simul.initial_distribution'
        tooltip = "";
    
    case 'kinetics.dkeparam'
        tooltip = "";
    
    case 'kinetics.dkeparam.comment'
        tooltip = "";
    
    case 'kinetics.dkeparam.source'
        tooltip = "";
    
    case 'kinetics.dkeparam.preset'
        tooltip = "";
    
    case 'kinetics.dkeparam.rho_S'
        tooltip = "";
    
    case 'kinetics.dkedisplay.comment'
        tooltip = "";
    
    case 'kinetics.dkedisplay.source'
        tooltip = "";
    
    case 'kinetics.dkedisplay.preset'
        tooltip = "";
    
    case 'kinetics.elements'
        tooltip = "";
    
    case 'kinetics.elements.coulog_model'
        tooltip = "Coulomb logarithm model";
    
    case 'kinetics.elements.Zi_ref'
        tooltip = "Zi values whose desnity may be modified by the factor density_factor from C3PO/LUKE/R5X2 calculations if exist in equil structure (for tests). May be vector";
    
    case 'kinetics.elements.Zi_density_factor'
        tooltip = "Ad-hoc multiplication factors of the density of the elements Zi_ref";
    
    case 'kinetics.elements.screening'
        tooltip = "";
    
    case 'kinetics.elements.screening.ADAS'
        tooltip = "Full path for the full ion screening model ADAS (necessary for screening of partially ionized atoms). If empty, fully ionized impurities are considered. If 'ADAS.mat', default ADAS value in LUKE";
    
    case 'kinetics.elements.screening.partial'
        tooltip = "";
    
    case 'kinetics.elements.screening.partial.elastic'
        tooltip = "Elastic scattering by partially ionized atoms. List of models : 'DFT', 'Thomas-Fermi', 'Thomas-Fermi-Kirillov', 'Tseng-Pratt-Avdonina-Lamoureux', 'Tseng-Pratt-Botto', 'Tseng-Pratt-Thomas-Fermi'";
    
    case 'kinetics.elements.screening.partial.inelastic'
        tooltip = "Inelastic scattering by partially ionized atoms : (0) -> no   (1) -> yes";
    
    case 'kinetics.elements.screening.partial.dftpath'
        tooltip = "For specific DFT file path only. Leave empty otherwise and the default calculations will be considered in LUKE";
    
    case 'kinetics.fast_electron_anomalous_transport'
        tooltip = "kinetics.fast_electron_anomalous_transport.comment";
    
    case 'kinetics.fast_electron_anomalous_transport.source'
        tooltip = "";
    
    case 'kinetics.fast_electron_anomalous_transport.preset'
        tooltip = "";
    
    case 'kinetics.fast_electron_anomalous_transport.file'
        tooltip = "";
    
    case 'kinetics.fast_electron_anomalous_transport.path'
        tooltip = "";
    
    case 'kinetics.fast_electron_anomalous_transport.Dr_type'
        tooltip = "Anomalous fast electron radial diffusion type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence, EM-: 1/v|| dependence)";
    
    case 'kinetics.fast_electron_anomalous_transport.Dr0'
        tooltip = "Radial diffusion (m^2/s). Dr0 = Dr_center + i*Dr_edge";
    
    case 'kinetics.fast_electron_anomalous_transport.pDr'
        tooltip = "Profile dependence (pDr = pDr0 + i*pDr1) : if pDr is real (flat or parabolic increase from center to the edge): Dr(rho) = Dr_center*(1+pDr0*rho^2). If pDr is imaginary (step size from center to the edge): Dr(rho) = (Dr_center-Dr_edge)/(1+exp((rho-pDr0)/pDr1))+Dr_edge";
    
    case 'kinetics.fast_electron_anomalous_transport.Vr_type'
        tooltip = "Anomalous fast electron radial pinch type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence, EM-: 1/v|| dependence)";
    
    case 'kinetics.fast_electron_anomalous_transport.Vr0'
        tooltip = "Radial pinch (m/s). Vr0 = Vr_center + i*Vr_edge";
    
    case 'kinetics.fast_electron_anomalous_transport.pVr'
        tooltip = "Profile dependence (pVr = pVr0 + i*pVr1) : if pVr is real (flat or parabolic increase from center to the edge): Vr(rho) = Vr_center*(1+pVr0*rho^2). If pVr is imaginary (step size from center to the edge): Vr(rho) = (Vr_center-Vr_edge)/(1+exp((rho-pVr0)/pVr1))+Vr_edge ";
    
    case 'kinetics.fast_electron_anomalous_transport.vparmin'
        tooltip = "Normalized unit";
    
    case 'kinetics.fast_electron_anomalous_transport.norm_ref'
        tooltip = "Normalization of the velocity threshold: (0) v||/vT (local), (1) v||/vT_ref (central value)";
    
    case 'equil'
        tooltip = "";
    
    case 'equil.comment'
        tooltip = "";
    
    case 'equil.source'
        tooltip = "";
    
    case 'equil.code'
        tooltip = "";
    
    case 'equil.file'
        tooltip = "";
    
    case 'equil.path'
        tooltip = "";
    
    case 'equil.equilconsistency'
        tooltip = "";
    
    case 'equil.equilconsistency.comment'
        tooltip = "";
    
    case 'equil.equilconsistency.auto_mode'
        tooltip = "";
    
    case 'equil.equilconsistency.display_mode'
        tooltip = "";
    
    case 'equil.equilconsistency.prho'
        tooltip = "";
    
    case 'equil.equilconsistency.mtheta'
        tooltip = "";
    
    case 'equil.fit'
        tooltip = "";
    
    case 'equil.fit.comment'
        tooltip = "";
    
    case 'equil.fit.mode_equil'
        tooltip = "";
    
    case 'equil.fit.method'
        tooltip = "";
    
    case 'equil.fit.nharm'
        tooltip = "";
    
    case 'equil.fit.ngridresample'
        tooltip = "";
    
    case 'equil.fit.opt_load'
        tooltip = "";
    
    case 'ohm.comment'
        tooltip = "";
    
    case 'ohm.source'
        tooltip = "";
    
    case 'ohm.code'
        tooltip = "";
    
    case 'ohm.file'
        tooltip = "";
    
    case 'ohm.path'
        tooltip = "";
    
    case 'rfwaves'
        tooltip = "";
    
    case 'rfwaves.type'
        tooltip = "'LH' lower hybrid wave or 'EC' electron cyclotron waves, or {'LH','EC'} if both waves are launched";
    
    case 'rfwaves.comment'
        tooltip = "comments on the antenna structure calculation";
    
    case 'rfwaves.source'
        tooltip = "";
    
    case 'rfwaves.file'
        tooltip = "";
    
    case 'rfwaves.path'
        tooltip = "";
    
    case 'rfwaves.enable'
        tooltip = "";
    
    case 'rfwaves.antenna.code'
        tooltip = "";
    
    case 'rfwaves.antenna.file'
        tooltip = "";
    
    case 'rfwaves.antenna.path'
        tooltip = "";
    
    case 'rfwaves.antenna.LH'
        tooltip = "";
    
    case 'rfwaves.antenna.ALOHA'
        tooltip = "";
    
    case 'rfwaves.antenna.ALOHA.port'
        tooltip = "antenna ports : Q6A, or Q6B or Q6A+Q6B -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST";
    
    case 'rfwaves.antenna.ALOHA.remote_profile'
        tooltip = "";
    
    case 'rfwaves.antenna.ALOHA.display'
        tooltip = "";
        
    case 'rfwaves.antenna.ALOHA.display.data'
        tooltip = "";
        
    case 'rfwaves.antenna.ALOHA.display.data.mode'
        tooltip = "display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist";
    
    case 'rfwaves.antenna.ALOHA.display.data.save'
        tooltip = "display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist";
    
    case 'rfwaves.antenna.ALOHA.display.results'
        tooltip = "display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)";
    
    case 'rfwaves.antenna.ALOHA.optim'
        tooltip = "";      
        
    case 'rfwaves.antenna.ALOHA.optim.method'
        tooltip = "(1) edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess";
    
    case 'rfwaves.antenna.ALOHA.optim.ne_guess'
        tooltip = "edge density in front of the grill (initial guess or enforced value) (m-3)";
    
    case 'rfwaves.antenna.ALOHA.optim.tolfun'
        tooltip = "Relative tolerance on targets (if aloha.optim.method = 1)";
    
    case 'rfwaves.antenna.ALOHA.optim.tolx'
        tooltip = "Relative tolerance on inputs (if aloha.optim.method = 1)";
    
    case 'rfwaves.antenna.ALOHA.optim.nitmax'
        tooltip = "Maximum number of iterations (if aloha.optim.method = 1)";
    
    case 'rfwaves.antenna.C3PO.ALOHA'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.param_tor'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.param_tor.dir'
        tooltip = "(0) P + preserve repartition and total power, (1) P/N^2 + preserve directivity and repartition, (2) P/N^2 + preserve directivity and total power (treating positive and negative spectra as blocks. Warning : some transfer of P/N^2 across N=0 necessary in this case), (3) P/N^2 + preserve repartition and total power ";
    
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.mode'
        tooltip = "(0) select a number of Gaussian peaks left unchanged (WARNING : total power less than Pin), (1) assemble peaks fixing Pmax and N, allowing dN to change, (2) assemble peaks allowing Pmax, N and dN to change";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.param_tor.nlobes'
        tooltip = "number of lobes selected in the power spectrum";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.param_pol'
        tooltip = "";
        
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.param_pol.Pin_in'
        tooltip = "corrected initial total power. If NaN take value ALOHA else the value is enforced by Pin_in (W). Consider globalspectrum to get the total LH power. ";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.opt_optim'
        tooltip = "use of function lsqnonlin for gaussian lobe fit (default : 0)";    
        
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.globalspectrum'
        tooltip = "upper and lower half-antenna modules are considered independently (0) or only half upper module for the whole antenna (1). If sparams.rfwaves.antenna.LH.ALOHA.optim.method == 0, sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum = 1 is enforced.";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.cocurrent'
        tooltip = "the Lower Hybrid wave drive co-current (1) or counter-current (-1)";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.sdisplay.inter'
        tooltip = "nteractive mode for selecting parameters";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.sdisplay.mode'
        tooltip = "display (0) none (1) text only (2) text and figures (default : 0)";
    
    case 'rfwaves.antenna.C3PO.ALOHA.spectrum.sdisplay.comparison'
        tooltip = "display comparison between experimental value and calculations (1) yes (0) no";
    
    case 'rfwaves.antenna.C3PO'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.omega_rf'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.bNpar0'
        tooltip = "";
        
    case 'rfwaves.antenna.C3PO.launch.bdNpar0'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.bPlhtot'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.mainlobeshift'
        tooltip = " artificial shift of the main lobe of the LH power spectrum : 0 nothing done, < 1 : reduction of the absolute value, > 1 increase of the absolute value";

    case 'rfwaves.antenna.C3PO.launch.rZ0'
        tooltip = "";
        
    case 'rfwaves.antenna.C3PO.launch.m0'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.phi0'
        tooltip = "";
 
    case 'rfwaves.antenna.C3PO.launch.i_ref'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.LFS'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.mmode'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.nparp'
        tooltip = "";
        
    case 'rfwaves.antenna.C3PO.launch.a_sdNpar'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.w0'
        tooltip = "";
        
    case 'rfwaves.antenna.C3PO.launch.z_L'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.tail'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.tail.dtn'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.tail.mode'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.tail.bNparmax_tail'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.tail.bn_tail'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.tail.bP_tail'
        tooltip = "";
    
    case 'rfwaves.antenna.C3PO.launch.tail.bopt_tail'
        tooltip = "";
    
    case 'rfwaves.solver'
        tooltip = "";
    
    case 'rfwaves.solver.type'
        tooltip = "";
    
    case 'rfwaves.solver.code'
        tooltip = "";
    
    case 'rfwaves.solver.enable'
        tooltip = "";
    
    case 'rfwaves.solver.remote_profile'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.testmode'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.tensortype'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.t0'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.tfinal'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.dt0'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.dS'
        tooltip = "";

    case 'rfwaves.solver.C3PO.rayparam.tol'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.kmax'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.ncyclharm'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.reflection'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.rel_opt'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.nperp'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.pperpmax'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.tau_lim'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.rayparam.kextra'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.raydisplay.ray'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.raydisplay.equilibrium'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.raydisplay.p_opt'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam.mmode'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam.kmode'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam.opt_rf'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam.dsmin'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam.n_rf_list'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam.a_sdNpar'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.waveparam.cut_fac'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.C3POparam'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.C3POparam.clustermode'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler'
        tooltip = "";
        
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.mode'
        tooltip = "";
    
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.memory'
        tooltip = "";
    
    case 'postprocessing'
        tooltip = "";
    
    case 'postprocessing.comment'
        tooltip = "";
    
    case 'postprocessing.source'
        tooltip = "";
    
    case 'postprocessing.ir_display'
        tooltip = "no interactive post-processing display";
    
    case 'postprocessing.p_opt'
        tooltip = "";
    
    case 'postprocessing.dp_cyl'
        tooltip = "";
    
    case 'postprocessing.pnmax'
        tooltip = "";
    
    case 'postprocessing.peak'
        tooltip = "";
    
    case 'postprocessing.wave'
        tooltip = "";
    
    case 'postprocessing.peakmode'
        tooltip = "";
    
    case 'postprocessing.rho'
        tooltip = "";
    
    case 'postprocessing.spec'
        tooltip = "";
    
    case 'postprocessing.its_rf'
        tooltip = "";
    
    case 'postprocessing.blist'
        tooltip = "";
    
    case 'postprocessing.diaryname'
        tooltip = "";
    
    case 'diags'
        tooltip = "";
    
    case 'diags.code'
        tooltip = "name of the FEB code";
        
    case 'diags.remote_calculations'
        tooltip = "synthetic diagnostic calculations done remotely (1) or locally( 0)";
        
    case 'diags.enable'
        tooltip = "synthetic diagnostic calculations is enabled (1) or disabled (0)";
        
    case 'diags.exp'
        tooltip = "load experimental data enabled (1) or disabled (0)";
        
    case 'diags.hxrspec'
        tooltip = "";
        
    case 'diags.hxrspec.comment'
        tooltip = "";
        
    case 'diags.hxrspec.source'
        tooltip = "source of the data (code, file, value). If empty, defaults values";
        
    case 'diags.hxrspec.file'
        tooltip = "file name";
        
    case 'diags.hxrspec.path'
        tooltip = "";
        
    case 'diags.hxrspec.chordstatus_hxr'
        tooltip = "";
        
    case 'diags.R5X2'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.comment'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.source'
        tooltip = "source of the data (code, file, value). If empty, defaults values";
        
    case 'diags.R5X2.hxrparam.mfactor'
        tooltip = "for the magnetic equilibrium";
        
    case 'diags.R5X2.hxrparam.method'
        tooltip = "for the magnetic equilibrium in the HXR calculations";
        
    case 'diags.R5X2.hxrparam.ns'
        tooltip = "for chord integration";
        
    case 'diags.R5X2.hxrparam.n_gauleg'
        tooltip = "Number of Legendre polynomials for projections of cross-section and electron velocity distribution";
        
    case 'diags.R5X2.hxrparam.epsi_gauleg'
        tooltip = "accuracy of the Legendre projection";
        
    case 'diags.R5X2.hxrparam.kmin'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.kmax'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.kphot'
        tooltip = "photon energy in keV (important for bremsstrahlung with partial screening effects)";

    case 'diags.R5X2.hxrparam.full_results'
        tooltip = "save all simulations results (1) or just those that can be compared directly to experimental measurements (0).";
        
    case 'diags.R5X2.hxrparam.screening'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.screening_model'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params.tables'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params.tables.nphi'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params.tables.flag_mem'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params.tables.ntheta'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params.tables.integral'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params.tables.nEc'
        tooltip = "";
        
    case 'diags.R5X2.hxrparam.screening.partial.params.tables.Ecmax'
        tooltip = "";
    otherwise
        tooltip = "";
end
end

