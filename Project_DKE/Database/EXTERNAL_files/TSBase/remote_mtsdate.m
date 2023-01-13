function [ydates]= remote_mtsdate(sinputs)
%
%LUKE -  Function which load multipes shot dates from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumbers: list shot number (ex: [32299,45525])
%
%   Output:
%
%		ydates: structures of shot dates
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
ydates = [];
%
if nargin < 1
     error('Not enough input argument in remote_mtsdate.m');
end
%
if ~isreal(sinputs)
    %
    shotnumbers = imag(sinputs);
    %
else
    %
    shotnumbers = sinputs;
    %
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
            job.wait = 0;% (0) return hand (1) wait for result
            job.remtimout = 0;% in minutes
            remote.timeout = 0;%Don't wait until ALOHA job is done
        else
            job.wait = 1;%1;% (0) return hand (1) wait for result
            job.remtimout = 10;% in minutes
        end    
        %
        [err,job,ydates] = matremote_jd('mtsdate',{shotnumbers},remote,job);
        %
        if ~isempty(err)
            ydates.err = err;
        elseif ~isempty(ydates) % job completed
            ydates = ydates;
        else
            ydates.job = job;
        end
        %
    else
        %
         if isempty(remote)
            %
            cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
            %
        else
            %
            [ydates] = mtsdate(shotnumbers);
            %
        end
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    end 
    %
else %previously running job
    %
    if isfield(sinputs,'job') 
        %
        [err,job,ydates] = matremote_jd(sinputs.job);
        %
        if ~isempty(err) 
            ydates.err = err;
        elseif ~isempty(ydates) % job completed
            ydates = ydates;
        else
            ydates.job = job;
        end
        %
   else% previously completed jobs
        %
        ydates = sinputs;
        %
    end
    %
end
%
for jj = 1:length(ydates)
    %
    if length(ydates{jj}) > 10
        %
        ydates{jj} = ydates{jj}(1:10);%remove possible spurious ending char
        %
    end
end
