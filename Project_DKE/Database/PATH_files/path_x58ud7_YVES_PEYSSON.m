function dkepath = path_x58ud7_YVES_PEYSSON
%
% path definitions for X58-UD7 linux server (core i7 Intel) of Yves Peysson
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@epfl.ch)
%
dkepath.machine = 'ypeysson-X58A-UD7';
dkepath.hostname = 'ypeysson-X58A-UD7';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'ypeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.ypeysson(1).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.ypeysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.ypeysson(1).local_root = '/home/ypeysson/';
%
dkepath.ypeysson(1).mex901 = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Bin/ypeysson-X58A-UD7/MATLAB901/'];%r2016b
dkepath.ypeysson(1).mex902 = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Bin/ypeysson-X58A-UD7/MATLAB902/'];%r2017a
%
dkepath.ypeysson(1).compiler_opt.libs.gfortran = '';
dkepath.ypeysson(1).compiler_opt.copts = '';
dkepath.ypeysson(1).compiler_opt.fopts.mex901 = 'FC=''gfortran''';%
dkepath.ypeysson(1).compiler_opt.separatrice.mex901 = [' -largeArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.7.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.helmex.mex901 = [' -compatibleArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.7.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.fopts.mex901 = ' ';%-largeArrayDims
dkepath.ypeysson(1).compiler_opt.fopts.mex902 = 'FC=''gfortran''';%
dkepath.ypeysson(1).compiler_opt.separatrice.mex902 = [' -largeArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.7.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.helmex.mex902 = [' -compatibleArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.7.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.fopts.mex902 = ' ';%-largeArrayDims
%
%dkepath.ypeysson(1).MUMPS.mex901 = [dkepath.ypeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.ypeysson(1).MUMPS.mex901 = [dkepath.ypeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.0.2_S_gfortran/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.ypeysson(1).MUMPS.mex902 = [dkepath.ypeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB902'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.ypeysson(1).MUMPS.mex902 = [dkepath.ypeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.0.2_S_gfortran/MATLAB902'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.ypeysson(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.ypeysson(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.ypeysson(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.ypeysson(1).remote(1).remoteid = 'x58ud7_YVES_PEYSSON';
dkepath.ypeysson(1).remote(1).schedulername = 'condor';
dkepath.ypeysson(1).remote(1).profilename = 'ypeysson';
dkepath.ypeysson(1).remote(1).luke_root = dkepath.ypeysson(1).luke_root;% local cluster
dkepath.ypeysson(1).remote(1).link_mode = '';
dkepath.ypeysson(1).remote(1).cvsupdate = false;% update done in 'direct' mode
dkepath.ypeysson(1).remote(1).gitupdate = false;% update done in 'direct' mode
dkepath.ypeysson(1).remote(1).gitmode.cmd = 'cd /home/ypeysson/luke/*;git pull;echo "* update done";';
%
dkepath.ypeysson(1).remote(2) = dkepath.ypeysson(1).remote(1);
dkepath.ypeysson(1).remote(2).schedulername = 'direct';
dkepath.ypeysson(1).remote(2).gitupdate = true;
%