function [] = make_all(build_mode)
%
%This script removes all *.mat files in the database
%
% by  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) and Joan Decker <joan.decker@cea.fr> (CEA/DRFC)
%
if nargin == 0,
	info_dke_yp(2,'This script removes all *.mat files in the database.')
	build_mode = input_dke_yp('Build *.mat with mexfiles (1:yes,0:no)',0);
end
clearmat(build_mode,'DISPLAY_files')
clearmat(build_mode,'DKEPARAM_files')
clearmat(build_mode,'EQUIL_files')
clearmat(build_mode,'HXR_files')
clearmat(build_mode,'OHM_files')
clearmat(build_mode,'RIPPLE_files')
clearmat(build_mode,'TRANSP_files')
clearmat(build_mode,'WAVE_files')
%
