%LUKE - Script for writing all magnetic equilibrium used by LUKE into the ITM MDS+ database
%
%Script for writing all magnetic equilibrium used by LUKE into the ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
equil_LUKE = {};
equil_name = {};
path_equil = {};
%
[dkepath] = load_structures_yp('dkepath','','');
%
% Magnetic equilibria from ~/LUKE/Project_DKE/Database/EQUIL_files/
%
for numshot = 1:LUKE2ITM(dkepath,'equil'),
	[equil_name{numshot},path_equil{numshot}] = ITM2LUKE(dkepath,'equil',numshot);
	try,
		if numshot > 6,dirini = pwd;execute_Mscript_dke_yp(['make_equil_',equil_name{numshot}],path_equil{numshot});cd(dirini);end
		equil_LUKE{numshot} = load_structures_yp('equil',equil_name{numshot},path_equil{numshot});		
	catch,
		equil_LUKE{numshot} = '';
		disp(['Fail to load ',equil_name{numshot},' LUKE magnetic equilibrium !']);
	end
end
%
[machine,user,ver] = which_MDSdatabase(dkepath);%Check access to database (Environment variable must be set-up before launching MatLab)
%
if isempty(machine) | isempty(user) | isempty(ver),
	disp(['WARNING: Unsuccessful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
else
	disp(['Successful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
	numrun = 1;
	for numshot = 1:length(equil_LUKE),
		if ~isempty(equil_LUKE{numshot}),
			[status,result] = write_equil_ITM(equil_LUKE{numshot},numshot,numrun);
			if ~status,
				disp(['LUKE magnetic equilibrium ',equil_name{numshot},' successfully writen in the ITM-MDS+ database']);
			else
				disp(result);
			end
		end
	end
end
%

