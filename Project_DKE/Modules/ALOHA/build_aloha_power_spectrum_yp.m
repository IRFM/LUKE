%function antenna = build_aloha_power_spectrum_yp(sc,ptot,edge_ne,rc,eps_rc,dkepath,scheduler)
%
clear all
load toto.mat
%
if isempty(rc)
   sc.plasma.ne0 = edge_ne;
end
%
clustermode.aloha_scenario.scheduler = scheduler;
dkecluster = clustermode_luke(clustermode,'aloha_scenario',dkepath);%MatLab distributed computing environment

%
[flag_aloha_scenario,sc_out] = mdce_run(@aloha_scenario,{sc},1,{sc},dkecluster);





[remoteprofiles,profilestr] = load_remoteprofiles_jd(NaN,0,0,'',NaN,1,1)
remote = remoteprofiles(1);

test_job = matstandardjob_jd;
        %
        test_job.wait = 0;%1;% (0) return hand (1) wait for result
        test_job.nodes = 1;%number of nodes required
        test_job.ppn = 1;%number of cores required
        test_job.memory = 2000;% memory required (in mb) - leave empty if no requirement
        test_job.walltime = 1;%[];% time required (integers - in hours) - leave empty if no requirement
        test_job.rempause = 1/60;% in minutes
        %
       
            test_job.remtimout = 0;% in minutes
        
        %
       
        test_job.debugmode = 0;

test_job.funcopy = true;% to copy function remotetest to remote folder
                test_job.env.remotematfnc = 'runmat'; % matlab function to be called remotely by remotematrun (case of standard call using runmat)
                test_job.displaymode = 1;
                %
                [err,test_job,soutput] = matremote_jd('aloha_scenario',{sc},remote,test_job);

[flag_aloha_scenario,sc] = mdce_run(@aloha_scenario,{sc},1,'',dkecluster);

