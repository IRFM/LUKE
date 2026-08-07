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
function [] = remove_all
%LUKE - Remove all binary files (*.mat) in the ~/LUKE/Project_DKE/Database
%
%This script removes all *.mat files in the database~/LUKE/Project_DKE/Database
%
% by  Yves Peysson <yves.peysson@cea.fr> (CEA/DSM/IRFM) and Joan Decker <joan.decker@cea.fr> (CEA/DSM/IRFM)
%
clearmat('DISPLAY_files')
clearmat('DKEPARAM_files')
clearmat('EQUIL_files')
clearmat('HXR_files')
clearmat('OHM_files')
clearmat('PATH_files')
clearmat('RIPPLE_files')
clearmat('TRANSP_files')
clearmat('WAVE_files')
%
