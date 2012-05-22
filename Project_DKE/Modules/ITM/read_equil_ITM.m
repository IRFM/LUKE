function [equil] = read_equil_ITM(numshot,numrun,time,time_interp,display_mode,save_mode)
%LUKE - Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in read_equil_ITM.m');end
%
if nargin == 2,
	time = 0;%Time is zero when the variable is not transfered
	time_interp = 1;%Time interpolation (1:linear,2:******,3:nearest neighbor)
	display_mode = 0;%display option
    save_mode = 0;%save euitm datastructure in a mat-file
end
%
if nargin == 3,
	time_interp = 1;%Time interpolation (1:linear,2:******,3:nearest neighbor)
	display_mode = 0;%display option
	save_mode = 0;%save euitm datastructure in a mat-file
end
%
if nargin == 4,
	display_mode = 0;%display option
	save_mode = 0;%save euitm datastructure in a mat-file
end
%
if nargin == 5,
	save_mode = 0;%save euitm datastructure in a mat-file
end
%
status = 0;
equil = [];
%
try
	expIdx = euitm_open('euitm',numshot,numrun);%Open the ITM MDS+ database
	%
	equil_euitm = euitm_get_slice(expIdx,'equilibrium',time,time_interp);%Read 'equilibrium' CPO
	coreprof_euitm = euitm_get_slice(expIdx,'coreprof',time,time_interp);%Read 'coreprof' CPO
	%
	info_dke_yp(4,'EQUILIBRIUM and COREPROF data structures successfully loaded from the ITM-MDS+ database.');
	%
	euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database
	%
	if isempty(equil_euitm.datainfo.whatref.machine),
		id = ['euitm_shot_',int2str(numshot),'_run_',int2str(numrun),'_time_',int2str(time),'_timeinterp_',int2str(time_interp)];
		equil_euitm.datainfo.whatref.machine = id;
		info_dke_yp(6,['The field equil_euitm.datainfo.whatref.machine is empty -> the reference id is enforced to ',id]);
	else
		id = equil_euitm.datainfo.whatref.machine;
	end
catch
	status = -1;
	info_dke_yp(7,'Problem while reading the ITM-MDS+ database : ''equilibrium'' and ''coreprof'' data may not exist.')
end
%
if ~status & nargout == 1,
	if save_mode,
		save(['equil_',id],'equil_euitm','coreprof_euitm')
	end
	%
    equil = process_euitm_dataequil(equil_euitm,coreprof_euitm,display_mode);
end
