function [varargout] = sluke(varargin)
%



%{
if length(sdata.inputs.simulation.shotnumbers) == length(sdata.inputs.simulation.times)
    %
    for ii = 1:length(sdata.inputs.simulation.shotnumbers)
        %
        sdata.outputs(ii).shotnumber = sdata.inputs.simulation.shotnumbers(ii);
        sdata.outputs(ii).times = sdata.inputs.simulation.times(ii);

    end 
    %
else
    if length(sdata.inputs.simulation.shotnumbers) >= 1 && length(sdata.inputs.simulation.times) == 1
        for ii = 1:length(sdata.inputs.simulation.shotnumbers)

        end
    elseif length(sdata.inputs.simulation.times) >= 1 && length(sdata.inputs.simulation.shotnumbers) == 1
                for ii = 1:length(sdata.inputs.simulation.times)

        end
        
    else
        %
        sdata.output.err = 'Inconsistent input data');
        %
    end
    % 
end
%








if ~isfield(sdata,'job')

%
if ~isstruct(sdata.sinputs)% new job
    %
    remote = dkepath.remote(scheduler.remnum);
    remote.timeout = 0;%Don't wait until ALOHA job is done
    %
    job = matstandardjob_jd('runmat');%new job
    job.remtimout = 0;%Don't wait until ALOHA job is done
    %
    machine = sinputs;
    %
    tmin = real(t);
    tmax = image(t);
    %
    [err,job,soutputs] = matremote_jd('sluke_remote',{machine,shotnumber,tmin,tmax,sparams},remote,job);%fixed density in front of the grill
    %
    if ~isempty(err)
        soutputs(ii).err = err;
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
%}