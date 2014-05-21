function [waves] = itm2luke(equil_euitm,coreprof_euitm,antennas_euitm)


if nargin < 3, error('Not enough input arguments in itm2luke.m.');end
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
        dkeparam = load_structures_yp('dkeparam','EC_RT','');
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
id_simul = ['timeslice_',equil.id];
%
luke_in.id_simul = id_simul;
luke_in.dkeparam = dkeparam;
luke_in.equil = equil;
luke_in.dkedisplay = dkedisplay;
luke_in.wavestructs = wavestructs;
luke_in.waves = '';
luke_in.ohm = '';
luke_in.transpfaste = '';
luke_in.ripple = '';
%
%--------------------------- Run C3PO/LUKE --------------------------- 
%

if isempty(remotename),
	[luke_out.Znorm,luke_out.Zcurr,luke_out.ZP0,luke_out.dke_out,luke_out.radialDKE,luke_out.equilDKE,luke_out.momentumDKE,luke_out.gridDKE,luke_out.Zmomcoef,luke_out.Zbouncecoef,luke_out.Zmripple,luke_out.mksa,luke_out.XXsinksource] = run_lukert(luke_in.id_simul,luke_in.wavestructs,luke_in.waves,[],luke_in.dkeparam.rho_S,dkepath,luke_in.equil,luke_in.dkeparam,luke_in.dkedisplay,luke_in.ohm,luke_in.transpfaste,luke_in.ripple,[],[]);
else
    [flag,remote] = check_remote_yp(dkepath,remotename);
	%
	if ~flag,%local calculations
		[luke_out.Znorm,luke_out.Zcurr,luke_out.ZP0,luke_out.dke_out,luke_out.radialDKE,luke_out.equilDKE,luke_out.momentumDKE,luke_out.gridDKE,luke_out.Zmomcoef,luke_out.Zbouncecoef,luke_out.Zmripple,luke_out.mksa,luke_out.XXsinksource] = run_lukert(luke_in.id_simul,luke_in.wavestructs,luke_in.waves,[],luke_in.dkeparam.rho_S,dkepath,luke_in.equil,luke_in.dkeparam,luke_in.dkedisplay,luke_in.ohm,luke_in.transpfaste,luke_in.ripple,[],[]);
	else
		[tid,jid] = runluke_remote_jd(luke_in,remote);%Job submission
		timeid = {tid};
		jobid = {jid};
		%
   	 	i_simul = 1;
    	flag = ones(length(timeslice),1);
    	%
    	while 1,
        	if flag(i_simul)
            	output = getluke_remote_jd(timeid{i_simul},jobid{i_simul},remote);
            	if ~isempty(output)
                	luke_out(i_simul) = output;
                	flag(i_simul) = 0;
            	end
        	end
        	%
        	i_simul = i_simul + 1;
        	if i_simul > length(timeslice), i_simul = 1;end
        	%
        	if sum(flag) == 0;break;end
    	end
    end
end
%--------------------------- WRITE CPO's' into ITM database ------------------%
CPO_waves = [];
%
id_simul = ['timeslice_',int2str(timeslice)];
%
Znorm = luke_out.Znorm;
Zcurr = luke_out.Zcurr;
ZP0 = luke_out.ZP0;
dke_out = luke_out.dke_out;
%
for iray = 1:length(dke_out.waves{1}.rays),
    if ~isfield(dke_out.waves{1}.rays{iray},'mask_p') | ~isfield(dke_out.waves{1}.rays{iray},'mask_m');
        dke_out.waves{1}.rays{iray}.mask_p = zeros(size(dke_out.waves{1}.rays{iray}.ss));
        dke_out.waves{1}.rays{iray}.mask_m = ones(size(dke_out.waves{1}.rays{iray}.ss));
    end
end
%
radialDKE = luke_out.radialDKE;
equilDKE = luke_out.equilDKE;
momentumDKE = luke_out.momentumDKE;
gridDKE = luke_out.gridDKE;
Zmomcoef = luke_out.Zmomcoef;
Zbouncecoef = luke_out.Zbouncecoef;
Zmripple = luke_out.Zmripple;
mksa = luke_out.mksa;
XXsinksource = luke_out.XXsinksource;
%
filename = ['EC17_benchmark_',equil.id,'_',id_simul,'.mat'];
save(filename,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equil','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource','dkepath');
%
rawdata = load(filename);
%
procdata = proc_luke_jd(rawdata,ir_display,p_opt,0.1,NaN,'',opt);
%
CPO_waves = LUKEstruct2CPO(numshot,numrun_out,timeslice,'waves',rawdata,procdata,CPO_waves);
%
delete(filename);




