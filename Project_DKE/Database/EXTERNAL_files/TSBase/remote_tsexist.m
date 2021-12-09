function [cr,nb_mesures,num_version,certif,date,heure]= remote_tsexist(num_choc,nom_donnee,remote_enforce)
%
%LUKE -  Function used to retrieve informations on a TPROF signal contained in the database without having to access the data. It interfaces the TSExist function of TsLib to Matlab
%
%   Input:
%
%       num_choc : shot number
%       nom_donnee : data name
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
%
%   Output:
%
%       cr			:	compte rendu d'execution ( 0 = ok , 3 ou 10 = donnee inconnue ,7, 8 ou 9 = donnee nom produite pour ce choc)
%       nb_mesures	:	vecteur a trois elements , le premier indique le nombre de temps, le second le nombre de voies pour un groupe et le troisieme est generalement pas utiliser
%	    num_version	=	numero de la version du producteur de la donnee
%	    certif		=	vecteur des certification pour les donnees traitees (a 0 ou -2 pour les donnees brutes)
%       date & heure=	date et heure de production
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
cr = [];
nb_mesures = [];
num_version = [];
certif = [];
date = [];;
heure = [];
%
if nargin < 2,
     error('Not enough input argument in remote_tsexist.m');
end
if nargin < 3
    remote_enforce = 0;
end
%
flag_remote = 0;
%
if remote_enforce == 0 %try first direct access
    %
    if ~isempty(which('tsexist'))
        %
        [cr,nb_mesures,num_version,certif,date,heure] = tsexist(num_choc,nom_donnee);
        %
        if isempty(cr) && isempty(nb_mesures) && isempty(num_version) && isempty(certif) && ~isempty(date) && ~isempty(heure)
            %
            cprintf([1,0.5,0],['---> Direct access to tsexist failed. Remote access to tsexist is performed.']);disp(' ')
            flag_remote = 1;
            %
        end
        %
    else
        %
        flag_remote = 1;
        cprintf([1,0.5,0],['---> The mex function of tsexist does not exist. Compile it first in ~/Project_DKE/Database/EXTERNAL_files/TSBase/TSBase/ folder. Remote access to tsexist is performed.']);disp(' ')
        %
    end
    %
else
    %
    flag_remote = 1;
    cprintf([1,0.5,0],['---> Remote access to tsexist is enforced.']);disp(' ')
    %
end
%
if flag_remote == 1
    %
    [remote,err] = remote_cea;
    %
    if err == 0
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
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
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %
        [err,job,cr,nb_mesures,num_version,certif,date,heure] = matremote_jd('tsexist',{num_choc,nom_donnee},remote,job);
      %
    else
        %
        cprintf('red*','---> ALTAIR, ANDROMEDE and SIRRAH are unreachable for remote_tsexist.m. Check the connection parameters (ssh).');disp(' ')
        %
    end 
    %
end
%
