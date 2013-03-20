% Benchmark procedure for the EC wave using the ITM framework (to be presented at the EC17 conference, Deurne, The Netherlands)
% Data provided by Lorenzo Figini <figini@ifp.cnr.it> (CNR, Milan). Contact him for details on this ITER Scen 2 discharge (end burning phase), old EQDSK equilibrium file
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
% Prior to run the script, the following steps must be fullfiled
% 1) in the shell, type the command: "create_user_itm_dir test 4.09a" for creating the database folder structure (machine:test, datastructure: 4.09a)
% 2) transfer the file by typing the command: "cp ~westerho/public/itmdb/itm_trees/test/4.09a/mdsplus/0/euitm_20001.* ~/public/itmdb/itm_trees/test/4.09a/mdsplus/0"
% 3) in the .cshrc, the line "source /afs/efda-itm.eu/project/switm/scripts/ITMv1 kepler test 4.09a >/dev/null" should be activated, and all equivalent should be commented
%    IMPORTANT: when matlab is launched, its environment is based on the .cshrc file. 
% Once these steps have been done, it is possible to start calculation with Matlab.
%
clear mex
clear all
clear functions
close all
clc
%
[dkeparam,dkepath,dkedisplay] = load_structures_yp('dkeparam','EC_RT','','dkepath','','','dkedisplay','NO_DISPLAY','');
% ITM simulation references (EC17 benchmark)
%
numshot = 2;
numrun_in = 551;
numrun_out = 502;%single ray: 502, beam: 503
timeslice = [0,1,2,3];
%
time_interp = 1;%nearest point
%
% Remote computing options
%
remnum = 2;%See the path of the user to identify the remote number to a specific machine/scheduler. Empty is local calculations
remtimout = 60;%Remote calculations time out (minutes)
debug_mode = 0;%set to 1 in case of problem
%
% Save euitm structures in mat-files
%
save_mode = 0;% 0 -> no save, > 1 -> save
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
%
info_dke_yp(1,'--------------------------------------------------------------------')
info_dke_yp(1,'Benchmarking EC codes using the EFDA-ITM framework')
info_dke_yp(1,'EC17 conference, Deurne, The Netherlands (2012)')
info_dke_yp(1,'--------------------------------------------------------------------')
%
% Test if a connection to the ITM MDS+ database may be established
%
[machine,user,ver] = which_MDSdatabase;%test the database is correct
%
if  ~isempty(machine) && ~isempty(user) && ~isempty(ver)
	info_dke_yp(4,['ITM database well connected -> machine: ',machine,', user: ',user,', datastructure version: ',ver]);
	itm_connect = 1;
	%
else
	itm_connect = 0;	
end
%
% run number of the output 
%
dkeparam.rho_S = [25];
%
if numrun_out == 503,%beam tracing
	beam_mode = 1;
	%
	nd = 2;%Number of transverse distance positions for beamlets
	nchi= 3;%Number of angular positions for beamlets
	%
	if itm_connect,
		idx  = euitm_create('euitm',numshot,numrun_out);%create database for this run if not exists
		euitm_close(idx,'euitm',numshot,numrun_out);
	end
elseif numrun_out == 502,%ray tracing
	beam_mode = 0;
	%
	nd = 1;%Number of transverse distance positions for beamlets
	nchi= 1;%Number of angular positions for beamlets
	%
	if itm_connect,
    	idx  = euitm_create('euitm',numshot,numrun_out);%create database for this run if not exists
		euitm_close(idx,'euitm',numshot,numrun_out);
    end
end
%
if isempty(remnum) & ~strcmp(mexext,'mexmaci64'),
	dkeparam.invproc = 1;%MUMPS is not working on the ITM gateway
	info_dke_yp(6,['The use of dmumpsmex is temporarily disabled on the ITM gateway.'])
end
%
dkeparam.npresmin = 0;%for the quasilinear calculations
%
run_id = ['euitm_shot_',int2str(numshot),'_run_',int2str(numrun_in),'_CPO_',int2str(numrun_out)];
%
if timeslice(1) > 0,
    timeslice_equil = 0;
else
    timeslice_equil = timeslice(1);
end
%
if itm_connect,
	equil = read_equil_ITM(numshot,numrun_in,timeslice_equil,time_interp,{'equilibrium','coreprof'},display_mode,save_mode);%Create magnetic equilibrium structure
else
    equil = [];
end
%
if isempty(equil),
	id_equil = ['euitm_shot_',int2str(numshot),'_run_',int2str(numrun_in),'_time_',int2str(timeslice_equil),'_timeinterp_',int2str(time_interp)];
	%
	if exist(['equil_',id_equil,'.mat']) == 2,
		load(['equil_',id_equil,'.mat']);
		equil = process_euitm_dataequil(equil_euitm,coreprof_euitm,display_mode);
	else
		error(['Unable to find the euitm equil file: equil_',id_equil,'.mat.']);
	end
end
%
for it = 1:length(timeslice),
	%
	if itm_connect,
		launchs = read_launchs_ITM(numshot,numrun_in,timeslice(it),time_interp,{'antennas'},save_mode);%Create rf waves launchs structure
    else
    	launchs = [];
    end
    %
	if isempty(launchs),
		id_launchs = ['euitm_shot_',int2str(numshot),'_run_',int2str(numrun_in),'_time_',int2str(timeslice(it)),'_timeinterp_',int2str(time_interp)];
		%
		if exist(['antennas_',id_launchs,'.mat']) == 2,
			load(['antennas_',id_launchs,'.mat']);
			launchs = CPO2LUKEstruct_yp('antennas',antennas_euitm);% Data conversion between ITM CPO's and C3PO/LUKE format
        else
			error(['Unable to find the euitm antennas file: antennas_',id_launchs,'.mat.']);
		end
    end    
	%
	wavestructs = cell(1,length(launchs));
	%
	for iw = 1:length(launchs),
        %
        %[sysh,sysZ,syR,syZ,syphi,syalpha,sybeta,sygR,sygZ,sygphi] = raypath_prop_jd(launchs{iw}.yR_L,launchs{iw}.yZ_L,launchs{iw}.yphi_L,launchs{iw}.yalpha_L,launchs{iw}.ybeta_L,linspace(0,10,1000));
        %
        %equilibrium_jd(equil,'',3);
        %hold on
        %graph1D_jd(syR-equil.Rp,syZ-equil.Zp,0,0,'','','',NaN,'','','-','non','k',2);%plot ray trajectory  
        %
        % Generic parameters for EC wave calculations
        %
        data = load([dkepath.luke_root,'Project_DKE/Database/WAVE_files/C3POPARAM_EC.mat']);
        %
        wavestructs{iw}.wavesolver = 'C3PO';
        wavestructs{iw}.id = launchs{iw}.id;      
        wavestructs{iw}.equil_id = equil.id; 
        %
        wavestructs{iw}.launch = launchs{iw};
        %
        wavestructs{iw}.waveparam = conc_struct_jd(wavestructs{iw},data.waveparam);%******
        wavestructs{iw}.waveparam.dsmin = 0;
      	wavestructs{iw}.waveparam.nd = nd;%Number of transverse distance positions for beamlets
		wavestructs{iw}.waveparam.nchi = nchi;%Number of angular positions for beamlets
        wavestructs{iw}.waveparam.mmode = -1;%O-mode
        wavestructs{iw}.waveparam.cut_fac = Inf;
        wavestructs{iw}.waveparam.a_sdNpar = 0;
    	%
        wavestructs{iw}.fitequilparam = conc_struct_jd(wavestructs{iw},data.fitparam);
        %
        wavestructs{iw}.rayparam = conc_struct_jd(wavestructs{iw},data.rayparam);
        wavestructs{iw}.rayparam.tfinal = 100000;
        wavestructs{iw}.rayparam.dt0 = 1e-5;
        wavestructs{iw}.rayparam.dS = 1e-4;
        wavestructs{iw}.rayparam.tol = 1e-10;
        wavestructs{iw}.rayparam.kmax = 100000;
        %
        wavestructs{iw}.C3POparam = conc_struct_jd(wavestructs{iw},data.C3POparam);
    	%
        % Specific parameters for EC wave calculations
        %
 		wavestructs{iw}.raydisplay.ray = ray_display;%for display ray propagation
        wavestructs{iw}.raydisplay.equilibrium = 0;
        wavestructs{iw}.raydisplay.p_opt = -1;%Printing or saving option of the figures
   		%
		if wavestructs{iw}.launch.yP_L == 0, 
			wavestructs{iw}.launch.yP_L = eps;%to avoid interpolation problems
		end
 		%
        info_dke_yp(4,['wave : ',int2str(iw),' type :',launchs{iw}.type])
	end
	%
	id_simul = ['timeslice_',int2str(timeslice(it))];
	%
	luke_in(it).id_simul = id_simul;
	luke_in(it).dkeparam = dkeparam;
    luke_in(it).equil = equil;
    luke_in(it).dkedisplay = dkedisplay;
    luke_in(it).wavestructs = wavestructs;
    luke_in(it).waves = '';
    luke_in(it).ohm = '';
    luke_in(it).transpfaste = '';
    luke_in(it).ripple = '';
end
%
if debug_mode,
	filename = ['EC17_benchmark_',run_id,'_input.mat'];
	save(filename,'luke_in');
	info_dke_yp(2,['Debug mode: LUKE input data saved in ',filename]);
end
%
dkepath.remnum = remnum;
dkepath.remtimout = remtimout;
%
for it = 1:length(timeslice),%local calculations
	[luke_out(it).Znorm,luke_out(it).Zcurr,luke_out(it).ZP0,luke_out(it).dke_out,luke_out(it).radialDKE,luke_out(it).equilDKE,luke_out(it).momentumDKE,luke_out(it).gridDKE,luke_out(it).Zmomcoef,luke_out(it).Zbouncecoef,luke_out(it).Zmripple,luke_out(it).mksa,luke_out(it).XXsinksource] = run_lukert(luke_in(it).id_simul,luke_in(it).wavestructs,luke_in(it).waves,[],luke_in(it).dkeparam.rho_S,dkepath,luke_in(it).equil,luke_in(it).dkeparam,luke_in(it).dkedisplay,luke_in(it).ohm,luke_in(it).transpfaste,luke_in(it).ripple,[],[]);
end
%
if debug_mode | ~itm_connect,
	filename = ['EC17_benchmark_',run_id,'_output.mat'];
	save(filename,'luke_out');
	info_dke_yp(2,['Debug mode or no connection to the ITM database: LUKE output data saved in ',filename]);
end
%
% Build structure for CPO 'waves'
%
CPO_waves = [];
%
for it = 1:length(timeslice),%local calculations
	%
	id_simul = ['timeslice_',int2str(timeslice(it))];
	%
	Znorm = luke_out(it).Znorm;
	Zcurr = luke_out(it).Zcurr;
	ZP0 = luke_out(it).ZP0;
	dke_out = luke_out(it).dke_out;
    %
    for iray = 1:length(dke_out.waves{1}.rays),
        if ~isfield(dke_out.waves{1}.rays{iray},'mask_p') | ~isfield(dke_out.waves{1}.rays{iray},'mask_m');
            dke_out.waves{1}.rays{iray}.mask_p = zeros(size(dke_out.waves{1}.rays{iray}.ss));
            dke_out.waves{1}.rays{iray}.mask_m = ones(size(dke_out.waves{1}.rays{iray}.ss));
        end
    end
    %
	radialDKE = luke_out(it).radialDKE;
	equilDKE = luke_out(it).equilDKE;
	momentumDKE = luke_out(it).momentumDKE;
	gridDKE = luke_out(it).gridDKE;
	Zmomcoef = luke_out(it).Zmomcoef;
	Zbouncecoef = luke_out(it).Zbouncecoef;
	Zmripple = luke_out(it).Zmripple;
	mksa = luke_out(it).mksa;
	XXsinksource = luke_out(it).XXsinksource;
	%
	filename = ['EC17_benchmark_',equil.id,'_',id_simul,'.mat'];
	save(filename,'Znorm','Zcurr','ZP0','dke_out','radialDKE','equil','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource','dkepath');
    %
	rawdata = load(filename);
    %
    if debug_mode,
        procdata = proc_luke_jd(rawdata,0,p_opt);
        graph_wave_jd(equil,dke_out.waves);
    else
        procdata = proc_luke_jd(rawdata,ir_display,p_opt,0.1,NaN,'',opt);
    end
	%
	[CPO_waves] = LUKEstruct2CPO(numshot,numrun_out,timeslice(it),'waves',rawdata,procdata,CPO_waves);
	%
	delete(filename);
end
%
% Write results in CPO 'waves'
%
if itm_connect,
	write_waves_ITM(numshot,numrun_out,CPO_waves);%build the structure to be transfered in the ITM MDS+ database
end
%
filename = ['EC17_benchmark_',run_id,'.mat'];
save(filename,'numshot','numrun_out','CPO_waves');
info_dke_yp(2,['Results saved in ',filename]);
