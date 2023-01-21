function [youts]= remote_mtsexist(sinputs,nom_donnee)
%
%LUKE -  Function used to retrieve informations on a signal contained in the database without having to access the data. It interfaces the TSExist function of TsLib to Matlab
%
%   Input:
%
%       sinputs : array shot numbers [num1,num2,num3]
%       nom_donnee : data name ('GPROFTEFIT' for tprof data available)
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
if ~isstruct(sinputs)% new job
    %
    remote = remote_cea;
    %
    if isstruct(remote)
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ')
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
            remote.timeout = 0;%Don't wait until job is done
        else
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
         if isempty(remote)
            %
            cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
            %
        else
            %
            [youts] = mtsexist(num_chocs,nom_donnee);
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
