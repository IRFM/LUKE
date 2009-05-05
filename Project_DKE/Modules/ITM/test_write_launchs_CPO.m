%LUKE - Script for writing a LUKE launchs structure in the ITM MDS+ database
%
%Script for writing a LUKE launchs structure in the ITM MDS+ database. LUKE scenarios
% are numbered from the magnetic equilibrium list given in the MatLab function LUKEITM.m
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
disp('---------------------------------------------------------------------------------------------------------')
disp('List of LUKE waves. See MatLab function LUKEITM.m for adding new waves.')
for iwave = 1:LUKE2ITM(dkepath,'wave'),
	[wave_name{iwave},path_wave{iwave}] = ITM2LUKE(dkepath,'wave',iwave);
	disp([' - ',wave_name{iwave}])
end
disp('---------------------------------------------------------------------------------------------------------')
%
numwave = '';
numshot = '';
%
while isempty(numwave),
	numwave = LUKE2ITM(dkepath,'wave',input_dke_yp('Wave name',wave_name{1}));
end
%
for iequil = 1:LUKE2ITM(dkepath,'equil'),
	if strfind(ITM2LUKE(dkepath,'wave',numwave),ITM2LUKE(dkepath,'equil',iequil)),
		[equil_name,path_equil] = ITM2LUKE(dkepath,'equil',iequil);
		numshot = iequil;
		break;
	end
end
%
if isempty(numshot),
	error('The chosen wave structure has no attached magnetic equilibrium. See MatLab function LUKEITM.m')
else
	numrun = 1;%Default value for LUKE tests
	%
	[machine,user,ver] = which_MDSdatabase(dkepath);%Check access to database (Environment variable must be set-up before launching MatLab)
	if isempty(machine) | isempty(user) | isempty(ver),
		disp(['WARNING: Unsuccessful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
	else
		disp(['Successful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
		[equil,wave] = load_structures_yp('equil',equil_name,path_equil,'waves',wave_name{numwave}(length(['WAVE_',equil_name])+2:end),path_wave{numwave});
		[status,result] = write_launchs_ITM(wave,numshot,numrun);
		%
		if ~status,
			disp(['LUKE ''launch'' structure successfully written in the ITM-MDS+ database for scenario ',int2str(numshot),'.']);
		else
			disp(result);
		end
	end
end
%

