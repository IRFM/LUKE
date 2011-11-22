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
root_dir = '';%empty or pwd if local or  /local/peysson/Simulations/Yves/DKE/FLUCT/ when calculations are done on cephee cluster (local or remote)
scenario = 'Npar0_fluct';
%
load ('before_luke@TS_32299_100.0117.mat','equil');%data file from cronos
%
opt_dist = 0;% batch run index in dkepath.remote; (0) for local run, (1) local multicore, (2) remote cephee, (3) remote saturne
opt_save = 1;%In case of crash, to restart simulation from an intermediate step stored in a *.mat file (<0 for launching simulation from backup, 0 no backup, >0 for performing backup)
tn_max = 20;%Maximum normalized integration time
display_mode = [0,1,2];%option for display [C3PO, LUKE, time evolution]
p_opt = 2;%option for printing
%
%%%%%%%%%%% WARNING: Nothing below must be modified in case of reload %%%%%%%%%%% %%%%%%%%%%%%%%%
%
dtn_in = [10];%normalized integration time step
%
dtn_fluct_in = [10];%normalized integration time step (edge fluctuations)
hwhm_npar_in = [0.05];%edge plasma fluctuations
%
racc = 0.05;%relative accuracy for time averaged power and current calculation
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SCAN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
ijob = 1;
%
for dtn = dtn_in,%scan in integration time
    for hwhm_npar = hwhm_npar_in,%scan random width
        %
        ntn = tn_max/dtn;%number of time steps
        %
        dtn_fluct = dtn_fluct_in;
        %
        fluct_ref =  ['dtnf',num2str(dtn_fluct),'_hwhmnpar',num2str(hwhm_npar)];
        %
        if isempty(Npar_p),
            shot_ref = ['dtn',num2str(dtn),'_',fluct_ref];
        else
            shot_ref = ['Npar_p',num2str(abs(Npar_p)),'_dtn',num2str(dtn),'_',fluct_ref];
        end
        %
        id_simul = [scenario,'_',shot_ref];
        %
        % Edge plasma fluctuations outside the separatrix (for LH wave only, run with run_lukert or a specific script)
        %
        naequilp.edge.fluct.dtn = dtn_fluct;%Gaussian time correlation model, edge_dtn = 2.14*t_correlation (if edge_dtn is Inf, no fluctuations)
        naequilp.edge.fluct.hwhm_npar = hwhm_npar;%Gaussian distribution (if hwhm is NaN or empty, no fluctuations)
        %
        if opt_dist == 0,%local calculations
            %
            [timeid,jobid,dkeparam,dkepath,Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = loop_cronos_C3PO_yp(opt_dist,opt_save,id_simul,root_dir,scenario,dtn,ntn,naequilp,display_mode,Npar_p,Npar_m);
            %
            % ---------------------------------------------- Save results ----------------------------------------------
            %
            save_file = ['LUKE_RESULTS_',id_simul,'.mat'];
            save([dkeparam.path_simul,save_file]);
            info_dke_yp(2,['Data saved in ',dkeparam.path_simul,save_file]);
            %
            % ---------------------------------------------- Display results ----------------------------------------------
            %
            display_cronos_C3PO(id_simul,equilDKE,ZP0,Zcurr,dkeparam,mksa,racc,p_opt,root_dir)
            %
        else
            [timeid,jobid,dkeparam,dkepath] = loop_cronos_C3PO_yp(opt_dist,opt_save,id_simul,root_dir,scenario,dtn,ntn,naequilp,display_mode,Npar_p,Npar_m);
            %
            job.id_simul{ijob} = id_simul;
            job.id(ijob) = str2num(jobid);
            job.timeid(ijob) = str2num(timeid);
            job.dtn(ijob) = dtn;
            job.hwhm_npar(ijob) = hwhm_npar;
            job.state(ijob) = 0;
            %
            ijob = ijob + 1;
        end    
    end
end
%
if opt_dist > 0,%distributed calculations 
    job_file = ['LUKE_JOB_',id_simul,'.mat'];
    save(job_file,'job','opt_dist','dkepath','dkeparam');
    info_dke_yp(2,['Data saved in ',job_file]);
end
