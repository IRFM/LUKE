function [waves_ITM] = write_waves_ITM(numshot,numrun,LUKE_waves)
%LUKE - Function that writes LUKE results into the 'waves' CPO of ITM MDS+ database
%
%Function that writes LUKE results into the 'waves' CPO of ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 3,error('Not enough input arguments in write_waves_ITM.m');end
%
try
	expIdx  = euitm_create('euitm',numshot,numrun);%recreate the database otherwise no refreshment when writing 
	euitm_close(expIdx,'euitm',numshot,numrun);
	%
	expIdx = euitm_open('euitm',numshot,numrun);%Open the ITM MDS+ database
	%
	ITM_waves = CPO_gen('waves',length(LUKE_waves));%the number of time slice
	%
	ITM_waves = LUKE_waves;
	%
	euitm_put(expIdx,'waves',ITM_waves);%write results in the 'waves' CPO
	%
	info_dke_yp(4,'Data structures for ''waves'' CPO successfully writen from the ITM-MDS+ database.');
	%
	euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database
	%
	% check write
	%
	expIdx = euitm_open('euitm',numshot,numrun);
	waves  = euitm_get_slice(expIdx,'waves',0,1)
	size(waves.coherentwave(1).profiles_1d.pow_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.pow_tot)
	%
	waves  = euitm_get_slice(expIdx,'waves',1,1)
	size(waves.coherentwave(1).profiles_1d.pow_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.pow_tot)
	%
	waves  = euitm_get_slice(expIdx,'waves',2,1)
	size(waves.coherentwave(1).profiles_1d.pow_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.pow_tot)
	%
	waves  = euitm_get_slice(expIdx,'waves',3,1) 
	size(waves.coherentwave(1).profiles_1d.pow_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.pow_tot)
	%
	euitm_close(expIdx,'euitm',numshot,numrun)  
	%
catch
	info_dke_yp(7,'Problem while writing into the ITM-MDS+ database.')
end
