function dkepath = path_PSFC_EOFE7
%
% path definitions for PSFC/MIT EOFE7 engaging cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'eofe7'};
dkepath.hostname = {'eofe7'};%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
%
dkepath.computer = computer;%machine type and supported OS
%
dkepath.default = 'ypeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.ypeysson(1).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.ypeysson(1).temppathroot = '/home/ypeysson/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.ypeysson(1).eofe7.local_root = '/home/ypeysson/luke/Packages/';
%
dkepath.ypeysson(1).eofe7.mex903 = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Bin/eofe7/MATLAB903/'];%R2017b
%
%dkepath.ypeysson(1).eofe7.compiler_opt.libs.gfortran = [dkepath.ypeysson(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
%
dkepath.ypeysson(1).eofe7.compiler_opt.copts = '';
dkepath.ypeysson(1).eofe7.compiler_opt.copts.cpp.mex903 = '-f /home/ypeysson/luke/LUKE/Project_DKE/MEX/Bin/eofe7/MATLAB903/g++_glnxa64.xml';
%
dkepath.ypeysson(1).eofe7.compiler_opt.fopts.mex903 = 'FC=''gfortran''';%
dkepath.ypeysson(1).eofe7.compiler_opt.separatrice.mex903 = [' -largeArrayDims -lgfortran -L',dkepath.ypeysson(1).eofe7.local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).eofe7.compiler_opt.helmex.mex903 = [' -compatibleArrayDims -lgfortran -L',dkepath.ypeysson(1).eofe7.local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.ypeysson(1).eofe7.compiler_opt.fopts.mex903 = ' ';%-largeArrayDims';
%
dkepath.ypeysson(1).MUMPS.mex903 = [dkepath.ypeysson(1).eofe7.local_root,'MUMPS/MUMPS_5.1.2/MATLAB903'];;%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.ypeysson(1).eofe7.graphviz.env = 'bin/';% Graphviz environment variable
dkepath.ypeysson(1).eofe7.latex.env = '/bin/';% Latex environment variable
dkepath.ypeysson(1).eofe7.imagemagick.env = '/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
%
% -------------------------- abacus 01-02-03 -----------------------------
%
%dkepath.peysson(1).abacus01 = dkepath.peysson(1).abacus;
%dkepath.peysson(1).abacus02 = dkepath.peysson(1).abacus;
%dkepath.peysson(1).abacus03 = dkepath.peysson(1).abacus;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.ypeysson(1).remote(1).remoteid = 'eofe7';
dkepath.ypeysson(1).remote(1).schedulername = 'slurm';
dkepath.ypeysson(1).remote(1).profilename = 'local';
dkepath.ypeysson(1).remote(1).luke_root = dkepath.ypeysson(1).luke_root;% local cluster
%


