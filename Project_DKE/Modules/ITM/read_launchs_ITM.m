function [launchs] = read_launchs_ITM(numshot,numrun,time,time_interp)
%LUKE - Function that build a LUKE compliant launchs (multiple antennas) structure from ITM MDS+ database
%
%Function that build a LUKE compliant launchs (multiple antennas) structure from ITM MDS+ database 
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in read_launchs_ITM.m');end
%
if nargin == 2,
	time = 0;%Time is zero when the variable is not transfered
	time_interp = 1;%Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
if nargin == 3,
	time_interp = 1;%Time interpolation (1:linear,2:******,3:nearest neighbor)
end
%
status = 0;
launchs = [];
%
try
	expIdx = euitm_open('euitm',numshot,numrun);%Open the ITM MDS+ database
	%
	antennas_euitm = euitm_get_slice(expIdx,'antennas',time,time_interp);%Read antennas data 
	%
	info_dke_yp(4,'The ANTENNAS data structure successfully loaded from the ITM-MDS+ database.');
	%
	euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database
	%
	if isempty(antennas_euitm.datainfo.whatref.machine),
		id = ['euitm_shot_',int2str(numshot),'_run_',int2str(numrun),'_time_',int2str(time),'_timeinterp_',int2str(time_interp)];
		antennas_euitm.datainfo.whatref.machine = id;
		info_dke_yp(6,['The field antennas_euitm.datainfo.whatref.machine is empty -> the reference id is enforced to ',id]);
	end
catch
	status = -1;
	info_dke_yp(7,'Problem while reading the ITM-MDS+ database. Data may not exist.')
end
%
if ~status & nargout == 1, 
	launchs = CPO2LUKEstruct_yp('antennas',antennas_euitm);% Data conversion between ITM CPO's and C3PO/LUKE format
end
