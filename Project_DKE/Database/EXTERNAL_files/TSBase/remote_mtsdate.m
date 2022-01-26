function [ydates]= remote_mtsdate(sinputs,remote_enforce)
%
%LUKE -  Function which load multipes shot dates from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumbers: list shot number (ex: [32299,45525])
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
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
if ~isstruct(sinputs)% new job
    %
    if nargin < 2
        remote_enforce = 0;
    end
    %
    flag_remote = 0;
    %
    [err_local,txt_local] = unix('hostname');%local client machine
    %
    txt_local = deblank(txt_local);
    %
    if remote_enforce == 0 && isempty(strfind(txt_local,'partenaires.cea.fr')) && isempty(strfind(txt_local,'intra.cea.fr'))
        %
        cprintf([1,0.5,0],['---> Direct access to mtsdate is forbidden outside internal CEA network. Remote access is enforced']);disp(' ')
        remote_enforce = 1;
        %
    end
    %
    if remote_enforce == 0 %try first direct access
        %
        if ~isempty(which('tsdate'))
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
            [ydates] = mtsdate(shotnumbers);%
            %
            if isempty(ydates)
                %
                cprintf([1,0.5,0],['---> Direct access to mtsdate failed. Remote access to mtsdate is performed.']);disp(' ')
                flag_remote = 1;
                %
            end
            %
        else
            %
            flag_remote = 1;
            cprintf([1,0.5,0],['---> The mex function of mtsdate does not exist. Compile it first in ~/Project_DKE/Database/EXTERNAL_files/TSBase/TSBase/ folder. Remote access to mtsdate is performed.']);disp(' ')
            %
        end
        %
    else
        %
        flag_remote = 1;
        cprintf([1,0.5,0],['---> Remote access to mtsdate is enforced.']);disp(' ')
        %
    end
    %
    if flag_remote == 1
        %
        [remote,err] = remote_cea;
        %
        if err == 0 && isstruct(remote)
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
                shotnumbers = imag(sinputs);
                job.wait = 0;% (0) return hand (1) wait for result
                job.remtimout = 0;% in minutes
                remote.timeout = 0;%Don't wait until ALOHA job is done
            else
                shotnumbers = sinputs;
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
            cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
            %
        end 
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
