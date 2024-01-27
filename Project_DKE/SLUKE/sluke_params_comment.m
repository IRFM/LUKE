function str_o = sluke_params_comment(str_i)
%
if strfind(str_i,'simul.mute.')
    str_i = 'simul.mute.*';% for repetitive fields
end
%
switch str_i
    %
    case 'machine'
        str_o = 'Name of tokamaks';
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
    case 'simul.id'
        str_o = 'Simulation identifier';
    %
    case 'simul.enable'
        str_o = 'Enable (1) or not (0) the simulations';
    %
    case 'simul.comment'
        str_o = 'Comments on the simulation';
    %
    case 'simul.enforce'
        str_o = '(1) -> enforce new simulation (erase all corresponding files), (0) -> simulation is not enforced (but may be cancelled manually : file LUKE_DATA_*** is deleted in case of problem),  (-1) -> simulation is not enforced and not cancelled';
    %
    case 'simul.remote_profile'
        str_o = 'type dispremoteprofiles('''',''scheduler''); to get the profile of the machine on which calculations will be performed';
    %
    case 'simul.wait4results'
        str_o = '(0) -> disable remote calculations which are performed locally for debug only, (1) -> enable remote calculations';
    %
    case 'simul.log'
        str_o = '(1) -> generate log file of the simulation (diary), (0) -> no log of the simulations';
    %
    case 'simul.save'
        str_o = 'save mode : (0) or empty -> save just main results in PROC_LUKE_DATA files, (1) -> save all results in LUKE_DATA and PROC_LUKE_DATA (WARNING : storage capacity must be very large). Note : in order to vizualise all details of the calculations with irunluke_jd.m, the option (1) must be selected but for specific simulations only, in order to avoid too large storage requirements.';
    %
    case 'simul.equilconsistency.code'
        str_o = 'selfconsistency between LUKE calculations and toroidal MHD equilibrium solver (may be METIS or other code)';
    %
    case 'simul.equilconsistency.nit'
        str_o = 'number of iterations for selfconsistency between LUKE calculations and toroidal MHD equilibrium solver (may be METIS or other code)';
    %
    case 'simul.mute.*'
        str_o = '(0) -> enable display of the function if any, (1) -> disable display of the function if any';
    %
    case 'kinetics.dkeparam.id'
        str_o = '';
    %
    case 'kinetics.dkeparam.comment'
        str_o = '';
    %
    case 'kinetics.dkeparam.source'
        str_o = '';
    %
    case 'kinetics.dkeparam.preset'
        str_o = '';
    %
    case 'kinetics.dkedisplay.id'
        str_o = '';
    %
    case 'kinetics.dkedisplay.comment'
        str_o = '';
    %
    case 'kinetics.dkedisplay.source'
        str_o = '';
    %
    case 'kinetics.dkedisplay.preset'
        str_o = '';
    %
    case 'equil.id'
        str_o = '';
    %
    case 'equil.comment'
        str_o = '';
    %
    case 'equil.source'
        str_o = '';
    %
    case 'equil.code'
        str_o = '';
    %
    case 'equil.file'
        str_o = '';
    %
    case 'equil.path'
        str_o = '';
    %
    case 'equil.equilconsistency.id'
        str_o = '';
    %
    case 'equil.equilconsistency.comment'
        str_o = '';
    %
    case 'equil.equilconsistency.source'
        str_o = '';
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
    case 'equil.fit.id'
        str_o = '';
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
    case 'ohm.id'
        str_o = '';
    %
    case 'ohm.comment'
        str_o = '';
    %
    case 'ohm.source'
        str_o = '';
    %
    case 'ohm.code'
        str_o = '';
    %
    case 'ohm.file'
        str_o = '';
    %
    case 'ohm.path'
        str_o = '';
    %
    case 'rfwaves.id'
        str_o = '';
    %
    case 'rfwaves.comment'
        str_o = '';
    %
    case 'rfwaves.source'
        str_o = '';
    %
    case 'rfwaves.file'
        str_o = '';
    %
    case 'rfwaves.path'
        str_o = '';
    %
    case 'rfwaves.enable'
        str_o = '';
    %
    case 'rfwaves.antenna.type'
        str_o = '{''''} if no rf wave isused, {''LH''} lower hybrid wave or {''EC''} electron cyclotron waves. If several rf antennas are used, the formalism is {''LH'',''LH'',''EC'',...}. ';
    %
    case 'rfwaves.antenna.id'
        str_o = 'id of the rf antenna calculations';
    %
    case 'rfwaves.antenna.comment'
        str_o = 'comments on the antenna calculations';
    %
    case 'rfwaves.antenna.source'
        str_o = '';
    %
    case 'rfwaves.antenna.code'
        str_o = '';
    %    
    case 'rfwaves.antenna.LH.ALOHA.port'
        str_o = 'antenna ports : {''Q6A''} or {''Q6B''} or {''Q6A'',''Q6B''} if multiple antennas -> (C2,C3) or (C3,C4) or (LH1,LH2) for Tore Supra or WEST here given as examples';
    %
    case 'rfwaves.antenna.LH.ALOHA.remote_profile'
        str_o = 'type dispremoteprofiles('''',''scheduler''); to get the profile of the machine on which ALOHA calculations will be performed';;
    %
    case 'rfwaves.antenna.LH.ALOHA.display.data.mode'
        str_o = '(-1) -> display, (1) -> display, (0) -> no display';
    %
    case 'rfwaves.antenna.LH.ALOHA.display.data.save'
        str_o = 'display and save experimental data figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1) if exist';
    %
    case 'rfwaves.antenna.LH.ALOHA.display.results'
        str_o = 'display and save ALOHA power spectrum and RC figures (2), display and do not save figures (1), do not display but save figures (0), do nothing (-1)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.method'
        str_o = '(1) Edge density in front of the grill is calculated such that simulated RC coefficients are the clostest to observations (0) Edge density in front of the grill is given by the guess';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.ne_guess'
        str_o = 'Edge density in front of the grill (initial guess [ne_min,ne_max] or enforced value [ne_fiexed]) (m-3)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.tolfun'
        str_o = 'Relative tolerance on targets (if aloha.optim.method = 1)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.tolx'
        str_o = 'relative tolerance on inputs (if aloha.optim.method = 1)';
    %
    case 'rfwaves.antenna.LH.ALOHA.optim.nitmax'
        str_o = 'maximum number of iterations (if aloha.optim.method = 1)';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.dir'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.mode'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.nlobes'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.Pin_in'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.inter'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.mode'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.opt_optim'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.ALOHA.spectrum.comparison'
        str_o = '';
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
        str_o = 'Vertical position of the antenna rowswith respect of the equatorial mid-plane (m) ';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.m0'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.phi0'
        str_o = '';
    %
    case 'rfwaves.antenna.LH.C3PO.launch.i_ref'
        str_o = '';
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
    case 'rfwaves.solver.id'
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
    case 'rfwaves.solver.C3PO.raydisplay.ray'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.raydisplay.equilibrium'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.raydisplay.p_opt'
        str_o = '';
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
    case 'rfwaves.solver.C3PO.waveparam.n_rf_list'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.waveparam.a_sdNpar'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.waveparam.cut_fac'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.mode'
        str_o = '';
    %
    case 'rfwaves.solver.C3PO.C3POparam.clustermode.main_C3PO_jd.scheduler.memory'
        str_o = '';
    %
    case 'postprocessing.id'
        str_o = '';
    %
    case 'postprocessing.comment'
        str_o = '';
    %
    case 'postprocessing.source'
        str_o = '';
    %
    case 'postprocessing.ir_display.ir_display'
        str_o = '';
    %
    case 'postprocessing.ir_display.p_opt'
        str_o = '';
    %
    case 'postprocessing.ir_display.pnmax'
        str_o = '';
    %
    case 'postprocessing.ir_display.peak'
        str_o = '';
    %
    case 'postprocessing.ir_display.wave'
        str_o = '';
    %
    case 'postprocessing.ir_display.peakmode'
        str_o = '';
    %
    case 'postprocessing.ir_display.rho'
        str_o = '';
    %
    case 'postprocessing.ir_display.spec'
        str_o = '';
    %
    case 'postprocessing.ir_display.its_rf'
        str_o = '';
    %
    case 'postprocessing.ir_display.blist'
        str_o = '';
    %
    case 'postprocessing.ir_display.diaryname'
        str_o = '';
    %
    case 'postprocessing.dp_cyl'
        str_o = '';
    %
    case 'diags.hxr.hxrspec.id'
        str_o = '';
    %
    case 'diags.hxr.hxrspec.comment'
        str_o = '';
    %
    case 'diags.hxr.hxrspec.source'
        str_o = 'source of the data (code, file, value)';
    %
    case 'diags.hxr.hxrspec.code'
        str_o = 'code name if this option is chosen';
    %
    case 'diags.hxr.hxrspec.chordstatus_hxr'
        str_o = 'enable or disable chords which may have technical problems for display';
    %
    case 'diags.hxr.hxrparam.id'
        str_o = '';
    %
    case 'diags.hxr.hxrparam.comment'
        str_o = '';
    %
    case 'diags.hxr.hxrparam.source'
        str_o = 'source of the data (code, file, value)';
    %
    case 'diags.hxr.hxrparam.mfactor'
        str_o = 'for the magnetic equilibrium in the HXR calculations';
    %
    case 'diags.hxr.hxrparam.method'
        str_o = 'for the magnetic equilibrium in the HXR calculations';
    %
    case 'diags.hxr.hxrparam.ns'
        str_o = 'for chord integration';
    %
    case 'diags.hxr.hxrparam.n_gauleg'
        str_o = 'number of Legendre polynomials for projections of cross-section and electron velocity distribution';
    %
    case 'diags.hxr.hxrparam.epsi_gauleg'
        str_o = 'accuracy of the Legendre projection';
    %      
    case ''
        str_o = '';
    % 
    case ''
        str_o = '';
    %
    case ''
        str_o = '';
    %
    case ''
        str_o = '';
    %
    case ''
        str_o = '';
    %
    case ''
        str_o = '';
    %
    otherwise 
        cprintf([1,0.5,0],['WARNING : field ',str_i,' has no help']);disp(' ')
        str_o = '';
end


