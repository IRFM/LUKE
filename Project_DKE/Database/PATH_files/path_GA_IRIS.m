function dkepath = path_GA_IRIS
%
% path definitions for General Atomics IRIS cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'iris'};
dkepath.hostname = {'iris'};%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
%
dkepath.computer = computer;%machine type and supported OS
%
dkepath.default = 'peyssony';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.peyssony(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.peyssony(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.peyssony(1).temppathroot = '/cscratch/peyssony/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.peyssony(1).iris.local_root = '/fusion/projects/codes/c3po-luke/Packages/';
%
dkepath.peyssony(1).iris.mex903 = [dkepath.peyssony(1).luke_root,'Project_DKE/MEX/Bin/iris/MATLAB903/'];%R2017b
%
%dkepath.peyssony(1).iris.compiler_opt.libs.gfortran = [dkepath.peyssony(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
%
dkepath.peyssony(1).iris.compiler_opt.copts = '';
%dkepath.peyssony(1).iris.compiler_opt.copts.cpp.mex903 = '-f /home/ypeysson/luke/LUKE/Project_DKE/MEX/Bin/iris/MATLAB903/g++_glnxa64.xml';
%
dkepath.peyssony(1).iris.compiler_opt.fopts.mex903 = 'FC=''gfortran''';%
dkepath.peyssony(1).iris.compiler_opt.separatrice.mex903 = [' -largeArrayDims -lgfortran -L',dkepath.peyssony(1).iris.local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peyssony(1).iris.compiler_opt.helmex.mex903 = [' -compatibleArrayDims -lgfortran -L',dkepath.peyssony(1).iris.local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peyssony(1).iris.compiler_opt.fopts.mex903 = ' ';%-largeArrayDims';
%
dkepath.peyssony(1).MUMPS.mex903 = [dkepath.peyssony(1).iris.local_root,'MUMPS/MUMPS_5.1.2/MATLAB903'];;%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.peyssony(1).iris.graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.peyssony(1).iris.latex.env = '/usr/bin/';% Latex environment variable
dkepath.peyssony(1).iris.imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.peyssony(1).remote(1).remoteid = 'GA_IRIS';
dkepath.peyssony(1).remote(1).schedulername = 'slurm';
dkepath.peyssony(1).remote(1).profilename = 'peyssony';
dkepath.peyssony(1).remote(1).luke_root = dkepath.peyssony(1).luke_root;% local cluster
%
dkepath.peyssony(1).remote(2) = dkepath.peyssony(1).remote(1);
dkepath.peyssony(1).remote(2).schedulername = 'direct';
%
%
%------------------------------------ Profile number 2, Michael Brookman ------------------------------------
%
dkepath.brookmanmw(1) = dkepath.peyssony(1);
dkepath.brookmanmw(1).remote(1).profilename = 'brookmanmw';
dkepath.brookmanmw(1).temppathroot = '/cscratch/brookmanmw/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)



