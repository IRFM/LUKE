function [timeid,jobid,dkeparam,dkepath,Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = loop_cronos_C3PO_yp(opt_dist,opt_save,id_simul,root_dir,scenario,Nfluct,tn,dtn,naequilp,display_mode,Npar_p,Npar_m,XXfinit)
%
timeid = [];
jobid = [];
%
load ('before_luke@TS_32299_100.0117.mat','dkeparam','dkedisplay','transpfaste','ohm','ripple','wavestructs','equil');%data file from cronos
%
if strfind(id_simul,'ALOHA'),
    aloha_file = 'TS32299_C3_ne03e17.mat';
    aloha_path = 'ALOHA_C3_nefluct_TS32299/';
    param = 1i;%2i;%Number of lobes selected (0 < param < 1: lobes whose fraction is larger than param are considerered, param >=1: number of lobes considered in the spectrum)
    nlobes = 0;%number of lobes to keep (all if 0);
    %
    id_launch = [aloha_file(1:strfind(aloha_file,'.')-1),'_param_',num2str(param),'_nlobes_',num2str(nlobes)];
    load_str = ['LAUNCH_',id_launch,'.mat'];
    load([aloha_path,load_str],'launch');
    %
    wavestructs = {wavestructs{1}};
    wavestructs{1}.launch = launch;
    %
    wavestructs{1}.launch.i_ref = 100;
    wavestructs{1}.launch.mmode = -1;
    wavestructs{1}.launch.nparp = 0;
    wavestructs{1}.launch.a_sdNpar = 0;
    wavestructs{1}.launch.w0 = NaN;
    wavestructs{1}.launch.z_L = NaN;
    %
    wavestructs{1}.id = wavestructs{1}.launch.id;
end
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath] = load_structures_yp('dkepath',id_dkepath,path_dkepath);
%
% --------------------------------------------------------------------------------------------
%
if ~isempty(naequilp),
    equil.fluct = fluctstruct_yp(equil,'',naequilp);%Edge plasma fluctuations
end
%
if ~isempty(Npar_p),
    if strfind(id_simul,'ALOHA'),
        wavestructs{1}.launch.bNpar0(1) = Npar_p;        
    else
        wavestructs{1}.launch.bNpar0(1) = Npar_p;
        wavestructs{2}.launch.bNpar0(1) = Npar_p;
    end
end
%
if ~isempty(Npar_m),
    if strfind(id_simul,'ALOHA'),
        wavestructs{1}.launch.bNpar0(2) = Npar_m;
    else
        wavestructs{1}.launch.bNpar0(2) = Npar_m;
        wavestructs{2}.launch.bNpar0(2) = Npar_m;
    end
end
%
if strfind(id_simul,'ALOHA'),
    wavestructs{1}.rayparam.tfinal = 20000;
    wavestructs{1}.rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
    wavestructs{1}.rayparam.kextra = 3000;
    wavestructs{1}.raydisplay.ray = 0;    
else
    wavestructs{1}.rayparam.tfinal = 20000;
    wavestructs{2}.rayparam.tfinal = 20000;
    wavestructs{1}.rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
    wavestructs{2}.rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
    wavestructs{1}.rayparam.kextra = 3000;
    wavestructs{2}.rayparam.kextra = 3000;
    wavestructs{1}.raydisplay.ray = 0;
    wavestructs{2}.raydisplay.ray = 0;
end
%
% Parallel computing parameters
%
dkeparam = rmfield(dkeparam,'clustermode');%remove old structure for backward compatibility
%
if strfind(id_simul,'ALOHA'),
    wavestructs{1}.C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 0;
    wavestructs{1}.C3POparam.clustermode.main_C3PO_jd.scheduler.memory = 500;
else
    wavestructs{1}.C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 0;
    wavestructs{1}.C3POparam.clustermode.main_C3PO_jd.scheduler.memory = 500;
    wavestructs{2}.C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 0;
    wavestructs{2}.C3POparam.clustermode.main_C3PO_jd.scheduler.memory = 500;
end
%
dkeparam.clustermode.wave_solver_yp.scheduler.mode = 2;%MatLab distributed computing environment (3)
dkeparam.clustermode.wave_solver_yp.scheduler.memory = 500;
%
dkeparam.psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
dkeparam.rho_S = 25;%dkeparam.rho_S;%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
% ---------------------------------------------- Run LUKE + RT ----------------------------------------------
%
if exist('dmumpsmex','file');
    dkeparam.invproc = -2;%MUMPSMEX
end
%
if ~exist('XXfinit');
    XXfinit = [];
end
%
%
if isempty(opt_save);
    opt_save = 1;%In case of crash, to restart simulation from an intermediate step stored in a *.mat file (<0 for launching simulation from backup, 0 no backup, >0 for performing backup)
end
%
dkeparam.rt_mode = 1;
%
if length(display_mode) == 3,
    if strfind(id_simul,'ALOHA'),
        wavestructs{1}.raydisplay.ray = display_mode(1);       
    else
        wavestructs{1}.raydisplay.ray = display_mode(1);
        wavestructs{2}.raydisplay.ray = display_mode(1);
    end
    %
    dkedisplay.display_mode = display_mode(2);
    %
    dkedisplay.display_time_mode = display_mode(3);
elseif length(display_mode) == 2,
    if strfind(id_simul,'ALOHA'),
        wavestructs{1}.raydisplay.ray = 0;
    else
        wavestructs{1}.raydisplay.ray = 0;
        wavestructs{2}.raydisplay.ray = 0;
    end
    %
    dkedisplay.display_mode = display_mode(1);
    dkedisplay.display_time_mode = display_mode(2);
elseif length(display_mode) == 1,
    if strfind(id_simul,'ALOHA'),
        wavestructs{1}.raydisplay.ray = 0;        
    else
        wavestructs{1}.raydisplay.ray = 0;
        wavestructs{2}.raydisplay.ray = 0;
    end
    %
    dkedisplay.display_mode = 0;
    dkedisplay.display_time_mode = display_mode(1);
else
    if strfind(id_simul,'ALOHA'),
    	wavestructs{1}.raydisplay.ray = 0;
    else
        wavestructs{1}.raydisplay.ray = 0;
        wavestructs{2}.raydisplay.ray = 0;
    end
    %
    dkedisplay.display_mode = 0;
    dkedisplay.display_time_mode = 0;    
end
%
if ~isempty(Nfluct) && ~isnan(Nfluct),
    dkeparam.Nfluct = Nfluct;
end
dkeparam.tn = tn;%LUKE internal evolution time
dkeparam.dtn = dtn;%LUKE internal time step
dkeparam.finitabs = 0;%the initial distribution is used to first estimate the ray absorption (1) otherwise (0)
%
if opt_dist == 0,%local calculations
    %
    if strcmp(computer,'GLNXA64'),%Overwrite root directory when local calculations are done on cephee
        root_dir = '/local/peysson/Simulations/Yves/DKE/FLUCT/';%cephee 
    end
    %
    dkeparam.path_simul = [root_dir,id_simul,'/'];%Local directory
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,wavestructs,[],dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,XXfinit,[],opt_save);
    %
    dkeparam = dke_out.dkeparam;
    %
else,%remote calculations
    %
    if opt_dist == 2,%cephee
        root_dir = '/local/peysson/Simulations/Yves/DKE/FLUCT/';%cephee 
    elseif opt_dist == 3,%saturne
        root_dir = '';%saturne 
    end     
    %   
    dkeparam.path_simul = [root_dir,id_simul,'/'];%Local directory
    %
    remote = dkepath.remote(opt_dist);
    %
    luke_input.id_simul = id_simul;
    luke_input.dkeparam = dkeparam;
    luke_input.dkedisplay = dkedisplay;
    luke_input.equil = equil;
    luke_input.waves = '';
    luke_input.wavestructs = wavestructs;
    luke_input.ohm = ohm;
    luke_input.transpfaste = transpfaste;
    luke_input.ripple = ripple;
    luke_input.Zf0_interp = XXfinit;
	luke_input.XXsinksource = '';
	luke_input.opt_save = opt_save;
    %
    [timeid,jobid] = runluke_remote_jd(luke_input,remote);%Job submission
end


