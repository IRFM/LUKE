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
scenario = 'EDW_core_fluct';
%
load ('before_luke@TS_32299_100.0117.mat','equil');%data file from cronos
%
opt_dist = 0;% batch run index in dkepath.remote; (0) for local run, (1) local multicore, (2) remote cephee, (3) remote saturne
opt_save = 1;%In case of crash, to restart simulation from an intermediate step stored in a *.mat file (<0 for launching simulation from backup, 0 no backup, >0 for performing backup)
tn_max = 20;%Maximum normalized integration time
display_mode = [1,1,1];%option for display [C3PO, LUKE, time evolution]
p_opt = 2;%option for printing
%
%%%%%%%%%%% WARNING: Nothing below must be modified in case of reload %%%%%%%%%%% %%%%%%%%%%%%%%%
%
dtn = [2];%normalized integration time step (note that the effective collision time step is dtn/nit_f)
%
sigmar_max_in = 0.5;%Core plasma fluctuations
epsi_rho_in = [0.01];%Core plasma fluctuations
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
path_simul = [root_dir,scenario,'/'];
if exist(path_simul) ~= 7, mkdir(path_simul);end
%
for sigmar_max = sigmar_max_in,
    for epsi_rho = epsi_rho_in,
        %
        ntn = tn_max/dtn;%number of time steps
        %
        epsi_theta = epsi_rho;%Core plasma fluctuations
        %
        fluct_ref =  ['sigmar_max',num2str(sigmar_max),'_epsi_rho',num2str(epsi_rho)];
        %        
        if isempty(Npar_p),
            shot_ref = ['dtn',num2str(dtn),'_',fluct_ref];
        else
            shot_ref = ['Npar_p',num2str(abs(Npar_p)),'_dtn',num2str(dtn),'_',fluct_ref];
        end
        %
        id_simul = [scenario,'_',shot_ref];
        %
        % Core plasma fluctuations (LH or EC waves)
        %
        naequilp.core.fluct.type = {'ne'};%Type of fluctuations or modulations ('ne': electron density, 'B': magnetic field) {1,nfluct_types}
        naequilp.core.fluct.model = [5];%Statistical ne fluctuation model (>= 1) : [1,nfluct_types]
                                %    - (1) -> 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO)
                                %    - (2) -> 3-D Gaussian model (rho,theta,phi), absolute epsi values (m)
                                %    - (3) -> 2-D Gaussian drift-wave like model global (rho,curtheta), absolute epsi values (m)
                                %    - (4) -> 1-D Gaussian drift-wave like model local (curtheta), absolute epsi values (m)
                                %    - (5) -> 1-D Gaussian drift-wave like model local (cn,cm), absolute epsi values (m)
                                %    - (6) -> 2-D Gaussian drift-wave like model local (rho,cn,cm), absolute epsi values (m)
                                %    - (7) -> *** NOT IMPLEMENTED *** 2-D Gaussian drift-wave like model local (rho,lperp), absolute epsi values (m)
        naequilp.core.fluct.sigmar_max = sigmar_max;%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
        naequilp.core.fluct.sigmar_hwhm = [0.05];%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
        naequilp.core.fluct.sigmar_rho = [1];%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
        naequilp.core.fluct.polmode = [0.0];%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
        %
        naequilp.core.fluct.epsi_rho = epsi_rho;%
        naequilp.core.fluct.epsi_theta = epsi_theta;%theta direction is perp direction for models 3 & 4
        naequilp.core.fluct.epsi_phi = [0.2];%useless for models 3 & 4
        %
        naequilp.core.fluct.lmin = [1];%
        naequilp.core.fluct.mmin = [1];%for perp direction for models 3 & 4
        naequilp.core.fluct.nmin = [1];%useless for models 3 & 4
        %
        naequilp.core.fluct.lmax = [200];%
        naequilp.core.fluct.mmax = [200];%for perp direction for models 3 & 4
        naequilp.core.fluct.nmax = [5];%useless for models 3 & 4%
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
