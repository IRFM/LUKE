function [waves_euitm] = itm2luke(euitmshot,equil_euitm,coreprof_euitm,antennas_euitm,ver_mds,opts)
%LUKE -  Interface for running C3PO/LUKE using euitm data
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin < 5, error('Not enough input arguments in itm2luke.m');end
%
% LUKE post-processing options
%
opt.rho = 'g';
opt.nr_dep = 0;
opt.peakmode = 0;
opt.peak = 'n';
opt.wave = 'n';
opt.blist = '';
opt.diaryname = '';
opt.spec = 0;
%
p_opt = -1;%Printing options
%
% User specific C3PO/LUKEparameters
%
ray_display = 1;%for display ray propagation (0,1,2)
display_mode = 2;%display results 'equilibrium, Fokker-Planck (0,1,2)
ir_display = -1;%proc_luke_jd display option (-1,0,1,2)
%
dataname = dataname_ITM(euitmshot.machine,euitmshot.numshot,euitmshot.numrun_in,euitmshot.timeslice,euitmshot.time_interp);   
filename = [pwd,'/LUKE_RESULTS_',dataname,'.mat'];
%
if ~exist(filename,'file'),
    %
    [dkepath,dkedisplay] = load_structures_yp('dkepath','','','dkedisplay','NO_DISPLAY','');
    %
    profilestr = dkepath.profilestr;
    %
    disp('WARNING: dkeparam for EC wave only. LH case not yet implemented');
    dkeparam = load_structures_yp('dkeparam','EC_RT','');%yet EC wave only
    %
    if isfield(opts,'opt_struct'),
        dkeparam.opt_struct = opts.opt_struct;
    end
    %
    if isfield(opts,'rho_S'),dkeparam.rho_S = opts.rho_S;end
    %
    %TODO: implement dkeparam for LH or mixed EC+LH 
    %
    disp('----------------------------------------------------------');
    disp('Simulation status');
    disp('----------------------------------------------------------');
    %
    if exist(['LUKE_RESULTS_',dataname,'.mat'],'file'),
        load(['LUKE_RESULTS_',dataname,'.mat'])
    else
        if nargin == 5,
            %
            dkepath.clustermode.run_lukert.scheduler.remnum = opts.remnum;% remote profile number. Use 0 for local sequential calculations
            dkepath.clustermode.run_lukert.scheduler.mode = opts.remmdce;%distribution mode of LUKE on the remote machine
            dkepath.clustermode.run_lukert.scheduler.remtimout = opts.remtimout;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
            dkepath.clustermode.run_lukert.scheduler.rempause = opts.rempause;% pause between job checks (in minutes) (only for remtimout > 0)
            dkepath.clustermode.run_lukert.scheduler.debugmode = opts.remdebugmode;% debug mode (0) off (1) on
            dkepath.clustermode.run_lukert.scheduler.clean = opts.remclean;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
            %dkepath.clustermode.run_lukert.scheduler.memory = opts.luke_memory;% job memory in mb
            %dkepath.clustermode.run_lukert.scheduler.walltime = opts.luke_walltime;%job walltime in hours
            dkepath.clustermode.run_lukert.scheduler.enforce = opts.enforce;% exit if remote calculation failed 
            if opts.opt.save,% (1): save LUKE_RESULTS or return error (0): return results or error
                dkepath.clustermode.run_lukert.scheduler.localdatadir = opts.opt.localdatadir;
                if exist(opts.opt.localdatadir,'dir') && length(dir(opts.opt.localdatadir)) > 2,
                    delete([opts.opt.localdatadir,'*']);
                end
            end
            %
            optluke.fields = opts.opt.fields;% selected fields in returned lukestructs. Use NaN for all fields
            optluke.backup = opts.opt.backup;% (1) save fluctuation time steps (0) do not save
            optluke.waves = opts.opt.waves;%(-1) waves are not saved in "wave_results/" and not stored in dke_out. In this case, C3PO must be rerun to see the rays (0) waves are stored in dke_out and saved in LUKE_RESULTS, (1) waves are saved in "wave_results/" but not stored in dke_out
            optluke.saveinputs = opts.opt.saveinputs;% (1) save input structures in .mat files before starting (0) do not save
            %
        end
        %
        waves = '';
        ohm = '';
        transpfaste = '';
        ripple = '';
        distrib = '';
        %
        for it = 1:length(equil_euitm),%the number if equils is the number of timeslice
            %
            if it == 1,
                equil = process_euitm_dataequil(ver_mds,equil_euitm{it},coreprof_euitm{it},display_mode);%Data conversion between CPO and LUKE format
            else
                equil_euitm1 = rmfield(equil_euitm{it-1},'time');
                equil_euitm2 = rmfield(equil_euitm{it},'time');
                %
                if comp_struct_jd(equil_euitm1,equil_euitm2,0) == 0,
                    equil = process_euitm_dataequil(ver_mds,equil_euitm{it},coreprof_euitm{it},display_mode);%Data conversion between CPO and LUKE format
                end
            end
            %
            launchs = CPO2LUKEstruct_yp(ver_mds,'antennas',antennas_euitm{it});%Data conversion between CPO and LUKE format
            %
            iw = 1;
            %
            for jw = 1:length(launchs),
                %
                % Conversion to the generalized axial coordinate system
                %
                launchs{jw}.yx_L = launchs{jw}.yR_L - equil.Rp;
                launchs{jw}.yy_L = launchs{jw}.yZ_L - equil.Zp;
                launchs{jw}.yz_L = launchs{jw}.yphi_L*equil.Rp;    
                %
                if ray_display,%launching direction
                    [sysh,sysy,syx,syy,syz,syalpha,sybeta,sygx,sygy,sygz] = raypath_prop_jd(equil.Rp,launchs{jw}.yx_L,launchs{jw}.yy_L,launchs{jw}.yz_L,launchs{jw}.yalpha_L,launchs{jw}.ybeta_L,linspace(0,10,1000));
                    %
                    %equilibrium_jd(equil,'',3);
                    figure(1)
                    hold on
                    graph1D_jd(syx,syy,0,0,'','','',NaN,'','','-','non','k',2);%plot ray trajectory
                end
                %
                if launchs{jw}.yP_L > 0,%calculation done only for rays carrying EC power 
                    %
                    if strcmp(launchs{jw}.type,'EC'),
                        data = load([dkepath.luke_root,'Project_DKE/Database/WAVE_files/C3POPARAM_EC.mat']);%Generic parameters for EC wave calculations
                    elseif strcmp(launchs{jw}.type,'LH'),
                        data = load([dkepath.luke_root,'Project_DKE/Database/WAVE_files/C3POPARAM_LH.mat']);%Generic parameters for LH wave calculations
                    end
                    %
                    wavestructs{iw}.id = launchs{jw}.id;
                    wavestructs{iw}.launch = launchs{jw};
                    wavestructs{iw}.waveparam = conc_struct_jd(wavestructs{iw},data.waveparam);
                    wavestructs{iw}.fitequilparam = conc_struct_jd(wavestructs{iw},data.fitparam);
                    wavestructs{iw}.rayparam = conc_struct_jd(wavestructs{iw},data.rayparam);
                    wavestructs{iw}.C3POparam = conc_struct_jd(wavestructs{iw},data.C3POparam);
                    wavestructs{iw}.wavesolver = 'C3PO';
                    wavestructs{iw}.equil_id = equil.id;       
                    %
                    % Specific parameters for EC wave calculations
                    %
                    wavestructs{iw}.raydisplay.ray = ray_display;%for display ray propagation
                    wavestructs{iw}.raydisplay.equilibrium = 0;
                    wavestructs{iw}.raydisplay.p_opt = -1;%Printing or saving option of the figures
                    %
                    wavestructs{iw} = make_wavert_cronos(launchs{jw},0);
                    %
                    wavestructs{iw}.waveparam.dsmin = 0;
                    %
                    wavestructs{iw}.fitequilparam.method = 'spline';
                    %
                    if wavestructs{iw}.launch.yP_L == 0, 
                        wavestructs{iw}.launch.yP_L = eps;%to avoid interpolation problems
                    end
                    %
                    info_dke_yp(4,['time slice: ',int2str(it),' - wave : ',int2str(jw),' type : ',launchs{jw}.type,' used. Power = ',num2str(launchs{jw}.yP_L),' (W)'])
                    %
                    iw = iw + 1;
                else
                    info_dke_yp(4,['time slice: ',int2str(it),' - wave : ',int2str(jw),' type : ',launchs{jw}.type,' removed. No power'])
                end     
            end
            %
            lukestructs{it} = struct;
            %
            lukestructs{it}.simul.id_simul = equil.id;
            lukestructs{it}.simul.path = '';
            lukestructs{it}.dkeparam = dkeparam;
            lukestructs{it}.dkepath = dkepath;
            lukestructs{it}.dkedisplay = dkedisplay;
            lukestructs{it}.equil = equil;
            lukestructs{it}.waves = waves;
            lukestructs{it}.wavestructs = wavestructs;
            lukestructs{it}.ohm = ohm;
            lukestructs{it}.transpfaste = transpfaste;
            lukestructs{it}.ripple = ripple;
            lukestructs{it}.Zf0_interp = distrib;
            %
            if nargin == 5,
                lukestructs{it}.opt = optluke;
            end
            %
            if exist('wavestructs'),clear wavestructs;end
            %
        end
    end
else
    load(filename,'lukestructs','dkepath','profilestr');
end
%
%--------------------------- Run C3PO/LUKE --------------------------- 
%
disp('---------------------------------------------')
disp(['--> ',profilestr{opts.remnum}]);
disp('---------------------------------------------')
%
lukestructs = run_lukert(lukestructs,dkepath);
%
flag_running = false(1,length(lukestructs));
%
for it = 1:length(lukestructs),
    if isfield(lukestructs{it},'job'),flag_running(it) = true;end
end
%
waves_euitm = [];
%
save(['LUKE_RESULTS_',dataname,'.mat'],'lukestructs','dkepath','profilestr','ver_mds');
%
if sum(flag_running) > 0,
    %
    disp(['----> ',int2str(length(lukestructs)-sum(flag_running)),'/',int2str(length(lukestructs)),' calculations done.'])
    %
    return
else
    %
    disp('----> All calculations are done.')
    %
    for it = 1:length(lukestructs),
        Znorm = lukestructs{it}.output.Znorm;
        Zcurr = lukestructs{it}.output.Zcurr;
        ZP0 = lukestructs{it}.output.ZP0;
        dke_out = lukestructs{it}.output.dke_out;
        radialDKE = lukestructs{it}.output.radialDKE;
        equilDKE = lukestructs{it}.output.equilDKE;
        equil = lukestructs{it}.output.dke_out.equil;
        momentumDKE = lukestructs{it}.output.momentumDKE;
        gridDKE = lukestructs{it}.output.gridDKE;
        Zmomcoef = lukestructs{it}.output.Zmomcoef;
        Zbouncecoef = lukestructs{it}.output.Zbouncecoef;
        Zmripple = lukestructs{it}.output.Zmripple;
        mksa = lukestructs{it}.output.mksa;
        XXsinksource = lukestructs{it}.output.XXsinksource;
        %
        for iray = 1:length(dke_out.waves{1}.rays),
            if ~isfield(dke_out.waves{1}.rays{iray},'mask_p') | ~isfield(dke_out.waves{1}.rays{iray},'mask_m');
                dke_out.waves{1}.rays{iray}.mask_p = zeros(size(dke_out.waves{1}.rays{iray}.ss));
                dke_out.waves{1}.rays{iray}.mask_m = ones(size(dke_out.waves{1}.rays{iray}.ss));
            end        
        end        
        %        
        dataname_out = dataname_ITM(euitmshot.machine,euitmshot.numshot,euitmshot.numrun_in,euitmshot.timeslice,euitmshot.time_interp,euitmshot.numrun_out,euitmshot.occurrence_out);   
        %
        temp_filename = ['temp_EUITM_',dataname_out,'.mat'];
        %  
        save(temp_filename,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equil','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource','dkepath');
        %
        rawdata = load(temp_filename);
        rawdata.dkepath.profilestr = profilestr;
        %
        procdata{it} = proc_luke_jd(rawdata,ir_display,p_opt,0.1,NaN,'',opt);
        %
        waves_euitm = LUKEstruct2CPO(euitmshot.machine,euitmshot.numshot,euitmshot.numrun_out,euitmshot.timeslice,'waves',rawdata,procdata{it},waves_euitm);
        %
        delete(temp_filename);        
        %
    end
    %
    save(['LUKE_RESULTS_',dataname,'.mat'],'procdata','-append');
end

