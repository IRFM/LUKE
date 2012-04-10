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
numrun = 11;
timeslice = 0;
time_interp = 1;%nearest point
angle_simul = {'20','40','20+40'};
%
%Printing options
%
p_opt = -1;
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
par.luke_mode = 'ecrh';%'mixte','ecrh','lh'
par.rt_mode = 1;%RT-DKE power consistency
par.abs_lim = 0.95;%Relative level of RF power absorption that is accpeted for in the quasilinear convergence loop (0: no threshold, 1: full absorption)
par.nit_rf = 20;%Maximum number of iteration in ray-tracing. Works only if rt_mode = 1 and more than one radial point (default = 1)
par.dke_mode = 0;%Fokker-Planck equation (0), Drift Kinetic equation (1)
par.tn = 100000;%LUKE time step (1/nhuth_ref)
par.invproc = 1;%Iterative matrix inversion method: (1) cgs iterative method, (2) bicg iterative method, (3) qmr iterative method
par.nk_abs = 1;%maximum number of iterations on a_sdNpar for full absorption
par.Dql = Inf;%Upper limit of the quasilinear diffusion coefficient. Important for low temperature plasmas et high power level for stability of the code
par.rho_S = 20;%number of points for radial grid calculation
%
ray_display = 1;%for display ray propagation
%
[dkepath,dkedisplay] = load_structures_yp('dkepath','','','dkedisplay','PARTIAL_VISUAL','');
%
info_dke_yp(1,'Benchmark using the ITM framework for the EC17 conference')
%
[machine,user,ver] = which_MDSdatabase;%test the database is correct
info_dke_yp(4,['machine: ',machine,', user: ',user,', datastructure version: ',ver])
%
[equil] = read_equil_ITM(numshot,numrun,timeslice,time_interp);%Create magnetic equilibrium structure
%
[launchs] = read_launchs_ITM(numshot,numrun,timeslice,time_interp);%Create rf waves launchs structure
%
dkeparam = make_dkeparam_cronos(par);
%
wavestructs = cell(1,length(launchs));
%
for iw = 1:length(launchs),
 	wavestructs{iw} = make_wavert_cronos(launchs{iw},0);%parameter for ray-tracing are adapted to the selected wave
	%
 	wavestructs{iw}.equil_id = equil.id;
 	wavestructs{iw}.raydisplay.ray = ray_display;%for display ray propagation
 	%
 	if strcmp(launchs{iw}.type,'EC')
     	%
     	info_dke_yp(4,['wave :',int2str(iw),' type :',launchs{iw}.type])
     	%
 	else
     	info_dke_yp(4,['wave :',int2str(iw),' type :',launchs{iw}.type,' n// = ',num2str(wavestructs{iw}.launch.bNpar0,4)])
     	info_dke_yp(4,['wave :',int2str(iw),' type :',launchs{iw}.type,' Plh = ',num2str(wavestructs{iw}.launch.bPlhtot,4)])
 	end
 	%
end
%
% Perform all simulations case. 
%
CPO_waves = [];
%
for i_simul = 1:length(angle_simul),
	id_simul = ['launch_angle_',angle_simul{i_simul}];
	%
	if i_simul == 1, 
		wavestructs_simul = {wavestructs{1}};%angle 20 deg. only
		timeslice = 1;
	elseif i_simul == 2, 
		wavestructs_simul = {wavestructs{2}};%angle 40 deg. only
		timeslice = 2;
	else 
		wavestructs_simul = wavestructs;%both angles: 20 deg. + 40 deg.
		timeslice = 3;
	end
	%
	[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert('ITM',wavestructs_simul,[],[],dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,[],[],[],[],[]);
	%
	filename = ['EC17_benchmark_',id_simul,'.mat'];
	save(filename);
	info_dke_yp(2,['LUKE Results saved in ',filename]);
	%
	rawdata = load(filename);
	procdata = proc_luke_jd(rawdata,0,p_opt,0.1,NaN,'',opt);
	%
	[CPO_waves] = LUKEstruct2CPO(numshot,numrun,timeslice,'waves',rawdata,procdata,CPO_waves);
	%
end
save toto.mat
%
%write results in CPO 'waves'
%
write_waves_ITM(numshot,numrun,CPO_waves);%build the structure to be transfered in the ITM MDS+ database
%
