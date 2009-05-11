%LUKE - Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%
%Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%Part of this script may be used readily in the KEPLER actor
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
shot = 13;
run= 1;
time = NaN;
method = 1;
%
dkepath = load_structures_yp('dkepath','','');
%
flag = writeCPO(shot,run,NaN,1,itm_starwars(loadCPO(shot,run,NaN,1,'equilibrium','coreprof')));