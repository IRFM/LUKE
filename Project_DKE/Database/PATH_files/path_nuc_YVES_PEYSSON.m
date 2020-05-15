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
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.yvespeysson(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.yvespeysson(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.yvespeysson(1).temppathroot = '/media/yvespeysson/Pollux/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.yvespeysson(1).local_root = '/home/yvespeysson/';
%
dkepath.yvespeysson(1).mex908 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/nucyves/MATLAB908/'];%r2020a
%
dkepath.yvespeysson(1).compiler_opt.libs.gfortran = '';
dkepath.yvespeysson(1).compiler_opt.copts = '';
dkepath.yvespeysson(1).compiler_opt.fopts.mex908 = 'FC=''gfortran''';%
dkepath.yvespeysson(1).compiler_opt.separatrice.mex908 = [' -largeArrayDims -lgfortran -L',dkepath.yvespeysson(1).local_root,'Packages/LAPACK/lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.helmex.mex908 = [' -compatibleArrayDims -lgfortran -L',dkepath.yvespeysson(1).local_root,'Packages/LAPACK/lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.fopts.mex908 = ' ';%-largeArrayDims
%
dkepath.yvespeysson(1).MUMPS.mex908 = [dkepath.yvespeysson(1).local_root,'Packages/MUMPS/MUMPS_5.1.2/MATLAB908'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.yvespeysson(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.yvespeysson(1).latex.env = '/usr/local/texlive/2018/bin/x86_64-linux/';% Latex environment variable
dkepath.yvespeysson(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.yvespeysson(1).remote(1).remoteid = 'NUC_YVES_PEYSSON';
dkepath.yvespeysson(1).remote(1).schedulername = 'condor';
dkepath.yvespeysson(1).remote(1).profilename = 'yvespeysson';
dkepath.yvespeysson(1).remote(1).luke_root = dkepath.yvespeysson(1).luke_root;% local cluster
dkepath.yvespeysson(1).remote(1).link_mode = '';
dkepath.yvespeysson(1).remote(1).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(1).gitupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(1).gitmode.cmd = 'cd home/yvespeysson/*;git pull;echo "* update done";';
%
dkepath.yvespeysson(1).remote(2) = dkepath.yvespeysson(1).remote(1);
dkepath.yvespeysson(1).remote(2).schedulername = 'direct';
dkepath.yvespeysson(1).remote(2).gitupdate = true;
%