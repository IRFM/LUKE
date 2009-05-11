function [flag] = writeCPO(varargin)
%LUKE - Function that write data in the ITM MDS+ database using the CPO format
%
%Function that write data in the ITM MDS+ database using the CPO format
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
%TODO: write this Matlab function once itm_starwars.m is done
%
flag = pi;

