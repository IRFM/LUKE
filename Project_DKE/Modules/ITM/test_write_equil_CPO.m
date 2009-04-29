%LUKE - Script for writing an ITM-CPOs (read/write) from Matlab
%
%Script for for writing an ITM-CPOs (read/write) from Matlab
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath,equil] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil);
%
machine = input_dke_yp('Machine name',id_equil);
user = input_dke_yp('User name','LUKE');
ver = input_dke_yp('Database version','4.06d');
%
numshot = input_dke_yp('Shot number',1);
numrun = input_dke_yp('Run number',1);
%
equil = write_equil_ITM(dkepath,machine,user,ver,numshot,numrun);
