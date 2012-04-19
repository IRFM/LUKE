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
catch
	info_dke_yp(7,'Problem while writing into the ITM-MDS+ database.')
end
