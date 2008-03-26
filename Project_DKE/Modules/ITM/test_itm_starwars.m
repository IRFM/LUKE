%
%Test program for the itm_starwars function (C3PO/LUKE for ITM simulator)
%
numshot = 11;%Solovied equilibrium
numshot_ref = 11;%Solovied equilibrium
%
numshot = 13;%Helena magnetic equilibrium
numshot_ref = 13;%Helena magnetic equilibrium
numrun= 1;
numrun_ref = 0;
time = [1.0,1.2];
interp_method = 1;%Time interpolation (1: linear, 2:   ,3: nearest neighbor interpolation)
%
flag = itm_starwars(numshot,numrun,numshot_ref,numrun_ref,time,interp_method);
%
