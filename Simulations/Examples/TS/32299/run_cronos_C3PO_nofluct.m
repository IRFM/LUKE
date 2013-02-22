clear all
clear mex
clear functions
close all
warning off
pause(1)
dbstop if error
%
% Script for TORE-SUPRA LH discharge #32299 only
%
root_dir = '';%empty or pwd if local
scenario = 'no_fluct';
%
load ('before_luke@TS_32299_100.0117.mat','equil');%data file from cronos
%
opt_dist = 0;% batch run index in dkepath.remote; (0) for local run, (1) local multicore, (2) remote cephee, (3) remote saturne
opt_save = 1;%In case of crash, to restart simulation from an intermediate step stored in a *.mat file (<0 for launching simulation from backup, 0 no backup, >0 for performing backup)
tn = 10000;%Total normalized integration time. As an imaginary number, dkeparam.tn prescribes the number of fluctuation iterations
display_mode = [0,1,1];%option for display [C3PO, LUKE, time evolution]
p_opt = 2;%option for printing
%
dtn = 10000;% LUKE internal time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
% 
% positive lobe (co-current)
%
Npar_p = [];%if empty, use the launch power spectrum calculated by CRONOS (negative value)
dNpar_p = [];%if empty, use the launch power spectrum calculated by CRONOS (negative value)
%
% negative lobe (counter-current)
%
Npar_m = [];%if empty, use the launch power spectrum calculated by CRONOS (positive value)
dNpar_m = [];%if empty, use the launch power spectrum calculated by CRONOS (positive value)
%
ijob = 1;
%
path_simul = [root_dir,scenario,'/'];
if exist(path_simul) ~= 7, mkdir(path_simul);end
%
if isempty(Npar_p),
    shot_ref = '';
else
    shot_ref = ['Npar_p',num2str(abs(Npar_p))];
end
%
if isempty(shot_ref),
    id_simul = [scenario];
else
    id_simul = [scenario,'_',shot_ref];
end
%
if opt_dist == 0,%local calculations
    %
    [timeid,jobid,dkeparam,dkepath,Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = loop_cronos_C3PO_yp(opt_dist,opt_save,id_simul,root_dir,scenario,'',tn,dtn,'',display_mode,Npar_p,Npar_m);
    %
    % ---------------------------------------------- Save results ----------------------------------------------
    %
    save_file = ['LUKE_RESULTS_',id_simul,'.mat'];
    save([dkeparam.path_simul,save_file]);
    info_dke_yp(2,['Data saved in ',dkeparam.path_simul,save_file]);
    %
    % ---------------------------------------------- Display results ----------------------------------------------
    %
    display_cronos_C3PO(id_simul,equilDKE,ZP0,Zcurr,dkeparam,mksa,'',p_opt,root_dir)
    %
else
    [timeid,jobid,dkeparam,dkepath] = loop_cronos_C3PO_yp(opt_dist,opt_save,id_simul,root_dir,'',tn,dtn,'',display_mode,Npar_p,Npar_m);
    %
    job.id_simul{ijob} = id_simul;
    job.id(ijob) = str2num(jobid);
    job.timeid(ijob) = str2num(timeid);
    job.dtn(ijob) = dtn;
    job.hwhm_npar(ijob) = hwhm_npar;
    job.state(ijob) = 0;
end    
%
if opt_dist > 0,%distributed calculations 
    job_file = ['LUKE_JOB_',id_simul,'.mat'];
    save(job_file,'job','opt_dist','dkepath','dkeparam');
    info_dke_yp(2,['Data saved in ',job_file]);
end
