function [antenna] = build_aloha_power_spectrum_yp(sc,edge_ne,rc,eps_rc,dkepath,scheduler)
%
clear all
load toto.mat
%
% other remote method (wait until calculation is done)
%
%clustermode.aloha_scenario.scheduler = scheduler;
%dkecluster = clustermode_luke(clustermode,'aloha_scenario',dkepath);%MatLab distributed computing environment
%[flag_aloha_scenario,sc_out] = mdce_run(@aloha_scenario,{sc},1,{sc},dkecluster);
%
if nargin < 7
    antenna = struct;
end
%
if ~isfield(antenna,'job'),
    %
    remote = dkepath.remote(scheduler.remnum);
    job = matstandardjob_jd('runmat');
    %
end
%
if isempty(rc)
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
        antenna.spectrum.dP = sc_out.results.dP*2;%because calculation is done for half-antenna
        antenna.spectrum.dP_nz = sc_out.results.dP_nz*2;%because calculation is done for half-antenna
        antenna.spectrum.nz = sc_out.results.nz;
        antenna.spectrum.ny = sc_out.results.ny;
        %
    else
        return
    end
else
    %
    if ~isfield(antenna,'job')
        %
        remote.timeout = 0;%Don't wait until ALOHA job is done
        job.remtimout = 0;%Don't wait until ALOHA job is done
        %
        optim.tolfun = 1e-1;% tolerance on targets
        optim.tolx = 1e-1;% tolerance on inputs
        optim.nitmax = 3;%
        %
        [err,job,sc] = matremote_jd('aloha_process_yp',{sc,rc,optim},remote,job);
        %  
        if isempty(err) 
            %
            if isempty(job.remote.host)
                disp(['ALOHA has been launched on the local host for optimizing density in front of the grill'])
            else
                disp(['ALOHA has been launched on host : ',job.remote.host,' for optimizing density in front of the grill'])
            end
            %
            antenna.job = job;
            antenna.sc = sc;
            %
            clear job
            %
            return
        else
            return
        end
    else
        %
        [err,job,sc] = matremote_jd(antenna.job);%check if job is done 
        %
        if isempty(err) 
            if ~isempty(sc) 
                %
                clear job
                antenna = rmfield(antenna,'job');
                antenna = rmfield(antenna,'sc');
                %
                disp(['ALOHA job is done. Post-processing for optimal density starts.']);
                %
                antenna.aloha = sc;
                antenna = aloha_process_yp(antenna,rc,eps_rc,dkepath,scheduler);    
                %
            else
                %
                if isempty(job.remote.host)
                    disp(['ALOHA is running on the local host'])
                else
                    disp(['ALOHA is running on host : ',job.remote.host])
                end
                %
                clear job
                %
                return
            end
        else
            return
        end
    end
end
%




