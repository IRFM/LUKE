function [waves_euitm] = itm2luke(numshot,numrun_out,timeslice,equil_euitm,coreprof_euitm,antennas_euitm,opts)
%LUKE -  Interface for running C3PO/LUKE using euitm data
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin < 6, error('Not enough input arguments in itm2luke.m');end
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
ray_display = 0;%for display ray propagation (0,1,2)
display_mode = 2;%display results 'equilibrium, Fokker-Planck (0,1,2)
ir_display = -1;%proc_luke_jd display option (-1,0,1,2)
%
equil = process_euitm_dataequil(equil_euitm,coreprof_euitm,display_mode);%Data conversion between CPO and LUKE format
launchs = CPO2LUKEstruct_yp('antennas',antennas_euitm);%Data conversion between CPO and LUKE format
%
[dkepath,dkedisplay] = load_structures_yp('dkepath','','','dkedisplay','NO_DISPLAY','');
%
wavestructs = cell(1,length(launchs));
%
for iw = 1:length(launchs),
    %
    if ray_display,%launching direction
    	[sysh,sysZ,syR,syZ,syphi,syalpha,sybeta,sygR,sygZ,sygphi] = raypath_prop_jd(launchs{iw}.yR_L,launchs{iw}.yZ_L,launchs{iw}.yphi_L,launchs{iw}.yalpha_L,launchs{iw}.ybeta_L,linspace(0,10,1000));
    	%
    	equilibrium_jd(equil,'',3);
    	hold on
    	graph1D_jd(syR-equil.Rp,syZ-equil.Zp,0,0,'','','',NaN,'','','-','non','k',2);%plot ray trajectory
    end
    %
    if 1,
        dkeparam = load_structures_yp('dkeparam','EC_RT','');%yet EC wave only
    	data = load([dkepath.luke_root,'Project_DKE/Database/WAVE_files/C3POPARAM_EC.mat']);%Generic parameters for EC wave calculations
    end
    %
    wavestructs{iw}.id = launchs{iw}.id;
    wavestructs{iw}.launch = launchs{iw};
    wavestructs{iw}.waveparam = conc_struct_jd(wavestructs{iw},data.waveparam),
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
    wavestructs{iw} = make_wavert_cronos(launchs{iw},0);
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
end
%
id_simul = equil.id;
%
%--------------------------- Run C3PO/LUKE --------------------------- 
%
if nargin == 7,
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
lukestructs = struct;
lukestructs.simul.id_simul = id_simul;
lukestructs.simul.path = '';
lukestructs.dkeparam = dkeparam;
lukestructs.dkepath = dkepath;
lukestructs.dkedisplay = dkedisplay;
lukestructs.equil = equil;
lukestructs.waves = waves;
lukestructs.wavestructs = wavestructs;
lukestructs.ohm = ohm;
lukestructs.transpfaste = transpfaste;
lukestructs.ripple = ripple;
lukestructs.Zf0_interp = distrib;
if nargin == 7,
    lukestructs.opt = optluke;
end
%
lukestructs = run_lukert(lukestructs,dkepath);
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
filename = ['EC17_benchmark_',equil.id,'_',id_simul,'.mat'];
save(filename,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equil','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource','dkepath');
%
rawdata = load(filename);
%
procdata = proc_luke_jd(rawdata,ir_display,p_opt,0.1,NaN,'',opt);
%
waves_euitm = LUKEstruct2CPO(numshot,numrun_out,timeslice,'waves',rawdata,procdata,waves_euitm);
%
delete(filename);




