%LUKE - Script for reading ITM-CPOs (read/write) from Matlab
%
%Script for reading to ITM-CPOs (read/write) from Matlab
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
dkepath = load_structures_yp('dkepath','','');
%
numshot = input_dke_yp('Shot number',1);
numrun = input_dke_yp('Run number',1);
%
time = input_dke_yp('Time value (s)',NaN);%Get all times if NaN
method = input_dke_yp('Time interpolation (1:linear,2:****, 3:nearest neighbor)',[1:3]);%Time interpolation (1:linear,2:****,3:nearest neighbor)
%
[machine,user,ver] = which_MDSdatabase(dkepath);%Check access to database (Environment variable must be set-up before launching MatLab)
if isempty(machine) | isempty(user) | isempty(ver),
	disp(['WARNING: Unsuccessful connexion to ITM MDS+ database, user: ',user,', database version',ver,', machine: ',machine]);
else
	disp(['Successful connexion to ITM MDS+ database, user: ',user,', database version',ver,', machine: ',machine]);
	[equil,status,result] = read_equil_ITM(numshot,numrun,time,method);
	%
	if ~status,
		disp('LUKE magnetic equilibrium successfully read from the ITM-MDS+ database');
	else
		disp(result);
	end
end
