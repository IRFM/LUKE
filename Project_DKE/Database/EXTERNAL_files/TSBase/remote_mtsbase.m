function [soutputs]= remote_mtsbase(sinputs,signals)
%
%LUKE -  Function which load multiple signals from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		sinputs : shot number (real number for waiting results or imaginary number for giving hand after launching function and getting back data later) or data structure (with or without job for remote calculations)
%		signals : structure of signal types (ex: {'gphyb','gphase'})
%
%   Output:
%
%       soutputs : signals structure
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
soutputs = [];
%
if nargin < 2
     error('Not enough input argument in remote_mtsbase.m');
end
%
if ~isstruct(sinputs)% new job
    %
    remote = remote_cea;
    %
    if isstruct(remote)
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
        %
        remote.matver.matdef = remote.matver.mat903;%enforce Matlab R2013b for tsbase only
        %                      
        job = matstandardjob_jd;
        job.env.remotematfnc = 'runmat';
        %
        job.funcopy = true;
        job.localdatapath = [pwd,filesep];
        %
        job.displaymode = 0;
        job.debugmode = 1;
        %
        job.nodes = 1;%number of nodes required
        job.ppn = 1;%number of cores required
        job.memory = 2000;% memory required (in mb) - leave empty if no requirement
        job.walltime = 5;%[];% time required (integers - in hours) - leave empty if no requirement
        job.rempause = 1/60;% in minutes
        %
        if ~isreal(sinputs)
            shotnumber = imag(sinputs);
            job.wait = 0;% (0) return hand (1) wait for result
            job.remtimout = 0;% in minutes
            remote.timeout = 0;%Don't wait until ALOHA job is done
        else
            shotnumber = sinputs;
            job.wait = 1;%1;% (0) return hand (1) wait for result
            job.remtimout = 10;% in minutes
        end    
        %
        [err,job,soutputs] = matremote_jd('mtsbase',{shotnumber,signals},remote,job);
        %
        if ~isempty(err)
            soutputs.err = err;
        elseif ~isempty(soutputs) % job completed
            soutputs = soutputs;
        else
            soutputs.job = job;
        end
        %
    else
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
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




























