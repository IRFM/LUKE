function [CPO] = loadCPO(varargin)
%LUKE - Function that load CPOs from ITM MDS+ database
%
%Function that load CPOs from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if length(varargin) < 4,error('Not enough input arguments in loadCPO.m');end
%
if ischar(varargin{4}),%Simulation is identified by the shot and run numbers
	expIdx = varargin{1};
	time = varargin{2};
	method = varargin{3};
	i_struct_ref = 4;
elseif ischar(varargin{5}),%Simulation is identified by the shot and run numbers
	numshot = varargin{1};
	numrun = varargin{2};
	time = varargin{3};
	method = varargin{4};
	i_struct_ref = 5;
end
%
import ualmemory.javainterface.*;
%
if i_struct_ref > 4,
	expIdx = openBD('euitm',numshot,numrun);%Open the database by the shot and run numbers
end
%
for i_struct = i_struct_ref:length(varargin),
	if isnan(time),%All data are loaded
		CPO{i_struct - i_struct_ref + 1} = CPO_get(expIdx,varargin{i_struct});%Read CPO
    else,%Only data at a given time are loaded
		CPO{i_struct - i_struct_ref + 1} = CPO_get(expIdx,varargin{i_struct},time,method);%Read CPO
    end
end
%
closeBD(expIdx,'euitm',numshot,numrun);
%


