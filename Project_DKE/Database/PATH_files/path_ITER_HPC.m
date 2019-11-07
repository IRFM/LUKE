function dkepath = path_ITER_HPC
%
% path definitions for ITER/HPC cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
dkepath.machine = 'hpc';
dkepath.hostname = 'hpc';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
%
dkepath.computer = computer;%machine type and supported OS
%
dkepath.default = 'peyssoy';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.peyssoy(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.peyssoy(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.peyssoy(1).temppathroot = '/home/ITER/ypeyssoy/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.peyssoy(1).local_root = '/home/ITER/ypeyssoy/packages/';
%
dkepath.peyssoy(1).mex904 = [dkepath.peyssoy(1).luke_root,'Project_DKE/MEX/Bin/hpc/MATLAB904/'];%R2018a
%
dkepath.peyssoy(1).compiler_opt.libs.gfortran = [dkepath.peyssoy(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
%
dkepath.peyssoy(1).compiler_opt.copts = '';
dkepath.peyssoy(1).compiler_opt.copts.cpp.mex904 = '';
dkepath.peyssoy(1).compiler_opt.fopts.mex904 = 'FC=''gfortran''';%
dkepath.peyssoy(1).compiler_opt.separatrice.mex904 = [' -largeArrayDims -lgfortran -L',dkepath.peyssoy(1).local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peyssoy(1).compiler_opt.helmex.mex904 = [' -compatibleArrayDims -lgfortran -L',dkepath.peyssoy(1).local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peyssoy(1).compiler_opt.fopts.mex904 = ' ';%-largeArrayDims';
%
dkepath.peyssoy(1).MUMPS.mex904 = [dkepath.peyssoy(1).local_root,'MUMPS/MUMPS_5.1.2/MATLAB904'];;%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.peyssoy(1).graphviz.env = '/bin/';% Graphviz environment variable
dkepath.peyssoy(1).latex.env = '/bin/';% Latex environment variable
dkepath.peyssoy(1).imagemagick.env = '/bin/';% ImageMagick environment variable
%
% ---------------------------- login other node -------------------------------
%
dkepath.peyssoy(1).node = dkepath.peyssoy(1);
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.peyssoy(1).remote(1).remoteid = 'ITER_HPC';
dkepath.peyssoy(1).remote(1).schedulername = 'slurm';
dkepath.peyssoy(1).remote(1).profilename = 'local';
dkepath.peyssoy(1).remote(1).luke_root = dkepath.peyssoy(1).luke_root;% local cluster
%
dkepath.peyssoy(1).remote(2) = dkepath.peyssoy(1).remote(1);
dkepath.peyssoy(1).remote(2).schedulername = 'direct';

