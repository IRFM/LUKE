function rundke_metis_LH(basestr,shotnum,shotimes,locpath_simul,locid_simul,configs,opt,dkepath,dkeparam,dkedisplay,equil,ohm,transpfaste_in,ripple,rayparam,waveparam,C3POparam,scheduler_run_lukert)
    %
    if nargin < 18,
        scheduler_run_lukert = struct;
    end
    if nargin < 17,
        C3POparam = struct;
    end
    if nargin < 16,
        waveparam = struct;
    end
    if nargin < 15,
        rayparam = struct;
    end
    %
    % Simulation locid from config
    %
    % config = configs(1);
    % %
    % % aloha
    % %
    % locid_simul = ['aloha_',num2str(config.opt_aloha)];
    % %
    % if isfield(config,'locid'),
    %     locid_simul = [locid_simul,'_',config.locid];
    % elseif real(config.opt_aloha) >= 1 && config.aloha.inter == 0,
    %     if isfield(config,'locid_aloha'),% one spectrum for both modules
    %         locid_simul_aloha = config.locid_aloha;
    %     elseif isfield(config,'locid_aloha_b') && isfield(config,'locid_aloha_h'),% one spectrum for each modules
    %         locid_simul_aloha = [config.locid_aloha_b,config.locid_aloha_h];
    %     else
    %         error('aloha module division not consistent')
    %     end
    %     %
    %     if isfield(config,'aloha'),
    %         locid_simul = [locid_simul,'_nlobes_',num2str(config.aloha.nlobes),'_dir_',num2str(config.aloha.dir),'_mode_',num2str(config.aloha.mode),...
    %             '_nrZ0_',num2str(config.nrZ0),locid_simul_aloha];
    %     else
    %         locid_simul = [locid_simul,'_param_',num2str(config.aloha_param),'_dir_',num2str(config.aloha_dir),...
    %             '_nrZ0_',num2str(config.nrZ0),locid_simul_aloha];
    %     end
    % elseif ~isnan(config.bNpar0),
    %     locid_simul = [locid_simul,'_bNpar0',num2str(config.bNpar0),'_bdNpar0_',num2str(config.bdNpar0),'_bPlhtot_',num2str(config.bPlhtot)];
    % end
    % %
    % % tail
    % %
    % if isfield(config,'tail'),
    %     locid_simul_tail = make_tail_simulid_jd(config.tail);
    %     if ~isempty(locid_simul_tail),
    %         locid_simul = [locid_simul,'_',locid_simul_tail];
    %     end
    % end
    % %
    % if ~isempty(locid_simul_end),
    %     locid_simul = [locid_simul,'_',locid_simul_end];
    % end
    %
    % WARNING : use this line to invert spectra
    % locid_simul = [locid_simul,'_inverted'];% Simulation local id (leave empty for standard id)
    %
    if ~iscell(locpath_simul),
        path_simul = [basestr,filesep,shotnum,filesep,locpath_simul];% Simulation path (leave empty for current path)
    else
        path_simul = [locpath_simul{1},basestr,filesep,shotnum,filesep,locpath_simul{2}];% Simulation path (leave empty for current path)
    end    
    %
    shotimes = select_shotimes_jd(['before_luke@',basestr,'_',shotnum,'_'],'.mat',path_simul,shotimes);
    nshots = length(shotimes);
    %
    dkepath = conc_struct_jd(load_structures_yp('dkepath','',''),dkepath);
    %
    % ---- RADIAL TRANSPORT ----
    %
    if transpfaste_in.Dr0 > 0,
        %
        % initialization
        %
        transpfaste.Dr0 = 0;%Core radial diffusion coefficient (m/s)
        transpfaste.pDr = 0;%Coefficient for the Dr radial profile
        transpfaste.Dr_model = 0;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), (2) Energy dependence
        transpfaste.Vr0 = 0;%Core radial pinch coefficient (m/s)
        transpfaste.pVr = 0;%Coefficient for the Vr radial profile
        transpfaste.Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), (2) Energy dependence
        transpfaste.vparmin = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
        transpfaste.norm_ref = 1;%Normalization procedure for the lower limit of the parallel velocity dependence of the radial diffusion and pinch: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
        %
        transpfaste = conc_struct_jd(transpfaste,transpfaste_in);
        %
        transpfaste.id = ['TR_',num2str(transpfaste.Dr_model),'_Dr0_',num2str(transpfaste.Dr0),'_pDr_',num2str(transpfaste.pDr)];
    else
        transpfaste = struct;
    end
    %
    % ---- LH WAVES ----
    %
    wavestructs = {};
    nconf = length(configs);
    %
    for ic = 1:nconf,
        %
        config = configs(ic);
        %
        if isfield(config,'include') & config.include == 0,
            continue
        end
        %
        % vertical positions
        %
        if ~isfield(config,'rZ0'),% rZ0 not specified, calculated from model and number of vertical positions
            if isnan(config.nrZ0),
                opt_ny = 1;% calculate m spectrum
                if real(config.opt_aloha) >= 1,% aloha with two antenna blocks
                    config.nrZ0 = 2;% one ray per antenna block
                else
                    config.nrZ0 = 1;% one ray per antenna
                end
            else
                opt_ny = 0;% do not calculate m spectrum - but poloidally distributed rays
            end
            %
            n2 = fix(config.nrZ0/2);
            if config.type == 1,% waveguide rows at positions [-0.155,-0.075,0.075,0.155]
                rZ0min = 0.035;
                rZ0max = 0.195;
            elseif config.type == 2,% waveguide rows at positions [-0.244,-0.162,-0.080,0.080,0.162,0.244]
                rZ0min = 0.039;
                rZ0max = 0.285;
            else
                error('Antenna configuration not recognized')
            end
            %
            if n2 >= 1,
                rZ0 = linspace(rZ0min,rZ0max,n2+1);
                rZ0 = (rZ0(1:end-1) + rZ0(2:end))/2;
            else
                rZ0 = [];
            end
            %
            if rem(config.nrZ0,2) == 0,%even number of positions
                rZ0 = [-fliplr(rZ0),rZ0];
            else
                rZ0 = [-fliplr(rZ0),0,rZ0];
            end
        else
            rZ0 = config.rZ0;
        end
        %
        locwavestructs = {};
        %
        for ishot = 1:nshots,
            %
            launch = struct;
            %
            if isfield(config,'tail') && ~isempty(fieldnames(config.tail)),
                launch.tail = config.tail;
            end
            %
            if real(config.opt_aloha) == 0, 
                %
                if isfield(config,'bNpar0') && ~any(isnan(config.bNpar0)),
                    launch.bNpar0 = config.bNpar0;
                end
                if isfield(config,'bdNpar0') && ~any(isnan(config.bdNpar0)),
                    launch.bdNpar0 = config.bdNpar0;
                end
                if isfield(config,'bPlhtot') && ~any(isnan(config.bPlhtot)),
                    launch.bPlhtot = config.bPlhtot;
                end
                launch.rZ0 = rZ0;
                %
                launch.id = make_launchid_jd(config);
                %        
                locwavestructs{1}(ishot).launch = launch;
                locwavestructs{1}(ishot).id = ['C3PO_',launch.id];
                %
            elseif real(config.opt_aloha) >= 1, 
                %
                if isfield(config,'locid_aloha'),% one spectrum for both modules
                    %
                    if imag(config.opt_aloha) == 0,% different spectrum for each time
                        aloha_str = ['ALOHA_',basestr,'_',shotnum,'_',shotimes{ishot},config.locid_aloha,'.mat'];
                    else% common spectrum for all times
                        aloha_str = ['ALOHA_',basestr,'_',shotnum,config.locid_aloha,'.mat'];
                    end                
                    %
                    aloha = load([path_simul,config.path_aloha,filesep,aloha_str]);
                    %
                    % process toroidal aloha spectrum for LUKE
                    %
                    if isfield(config,'aloha'),
                        [bNtor0,bdNtor0,bPlhtor,param_out] = proc_aloha_spec_jd(aloha.antenna.nz,NaN,real(aloha.antenna.dP_nz),1,config.aloha(1),0,config.aloha(1).display_mode);
                    else
                        if isfield(config,'aloha_dir'),
                            Pin = 1 + config.aloha_dir*1i;
                        else
                            Pin = 1;
                        end
                        %
                        [bNtor0,bdNtor0,bPlhtor,param_out] = proc_aloha_spec_jd(aloha.antenna.nz,NaN,real(aloha.antenna.dP_nz),Pin,config.aloha_param(1),0,0);                
                    end
                    %
                    config.aloha = conc_struct_jd(config.aloha,param_out);
                    %
                    % initialize parameters
                    %
                    launch.id = make_launchid_jd(config);
                    %
                    if opt_ny == 1,% process poloidal aloha spectrum for LUKE
                        if isfield(config,'aloha'),
                            [bNpol0,bdNpol0,bPlhpol] = proc_aloha_spec_jd(aloha.antenna.ny,NaN,sum(real(aloha.antenna.dP.')),1,config.aloha(2),0,config.aloha(2).display_mode);     
                        else
                            [bNpol0,bdNpol0,bPlhpol] = proc_aloha_spec_jd(aloha.antenna.ny,NaN,sum(real(aloha.antenna.dP.')),1,config.aloha_param(2),0,0);     
                        end
                    else
                        bNpol0 = 0;
                        %
                        bdNpol0 = 0;
                        %
                        bPlhpol = 1;                
                    end
                    %
                    % Since N// is not strictly speaking Ntor, we make it imaginary to notify init_RT_jd. In this case, the real part is Npol
                    %
                    launch.bNpar0 = [];
                    %
                    launch.bdNpar0 = [];
                    %
                    launch.bPlhtot = [];
                    %
                    for iy = 1:length(bNtor0),
                        launch.bNpar0 = [launch.bNpar0,1i*bNtor0(iy) + bNpol0];
                        %
                        % the combined spectral width effect is not yet implemented
                        % (TODO) see how to include it, maybe in init_RT_jd
                        % watch for possible conflicts with square spectrum prescriptions
                        %
        %                 launch.bdNpar0 = [launch.bdNpar0,1i*bdNtor0(iy) + bdNpol0];
                        %
                        launch.bdNpar0 = [launch.bdNpar0,bdNtor0(iy)*ones(1,length(bdNpol0))];
                        %
                        launch.bPlhtot = [launch.bPlhtot,bPlhtor(iy)*bPlhpol];
                    end
                    %
                    % load METIS data for sign and/or power correction
                    %
                    metisdata = load([path_simul,filesep,'before_luke@',basestr,'_',shotnum,'_',shotimes{ishot},'.mat']);
                    %
                    %launch.bNpar0 = launch.bNpar0*(-metisdata.option.signe);% case of N//
                    launch.bNpar0 = launch.bNpar0*(-sign(metisdata.equil.psi_apRp(end)));% case of Npol +iNtor
                    launch.aloha = aloha;
                    %
                    if nconf == 1 && real(config.opt_aloha) == 1,% power from metis
                        %
                        plh = metisdata.cons.plh;% power divided into two antennas (upper and lower launcher)
                        %
                        launch.bPlhtot = launch.bPlhtot*plh;%/sum(launch.bPlhtot)
                        %
                    else % power from database
                        %
                        [tplh,tbase] = tsbase(str2double(shotnum),'GPHYB');
                        xplh = 1e6*interp1(tbase(:,1),tplh,str2double(shotimes{ishot}));
                        if any(xplh < 0) || (real(config.opt_aloha) == 2 && abs(xplh(end) - metisdata.cons.plh)/metisdata.cons.plh > 0.01),
                            disp('warning : total power from database is different from metis cons')
                            keyboard
                        end
                        %
                        plh = xplh(ic);
                        %
                        launch.bPlhtot = launch.bPlhtot*plh;%/sum(launch.bPlhtot)
                        %
                    end
                    %
                    locwavestructs{1}(ishot).launch = launch;
                    %
                    locwavestructs{1}(ishot).id = ['C3PO_',launch.id];
                    %
                    locwavestructs{1}(ishot).launch.rZ0 = rZ0;
                    %
                elseif isfield(config,'locid_aloha_b') && isfield(config,'locid_aloha_h'),% one spectrum for each modules
                    %
                    if imag(config.opt_aloha) == 0,% different spectrum for each time
                        aloha_str_b = ['ALOHA_',basestr,'_',shotnum,'_',shotimes{ishot},config.locid_aloha_b,'.mat'];
                        aloha_str_h = ['ALOHA_',basestr,'_',shotnum,'_',shotimes{ishot},config.locid_aloha_h,'.mat'];
                    else% common spectrum for all times
                        aloha_str_b = ['ALOHA_',basestr,'_',shotnum,config.locid_aloha_b,'.mat'];
                        aloha_str_h = ['ALOHA_',basestr,'_',shotnum,config.locid_aloha_h,'.mat'];
                    end                
                    %
                    aloha_b = load([path_simul,config.path_aloha,filesep,aloha_str_b]);
                    aloha_h = load([path_simul,config.path_aloha,filesep,aloha_str_h]);
                    %
                    % initialize parameters
                    %
                    launch_b = launch;
                    launch_h = launch;
                    %
                    % process toroidal aloha spectrum for LUKE
                    %
                    if isfield(config,'aloha'),
                        [bNtor0_b,bdNtor0_b,bPlhtor_b,param_out_b] = proc_aloha_spec_jd(aloha_b.antenna.nz,NaN,real(aloha_b.antenna.dP_nz),1,config.aloha(1),0,config.aloha(1).display_mode);
                        [bNtor0_h,bdNtor0_h,bPlhtor_h,param_out_h] = proc_aloha_spec_jd(aloha_h.antenna.nz,NaN,real(aloha_h.antenna.dP_nz),1,config.aloha(1),0,config.aloha(1).display_mode);
                    else
                        if isfield(config,'aloha_dir'),
                            Pin = 1 + config.aloha_dir*1i;
                        else
                            Pin = 1;
                        end
                        %
                        [bNtor0_b,bdNtor0_b,bPlhtor_b,param_out_b] = proc_aloha_spec_jd(aloha_b.antenna.nz,NaN,real(aloha_b.antenna.dP_nz),Pin,config.aloha_param(1),0,0);
                        [bNtor0_h,bdNtor0_h,bPlhtor_h,param_out_h] = proc_aloha_spec_jd(aloha_h.antenna.nz,NaN,real(aloha_h.antenna.dP_nz),Pin,config.aloha_param(1),0,0);                
                    end
                    %
                    config_b = rmfield(config,{'locid_aloha_b','locid_aloha_h'});
                    config_h = rmfield(config,{'locid_aloha_b','locid_aloha_h'});                 
                    %
                    config_b.locid_aloha = config.locid_aloha_b;
                    config_h.locid_aloha = config.locid_aloha_h;
                    %
                    config_b.aloha = conc_struct_jd(config.aloha,param_out_b);
                    config_h.aloha = conc_struct_jd(config.aloha,param_out_h);
                    %
                    % initialize parameters
                    %
                    launch_b.id = make_launchid_jd(config_b);
                    launch_h.id = make_launchid_jd(config_h);
                    %
                    if opt_ny == 1,% process poloidal aloha spectrum for LUKE
                        if isfield(config,'aloha'),
                            [bNpol0_b,bdNpol0_b,bPlhpol_b] = proc_aloha_spec_jd(aloha_b.antenna.ny,NaN,sum(real(aloha_b.antenna.dP.')),1,config.aloha(2),0,config.aloha(2).display_mode);
                            [bNpol0_h,bdNpol0_h,bPlhpol_h] = proc_aloha_spec_jd(aloha_h.antenna.ny,NaN,sum(real(aloha_h.antenna.dP.')),1,config.aloha(2),0,config.aloha(2).display_mode);     
                        else
                            [bNpol0_b,bdNpol0_b,bPlhpol_b] = proc_aloha_spec_jd(aloha_b.antenna.ny,NaN,sum(real(aloha_b.antenna.dP.')),1,config.aloha_param(2),0,0);
                            [bNpol0_h,bdNpol0_h,bPlhpol_h] = proc_aloha_spec_jd(aloha_h.antenna.ny,NaN,sum(real(aloha_h.antenna.dP.')),1,config.aloha_param(2),0,0);     
                        end
                    else
                        bNpol0_b = 0;
                        bNpol0_h = 0;
                        %
                        bdNpol0_b = 0;
                        bdNpol0_h = 0;
                        %
                        bPlhpol_b = 1;
                        bPlhpol_h = 1;                
                    end
                    %
                    % Since N// is not strictly speaking Ntor, we make it imaginary to notify init_RT_jd. In this case, the real part is Npol
                    %
                    launch_b.bNpar0 = [];
                    launch_h.bNpar0 = [];
                    %
                    launch_b.bdNpar0 = [];
                    launch_h.bdNpar0 = [];
                    %
                    launch_b.bPlhtot = [];
                    launch_h.bPlhtot = [];
                    %
                    for iy = 1:length(bNtor0_b),
                        launch_b.bNpar0 = [launch_b.bNpar0,1i*bNtor0_b(iy) + bNpol0_b];
                        launch_h.bNpar0 = [launch_h.bNpar0,1i*bNtor0_h(iy) + bNpol0_h];
                        %
                        % the combined spectral width effect is not yet implemented
                        % (TODO) see how to include it, maybe in init_RT_jd
                        % watch for possible conflicts with square spectrum prescriptions
                        %
        %                 launch_b.bdNpar0 = [launch_b.bdNpar0,1i*bdNtor0_b(iy) + bdNpol0_b];
        %                 launch_h.bdNpar0 = [launch_h.bdNpar0,1i*bdNtor0_h(iy) + bdNpol0_h];
                        %
                        launch_b.bdNpar0 = [launch_b.bdNpar0,bdNtor0_b(iy)*ones(1,length(bdNpol0_b))];
                        launch_h.bdNpar0 = [launch_h.bdNpar0,bdNtor0_h(iy)*ones(1,length(bdNpol0_h))];
                        %
                        launch_b.bPlhtot = [launch_b.bPlhtot,bPlhtor_b(iy)*bPlhpol_b];
                        launch_h.bPlhtot = [launch_h.bPlhtot,bPlhtor_h(iy)*bPlhpol_h];
                    end
                    %
                    % load METIS data for sign and/or power correction
                    %
                    metisdata = load([path_simul,filesep,'before_luke@',basestr,'_',shotnum,'_',shotimes{ishot},'.mat']);
                    %
                    %launch_b.bNpar0 = launch_b.bNpar0*(-metisdata.option.signe);% case of N//
                    launch_b.bNpar0 = launch_b.bNpar0*(-sign(metisdata.equil.psi_apRp(end)));% case of Npol +iNtor
                    launch_b.aloha = aloha_b;
                    %
                    %launch_h.bNpar0 = launch_h.bNpar0*(-metisdata.option.signe);% case of N//
                    launch_h.bNpar0 = launch_h.bNpar0*(-sign(metisdata.equil.psi_apRp(end)));% case of Npol +iNtor
                    launch_h.aloha = aloha_h;
                    %
                    if nconf == 1 && real(config.opt_aloha) == 1,% power from metis
                        %
                        plh = metisdata.cons.plh/2;% power divided into two antennas (upper and lower launcher)
                        %
                        launch_b.bPlhtot = launch_b.bPlhtot*plh;%/sum(launch_b.bPlhtot)
                        launch_h.bPlhtot = launch_h.bPlhtot*plh;%/sum(launch_h.bPlhtot)
                        %
                    else % power from database
                        %
                        [tplh,tbase] = tsbase(str2double(shotnum),'GPHYB');
                        xplh = 1e6*interp1(tbase(:,1),tplh,str2double(shotimes{ishot}));
                        if real(config.opt_aloha) == 2 && abs(xplh(end) - metisdata.cons.plh)/metisdata.cons.plh > 0.01,
                            disp('warning : total power from database is different from metis cons')
                            keyboard
                        end
                        %
                        plh = xplh(ic)/2;
                        %
                        launch_b.bPlhtot = launch_b.bPlhtot*plh;%/sum(launch_b.bPlhtot)
                        launch_h.bPlhtot = launch_h.bPlhtot*plh;%/sum(launch_h.bPlhtot)
                        %
                    end
                    %
                    locwavestructs{1}(ishot).launch = launch_b;
                    locwavestructs{2}(ishot).launch = launch_h;
                    %
                    locwavestructs{1}(ishot).id = ['C3PO_',launch_b.id];
                    locwavestructs{2}(ishot).id = ['C3PO_',launch_h.id];
                    %
                    locwavestructs{1}(ishot).launch.rZ0 = rZ0(rZ0 <= 0);
                    locwavestructs{2}(ishot).launch.rZ0 = rZ0(rZ0 >= 0);
                    %
                else
                    %
                    error('aloha module division not consistent')
                    %
                end
            end
            %
        end
        %
        wavestructs = [wavestructs,locwavestructs];
        %
    end
    %
    fnames = fieldnames(waveparam);
    nfields = length(fnames);
    for ifield = 1:nfields,
        locid_simul = [locid_simul,'_',fnames{ifield},'_',num2str(waveparam.(fnames{ifield}))];
    end
    %
    for iw = 1:length(wavestructs),
        for ishot = 1:nshots,
            wavestructs{iw}(ishot).rayparam = rayparam;
            wavestructs{iw}(ishot).waveparam = waveparam;
            wavestructs{iw}(ishot).C3POparam = C3POparam;
        end
    end
    %
    % WARNING : use this line to invert spectra (one wave only)
    %wavestructs{1} = fliplr(wavestructs{1});
    %
    % ===========================
    %
    % start rundke_metis function
    %
    rundke_metis(path_simul,locid_simul,basestr,shotnum,shotimes,opt,dkepath,wavestructs,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,0,scheduler_run_lukert)
    %
end
%
function id_launch = make_launchid_jd(config)
    %
    % launch id from config
    %
    id_launch = 'LH';
    %
    if isfield(config,'id') && ~isempty(config.id),% case imposed from config
        id_launch = [id_launch,'_',config.id];
        return
    end
    %
    % aloha
    %
    %id_launch = [id_launch,'_aloha_',num2str(config.opt_aloha)];
    %
    if isfield(config,'locid'),
        id_launch = [id_launch,'_',config.locid];
    elseif real(config.opt_aloha) >= 1,
        %
        id_launch = [id_launch,'_nr_',num2str(config.nrZ0),'_nl_',num2str(config.aloha.nlobes),'_dir_',num2str(config.aloha.dir),'_md_',num2str(config.aloha.mode),...
            config.locid_aloha];
        %
    elseif ~isnan(config.bNpar0),
        bNpar0str = '';
        bdNpar0str = '';
        bPlhtotstr = '';
        for ib = 1:length(config.bNpar0),
            bNpar0str = [bNpar0str,'_',num2str(config.bNpar0(ib))];
            bdNpar0str = [bdNpar0str,'_',num2str(config.bdNpar0(ib))];
            bPlhtotstr = [bPlhtotstr,'_',num2str(config.bPlhtot(ib)/1e6)];
        end
        %
        id_launch = [id_launch,'_N0',bNpar0str,'_dN0',bdNpar0str,'_P',bPlhtotstr];
    end
    %
    % tail
    %
    if isfield(config,'tail'),
        locid_simul_tail = make_tail_simulid_jd(config.tail);
        if ~isempty(locid_simul_tail),
            id_launch = [id_launch,'_',locid_simul_tail];
        end
    end
    %
end


