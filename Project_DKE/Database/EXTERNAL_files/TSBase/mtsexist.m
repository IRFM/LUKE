function youts = mtsexist(shotnumbers,signal)
%
%LUKE : multple load of signals from Tore Supra database
%
%   Input:
%
%       shotnumbers: array of shot numbers (ex: [45465,32299])
%       signal : structure of signal types (ex: 'GPROFTEFIT' for tprof data available)
%
%   Output:
%
%	youts: result structure 
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
if nargin < 2
    error('');
end
%
youts = [];
%
for ii = 1:length(shotnumbers) % load all shot numbers
    %
    youts{ii} = tsexist(shotnumber(ii),signal);%
    %
end