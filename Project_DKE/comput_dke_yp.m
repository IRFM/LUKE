function [s,dossier,machine] = comput_dke_yp
%
%
%	Computer look-up for data management
%
%	Input: none
%
%	Output:
%
%		- s: separator used for the machine (string) [1,1]
%		- dossier: root directory (string) [1,m]
%		- machine: computer name (string) [1,m]
%
%by Y.PEYSSON CEA-DRFC 05/12/94 <yves.peysson@cea.fr>
% 
machine = computer;
if strcmp(machine,'ALPHA') == 1,
	s = '/';
	dossier = '/usr/drfc/peysson';
elseif strcmp(machine,'PC') == 1,
	s = '\';
   	dossier = 'c:\';
elseif strcmp(machine,'PCWIN') == 1,
	s = '\';
   	dossier = 'c:\work\temp';
elseif strcmp(machine,'MAC') == 1,
	s = '/';
   	dossier = '/Volumes/Ailefroide/CVS/Project_DKE';
elseif strcmp(machine,'MAC2') == 1,
	s = ':';
	dossier = 'Ailefroide:CVS:Project_DKE';
end
