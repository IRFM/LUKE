%LUKE - Script for writing a LUKE magnetic equilibrium structure in the ITM MDS+ database
%
%Script for writing a LUKE magnetic equilibrium structure in the ITM MDS+ database. LUKE scenarios
% are numbered from the magnetic equilibrium list given in the MatLab function LUKEITM.m
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
[dkepath] = load_structures_yp('dkepath','','');
%
% List of LUKE scenarios in the ITM MDS+ database.
%
disp('---------------------------------------------------------------------------------------------------------')
disp('List of LUKE magnetic equilibrium. See MatLab function LUKEITM.m for adding a new equilibrium.')
for iequil = 1:LUKE2ITM(dkepath,'equil'),
	[equil_name{iequil},path_equil{iequil}] = ITM2LUKE(dkepath,'equil',iequil);
	disp([' - ',equil_name{iequil}])
end
disp('---------------------------------------------------------------------------------------------------------')
%
numshot = '';
while isempty(numshot),
	numshot = LUKE2ITM(dkepath,'equil',input_dke_yp('Equilibrium name',equil_name{1}));
end
numrun = 1;%Default value for LUKE tests
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
		disp(['LUKE magnetic equilibrium ''',equil_name{numshot},''' successfully written in the ITM-MDS+ database for scenario ',int2str(numshot),'.']);
	else
		disp(result);
	end
end
%

