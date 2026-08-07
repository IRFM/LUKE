% 
% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function make_path_LOCAL
%
%---------------------------------------------------------------------------------------------------
%-------------------------------------- PATH PARAMETERS --------------------------------------------
%---------------------------------------------------------------------------------------------------
%
% Create the local file LUKE_PATH.mat
%
% WARNING: matlab versions before 7.5 (R2007b) are no longer supported
% 
% by Y.Peysson CEA/DSM/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/DSM/IRFM (joan.decker@cea.fr)
%
dkepath = load_dkepath_yp;% Load local path profile
%
%---------------------------------------------------------------------------------------------------
%
% save LUKE_PATH.mat
%
pathfile = [dkepath.luke_root,'Project_DKE/Database/PATH_files/LUKE_PATH.mat'];
save(pathfile,'dkepath');
disp('------------------------------------------------------');
disp(['---> The dkepath structure is saved in ',pathfile]);
%