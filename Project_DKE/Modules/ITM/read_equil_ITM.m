function [equil_LUKE,status,result] = read_equil_ITM(numshot,numrun,time,method)
%LUKE - Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in read_equil_ITM.m');end
%
if nargin == 2,
	time = 1;%First time only
	method == 1;Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
if nargin == 3,
	method == 1;Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
status = 0;
result = '';
equil_LUKE = '';
%
try
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
catch
	status = -1;
	result = 'Error for reading the database. Data may not exist !';
end
%
%--------------------------- Data conversion between ITM CPO's and C3PO/LUKE format ------------------
%
%TODO: Data conversion between ITM CPO's and C3PO/LUKE format
%
equil_LUKE = equil;
