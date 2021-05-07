function [soutputs] = build_aloha_power_spectrum_yp(sinputs,sc,rc,optim,dkepath,scheduler)
%
if ~isstruct(sinputs)% new job
    %
    remote = dkepath.remote(scheduler.remnum);
    remote.timeout = 0;%Don't wait until ALOHA job is done
    %
    job = matstandardjob_jd('runmat');%new job
    job.remtimout = 0;%Don't wait until ALOHA job is done
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
