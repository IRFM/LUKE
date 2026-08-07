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
function [] = make_all(build_mode)
%LUKE - builds all the (*.mat) files for running the benchmarks 
%
%This script builds all the *.mat files for running the benchmarks what are published (see the folder ~/LUKE/Simulations/Benchmarks). Don't remove it.
%
% by  Yves Peysson <yves.peysson@cea.fr> (CEA/DSM/IRFM) and Joan Decker <joan.decker@cea.fr> (CEA/DSM/IRFM)
%
if nargin == 0,
	info_dke_yp(2,'This script builds all the *.mat files for running the examples. WARNING: All existing *.mat files are overwritten.')
	build_mode = input_dke_yp('Build *.mat with mexfiles (1:yes,0:no)',0,[0,1]);
end
buildmat(build_mode,'DISPLAY_files')
buildmat(build_mode,'DKEPARAM_files')
buildmat(build_mode,'EQUIL_files')
buildmat(build_mode,'HXR_files')
buildmat(build_mode,'HXR_files','HXR')
buildmat(build_mode,'OHM_files')
buildmat(build_mode,'RIPPLE_files')
buildmat(build_mode,'TRANSP_files')
buildmat(build_mode,'WAVE_files')

