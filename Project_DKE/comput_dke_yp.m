function [s,dossier,machine,mex] = comput_dke_yp
%
%	Computer look-up for data and file management
%
%	Input: none
%
%	Output:
%
%		- s: separator used for the machine (string) [1,1]
%		- dossier: root directory (string) [1,m]
%		- machine: computer name (string) [1,m]
%		- mex: mex file extension (string) [1,m]
%
%by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
% 
machine = computer;
if strcmp(machine,'ALPHA') == 1,
	s = '/';
	dossier = '/usr/drfc/peysson';
	mex = '.mexaxp';
elseif strcmp(machine,'PC') == 1,
	s = '\';
   dossier = 'c:\';
	mex = '.dll';
elseif strcmp(machine,'PCWIN') == 1,
	s = '\';
   dossier = 'c:\temp';
	mex = '.dll';
elseif strcmp(machine,'MAC') == 1,
	s = '/';
   dossier = '/Volumes/Ailefroide/CVS/Project_DKE';
	mex = '.mex';
elseif strcmp(machine,'MAC2') == 1,
	s = ':';
	dossier = 'Ailefroide:CVS:Project_DKE';
	mex = '.mexmac';
end
