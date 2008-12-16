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
