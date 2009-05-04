%LUKE - Script for writing an ITM-CPOs (read/write) from Matlab
%
%Script for for writing an ITM-CPOs (read/write) from Matlab
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
[dkepath] = load_structures_yp('dkepath','','');
%
% LUKE magnetic equilibrium list in ITM MDS+ database
%
disp('---------------------------------------------------')
disp('LUKE magnetic equilibrium list in ITM MDS+ database')
for iequil = 1:LUKE2ITM(dkepath,'equil'),
	[equil_name{iequil},path_equil{iequil}] = ITM2LUKE(dkepath,'equil',iequil);
	disp([' - ', int2str(iequil),': ',equil_name{iequil}])
end
disp('---------------------------------------------------')
%
numshot = input_dke_yp('Shot number',[1:length(equil_name)]);
if length(numshot) > 1, numshot = numshot(1);end
numrun = input_dke_yp('Run number',1);
%
[machine,user,ver] = which_MDSdatabase(dkepath);%Check access to database (Environment variable must be set-up before launching MatLab)
if isempty(machine) | isempty(user) | isempty(ver),
	disp(['WARNING: Unsuccessful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
else
	disp(['Successful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
	[equil] = load_structures_yp('equil',equil_name{numshot},path_equil{numshot});
	[status,result] = write_equil_ITM(equil,numshot,numrun);
	%
	if ~status,
		disp(['LUKE magnetic equilibrium ',equil_name{numshot},' successfully writen in the ITM-MDS+ database']);
	else
		disp(result);
	end
end
%

