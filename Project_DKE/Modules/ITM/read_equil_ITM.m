function [equil_LUKE,status,result] = read_equil_ITM(dkepath,user,machine,ver,numshot,numrun,time,method)
%LUKE - Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 6,error('Not enough input arguments in read_equil_ITM.m');end
%
if nargin == 6,
	time = 1;%First time only
	method == 1;Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
if nargin == 7,
	method == 1;Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
if ~strcmp(dkepath.hostname,'efdaitm'),
	status = -2;
	result = ['Remote access to the ITM MDS+ database from ',dkepath.hostname,' not yet implemented !'];
	equil_LUKE = [];
	return;
end
%
[ustatus,uresult] = unix(['source ',dkepath.local_root,'scripts/set_itm_data_env ',user,' ',machine,' ',ver]);
if ustatus,
	status = -1;
	result = ['Unsuccessful connexion to the ITM MDS+ database for the machine: ',machine,', user: ',user,'and version:',ver];
	equil_LUKE = [];
	return;
end
%
status = 0;
result = '';
%
import ualmemory.javainterface.*;
expIdx = openBD('euitm',numshot,numrun);%Open the database
%
if isnan(time),%All data are get
	equil = CPO_get(expIdx,'equilibrium');%Read magnetic equilibrium
	coreprof = CPO_get(expIdx,'coreprof');%Read data profile
else
	equil = CPO_get(expIdx,'equilibrium',time,method);%Read magnetic equilibrium
	coreprof = CPO_get(expIdx,'coreprof',time,method);%Read data profile
end
%
closeBD(expIdx,'euitm',numshot,numrun);%Close the currently open database
%
%--------------------------- Data conversion between ITM CPO's and C3PO/LUKE format ------------------
%
equil_LUKE = '';
keyboard