function [lukestructs] = run_lukert(lukestructs,dkepath)
%
% Wave and kinetic solver. Self-consistent calculations with or without plasma fluctuations
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
% remote luke run possible if specified in dkepath
%
if nargin < 2,
    dkepath = load_structures_yp('dkepath','','');
end
%
cellmode = 1;
%
if isfield(dkepath,'remnum') && isscalar(dkepath.remnum) && dkepath.remnum == round(dkepath.remnum) && dkepath.remnum >= 1 && dkepath.remnum <= length(dkepath.remote),
    %
    remote = dkepath.remote(dkepath.remnum);
    %
    if isfield(dkepath,'remtimout'),%timeout
        remote.remtimout = dkepath.remtimout;
    else
        remote.remtimout = input_dke_yp('Waiting for remote LUKE results... enter time out (minutes). Enter 0 to return and check later [0]',0);
    end
    %
    if isfield(dkepath,'rempause'),%timeout
        remote.rempause = dkepath.rempause;
    else
        remote.rempause = 0.5;%pause between job checks (in minutes)
    end
    %
    if isfield(dkepath,'debugmode'),
        remote.debugmode = dkepath.debugmode;
    else
        remote.debugmode = 0;
    end
    %
    if isfield(dkepath,'clean'),
        remote.clean = dkepath.clean;
    else
        remote.clean = 2;
    end
    %
    if ~iscell(lukestructs),
        cellmode = 0;
        lukestructs = {lukestructs};% lukestructs must be in cell for remote calculation
    end
    %
else
    %
    remote = '';%local sequential calculation
    %
end
%
if iscell(lukestructs),% remote and/or distributed calculation
    %
    lukestructsize = size(lukestructs);
    %
    lukestructs = lukestructs(:);
    %
    njobs = length(lukestructs);
    %
    luke_flag = zeros(1,njobs);% flags to control LUKE jobs status
    luke_time = tic;
    %
    while any(luke_flag == 0) && (isempty(remote) || remote.remtimout == 0 || toc(luke_time)/60 < remote.remtimout),
        %
        for ijob = 1:njobs,
            %
            if isempty(remote),%local sequential calculation
                %
                disp(['----> Starting job # ',num2str(ijob),'/',num2str(njobs),' locally'])
                %
                lukestructs{ijob} = run_lukert(lukestructs{ijob});
                %
                luke_flag(ijob) = 1;% job completed.
                %
            else            
                %
                lukestandardjob = '';
                %
                if isfield(lukestructs{ijob},'output'),
                    disp(['----> Job # ',num2str(ijob),'/',num2str(njobs),' already completed.'])
                    luke_flag(ijob) = 1;% job completed.
                    continue
                elseif isfield(lukestructs{ijob},'err'),
                    disp(['----> Job # ',num2str(ijob),'/',num2str(njobs),' was run already but failed due to the following error :'])
                    if ischar(lukestructs{ijob}.err),
                        disp(lukestructs{ijob}.err)
                    else
                        for ierr = 1:length(lukestructs{ijob}.err),
                            disp(lukestructs{ijob}.err{ierr})
                        end
                    end
                    luke_flag(ijob) = 1;% job completed.
                    continue
                elseif isfield(lukestructs{ijob},'job'),
                    disp(['----> Job # ',num2str(ijob),'/',num2str(njobs),' is checked on remote cluster : ',remote.host])
                elseif isfield(lukestructs{ijob},'equil'),
                    disp(['----> Job # ',num2str(ijob),'/',num2str(njobs),' is sent to remote cluster : ',remote.host])
                    %
                    lukestandardjob = matstandardjob_jd('runmat','setpath_luke_jd',[remote.env.luke_root,'Project_DKE/DKE/']);
                    %
                    if isfield(lukestructs{ijob},'dkeparam') && isfield(lukestructs{ijob}.dkeparam,'luke_memory'),
                        lukestandardjob.memory = lukestructs{ijob}.dkeparam.luke_memory;% requested memory specified in dkeparam
                    elseif isfield(lukestructs{ijob},'transpfaste') && isstruct(lukestructs{ijob}.transpfaste) && ~isempty(fieldnames(lukestructs{ijob}.transpfaste)), 
                        lukestandardjob.memory = 14000;%mb default value with transport
                    else
                        lukestandardjob.memory = 7000;%mb default value without transport
                    end
                    %
                    if isfield(lukestructs{ijob},'dkeparam') && isfield(lukestructs{ijob}.dkeparam,'luke_ppn'),
                        lukestandardjob.nodes = 1;
                        lukestandardjob.ppn = lukestructs{ijob}.dkeparam.luke_ppn;% number of cores specified in dkeparam
                    end
                    %
                    if isfield(lukestructs{ijob},'dkeparam') && isfield(lukestructs{ijob}.dkeparam,'luke_walltime'),
                        lukestandardjob.walltime = lukestructs{ijob}.dkeparam.luke_walltime;% walltime for remote LUKE calculation
                    else
                        lukestandardjob.walltime = 12;% default walltime in hours
                    end
                    %
                else
                    disp(['----> Job # ',num2str(ijob),'/',num2str(njobs),' structure is unknown. Aborted.'])
                    lukestructs{ijob}.err = 'Job aborted for unknown reasons';
                    luke_flag(ijob) = 1;% job completed.
                    continue
                end
                %
                [err,lukestructs{ijob}] = matremote_jd('run_lukert',lukestructs(ijob),remote,lukestandardjob);
                %
                if isfield(remote,'cvs')
                    remote.cvs.CVSROOT = '';%such that cvs update is done once (see remoterunbatch.m)
                end
                %
                if ~isempty(err),
                    %
                    if isfield(lukestructs{ijob},'equil') && isfield(dkepath,'remenforce') && dkepath.remenforce == 1,% enforce local calculation
                        lukestructs{ijob} = run_lukert(lukestructs{ijob});% local job enforced
                    else
                        lukestructs{ijob}.err = err;
                    end
                    %
                end
                %
                if remote.remtimout == 0,% return hand to caller
                    luke_flag(ijob) = 1;% job completed.
                end
            end
            %
        end
    end
    %
    for ijob = find(luke_flag == 0),
        %
        if isfield(lukestructs{ijob},'job')
            disp(['----> Job # ',num2str(ijob),'/',num2str(njobs),' timed out after ',num2str(remote.remtimout),' minutes.'])
            lukestructs{ijob}.err = ['Job timed out after ',num2str(remote.remtimout),' minutes.'];
        end
        %
    end
    %
    if cellmode == 0;
        lukestructs = lukestructs{1};
    else
        lukestructs = reshape(lukestructs,lukestructsize);
    end
    %
    return
    %
end   
%
% case where the job was already run
% 
if isfield(lukestructs,'output'),%~isempty(remote) && 
    disp('Job was successfully completed already.')
    return
elseif isfield(lukestructs,'err'),
    disp('Job was run already but failed due to an error. See lukestructs.err. Remove field ''err'' from lukestructs to start again.')
    return
elseif isfield(lukestructs,'job'),
    disp('lukestructs contains a seemingly active job. dkepath must contain the structure ''remote'' associated with the job.')
    return
end
%
% mandatory fields
%
equil           = lukestructs.equil;
dkeparam_in     = lukestructs.dkeparam;
dkedisplay_in   = lukestructs.dkedisplay;
%
% optional fields
%
if ~isfield(lukestructs,'simul'),
    simul_in = '';
else
    simul_in = lukestructs.simul;
end
%
if ~isfield(lukestructs,'wavestructs'),
    wavestructs = [];
else
    wavestructs = lukestructs.wavestructs;
end
%
if ~isfield(lukestructs,'waves'),
    waves = [];
else
    waves = lukestructs.waves;
end
%
if ~isfield(lukestructs,'ohm'),
    ohm = [];
else
    ohm = lukestructs.ohm;
end
%
if ~isfield(lukestructs,'transpfaste'),
    transpfaste = [];
else
    transpfaste = lukestructs.transpfaste;
end
%
if ~isfield(lukestructs,'ripple'),
    ripple = [];
else
    ripple = lukestructs.ripple;
end
%
if ~isfield(lukestructs,'XXf0'),
    XXf0 = [];
else
    XXf0 = lukestructs.XXf0;
end
%
if ~isfield(lukestructs,'XXsinksource'),
    XXsinksource_in = [];
else
    XXsinksource_in = lukestructs.XXsinksource;
end
%
if ~isfield(lukestructs,'loadstructs'),
    loadstructs = [];
else
    loadstructs = lukestructs.loadstructs;
end
%
if ~isfield(lukestructs,'opt'),
    opt.save = 0;% (1): save LUKE_RESULTS or return error (0): return results or error
    opt.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
    opt.backup = 0;% (1) save fluctuation time steps (0) do not save
    opt.waves = 0;% (1) save waves at each time step (0) do not save
else
    opt = lukestructs.opt;
    if ~isfield(opt,'save'),
        opt.save = 0;
    end
    if ~isfield(opt,'fields'),
        opt.fields = NaN;
    end
    if ~isfield(opt,'backup'),
        opt.backup = 0;
    end
    if ~isfield(opt,'waves'),    
        opt.waves = 0;
    end
end
%
[dummy,matlabversion,matlabrelease] = LUKEversion_jd;
%
if str2double(matlabversion) < 710,
	rand('seed',sum(100*clock));%reset rand with clock (never same state)
elseif str2double(matlabversion) < 712,
	RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));%reset rand with clock (never same state)
else
	RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));%reset rand with clock (never same state)
end
%
if ~isfield(equil,'fluct') || isempty(equil.fluct),
    equil.fluct = struct;%empty structure
end
%
if ~isstruct(simul_in),
    simul.id = simul_in;
    simul.locid = '';
    simul.path = './';
else
    simul = simul_in;
    if ~isfield(simul,'id'),
        simul.id = '';
    end
    if ~isfield(simul,'locid'),
        simul.locid = '';
    end
    if ~isfield(simul,'path'),
        simul.path = './';
    end
end
%
if isempty(simul.id),% automatic generation of filename
    simul.id = make_luke_simulid_jd(equil,ohm,transpfaste,ripple,waves,wavestructs,simul.locid);
end    
%
if ~exist(simul.path,'dir'), 
    if ~isempty(simul.path),
        mkdir(simul.path);
    end
end
if opt.waves && ~exist([simul.path,'wave_results'],'dir'), 
    mkdir([simul.path,'wave_results']);
end
%
if opt.backup < 0 && ~exist([simul.path,'backup_',simul.id,'.mat'],'file'),% pas de reload if backup file not found - start again and save
    opt.backup = 1;
end
%
disp(' ');
disp(['Simulation id : ',simul.id]);
disp(['Simulation path : ',simul.path]);
disp(' ');
%
itnmin = 1;
wavetype = 0;
%
for iw = 1:length(waves),
    if strcmp(waves{iw}.equil_id,equil.id) == 0,
        error('The wave structure was build with an inconsistent equilibrium')
    end
end   
%
f0struct = [];%Ray absorption in C3PO is first calculated with a thermal electron distribution function
%
if isempty(dkeparam_in.psin_S) && isempty(dkeparam_in.rho_S),
    dkeparam_in.rt_mode = 0;%Only ray-tracing is done, with or without plasma fluctuations. rt_mode = 0 is enforced
    disp('WARNING: dkeparam.rt_mode = 0 has been enforced, since both psin_S and rho_S are empty.');
end
%    
if ~isfield(dkeparam_in,'tn') || (isempty(dkeparam_in.psin_S) && isempty(dkeparam_in.rho_S)),
    dkeparam_in.tn = NaN;
    disp('WARNING: dkeparam.tn = NaN has been set, since tn field is not existing in dkeparam structure.');
end
%
if ~isfield(dkeparam_in,'Nfluct'),
    dkeparam_in.Nfluct = 1;%ratio of LUKE to fluctuation times
end
%
% fluctuation iteration management
%
flag_LH = 0;%check that LH wave is in one of the wavestruct
%
for iw = 1:length(wavestructs),
    if strcmp(wavestructs{iw}.launch.type,'LH'),
        flag_LH = 1;
    end
end    
%
if flag_LH == 0 && isfield(equil.fluct,'npar0_lh'),
    disp('Perturbation of the launched npar for the LH wave only; dismissed.')
    equil.fluct = rmfield(equil.fluct,'npar0_lh');
end
%
mksa = buildlukestruct_yp('mksa',equil,dkeparam_in,dkedisplay_in);
%
if isfield(dkeparam_in,'tn_mode') && dkeparam_in.tn_mode == 1,%time given in seconds
    %
    if ~isscalar(dkeparam_in.tn) || (~isnan(dkeparam_in.tn) && imag(dkeparam_in.tn) == 0),%real tn specified,
        dkeparam_in.tn = mksa.nhu_ref*dkeparam_in.tn;% time normalized to collision time
    end
    if ~isscalar(dkeparam_in.dtn) || (~isnan(dkeparam_in.dtn) && imag(dkeparam_in.dtn) == 0),%real dtn specified,
        dkeparam_in.dtn = mksa.nhu_ref*dkeparam_in.dtn;% time normalized to collision time
    end
    %
end
%
% TODO : use dtns_fluct to flag fluctuation phase renewal
%
[dtnmin_fluct,dtns_fluct] = calc_dtn_fluct_jd(equil.fluct,wavestructs,mksa);% minimum and list of fluctuation times for all fluctuations scenarios
%
dtn_phase = dkeparam_in.Nfluct*dtnmin_fluct;%time for phase renewal
%
if isscalar(dkeparam_in.tn) && imag(dkeparam_in.tn) > 0,% the number of fluctuation iterations is specified by imag(tn)
    itnmax = imag(dkeparam_in.tn);
    tn_in = itnmax*dtn_phase;%final time
elseif isscalar(dkeparam_in.tn) && ~isnan(dkeparam_in.tn),% the number of fluctuation iterations is specified by tn and Nfluct*dtnmin_fluct
    itnmax = max(1,ceil(dkeparam_in.tn/dtn_phase));
    tn_in = dkeparam_in.tn;
else% no fluctuation iterations
    itnmax = 1;
    tn_in = dkeparam_in.tn;
end
%
dkeparam_in = rmfield(dkeparam_in,'tn');%tn is specified in iteration loop
%
byPnonabs = NaN;% leftover power in each wave
%
if opt.backup >= 0;% start simulation from beginning
    %
    dkeparam = dkeparam_in;
    dkedisplay = dkedisplay_in;
    tn = tn_in;
    %
    calctime = struct;
    %
    if ~isinf(dtnmin_fluct),
        xJ = [];
        xP = [];
        Itot = [];
        Ptot = [];
    end
    %
    % Calculate vectorial axisymmetric magnetic equilibrium and eventually plasmas fluctuations (if substructure 'fluct' exists
    %
    if isstruct(equil.fluct) && ~isempty(fieldnames(equil.fluct)),
        equil.fluct = fluctphase_yp(equil.fluct);
    end
    %
    if ~isempty(wavestructs),
        for iws = 1:length(wavestructs),
            [wavestructs{iws}.equil] = equil;
            if isfield(wavestructs{iws},'fitparam'),
                [wavestructs{iws}.equil_fit] = fitequil_yp(equil,wavestructs{iws}.fitparam.mode_equil,wavestructs{iws}.fitparam.method,wavestructs{iws}.fitparam.ngridresample,wavestructs{iws}.fitparam.nharm);
            else
                [wavestructs{iws}.equil_fit] = fitequil_yp(equil,wavestructs{iws}.fitequilparam.mode_equil,wavestructs{iws}.fitequilparam.method,wavestructs{iws}.fitequilparam.ngridresample,wavestructs{iws}.fitequilparam.nharm);%backward compatibility         
            end  
            %
            if isstruct(equil.fluct) && ~isempty(fieldnames(equil.fluct)),
                if isfield(wavestructs{iws},'fitparam'),
                    [wavestructs{iws}.equil_fit.fluct_fit] = fitfluct_yp(equil.fluct,wavestructs{iws}.fitparam.mode_equil,equil.fluct.fitparam.method,equil.fluct.fitparam.ngridresample,equil.fluct.fitparam.nharm);
                else
                    if isfield(equil.fluct,'fitparam'),
                        [wavestructs{iws}.equil_fit.fluct_fit] = fitfluct_yp(equil.fluct,wavestructs{iws}.fitequilparam.mode_equil,equil.fluct.fitparam.method,equil.fluct.fitparam.ngridresample,equil.fluct.fitparam.nharm);
                    else
                        [wavestructs{iws}.equil_fit.fluct_fit] = fitfluct_yp(equil.fluct);                        
                    end
                end
            end     
        end
    end
else% reload mode
    %
    disp('------------------ RE-LOAD MODE ------------------');
    %
    load([simul.path,'backup_',simul.id,'.mat']);
    %
    if opt.backup == -1,%interactive update
        %
        dkeparam = imod_struct_jd(dkeparam,'dkeparam',1,dkedisplay.display_mode);
        dkedisplay = imod_struct_jd(dkedisplay,'dkedisplay',1,dkedisplay.display_mode);
        opt = imod_struct_jd(opt,'opt',1,dkedisplay.display_mode);
        %
        for ifluct = 1:size(wavestructs,1),
            for iw = 1:size(wavestructs,2),
                %
                wavestructs{ifluct,iw} = imod_struct_jd(wavestructs{ifluct,iw},['wavestructs{',num2str(ifluct),',',num2str(iw),'}'],1,dkedisplay.display_mode);
            end
        end                
        %
    elseif opt.backup == -2,%non interactive update
        dkedisplay.display_mode = dkedisplay_in.display_mode;
        if ~isfield(dkedisplay_in,'display_time_mode');
            dkedisplay.display_time_mode = 0;
        else
            dkedisplay.display_time_mode = dkedisplay_in.display_time_mode;
        end
    end
    %
    if itn == itnmax,
        disp(['The maximum number of iterations ',int2str(itnmax),' has already been reached.']);
    else
        disp(['The number of iterations already done is ',int2str(itn),'/',int2str(itnmax),'.']);
    end
    %
    if  tn < tn_in,
        if opt.backup == -1,
            overwrite_tn = input_dke_yp(['Do you want to overwrite the total simulation time from ',int2str(tn),' to ',int2str(tn_in),' (y/n) ?'],'n',{'y','n'});
        else
            overwrite_tn = 'y';
        end
        %
        if overwrite_tn == 'y',
            %
            disp(['- Old tn = ',int2str(tn)]);
            disp(['- New tn = ',int2str(tn_in)]);
            tn = tn_in;
            itnmax = max([1,ceil(tn/dtn_phase)]);
        end
        %
    end
    %
    opt.backup = 1;
    %
    disp('---------------------------------')
    disp('Iteration status')
    disp('---------------------------------')
    disp([' - tn = ',int2str(tn)])
    disp([' - number of iterations to be done = ',int2str(itnmax - itn)])
    %
    if itn < itnmax,
        itnmin = itn + 1;%restart from the saved iteration
    else
        itnmin = itnmax + 1;%no iteration
    end
end
%
for itn = itnmin:itnmax,%time evolution
    %
    if itn < itnmax,
        dkeparam.tn = dtn_phase;% fluctuations, one step
    elseif isscalar(tn) && ~isinf(dtn_phase),%fluctuations, last time step
        dkeparam.tn = tn - dtn_phase*(itnmax - 1);
    else% no fluctutions
        dkeparam.tn = tn;
    end
    %
    % RF wave propagation solver
    %
    time_waves = tic;
    %
    if ~isempty(wavestructs), 
        [waves,wavestructs,byisel] = wave_distribution_yp(dkepath,dkeparam,wavestructs,f0struct,dtnmin_fluct/mksa.nhu_ref,byPnonabs);%ray propagation in fluctuating plasma. The fluctuation phase in wavestructs is output to be later re-used by the same function taling into account of the phase evolution
    end
    %
    calctime(itn).waves = toc(time_waves);
    %
    %
    % RF wave absorption solver (drift kinetic calculations)
    %
    if itn > 1,        
        XXf0 = XXf0_t{itn-1};%internal time evolution. The previous time is the input for the next one
    end
    %
    time_luke = tic;
    %
    if itn == 1,
        [Znorm_loc,Zcurr_loc,ZP0_loc,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = loop_run_lukert(simul,waves,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,XXf0,XXsinksource_in,loadstructs);
        %
        equilDKE.fluct = equil.fluct;%for transfering info about plasma fluctuations
        %
        loadstructs.radialgrid_dke_jd.radialDKE = radialDKE;
        loadstructs.equilibrium_jd.equilDKE = equilDKE;
        loadstructs.momentumgrid_dke_jd.momentumDKE = momentumDKE;
        loadstructs.matrix3Dgridbuilder_dke_yp.gridDKE = gridDKE;
        loadstructs.momentumcoefbuilder_dke_yp.Zmomcoef = Zmomcoef;
        loadstructs.bouncecoefbuilder_dke_yp.Zbouncecoef = Zbouncecoef;
        loadstructs.mripplecoefbuilder_dke_yp.Zmripple = Zmripple;
        loadstructs.mksacoefbuilder_dke_yp.mksa = mksa;
        loadstructs.sinksourcecoeffbuilder_dke_yp.XXsinksource = XXsinksource;
        %
        loadstructs.rad_dke_yp.ZXXD_a = dke_out.ZXXD_a;
        loadstructs.rad_dke_yp.ZXXF_a = dke_out.ZXXF_a;
        %
        loadstructs.coll_dke_jd.ZXXD_c = dke_out.ZXXD_c;
        loadstructs.coll_dke_jd.ZXXF_c = dke_out.ZXXF_c;
        loadstructs.coll_dke_jd.ZXXD_c_tp = NaN;%dke_out.ZXXD_c_tp;
        loadstructs.coll_dke_jd.ZXXF_c_tp = NaN;%dke_out.ZXXF_c_tp;
        loadstructs.coll_dke_jd.XXfM = dke_out.XXfM;
        loadstructs.coll_dke_jd.XXILor = dke_out.XXILor;
        %
        loadstructs.efield_dke_jd.ZXXD_e = dke_out.ZXXD_e;
        loadstructs.efield_dke_jd.ZXXF_e = dke_out.ZXXF_e;
        loadstructs.efield_dke_jd.ZXXD_e_tp = NaN;%dke_out.ZXXD_e_tp;
        loadstructs.efield_dke_jd.ZXXF_e_tp = NaN;%dke_out.ZXXF_e_tp;
        loadstructs.efield_dke_jd.xepsi = dke_out.xepsi;
        loadstructs.efield_dke_jd.xEfield_validity = dke_out.xEfield_validity;
        %
%         loadstructs.rfwave_dke_jd.waveparam = dke_out.waveparam;
%         loadstructs.rfwave_dke_jd.xyprop_dke = dke_out.xyprop_dke;
%         loadstructs.rfwave_dke_jd.xyP0_2piRp_mod = dke_out.xyP0_2piRp_mod;
%         loadstructs.rfwave_dke_jd.yb = dke_out.yb;
%         loadstructs.rfwave_dke_jd.yP0_2piRp = dke_out.yP0_2piRp;
%         loadstructs.rfwave_dke_jd.xys = dke_out.xys;
        %
%         loadstructs.rfdiff_dke_jd.ZXYD_rf = dke_out.ZXYD_rf;
%         loadstructs.rfdiff_dke_jd.ZXYF_rf = dke_out.ZXYF_rf;
%         loadstructs.rfdiff_dke_jd.ZXYD_rf_tp = NaN;%dke_out.ZXYD_rf_tp;
%         loadstructs.rfdiff_dke_jd.ZXYF_rf_tp = NaN;%dke_out.ZXYF_rf_tp;
%         loadstructs.rfdiff_dke_jd.gridindex_rf = dke_out.gridindex_rf;
        %
%         loadstructs.finit_dke_yp.XXfinit = dke_out.XXfinit;   
        %         
    else
        [Znorm_loc,Zcurr_loc,ZP0_loc,dke_out] = loop_run_lukert(simul,waves,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,XXf0,XXsinksource_in,loadstructs);   
    end
    %
    calctime(itn).luke = toc(time_luke);
    %
    Ptot_0 = 0;%injected power at t=0
    Ptot_inj = 0;%injected power at t=itn
    Pnonabs = 0;%quasilinear power not absorbed at t=itn
    %    
    byPnonabs = cell(size(wavestructs));
    %
    if ~isinf(dtn_phase),
        %
        nit_rf = length(dke_out.residue_rf{end});%number of RF iterations in last LUKE time
        %
        for ifluct = 1:size(wavestructs,1),
            for iw = 1:size(wavestructs,2),
                %
                % calculate power injected at t=0 et t=tin
                %
                if isfield(wavestructs{ifluct,iw}.launch,'bPlhtot'),
                    yPtot_0 = wavestructs{ifluct,iw}.launch.bPlhtot_in;%LH injected power at t=0
                    yPtot_inj = wavestructs{ifluct,iw}.launch.bPlhtot;%LH injected power at t=itn
                elseif isfield(wavestructs{ifluct,iw}.launch,'yP_L'),
                    yPtot_0 = wavestructs{ifluct,iw}.launch.yP_L_in;%EC injected power at t=0
                    yPtot_inj = wavestructs{ifluct,iw}.launch.yP_L;%EC injected power at t=itn
                end
                %
                Ptot_0 = Ptot_0 + sum(yPtot_0)/1e6;%LH injected power at t=0
                Ptot_inj = Ptot_inj + sum(yPtot_inj)/1e6;%LH injected power at t=itn
                ny = length(yPtot_0);
                %
                % calculate ql power not absorbed at t=tn
                %
                byPnonabs{ifluct,iw} = yPtot_inj;
                for iy = 1:ny,% sum over lobes
                    for iray = 1:length(byisel{ifluct,iw}{iy}),
                        Pabs_loc = 2*pi*equil.Rp*(dke_out.yP0_2piRp(byisel{ifluct,iw}{iy}(iray)) - dke_out.zP_0_2piRp_mod{nit_rf,end}{byisel{ifluct,iw}{iy}(iray)}(end));
                        byPnonabs{ifluct,iw}(iy) = byPnonabs{ifluct,iw}(iy) - Pabs_loc;
                    end
                end
                %
                Pnonabs = Pnonabs + sum(byPnonabs{ifluct,iw})/1e6;
                %
            end
        end
        %
        disp(['---> Injected rf power @ itn = 1 : ',num2str(Ptot_0),' (MW)']);
        disp(['---> Injected rf power @ itn = ',int2str(itn),' : ',num2str(Ptot_inj),' (MW)']);
        disp(['---> Power not absorbed @ itn = ',int2str(itn),' : ',num2str(Pnonabs),' (MW)']);
    end
    %
    if itnmax > 1,
        %
        xrho = loadstructs.equilibrium_jd.equilDKE.xrho(:);
        xdA = loadstructs.equilibrium_jd.equilDKE.xdA_dke(:).';
        if isfield(loadstructs.equilibrium_jd.equilDKE,'xdV_dke'),
            xdV = loadstructs.equilibrium_jd.equilDKE.xdV_dke(:).';
        else
            xdV = loadstructs.equilibrium_jd.equilDKE.xdV_2piRp_dke(:).'*2*pi*loadstructs.equilibrium_jd.equilDKE.Rp;
        end
        %
        xtn(itn) = min([dtn_phase*itn,tn]);
        %
        xJ(itn,:) = Zcurr_loc(end).x_0_fsav*loadstructs.mksacoefbuilder_dke_yp.mksa.j_ref;
        xP(itn,:) = ZP0_loc(end).x_rf_fsav.'*loadstructs.mksacoefbuilder_dke_yp.mksa.P_ref;
        %
        Itot(itn) = sum(xJ(itn,:).*xdA,2);
        Ptot(itn) = sum(xP(itn,:).*xdV,2);
        %
        if ~isfield(dkedisplay,'display_time_mode'), dkedisplay.display_time_mode = 0;end
        %
        if dkedisplay.display_time_mode >= 1,
            %
            figure(figbyname_yp(['Jrf(r,t) / ',simul.id])),
            %
            if itn > 2,
                graph1D_jd(xrho,xJ([1:end-2],:),0,0,'\rho','J_{tot} (MA/m^2)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', I_{tot} = ',num2str(Itot(itn)),' (MA)'],NaN,'','','-','none','g',1);
            end
            %
            if itn > 1,
                graph1D_jd(xrho,xJ(end-1,:),0,0,'\rho','J_{tot} (MA/m^2)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', I_{tot} = ',num2str(Itot(itn)),' (MA)'],NaN,'','','-','none','b',1);            
            end
            %
            graph1D_jd(xrho,xJ(end,:),0,0,'\rho','J_{tot} (MA/m^2)',['I_{tot} = ',num2str(Itot(itn)),' (MA)'],NaN,'','','-','none','r',2);
            %
            figure(figbyname_yp(['Prf(r,t) / ',simul.id])),
            %
            if itn > 2,
                graph1D_jd(xrho,xP([1:end-2],:),0,0,'\rho','P_{abs} (MW/m^3)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', P_{abs} = ',num2str(Ptot(itn)),' (MW)'],NaN,'','','-','none','g',1);
            end
            %
            if itn > 1,
                graph1D_jd(xrho,xP(end-1,:),0,0,'\rho','P_{abs} (MW/m^3)',['Iteration = ',int2str(itn),'/',int2str(itnmax),', P_{abs} = ',num2str(Ptot(itn)),' (MW)'],NaN,'','','-','none','b',1); 
            end
            %
            graph1D_jd(xrho,xP(end,:),0,0,'\rho','P_{abs} (MW/m^3)',['P_{abs} = ',num2str(Ptot(itn)),' (MW)'],NaN,'','','-','none','r',2);
            %
            figure(figbyname_yp(['Irf(t) / ',simul.id])),
            %
            graph1D_jd(xtn,Itot,0,0,'t*\nu','I_{tot} (MA)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'','','none','.','c',2);  
            graph1D_jd(xtn,Itot,0,0,'t*\nu','I_{tot} (MA)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'','','-','none','c',2);  
            %
            figure(figbyname_yp(['Prf(t) / ',simul.id])),
            %
            graph1D_jd(xtn,Ptot,0,0,'t*\nu','P_{tot} (MW)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'',[0,Ptot_inj*2],'none','.','k',2);drawnow
            graph1D_jd(xtn,Ptot,0,0,'t*\nu','P_{tot} (MW)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'',[0,Ptot_inj*2],'-','none','k',2);drawnow
            graph1D_jd(xtn,Ptot_inj*ones(1,itn),0,0,'t*\nu','P_{tot} (MW)',['Iteration = ',int2str(itn),'/',int2str(itnmax)],NaN,'',[0,Ptot_inj*2],'--','none','k',1);drawnow
        else
            disp(' ');
            disp('------------------------------------------------------------------------------------');
            disp(['Simulation ',simul.id]);
            disp(['Iteration #',int2str(itn),': Pref = ',num2str(Ptot_inj),' (MW) - Ptot = ',num2str(Ptot(itn)),' (MW) - Itot = ',num2str(Itot(itn)),' (MA)']);
            disp('------------------------------------------------------------------------------------');
            disp(' ');
        end
        %
        % Feedback kinetic calculations for calculating the wave absorption with a non-Mawellian electron distribution in the propagation solver 
        %
        f0struct = build_f0struct_yp(dke_out,loadstructs.momentumgrid_dke_jd.momentumDKE,loadstructs.equilibrium_jd.equilDKE,loadstructs.mksacoefbuilder_dke_yp.mksa);%For absorption in C3PO with a non-Maxwellian electron distribution    
    end
    %
    XXf0_t{itn} = dke_out.XXf0{end};%for saving the time evolution of the electron velocity distribution function
    %
    % Display ray dynamics on the FP radial grid
    %
    for iws = 1:length(wavestructs),
        if isfield(wavestructs{iws}.launch,'yP_L'); 
            wavetype = wavetype + 1;
        end
    end
    %
    % build output structures by grouping internal and external time evolutions
    %
	if itn > 1,
        Znorm = [Znorm,Znorm_loc];
        Zcurr = [Zcurr,Zcurr_loc];
        ZP0 = [ZP0,ZP0_loc];
        %
        Ztime = [Ztime,Ztime(end) + dke_out.FPtime];
        Zitn = [Zitn,length(Ztime)];
    else
        Znorm = Znorm_loc;
        Zcurr = Zcurr_loc;
        ZP0 = ZP0_loc;
        %
        Ztime = dke_out.FPtime;
        Zitn = length(Ztime);
    end
    %
    if itnmax > 1 && opt.backup > 0,
        wavetype = wavetype/length(wavestructs);
        %
        if isfield(dkedisplay,'display_time_mode'),
            if dkedisplay.display_time_mode >= 2,
                rayevolution_yp(wavetype,wavestructs{1}.equil_fit,waves,0,loadstructs.radialgrid_dke_jd.radialDKE.xrho_S_dke,itn);
            end
        end
        %
        if opt.waves,
            save([simul.path,'wave_results/waves_',simul.id,'_',int2str(itn),'.mat'],'wavetype','waves','wavestructs','itn');
        end
        %
        wavetype = 0;
        %
        %Emergency backup of each iteration
        %
        save_str = [simul.path,'backup_',simul.id,'.mat'];
        if isfield(dke_out,'waves'),
            waves = dke_out.waves;
        else
            waves = '';
        end
        %
        eval(['save ',save_str,' tn itn itnmax calctime Ztime Zitn xrho xtn xJ xP Itot Ptot byPnonabs wavestructs waves f0struct XXf0_t loadstructs simul equil dkeparam dkedisplay ohm transpfaste ripple XXsinksource_in Znorm Zcurr ZP0']);
        disp('--------------------------------------------------------------------------------------------------');
        info_dke_yp(2,['Backup of iteration ',int2str(itn),'/',int2str(itnmax),' done in file ''',save_str,'''.']);
        disp('--------------------------------------------------------------------------------------------------');
        clear waves
        %
    elseif itnmax == 1 && opt.waves
        %
        save([simul.path,'wave_results/waves_',simul.id,'.mat'],'waves','wavestructs');
        %
    end
end
%
dke_out.dkeparam = dkeparam;%for data transfer only
dke_out.calctime = calctime;
%
output.Znorm = Znorm;
output.Zcurr = Zcurr;
output.ZP0 = ZP0;
output.dke_out = dke_out;
output.radialDKE = loadstructs.radialgrid_dke_jd.radialDKE;
output.equilDKE = loadstructs.equilibrium_jd.equilDKE;
output.momentumDKE = loadstructs.momentumgrid_dke_jd.momentumDKE;
output.gridDKE = loadstructs.matrix3Dgridbuilder_dke_yp.gridDKE;
output.Zmomcoef = loadstructs.momentumcoefbuilder_dke_yp.Zmomcoef;
output.Zbouncecoef = loadstructs.bouncecoefbuilder_dke_yp.Zbouncecoef;
output.Zmripple = loadstructs.mripplecoefbuilder_dke_yp.Zmripple;
output.mksa = loadstructs.mksacoefbuilder_dke_yp.mksa;
output.XXsinksource = loadstructs.sinksourcecoeffbuilder_dke_yp.XXsinksource;
%
if abs(opt.waves),
    output.dke_out = rmfield(output.dke_out,'waves');
end
%
% Reduced output
%
if ~isfield(dkeparam,'opt_struct') || dkeparam.opt_struct == 0,
    savefields_radialDKE = {'xrho_S_dke','xpsin_f','xpsin_f_dke','xdpsin_f_dke','xpsin_S_dke','r_dke'};
    savefields_momentumDKE = {'pn','pnp','pn_S','dpn','mhu','mhu_S','dmhu'};
    savefields_gridDKE = {'X1mmhu2','xmhubounce2'};
    savefields_Zmomcoef = {'gamma','v','Ec_ref','dEc_ref'};
    savefields_Zbouncecoef = {'xq','xqtilde','xqbar','xqhat','XXheaviside','Xxlambda'};
    savefields_Zmripple = {'XXlossripple','xdeltaripple','xNq','Xnhuloss','xthetabanana','xthetaloss','xpndetrap','xpnth','xEseuil'};
    %
    savefields_ZXXD_rf = {'parpar_ij','pp_ij'};
    rmfields_dke_out = {'ZXXS','ZXXF_rf','ZXXD_c','ZXXF_c','ZXXD_e','ZXXF_e','ZXXD_a','ZXXF_a','XXILor'};
    %
    output.radialDKE = selectfields_jd(output.radialDKE,savefields_radialDKE);
    output.momentumDKE = selectfields_jd(output.momentumDKE,savefields_momentumDKE);
    output.gridDKE = selectfields_jd(output.gridDKE,savefields_gridDKE);
    output.Zmomcoef = selectfields_jd(output.Zmomcoef,savefields_Zmomcoef);
    output.Zbouncecoef = selectfields_jd(output.Zbouncecoef,savefields_Zbouncecoef);
    output.Zmripple = selectfields_jd(output.Zmripple,savefields_Zmripple);
    %
    output.dke_out.ZXXD_rf = selectfields_jd(output.dke_out.ZXXD_rf,savefields_ZXXD_rf);
    output.dke_out = rmfield(output.dke_out,rmfields_dke_out);
end
%
lukestructs.output = output;
%
if opt.save,% save results in LUKE_RESULTS file
    savefile = [simul.path,'LUKE_RESULTS_',simul.id,'.mat'];
    save(savefile,'lukestructs','-v7.3');
end
%
if iscell(opt.fields),% select fields to return in output
    lukestructs.output = selectfields_jd(lukestructs.output,opt.fields);
end
%
if opt.save,% return at least savefile
    lukestructs.output.savefile = savefile;
end
%

    
