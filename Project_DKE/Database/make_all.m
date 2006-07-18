%This script builds all the *.mat files for running the examples. Don't remove it.
%
% by  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) and Joan Decker <joan.decker@cea.fr> (CEA/DRFC)
%
info_dke_yp(2,'This script builds all the *.mat files for running the examples. WARNING: All existing *.mat files are overwritten.')
build_mode = input_dke_yp('Build *.mat with mexfiles (1:yes,0:no)',0);
buildmat(build_mode,'DISPLAY_files')
buildmat(build_mode,'DKEPARAM_files')
buildmat(build_mode,'EQUIL_files')
buildmat(build_mode,'HXR_files')
buildmat(build_mode,'OHM_files')
buildmat(build_mode,'PATH_files')
buildmat(build_mode,'RIPPLE_files')
buildmat(build_mode,'TRANSP_files')
buildmat(build_mode,'WAVE_files')
%
