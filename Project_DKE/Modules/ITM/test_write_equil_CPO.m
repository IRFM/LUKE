%LUKE - Script for writing an ITM-CPOs (read/write) from Matlab
%
%Script for for writing an ITM-CPOs (read/write) from Matlab
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath,equil] = load_structures_yp('dkepath','','','equil',id_equil,path_equil);
%
numshot = input_dke_yp('Shot number',1);
numrun = input_dke_yp('Run number',1);
%
[machine,user,ver] = which_MDSdatabase(dkepath);%Check access to database (Environment variable must be set-up before launching MatLab)
if isempty(machine) | isempty(user) | isempty(ver),
	disp(['WARNING: Unsuccessful connexion to ITM MDS+ database, user: ',user,', database version',ver,', machine: ',machine]);
else
	disp(['Successful connexion to ITM MDS+ database, user: ',user,', database version',ver,', machine: ',machine]);
	[status,result] = write_equil_ITM(equil,numshot,numrun);
	%
	if ~status,
		disp('LUKE magnetic equilibrium successfully writen in the ITM-MDS+ database');
	else
		disp(result);
	end
end
%

