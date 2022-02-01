function [soutputs] = build_aloha_power_spectrum_yp(sinputs,sc,rc,optim,dkepath,scheduler)
%
if ~isstruct(sinputs)% new job
    %
    if scheduler.remnum == 0 %local run if ALOHA is installed
        %
        if isempty(rc)
            %
            soutputs = aloha_scenario(sc);
            %
        else
            %
            soutputs = aloha_process_yp(sc,rc,optim);
            %
        end
        %
    else
        %
        remote = dkepath.remote(scheduler.remnum);
        %
        if isfield(scheduler,'timeout') && scheduler.timeout > 0
            %
            remote.timeout = scheduler.timeout;%Wait until ALOHA job is done
            cprintf('*blue',['---> Waiting for ALOHA results is enforced. Calculations may take several minutes. ']);disp(' ')
            %
        else
            %
            remote.timeout = 0;%Don't wait until ALOHA job is done
            %
        end
        %
        job = matstandardjob_jd('runmat');%new job
        %
        if isfield(scheduler,'timeout') && scheduler.timeout > 0
            %
            job.timeout = scheduler.timeout;%Wait until ALOHA job is done
            %
        else
            %
            job.remtimout = 0;%Don't wait until ALOHA job is done
            %
        end
        %
        %sc = aloha_ondemand_scenario(shotnum, tmin, tmax, ne0,[gradne1,gradne2],port);%for a direct test of ALOHA
        %sc = aloha_scenario(sc);
        %
        if isempty(rc)
            %
            [err,job,soutputs] = matremote_jd('aloha_scenario',{sc},remote,job);%fixed density in front of the grill
            %
        else
            %
            [err,job,soutputs] = matremote_jd('aloha_process_yp',{sc,rc,optim},remote,job);%find the optimum density in front of the grill consistently with RC measurements
            %
        end
        %
        if ~isempty(err)
            soutputs.err = err;
        elseif ~isempty(soutputs) % job completed
            soutputs = soutputs;
        else
            soutputs.job = job;
        end
        %   
    end
else %previously running job
    %
    if isfield(sinputs,'job') 
        %
        [err,job,soutputs] = matremote_jd(sinputs.job);
        %
        if ~isempty(err) 
            soutputs.err = err;
        elseif ~isempty(soutputs) % job completed
            soutputs = soutputs;
        else
            soutputs.job = job;
        end
        %
   else% previously completed jobs
        %
        soutputs = sinputs;
        %
    end
    %
end
%
