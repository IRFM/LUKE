function dkepath = path_IPP_ABACUS
%
% path definitions for IPP ABACUS cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'abacus';
dkepath.hostname = 'abacus';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
dkepath.computer = computer;%machine type and supported OS
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.peysson(1).luke_root = [pwd,filesep];
dkepath.peysson(1).local_root = '/compass/home/peysson/Packages/';
dkepath.peysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.peysson(1).mex801 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/abacus/MATLAB801/'];
%
dkepath.peysson(1).compiler_opt.libs.gfortran = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
dkepath.peysson(1).compiler_opt.copts = '';
dkepath.peysson(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.peysson(1).compiler_opt.separatrice.mex801 = [' -largeArrayDims -lgfortran -L',dkepath.peysson(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).compiler_opt.helmex.mex801 = [' -compatibleArrayDims -lgfortran -L',dkepath.peysson(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
%
dkepath.peysson(1).MUMPS.mex801 = [dkepath.peysson(1).local_root,'MUMPS_4.10.0/MATLAB801'];;%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.peysson(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.peysson(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.peysson(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.peysson(1).remote(1).remoteid = 'IPP_ABACUS';
dkepath.peysson(1).remote(1).schedulername = 'pbs';
dkepath.peysson(1).remote(1).profilename = 'local';
dkepath.peysson(1).remote(1).luke_root = dkepath.peysson(1).luke_root;% local cluster
%
