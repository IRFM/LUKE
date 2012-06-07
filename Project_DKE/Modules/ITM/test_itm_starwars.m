%LUKE - Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%
%Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%Part of this script may be used readily in the KEPLER actor
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
[dkepath] = load_structures_yp('dkepath','','');
%
shot = 2;
run= 501;
run_out= 502;
timeslice = 0;
iter = 1;
occurrence_out = 0;
%
expIdx  = euitm_create('euitm',shot,run_out);%recreate the database otherwise no refreshment when writing 
euitm_close(expIdx,'euitm',shot,run_out);
%
time_interp = 1;
%
CPOs = {'equilibrium','coreprof','antennas'};
%
occurrence_eq = 0;%equilibrium CPO occurence
occurrence_cp = 0;%coreprof CPO occurence
occurrence_an = 0;%antenna CPO occurence
%
CPO_occurrences = [occurrence_eq,occurrence_cp,occurrence_an];
%
remotename = 'macproyves';%empty if local calculations on the ITM gateway
%
[machine,user,ver] = which_MDSdatabase;%test the database is correct
%
if isempty(machine) || isempty(user) || isempty(ver)
	error(['ITM database not recognized -> machine: ',machine,', user: ',user,', datastructure version: ',ver]);
end
%
waves = itm_starwars(dkepath,shot,run,run_out,timeslice,time_interp,CPOs,CPO_occurrences,remotename,iter,occurrence_out);
%
output = 'ok';
outputdata = waves.coherentwave(1).profiles_1d.powd_tot;
