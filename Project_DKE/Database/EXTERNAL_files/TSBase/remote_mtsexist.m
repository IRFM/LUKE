function [youts]= remote_mtsexist(sinputs,nom_donnee,remote_enforce)
%
%LUKE -  Function used to retrieve informations on a signal contained in the database without having to access the data. It interfaces the TSExist function of TsLib to Matlab
%
%   Input:
%
%       sinputs : array shot numbers [num1,num2,num3]
%       nom_donnee : data name ('GPROFTEFIT' for tprof data available)
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
%
%   Output:
%
%       youts: result structure 
% 
%   Outputs of tsexist : 
%
%       cr			:	compte rendu d'execution ( 0 = ok , 3 ou 10 = donnee inconnue ,7, 8 ou 9 = donnee nom produite pour ce choc)
%       nb_mesures	:	vecteur a trois elements , le premier indique le nombre de temps, le second le nombre de voies pour un groupe et le troisieme est generalement pas utiliser
%	    num_version	=	numero de la version du producteur de la donnee
%	    certif		=	vecteur des certification pour les donnees traitees (a 0 ou -2 pour les donnees brutes)
%       date & heure=	date et heure de production
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
youts = [];
%
if nargin < 2
     error('Not enough input argument in remote_mtsexist.m');
end
%
if ~isstruct(sinputs)% new job
    %
    if nargin < 3
        remote_enforce = 0;
    end
    %
    flag_remote = 0;
    %
    if remote_enforce == 0 %try first direct access
        %
        if ~isempty(which('mtsexist'))
            %
            if ~isreal(sinputs)
                %
                num_chocs = imag(sinputs);
                %
            else
                %
                num_chocs = sinputs;
                %
            end    
            %
            [youts] = mtsexist(real(num_chocs),nom_donnee);%
            %
            if isempty(youts)
                %
                cprintf([1,0.5,0],['---> Direct access to mtsexist failed. Remote access to mtsexist is performed.']);disp(' ')
                flag_remote = 1;
                %
            end
            %
        else
            %
            flag_remote = 1;
            cprintf([1,0.5,0],['---> The mex function of mtsexist does not exist. Compile it first in ~/Project_DKE/Database/EXTERNAL_files/TSBase/TSBase/ folder. Remote access to mtsexist is performed.']);disp(' ')
            %
        end
        %
    else
        %
        flag_remote = 1;
        cprintf([1,0.5,0],['---> Remote access to mtsexist is enforced.']);disp(' ')
        %
    end
    %
    if flag_remote == 1
        %
        [remote,err] = remote_cea;
        %
        if err == 0
            %
            cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ')
            %
            remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
            remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
            %
            if remote_enforce == 0
                remote.link_mode='';
            else
                remote.link_mode=1;
            end
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
                num_chocs = imag(sinputs);
                job.wait = 0;% (0) return hand (1) wait for result
                job.remtimout = 0;% in minutes
                remote.timeout = 0;%Don't wait until ALOHA job is done
            else
                num_chocs = sinputs;
                job.wait = 1;%1;% (0) return hand (1) wait for result
                job.remtimout = 10;% in minutes
            end    
            %
            [err,job,youts] = matremote_jd('mtsexist',{num_chocs,nom_donnee},remote,job);
            %
            if ~isempty(err)
                youts.err = err;
            elseif ~isempty(youts) % job completed
                youts = youts;
            else
                youts.job = job;
            end
            %
        else
            %
            cprintf('red*','---> ALTAIR, ANDROMEDE and SIRRAH are all unreachable for remote_mtsexist.m. Check the connection parameters (ssh and bridge.ssh).');disp(' ')
            %
        end 
        %
    end
    %
else %previously running job
    %
    if isfield(sinputs,'job') 
        %
        [err,job,youts] = matremote_jd(sinputs.job);
        %
        if ~isempty(err) 
            youts.err = err;
        elseif ~isempty(youts) % job completed
            youts = youts;
        else
            youts.job = job;
        end
        %
   else% previously completed jobs
        %
        youts = sinputs;
        %
    end
    %
end
