%LUKE - Script for reading ITM-CPOs (read/write) from Matlab
%
%Script for reading to ITM-CPOs (read/write) from Matlab
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
time = input_dke_yp('Time value (s)',NaN);%Get all times if NaN
method = input_dke_yp('Time interpolation (1:linear,2:****, 3:nearest neighbor)',[1:3]);%Time interpolation (1:linear,2:****,3:nearest neighbor)
%
[machine,user,ver] = which_MDSdatabase(dkepath);%Check access to database (Environment variable must be set-up before launching MatLab)
if isempty(machine) | isempty(user) | isempty(ver),
	disp(['WARNING: Unsuccessful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
else
	disp(['Successful connexion to ITM MDS+ database, user: ',user,', database version: ',ver,', machine: ',machine]);
	[equil_CPO,status,result] = read_equil_ITM(numshot,numrun,time,method);
	%
	if ~status,
		disp(['LUKE magnetic equilibrium ',equil_name{numshot},' successfully read from the ITM-MDS+ database']);
	else
		disp(result);
	end
end
%
disp('-----------------------------------------------------------------------------------------------------------------');
disp('Comparison between original LUKE magnetic equilibrium structure and the structure read from the ITM-MDS+ database');
disp('-----------------------------------------------------------------------------------------------------------------');
try,
	[equil_LUKE] = load_structures_yp('equil',equil_name{numshot},path_equil{numshot});
	totcomp = comp_struct_jd(equil_LUKE,equil_CPO,1);
catch
	disp(['Fail to load ',equil_name{numshot},' LUKE magnetic equilibrium !']);
end
%