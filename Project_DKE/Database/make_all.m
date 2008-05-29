function [] = make_all(build_mode)
%LUKE - builds all the (*.mat) files for running the benchmarks 
%
%This script builds all the *.mat files for running the benchmarks what are published (see the folder ~/LUKE/Simulations/Benchmarks). Don't remove it.
%
% by  Yves Peysson <yves.peysson@cea.fr> (CEA/DSM/IRFM) and Joan Decker <joan.decker@cea.fr> (CEA/DSM/IRFM)
%
if nargin == 0,
	info_dke_yp(2,'This script builds all the *.mat files for running the examples. WARNING: All existing *.mat files are overwritten.')
	build_mode = input_dke_yp('Build *.mat with mexfiles (1:yes,0:no)',0);
end
buildmat(build_mode,'DISPLAY_files')
buildmat(build_mode,'DKEPARAM_files')
buildmat(build_mode,'EQUIL_files')
buildmat(build_mode,'HXR_files')
buildmat(build_mode,'OHM_files')
buildmat(build_mode,'RIPPLE_files')
buildmat(build_mode,'TRANSP_files')
buildmat(build_mode,'WAVE_files')

