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
dkepath.ypeysson(1).mex903 = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Bin/ypeysson-X58A-UD7/MATLAB903/'];%r2017b
dkepath.ypeysson(1).mex904 = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Bin/ypeysson-X58A-UD7/MATLAB904/'];%r2018a
%
dkepath.ypeysson(1).compiler_opt.libs.gfortran = '';
dkepath.ypeysson(1).compiler_opt.copts = '';
dkepath.ypeysson(1).compiler_opt.fopts.mex903 = 'FC=''gfortran''';%
dkepath.ypeysson(1).compiler_opt.separatrice.mex903 = [' -largeArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.helmex.mex903 = [' -compatibleArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.fopts.mex903 = ' ';%-largeArrayDims
dkepath.ypeysson(1).compiler_opt.fopts.mex904 = 'FC=''gfortran''';%
dkepath.ypeysson(1).compiler_opt.separatrice.mex904 = [' -largeArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.helmex.mex904 = [' -compatibleArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'Packages/Bin/LAPACK/lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.fopts.mex904 = ' ';%-largeArrayDims
%
%dkepath.ypeysson(1).MUMPS.mex901 = [dkepath.ypeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.ypeysson(1).MUMPS.mex903 = [dkepath.ypeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2_S_gfortran/MATLAB903'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.ypeysson(1).MUMPS.mex904 = [dkepath.ypeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2_S_gfortran/MATLAB904'];%Where MUMPS matrix solver is stored (MEX function)
%
%
% LUKE documentation
%
dkepath.ypeysson(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.ypeysson(1).latex.env = '/usr/local/texlive/2018/bin/x86_64-linux/';% Latex environment variable
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
dkepath.ypeysson(1).remote(3).remoteid = 'CEA_ANDROMEDE';
dkepath.ypeysson(1).remote(3).schedulername = 'pbs';
dkepath.ypeysson(1).remote(3).profilename = 'YP105119';
dkepath.ypeysson(1).remote(3).luke_root = '/Applications/LUKE/LUKE/';
dkepath.ypeysson(1).remote(3).link_mode = '';
dkepath.ypeysson(1).remote(3).cvsupdate = false;% update done in 'direct' mode
dkepath.ypeysson(1).remote(3).gitupdate = false;
dkepath.ypeysson(1).remote(3).gitmode.cmd = 'cd /Applications/LUKE/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.ypeysson(1).remote(4) = dkepath.ypeysson(1).remote(3);
dkepath.ypeysson(1).remote(4).schedulername = 'direct';
dkepath.ypeysson(1).remote(4).gitupdate = true;
%
