function [ITM_waves] = write_waves_ITM(numshot,numrun,LUKE_waves,iter,occurrence)
%LUKE - Function that writes LUKE results into the 'waves' CPO of ITM MDS+ database
%
%Function that writes LUKE results into the 'waves' CPO of ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in write_waves_ITM.m');end
%
if nargin == 4,
	occurrence = 0;
end
%
CPO = 'waves';
%
try
	if nargin < 3
		expIdx  = euitm_create('euitm',numshot,numrun);%recreate the database otherwise no refreshment when writing (4.09a problem apparently)
		euitm_close(expIdx,'euitm',numshot,numrun);
		%
		expIdx = euitm_open('euitm',numshot,numrun);%Open the ITM MDS+ database
		%
		ITM_waves = CPO_gen(CPO,length(LUKE_waves));%the number of time slice
		%
		ITM_waves = LUKE_waves;
		%
		euitm_put(expIdx,CPO,ITM_waves);%write results in the 'waves' CPO
		%
		euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database
	else
		expIdx = euitm_open('euitm',numshot,numrun);%Open the ITM MDS+ database
		%
		ITM_waves = CPO_gen(CPO,1);%One time slice only
		%
		ITM_waves = LUKE_waves;
		%
		if ~isempty(occurrence),
			if occurrence ~= 0,
				CPO = [CPO,'/',num2str(occurrence)];
			end
		end
		%
		if iter == 1,
			euitm_put_non_timed(expIdx,CPO,ITM_waves);%write time-independent results in the 'waves' CPO
			euitm_put_slice(expIdx,CPO,ITM_waves);%write time-dependent results in the 'waves' CPO
		else
			euitm_put_slice(expIdx,CPO,ITM_waves);%write time-dependent results in the 'waves' CPO
		end
		%
		euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database
	end
	%
	info_dke_yp(4,'Data structures for ''waves'' CPO successfully writen from the ITM-MDS+ database.');
	%
	% check write
	%
	if 0
	expIdx = euitm_open('euitm',numshot,numrun);
	waves  = euitm_get_slice(expIdx,'waves',0,1)
	size(waves.coherentwave(1).profiles_1d.powd_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.powd_tot)
	%
	waves  = euitm_get_slice(expIdx,'waves',1,1)
	size(waves.coherentwave(1).profiles_1d.powd_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.powd_tot)
	%
	waves  = euitm_get_slice(expIdx,'waves',2,1)
	size(waves.coherentwave(1).profiles_1d.powd_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.powd_tot)
	%
	waves  = euitm_get_slice(expIdx,'waves',3,1) 
	size(waves.coherentwave(1).profiles_1d.powd_tot)
	figure,plot(waves.coherentwave(1).grid_1d.psi,waves.coherentwave(1).profiles_1d.powd_tot)
	%
	euitm_close(expIdx,'euitm',numshot,numrun)  
	end
	%
catch
	info_dke_yp(7,'Problem while writing into the ITM-MDS+ database.')
end
