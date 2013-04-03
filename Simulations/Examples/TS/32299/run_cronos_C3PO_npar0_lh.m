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
%
% Perturbation of the launched npar for the LH wave only (simulate possible diffraction of the LH wave in the SOL by edge density fluctuations)
%
scenario = 'Npar0_fluct';
%
load ('before_luke@TS_32299_100.0117.mat','equil');%data file from cronos
%
% WARNING: time definitions in LUKE with or without fluctuations
%
%if imag(tn) > 0 : dkeparam.tn = tn/Nfluct -> as an imaginary number, dkeparam.tn prescribes the number of fluctuation iterations
%if imag(tn) == 0 : dkeparam.tn = tn -> as a real number, dkeparam.tn specifies the final time explicitly 
%if imag(dtn) > 0: dkeparam.dtn = dtn*Nfluct -> as an imaginary number, dkeparam.dtn prescribes the number of internal time steps
%if imag(dtn) == 0: dkeparam.dtn = dtn -> as a real number, dkeparam.dtn prescribes the number of internal time steps
%
opts.remtimout = 0;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
opts.rempause = 1/60;%pause between job checks (in minutes) (only for remtimout > 0)
opts.remstart = 0;% (1) start new simulation; (0) check older simulation (only for remtimout = 0)
opts.remnum = 2;% remote profile number. Use 0 for local sequential calculations
opts.remdebug = 0;% remote debugmode
opts.dist = 0;% batch run index in dkepath.remote; (0) for local run, (1) local multicore, (2) remote cephee, (3) remote saturne
opts.save = 0;% save individual results in LUKE_RESULTS files (WARNING : Use absolute simul.path to save locally with local cluster)
opts.backup = 1;%In case of crash, to restart simulation from an intermediate step stored in a *.mat file (<0 for launching simulation from backup, 0 no backup, >0 for performing backup)
%
tn = 100i;%Total normalized integration time. As an imaginary number, dkeparam.tn prescribes the number of fluctuation iterations
display_mode = [0,1,1];%option for display [C3PO, LUKE, time evolution]
p_opt = 2;%option for printing
%
%%%%%%%%%%% WARNING: Nothing below must be modified in case of reload %%%%%%%%%%% %%%%%%%%%%%%%%%
%
Nfluct = [0.381141619674545];%ratio of LUKE internal evolution time to fluctuation time !! set to retrieve old dtn = 2
dtn = 1i;% LUKE internal time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
%
tn_fluct_correlation_npar0_lh = 1.0;%dtn_fluct_npar0_lh = 2.14*tn_fluct_correlation_npar0_lh (if dtn_fluct_npar0_lh is Inf, no fluctuations)
%
gaussian_tail = NaN;%Gaussian distribution for npar0 around npar_antenna given in the launch structure. If gaussian_npar0 is NaN or empty, no fluctuations of this type
fwhm_npar0_in = 0.4;%If fwhm_npar0 is NaN or empty, the width is dnpar_antenna.
%
linear_tail = NaN;%Linear distribution for npar0 from npar_antenna given in the launch structure to Nparmax_tail. If linear_tail is NaN or empty, no fluctuations of this type
calc_tail = 1;%Calculated distribution for npar0 from npar_antenna given in the launch structure to Nparmax_tail. If calc_tail is NaN or empty, no fluctuations of this type
Nparmax_tail_in = NaN;%npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is NaN or empty, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
n_tail_in = 5;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen) 
opt_tail_in = NaN;%Final power fraction of the tail @ Nparmax_tail.
P_tail_in = 0.5;%Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (no used if linear_tail is chosen) 
%
racc = 0.05;%relative accuracy for time averaged power and current calculation
% 
% LH wave: positive lobe (co-current)
%
Npar_p = [];%if empty, use the launch power spectrum calculated by CRONOS (negative value)
dNpar_p = [];%if empty, use the launch power spectrum calculated by CRONOS (negative value)
%
% LH wave: negative lobe (counter-current)
%
Npar_m = [];%if empty, use the launch power spectrum calculated by CRONOS (positive value)
dNpar_m = [];%if empty, use the launch power spectrum calculated by CRONOS (positive value)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SCAN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
ijob = 1;
%
for fwhm_npar0 = fwhm_npar0_in,%scan random width (Gaussian model)
    for opt_tail = opt_tail_in,%scan random width (linear or calculated tail model)
        for Nparmax_tail = Nparmax_tail_in,%scan upper limit in Npar of the tail (linear or calculated tail model)
            for n_tail = n_tail_in,%scan number of lobes in the tail (linear or calculated tail model)
                for P_tail = P_tail_in,%scan power fraction in the tail (linear or calculated tail model)
                    %
                    if (~isempty(fwhm_npar0) && ~isnan(fwhm_npar0)),
                        fluct_ref =  ['fwhm_npar0_lh_',num2str(fwhm_npar0)];
                    elseif (~isempty(h_npar0) && ~isnan(h_npar0)),
                        if (~isempty(nparmax_npar0) && ~isnan(nparmax_npar0)),
                            fluct_ref =  ['h_npar0_lh_',num2str(h_npar0),'_nparmax_npar0_lh_',num2str(h_npar0)];
                        else
                            fluct_ref =  ['h_npar0_lh_',num2str(h_npar0),'_nparmax_npar0_lh_Landau_Te0'];
                        end
                    end 
                    %
                    if isempty(Npar_p),
                        shot_ref = ['dtn',num2str(dtn),'_',fluct_ref];
                    else
                        shot_ref = ['Npar_p',num2str(abs(Npar_p)),'_dtn',num2str(dtn),'_',fluct_ref];
                    end
                    %
                    id_simul = [scenario,'_',shot_ref];
                    %
                    % Perturbation of the launched npar for the LH wave only (simulate possible diffraction of the LH wave in the SOL by edge density fluctuations)
                    %
                    fluctuations.npar0_lh.fluct.dtn = 2.14*tn_fluct_correlation_npar0_lh;%Gaussian time correlation model, dtn_fluct_npar0_lh = 2.14*tn_fluct_correlation_npar0_lh (if dtn_fluct_npar0_lh is Inf, no fluctuations)
                    %
                    fluctuations.npar0_lh.fluct.gaussian_tail = gaussian_tail;%Gaussian distribution for npar0 around npar_antenna given in the launch structure. If gaussian_npar0 is NaN or empty, no fluctuations of this type
                    fluctuations.npar0_lh.fluct.fwhm_npar0 = fwhm_npar0;%Gaussian distribution for npar0 around npar_antenna given in the launch structure. If fwhm_npar0 is NaN or empty, the width is dnpar_antenna.
                    %
                    fluctuations.npar0_lh.fluct.linear_tail = linear_tail;%Linear distribution for npar0 from npar_antenna given in the launch structure to Nparmax_tail. If linear_tail is NaN or empty, no fluctuations of this type
                    fluctuations.npar0_lh.fluct.calc_tail = calc_tail;%Calculated distribution for npar0 from npar_antenna given in the launch structure to Nparmax_tail. If calc_tail is NaN or empty, no fluctuations of this type
                    fluctuations.npar0_lh.fluct.P_tail = P_tail;%Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (no used if linear_tail is chosen) 
                    fluctuations.npar0_lh.fluct.Nparmax_tail = Nparmax_tail;%npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is NaN or empty, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
                    fluctuations.npar0_lh.fluct.n_tail = n_tail;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen) 
                    fluctuations.npar0_lh.fluct.opt_tail = opt_tail;%Final power fraction of the tail @ Nparmax_tail.
                    %
                    %%%%%%%%% A MODIFIER - YP %%%%%%%%%%
                    %
                    if opts.dist == 0,%locally distributed calculations
                        %
                        [timeid,jobid,dkeparam,dkepath,Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = loop_cronos_C3PO_yp(opts,id_simul,root_dir,Nfluct,tn,dtn,fluctuations,display_mode,Npar_p,Npar_m);                                                                                                                                                                         opt_dist,opt_save,id_simul,root_dir,Nfluct,tn,dtn,fluctuations,display_mode,Npar_p,Npar_m,XXfinit
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
                        [timeid,jobid,dkeparam,dkepath] = loop_cronos_C3PO_yp(opts,id_simul,root_dir,Nfluct,tn,dtn,fluctuations,display_mode,Npar_p,Npar_m);
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
        end
    end
end
%
if opt_dist > 0,%distributed calculations 
    job_file = ['LUKE_JOB_',id_simul,'.mat'];
    save(job_file,'job','opt_dist','dkepath','dkeparam');
    info_dke_yp(2,['Data saved in ',job_file]);
end
