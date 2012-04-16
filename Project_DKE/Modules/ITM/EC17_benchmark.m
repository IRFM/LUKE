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
% ITM simulation references (EC17 benchmark)
%
numshot = 2;
numrun_in = 551;
numrun_out = 502;%single ray: 502, beam: 503
timeslice = [0,1,2,3];
%
time_interp = 1;%nearest point
%
%Printing options
%
p_opt = -1;
%
%remote computing options
%
remotename = 'macproyves';%'','macproyves'
debugmode = 1;%set to 1 in case of problem
%
%LUKE post-processing options
opt.rho = 'g';
opt.nr_dep = 0;
opt.peakmode = 0;
opt.peak = 'n';
opt.wave = 'n';
opt.blist = '';
opt.diaryname = '';
opt.spec = 0;
%
% User specific C3PO/LUKEparameters
%
ray_display = 0;%for display ray propagation
%
if numrun_out == 503,
	beam_mode = 1;
	nd = 4;%Number of transverse distance positions for beamlets
	nchi= 6;%Number of angular positions for beamlets
	%
	idx  = euitm_create('euitm',numshot,numrun_out);%create database for this run if not exists
	euitm_close(idx,'euitm',numshot,numrun_out);
	%
elseif numrun_out == 502,
	beam_mode = 0;
	nd = 1;%Number of transverse distance positions for beamlets
	nchi= 1;%Number of angular positions for beamlets
	%
    idx  = euitm_create('euitm',numshot,numrun_out);%create database for this run if not exists
	euitm_close(idx,'euitm',numshot,numrun_out);
	%
end
%
[dkeparam,dkepath,dkedisplay] = load_structures_yp('dkeparam','EC_RT','','dkepath','','','dkedisplay','PARTIAL_VISUAL','');
%
info_dke_yp(1,'Benchmark using the ITM framework for the EC17 conference')
%
[machine,user,ver] = which_MDSdatabase;%test the database is correct
info_dke_yp(4,['machine: ',machine,', user: ',user,', datastructure version: ',ver])
%
[equil] = read_equil_ITM(numshot,numrun_in,timeslice(1),time_interp);%Create magnetic equilibrium structure
%
for it = 1:length(timeslice),
	%
	[launchs] = read_launchs_ITM(numshot,numrun_in,timeslice(it),time_interp);%Create rf waves launchs structure
	%
	wavestructs = cell(1,length(launchs));
	%
	for iw = 1:length(launchs),
 		wavestructs{iw} = make_wavert_cronos(launchs{iw},0);%parameter for ray-tracing are adapted to the selected wave
		%
 		wavestructs{iw}.equil_id = equil.id;
 		wavestructs{iw}.raydisplay.ray = ray_display;%for display ray propagation
		%
      	wavestructs{iw}.waveparam.nd = nd;%Number of transverse distance positions for beamlets
		wavestructs{iw}.waveparam.nchi = nchi;%Number of angular positions for beamlets
		%
		if ~beam_mode,
			wavestructs{iw}.launch.w0 = NaN;
         	wavestructs{iw}.launch.z_L = NaN;
		end
		%
		if wavestructs{iw}.launch.yP_L == 0, 
			wavestructs{iw}.launch.yP_L = eps;%to avoid interpolation problems
		end
 		%
 		if strcmp(launchs{iw}.type,'EC')
     		%
     		info_dke_yp(4,['wave :',int2str(iw),' type :',launchs{iw}.type])
     		%
 		else
     		info_dke_yp(4,['wave :',int2str(iw),' type :',launchs{iw}.type,' n// = ',num2str(wavestructs{iw}.launch.bNpar0,4)])
     		info_dke_yp(4,['wave :',int2str(iw),' type :',launchs{iw}.type,' Plh = ',num2str(wavestructs{iw}.launch.bPlhtot,4)])
 		end
	end
	%
	id_simul = ['timeslice_',int2str(timeslice(it))];
	%
	luke_in(it).id_simul = id_simul;
	luke_in(it).dkeparam = dkeparam;
    luke_in(it).equil = equil;
    luke_in(it).dkedisplay = dkedisplay;
    luke_in(it).wavestructs = {wavestructs{1},wavestructs{2}};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%luke_in(it).wavestructs = wavestructs;
    luke_in(1).waves = '';
    luke_in(it).ohm = '';
    luke_in(it).transpfaste = '';
    luke_in(it).ripple = '';    
    %
end
%
filename = ['EC17_benchmark_',id_simul,'_input.mat'];
save(filename,'luke_in');
info_dke_yp(2,['LUKE input data saved in ',filename]);
%
if isempty(remotename),
	for it = 1:length(timeslice),%local calculations
		[luke_out(it).Znorm,luke_out(it).Zcurr,luke_out(it).ZP0,luke_out(it).dke_out,luke_out(it).radialDKE,luke_out(it).equilDKE,luke_out(it).momentumDKE,luke_out(it).gridDKE,luke_out(it).Zmomcoef,luke_out(it).Zbouncecoef,luke_out(it).Zmripple,luke_out(it).mksa,luke_out(it).XXsinksource] = run_lukert(luke_in(it).id_simul,luke_in(it).wavestructs,luke_in(it).waves,[],luke_in(it).dkeparam.rho_S,dkepath,luke_in(it).equil,luke_in(it).dkeparam,luke_in(it).dkedisplay,luke_in(it).ohm,luke_in(it).transpfaste,luke_in(it).ripple,[],[]);
	end
else
    [flag,remote] = check_remote_yp(dkepath,remotename);
	%
	if ~flag,%local calculations
		[luke_out(it).Znorm,luke_out(it).Zcurr,luke_out(it).ZP0,luke_out(it).dke_out,luke_out(it).radialDKE,luke_out(it).equilDKE,luke_out(it).momentumDKE,luke_out(it).gridDKE,luke_out(it).Zmomcoef,luke_out(it).Zbouncecoef,luke_out(it).Zmripple,luke_out(it).mksa,luke_out(it).XXsinksource] = run_lukert(luke_in(it).id_simul,luke_in(it).wavestructs,luke_in(it).waves,[],luke_in(it).dkeparam.rho_S,dkepath,luke_in(it).equil,luke_in(it).dkeparam,luke_in(it).dkedisplay,luke_in(it).ohm,luke_in(it).transpfaste,luke_in(it).ripple,[],[]);
	else
		for it = 1:length(timeslice),%local calculations
			[tid,jid] = runluke_remote_jd(luke_in(it),remote,debugmode);%Job submission
			timeid(it) = {tid};
			jobid(it) = {jid};
		end
		
		%
   	 	i_simul = 1;
    	flag = ones(length(timeslice),1);
    	%
    	while 1,
        	if flag(i_simul)
            	output = getluke_remote_jd(timeid{i_simul},jobid{i_simul},remote,debugmode);
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
%
filename = ['EC17_benchmark_',id_simul,'_output.mat'];
save(filename,'luke_out');
info_dke_yp(2,['LUKE input data saved in ',filename]);
%
% Build structure for CPO 'waves'
%
CPO_waves = [];
%
for it = 1:length(timeslice),%local calculations
	id_simul = ['timeslice_',int2str(timeslice(it))];
	%
	Znorm = luke_out(it).Znorm;
	Zcurr = luke_out(it).Zcurr;
	ZP0 = luke_out(it).ZP0;
	dke_out = luke_out(it).dke_out;
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
	filename = ['EC17_benchmark_',id_simul,'.mat'];
	save(filename);
	%
	rawdata = load(filename);
	procdata = proc_luke_jd(rawdata,0,p_opt,0.1,NaN,'',opt);
	%
	[CPO_waves] = LUKEstruct2CPO(numshot,numrun_out,timeslice,'waves',rawdata,procdata,CPO_waves);
end
%
% Write results in CPO 'waves'
%
write_waves_ITM(numshot,numrun_out,CPO_waves);%build the structure to be transfered in the ITM MDS+ database
%
