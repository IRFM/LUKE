function [cr,nb_mesures,num_version,certif,date,heure]= remote_tsexist(num_choc,nom_donnee)
%
%LUKE -  Function used to retrieve informations on a TPROF signal contained in the database without having to access the data. It interfaces the TSExist function of TsLib to Matlab
%
%   Input:
%
%       num_choc : shot number
%       nom_donnee : data name
%
%   Output:
%
%       cr			:	compte rendu d'execution ( 0 = ok , 3 ou 10 = donnee inconnue ,7, 8 ou 9 = donnee nom produite pour ce choc)
%       nb_mesures	:	vecteur a trois elements , le premier indique le nombre de temps, le second le nombre de voies pour un groupe et le troisieme est generalement pas utiliser
%	    num_version	=	numero de la version du producteur de la donnee
%	    certif		=	vecteur des certification pour les donnees traitees (a 0 ou -2 pour les donnees brutes)
%       date & heure=	date et heure de production
%
% NOTE : data are save in a file place in a folder whose path is defined by the environment variable 'EXPERIMENTAL_TOKAMAK_DATA'. This variable must
%be defined in the startup file startup.m -> setenv('EXPERIMENTAL_TOKAMAK_DATA','**************')
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
%
datapath = getenv('EXPERIMENTAL_TOKAMAK_DATA');%folder path
%
if isempty(datapath)
    %
    warning('The environment variable EXPERIMENTAL_TOKAMAK_DATA must be set in the startup.m file. Otherwise, data are stored locally')
    %
end
%
nom_donnee = lower(nom_donnee);%enforce lower case
%
if exist([datapath,'tsexist_',int2str(num_choc),'_',nom_donnee,'.mat'])
    %
    load([datapath,'tsexist_',int2str(num_choc),'_',nom_donnee,'.mat'],'data');
    %
    cr = data.cr;
    nb_mesures = data.nb_mesures;
    num_version = data.num_version;
    certif = data.certif;
    date = data.date;
    heure = data.heure;
    %
    return
    %
end
%
remote = remote_cea;
%
if isstruct(remote)
    %
    [err,txt] = unix('hostname');
    txt = deblank(txt);
    %
    if ~isempty(strfind(txt,'partenaires')) || ~isempty(strfind(txt,'intra'))
        %
        [cr,nb_mesures,num_version,certif,date,heure] = tsexist(num_choc,nom_donnee);
        %
    else
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
        %
        remote.matver.matdef = remote.matver.mat903;%enforce Matlab R2013b for tsbase only
        %
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %
        [err,job,cr,nb_mesures,num_version,certif,date,heure] = matremote_jd('tsexist',{num_choc,nom_donnee},remote,job);
        %
    end
  %
else
    if isempty(remote)
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    else
        %
        [cr,nb_mesures,num_version,certif,date,heure] = tsexist(num_choc,nom_donnee);
        %
    end
    %
end 
%
data.cr = cr;
data.nb_mesures = nb_mesures;
data.num_version = num_version;
data.certif = certif;
data.date = date;
data.heure = heure;
%
save([datapath,'tsexist_',int2str(num_choc),'_',nom_donnee,'.mat'],'data');
%
if isempty(cr)
    %
    disp(['WARNING : tsexist data for discharge #',int2str(num_choc),' are empty.'])
    %
end
