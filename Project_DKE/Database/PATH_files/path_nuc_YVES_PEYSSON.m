function dkepath = path_nuc_YVES_PEYSSON
%
% path definitions for nuc (core i3 Intel) of Yves Peysson
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@epfl.ch)
%
dkepath.machine = 'nucyves';
dkepath.hostname = 'nucyves';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'yvespeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yvespeysson(1).luke_root = '/home/yvespeysson/luke/LUKE/';
dkepath.yvespeysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.yvespeysson(1).local_root = '/home/yvespeysson/';
%
dkepath.yvespeysson(1).mex901 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/nucyves/MATLAB901/'];%r2016b
%
dkepath.yvespeysson(1).compiler_opt.libs.gfortran = '';
dkepath.yvespeysson(1).compiler_opt.copts = '';
dkepath.yvespeysson(1).compiler_opt.fopts.mex901 = 'FC=''gfortran''';%
dkepath.yvespeysson(1).compiler_opt.separatrice.mex901 = [' -largeArrayDims -lgfortran -L',dkepath.yvespeysson(1).local_root,'lapack-3.7.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.helmex.mex901 = [' -compatibleArrayDims -lgfortran -L',dkepath.yvespeysson(1).local_root,'lapack-3.7.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.fopts.mex901 = ' ';%-largeArrayDims
%
dkepath.yvespeysson(1).MUMPS.mex901 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yvespeysson(1).MUMPS.mex901 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.0.2_S_gfortran/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.yvespeysson(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.yvespeysson(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.yvespeysson(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.yvespeysson(1).remote(1).remoteid = 'nuc_YVES_PEYSSON';
dkepath.yvespeysson(1).remote(1).schedulername = 'condor';
dkepath.yvespeysson(1).remote(1).profilename = 'yvespeysson';
dkepath.yvespeysson(1).remote(1).luke_root = dkepath.yvespeysson(1).luke_root;% local cluster
dkepath.yvespeysson(1).remote(1).link_mode = '';
dkepath.yvespeysson(1).remote(1).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(1).gitupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(1).gitmode.cmd = 'cd home/yvespeysson/luke/*;git pull;echo "* update done";';
%
dkepath.yvespeysson(1).remote(2) = dkepath.yvespeysson(1).remote(1);
dkepath.yvespeysson(1).remote(2).schedulername = 'direct';
dkepath.yvespeysson(1).remote(2).gitupdate = true;
%