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
function [waves] = check_write_waves_ITM(remote_mode,numshot,numrun)
%LUKE_ITM - Function that check if LUKE results into the 'waves' CPO of ITM MDS+ database are well written
%
%Function that check if LUKE results into the 'waves' CPO of ITM MDS+ database are well written%
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 3,error('Not enough input arguments in check_write_waves_ITM.m');end
%
if remote_mode,
    import_ual;%done once only (each time a new matlab is called otherwise... crash)
end
%
expIdx = euitm_open('euitm',numshot,numrun);
waves  = euitm_get(expIdx,'waves');
euitm_close(expIdx,'euitm',numshot,numrun);
