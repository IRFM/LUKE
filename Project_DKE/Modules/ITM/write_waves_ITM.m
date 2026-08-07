% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [flag] = write_waves_ITM(remote_mode,numshot,numrun,LUKE_waves,iter,occurrence)
%LUKE_ITM - Function that writes LUKE results into the 'waves' CPO of ITM MDS+ database
%
%Function that writes LUKE results into the 'waves' CPO of ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 4,error('Not enough input arguments in write_waves_ITM.m');end
%
if nargin == 4,
    iter = 1;
	occurrence = 0;
end
%
if nargin == 5,
	occurrence = 0;
end
%
if remote_mode,
    import_ual;%done once only (each time a new matlab is called otherwise... crash)
end
%
CPO = 'waves';
%
expIdx  = euitm_create('euitm',numshot,numrun);%recreate the database otherwise no refreshment when writing (4.09a problem apparently)
euitm_close(expIdx,'euitm',numshot,numrun);
%
expIdx = euitm_open('euitm',numshot,numrun);%Open the ITM MDS+ database
%
nslices = length(LUKE_waves);
%
try
	if nslices > 1,
		%
		ITM_waves = CPO_gen(CPO,length(LUKE_waves));%the number of time slice
		%
		ITM_waves = LUKE_waves;
		%
		euitm_put(expIdx,CPO,ITM_waves);%write results in the 'waves' CPO
		%
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
	end
	%
	flag = 'Data structures for ''waves'' CPO successfully writen from the ITM-MDS+ database';
	%
catch
	flag = 'Problem while writing into the ITM-MDS+ database';
end
%
euitm_close(expIdx,'euitm',numshot,numrun);%Close the currently open database

