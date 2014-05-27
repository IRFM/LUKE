function [waves_euitm] = itm2luke(euitmshot,equil_euitm,coreprof_euitm,antennas_euitm,opts)
%LUKE -  Interface for running C3PO/LUKE using euitm data
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin < 4, error('Not enough input arguments in itm2luke.m');end
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
[dkepath,dkedisplay] = load_structures_yp('dkepath','','','dkedisplay','NO_DISPLAY','');
%
dataname = dataname_ITM(euitmshot.numshot,euitmshot.numrun_in,euitmshot.timeslice,euitmshot.time_interp);   
%
if exist(['LUKE_RESULTS_',dataname,'.mat'],'file'),
    load(['LUKE_RESULTS_',dataname,'.mat'])
else
    if nargin == 5,
        dkepath.remnum = opts.remnum;% remote profile number. Use 0 for local sequential calculations
        dkepath.remtimout = opts.remtimout;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
        dkepath.rempause = opts.rempause;% pause between job checks (in minutes) (only for remtimout > 0)
        dkepath.debugmode = opts.debugmode;% debug mode (0) off (1) on
        dkepath.clean = opts.clean;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
        optluke.save = opts.save;% (1): save LUKE_RESULTS or return error (0): return results or error
        optluke.fields = opts.fields;% selected fields in returned lukestructs. Use NaN for all fields
        optluke.backup = opts.backup;% (1) save fluctuation time steps (0) do not save
        optluke.waves = opts.waves;% (1) save waves at each time step (0) do not save
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
            equil = process_euitm_dataequil(equil_euitm{it},coreprof_euitm{it},display_mode);%Data conversion between CPO and LUKE format
        else
            equil_euitm1 = rmfield(equil_euitm{it-1},'time');
            equil_euitm2 = rmfield(equil_euitm{it},'time');
            %
            if comp_struct_jd(equil_euitm1,equil_euitm2,0) == 0,
                equil = process_euitm_dataequil(equil_euitm{it},coreprof_euitm{it},display_mode);%Data conversion between CPO and LUKE format
            end
        end
        %
        launchs = CPO2LUKEstruct_yp('antennas',antennas_euitm{it});%Data conversion between CPO and LUKE format
        %
        wavestructs = cell(1,length(launchs));%multiple waves at each time slice
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
            if 1,
                dkeparam = load_structures_yp('dkeparam','EC_RT','');%yet EC wave only
                data = load([dkepath.luke_root,'Project_DKE/Database/WAVE_files/C3POPARAM_EC.mat']);%Generic parameters for EC wave calculations
            end
            %
            if launchs{iw}.yP_L > 0,%calculation done only for rays carrying EC power 
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
                info_dke_yp(4,['wave : ',int2str(iw),' type :',launchs{iw}.type])
                %
                iw = iw + 1;
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
    end
end
%
%--------------------------- Run C3PO/LUKE --------------------------- 
%
keyboard
%
flag_running = false(1,length(lukestructs));
%
for it = 1:length(lukestructs),
    lukestructs{it} = run_lukert(lukestructs{it},dkepath);
    if isfield(lukestructs{remnum},'job'),
        flag_running(remnum) = true;
    end
end

%
for it = 1:length(lukestructs),
    if isfield(lukestructs{remnum},'job'),
        flag_running(remnum) = true;
    end
end





%
%--------------------------- WRITE CPO's' into ITM database ------------------%
waves_euitm = [];
%
Znorm = lukestructs.output.Znorm;
Zcurr = lukestructs.output.Zcurr;
ZP0 = lukestructs.output.ZP0;
dke_out = lukestructs.output.dke_out;
radialDKE = lukestructs.output.radialDKE;
equilDKE = lukestructs.output.equilDKE;
momentumDKE = lukestructs.output.momentumDKE;
gridDKE = lukestructs.output.gridDKE;
Zmomcoef = lukestructs.output.Zmomcoef;
Zbouncecoef = lukestructs.output.Zbouncecoef;
Zmripple = lukestructs.output.Zmripple;
mksa = lukestructs.output.mksa;
XXsinksource = lukestructs.output.XXsinksource;
%
for iray = 1:length(dke_out.waves{1}.rays),
    if ~isfield(dke_out.waves{1}.rays{iray},'mask_p') | ~isfield(dke_out.waves{1}.rays{iray},'mask_m');
        dke_out.waves{1}.rays{iray}.mask_p = zeros(size(dke_out.waves{1}.rays{iray}.ss));
        dke_out.waves{1}.rays{iray}.mask_m = ones(size(dke_out.waves{1}.rays{iray}.ss));
    end
end
%
numshot,numrun_out,timeslice
dataname = dataname_ITM(shot,run,timeslice,time_interp,run_out,occurrence_out);

dataname = dataname_ITM(numshot,numrun_in,timeslice,time_interp);
%
filename = ['EC17_benchmark_',dataname,'.mat'];
%
save(filename,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equil','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource','dkepath');
%
rawdata = load(filename);
%
procdata = proc_luke_jd(rawdata,ir_display,p_opt,0.1,NaN,'',opt);
%
waves_euitm = LUKEstruct2CPO(numshot,numrun_out,timeslice,'waves',rawdata,procdata,waves_euitm);
%
delete(filename);




