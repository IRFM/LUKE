%
%Test program for the itm_starwars function (C3PO/LUKE for ITM simulator)
%
dkepath = load_structures_yp('dkepath','','');
%
numshot = 3;
numrun= 1;
time = 1;
interp_method = 1;%Time interpolation (1: linear,2:***,3:nearest neighbor interpolation)
%
flag = itm_starwars(numshot,numrun,time,interp_method);
%
