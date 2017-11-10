function [antenna] = build_aloha_power_spectrum_yp(sc,edge_ne,rc,optim,dkepath,scheduler)
%
%clear all
%load toto.mat
%
% other remote method (wait until calculation is done)
%
%clustermode.aloha_scenario.scheduler = scheduler;
%dkecluster = clustermode_luke(clustermode,'aloha_scenario',dkepath);%MatLab distributed computing environment
%[flag_aloha_scenario,sc_out] = mdce_run(@aloha_scenario,{sc},1,{sc},dkecluster);
%
remote = dkepath.remote(scheduler.remnum);
%
if isempty(rc)
    %
    job = matstandardjob_jd('runmat');
    %
    sc.antenna.a_ampl = sc.antenna.a_ampl(1,:)';% (first row is considered for coupling calculations, other rows are considered later)
    sc.antenna.a_phase = sc.antenna.a_phase(1,:)';
    %
    sc.plasma.ne0 = edge_ne;%single density run
    %
    [err,job,sc_out] = matremote_jd('aloha_scenario',{sc},remote,job);%wait until ALOHA calculation is done
    %
    if isempty(err)
        %
        clear job
        %
        antenna.aloha = sc_out;
        %
    else
        return
    end
else
    %
    remote.timeout = 0;%Don't wait until ALOHA job is done
    %
    sc_temp = sc;
    %
    for ii = 1:size(sc.antenna.a_ampl,1)
        %
        job = matstandardjob_jd('runmat');%new job
        job.remtimout = 0;%Don't wait until ALOHA job is done
        %
        sc_temp.antenna.a_ampl = sc.antenna.a_ampl(ii,:)';% (first row is considered for coupling calculations, other rows are considered later)
        sc_temp.antenna.a_phase = sc.antenna.a_phase(ii,:)';
        %
        rc_temp = rc(ii,:)';
        %
        [err,job,dummy] = matremote_jd('aloha_process_yp',{sc_temp,rc_temp,optim},remote,job);%find remotely the optimum density in front of the grill consistent with RC measurements
        %  
        if isempty(err) 
            %
            if isempty(job.remote.host)
                disp(['ALOHA job for row #',int2str(ii),'/',int2str(size(sc.antenna.a_ampl,1)),' has been launched on the local host to find density in front of the grill consistent with RC'])
            else
                disp(['ALOHA job for row #',int2str(ii),'/',int2str(size(sc.antenna.a_ampl,1)),' has been launched on host : ',job.remote.host,' to find density in front of the grill consistent with RC'])
            end
            %
            antenna.job{ii} = job;
            %
        else
            return
        end
    end
end
