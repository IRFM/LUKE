function dkepath = path_PSFC_CMODWS85
%
% path definitions for PSFC CMODWS85 workstation
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'cmodws85';
dkepath.hostname = 'cmodws85.psfc.mit.edu';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
dkepath.computer = computer;%machine type and supported OS
%
dkepath.default = 'ypeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.ypeysson(1).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.ypeysson(1).local_root = '/home/ypeysson/luke/Packages/';
dkepath.ypeysson(1).temppathroot = '/home/ypeysson/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.ypeysson(1).mex806 = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Bin/cmodws85/MATLAB806/'];%R2015b
%
dkepath.ypeysson(1).compiler_opt.libs.gfortran = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
%
dkepath.ypeysson(1).compiler_opt.copts = '';
dkepath.ypeysson(1).compiler_opt.copts.cpp.mex806 = '-f /home/ypeysson/luke/LUKE/Project_DKE/MEX/Bin/cmodws85/MATLAB806/g++_glnxa64.xml';
%
dkepath.ypeysson(1).compiler_opt.fopts.mex806 = 'FC=''gfortran''';%
dkepath.ypeysson(1).compiler_opt.separatrice.mex806 = [' -largeArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.helmex.mex806 = [' -compatibleArrayDims -lgfortran -L',dkepath.ypeysson(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).compiler_opt.fopts.mex806 = ' ';%-largeArrayDims';
%
dkepath.ypeysson(1).MUMPS.mex806 = [dkepath.ypeysson(1).local_root,'MUMPS_4.10.0/MATLAB806'];;%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.ypeysson(1).graphviz.env = '';% Graphviz environment variable
dkepath.ypeysson(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.ypeysson(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.ypeysson(1).remote(1).remoteid = 'PSFC_CMODWS85';
dkepath.ypeysson(1).remote(1).schedulername = 'direct';
dkepath.ypeysson(1).remote(1).profilename = 'local';
dkepath.ypeysson(1).remote(1).luke_root = '/home/ypeysson/LUKE/';% local cluster
%
dkepath.ypeysson(1).remote(2).remoteid = 'PSFC_LOKI';
dkepath.ypeysson(1).remote(2).schedulername = 'pbs';
dkepath.ypeysson(1).remote(2).profilename = 'ypeysson';
dkepath.ypeysson(1).remote(2).luke_root = '/home/ypeysson/LUKE/';% local cluster
%
dkepath.ypeysson(1).remote(3) = dkepath.ypeysson(1).remote(2);
dkepath.ypeysson(1).remote(3).schedulername = 'direct';



