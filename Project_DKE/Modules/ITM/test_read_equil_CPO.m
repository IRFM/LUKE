%LUKE - Script for reading ITM-CPOs (read/write) from Matlab
%
%Script for reading to ITM-CPOs (read/write) from Matlab
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
dkepath = load_structures_yp('dkepath','','');
%
machine = input_dke_yp('Machine name','test');
user = input_dke_yp('User name','public');
ver = input_dke_yp('Database version','4.06d');
%
numshot = input_dke_yp('Shot number',3);
numrun = input_dke_yp('Run number',1);
%
time = input_dke_yp('Time value (s)',NaN);%Get all times if NaN
method = input_dke_yp('Time interpolation (1:linear,2:****, 3:nearest neighbor)',[1:3]);%Time interpolation (1:linear,2:****,3:nearest neighbor)
%
equil = read_equil_ITM(dkepath,machine,user,ver,numshot,numrun,time,method);
%
