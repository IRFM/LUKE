function dkepath = path_ASIPP_SHENMA
%
% path definitions for ASIPP cluster SHENMA (Heifei, China) 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'shenma';
dkepath.hostname = 'shenma';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'PEYSSON';
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
dkepath.PEYSSON(1).luke_root = [pwd,filesep];
dkepath.PEYSSON(1).local_root = '/project/LUKE/Packages/';
dkepath.PEYSSON(1).temppathroot = '/scratch/PEYSSON/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.PEYSSON(1).localdatapath = dkepath.PEYSSON(1).temppathroot;
%
dkepath.PEYSSON(1).mex800 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB800/'];
dkepath.PEYSSON(1).mex801 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB801/'];
%
dkepath.PEYSSON(1).compiler_opt.libs.gfortran = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.7','/',dkepath.machine,'/'];%extra libraries
dkepath.PEYSSON(1).compiler_opt.copts = '';
dkepath.PEYSSON(1).compiler_opt.fopts.mex800 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).compiler_opt.separatrice.mex800 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).compiler_opt.helmex.mex800 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).compiler_opt.fopts.mex800 = ' ';%-largeArrayDims';
dkepath.PEYSSON(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).compiler_opt.separatrice.mex801 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).compiler_opt.helmex.mex801 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.PEYSSON(1).MUMPS.mex800 = ['/home/PEYSSON/Packages/MUMPS_4.10.0/MATLAB800'];
dkepath.PEYSSON(1).MUMPS.mex801 = ['/home/PEYSSON/Packages/MUMPS_4.10.0/MATLAB801'];
%
% LUKE documentation
%
dkepath.PEYSSON(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.PEYSSON(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.PEYSSON(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.PEYSSON(1).remote(1).remoteid = 'ASIPP_SHENMA';
dkepath.PEYSSON(1).remote(1).schedulername = 'torque';
dkepath.PEYSSON(1).remote(1).profilename = 'local';
dkepath.PEYSSON(1).remote(1).luke_root = dkepath.PEYSSON(1).luke_root;% local cluster
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 2, Joan Decker  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.PEYSSON(2) = dkepath.PEYSSON(1);
%
dkepath.PEYSSON(2).remote(1).profilename = 'joan';
%
