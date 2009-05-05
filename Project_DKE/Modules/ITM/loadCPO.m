function [CPO] = loadCPO(struct_name,numshot,numrun,time,method)
%LUKE - Function that load a CPO from ITM MDS+ database
%
%Function that load a CPO from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 3,error('Not enough input arguments in loadCPO.m');end
if nargin == 3,
	time = NaN;
	method = '';
end
%
import ualmemory.javainterface.*;
%
expIdx = openBD('euitm',numshot,numrun);%Open the database
%
if isnan(time),%All data are get
	CPO = CPO_get(expIdx,struct_name);%Read CPO
else
	CPO = CPO_get(expIdx,struct_name,time,method);%Read magnetic equilibrium
end
%
closeBD(expIdx,'euitm',numshot,numrun);