function [CPO] = loadCPO(varargin)
%LUKE - Function that load CPOs from ITM MDS+ database
%
%Generic function that load CPOs from ITM MDS+ database
%
%   INPUT:
%
%       - numshot: shot number [1,1]
%       - numrun: simulation run number [1,1]
%       - time: time (if NaN all times are retrived in one pass) [1,1]
%       - time_interp = time interpolation method (CLOSEST_SAMPLE = 1, PREVIOUS_SAMPLE = 2 or INTERPOLATION = 3) [1,1]
%       - list of CPO names ('equilibrium', 'coreprof', 'antennas',...) [1,p]
%
%   OUTPUT:
%   
%       - list of itm structures corresponding to the list of input CPO names ('equilibrium', 'coreprof', 'antennas',...) [1,p]
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if length(varargin) < 5,error('Not enough input arguments in loadCPO.m');end
%
numshot = varargin{1};
numrun = varargin{2};
time = varargin{3};
time_interp = varargin{4};
%
CPO = [];
%
try
	expIdx = euitm_open('euitm',numshot,numrun);%Open the ITM MDS+ database%Open the database by the shot and run numbers
	%
	i_struct_ref = 5;
	%
	for i_struct = i_struct_ref:length(varargin),
		if isnan(time),
			CPO{i_struct - i_struct_ref + 1} = euitm_get(expIdx,varargin{i_struct});%Retrieve the whole set of CPO(s) from the open database
    	else
			CPO{i_struct - i_struct_ref + 1} = euitm_get_slice(expIdx,varargin{i_struct},time,time_interp);%retrieves the CPO slice in the open database corresponding to the passed time, based on the selected interpolation mode.
    	end
	end
	%
	euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database
catch
	info_dke_yp(7,'Problem while reading the ITM-MDS+ database');
	euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database
end
%
