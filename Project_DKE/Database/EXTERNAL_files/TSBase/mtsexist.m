% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
if ~isempty(which('tsexist'))
    %
    for ii = 1:length(shotnumbers) % load all shot numbers
        %
        [youts{ii}.cr,youts{ii}.nb_mesures,youts{ii}.num_version,youts{ii}.certif,youts{ii}.date,youts{ii}.heure] = tsexist(shotnumbers(ii),signal);%
        %
    end
    %
end