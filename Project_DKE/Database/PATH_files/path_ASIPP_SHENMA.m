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
dkepath.machine = {'shenma110','shenma111','shenma112','shenma113'};%shenma113 is called by default from CEA intranet
dkepath.hostname = {'login110,login111,login112,login113'};
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
dkepath.PEYSSON(1).luke_root = '/project/LUKE/LUKE/';
dkepath.PEYSSON(1).local_root = '/home/users/PEYSSON/Packages/';
dkepath.PEYSSON(1).temppathroot = '/scratch/PEYSSON/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.PEYSSON(1).localdatapath = dkepath.PEYSSON(1).temppathroot;
%
% ---------------------------- shenma113 -------------------------------
%
dkepath.PEYSSON(1).shenma113.mex714 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB714/'];
dkepath.PEYSSON(1).shenma113.mex801 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB801/'];
dkepath.PEYSSON(1).shenma113.mex804 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB804/'];
%
dkepath.PEYSSON(1).shenma113.compiler_opt.libs.gfortran = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.7','/',dkepath.machine,'/'];%extra libraries
dkepath.PEYSSON(1).shenma113.compiler_opt.copts = '';
dkepath.PEYSSON(1).shenma113.compiler_opt.fopts.mex714 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).shenma113.compiler_opt.separatrice.mex714 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).shenma113.compiler_opt.helmex.mex714 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).shenma113.compiler_opt.fopts.mex714 = ' ';%-largeArrayDims';
dkepath.PEYSSON(1).shenma113.compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).shenma113.compiler_opt.separatrice.mex801 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).shenma113.compiler_opt.helmex.mex801 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).shenma113.compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
dkepath.PEYSSON(1).shenma113.compiler_opt.fopts.mex804 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).shenma113.compiler_opt.separatrice.mex804 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).shenma113.compiler_opt.helmex.mex804 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).shenma113.compiler_opt.fopts.mex804 = ' ';%-largeArrayDims';
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.PEYSSON(1).shenma113.MUMPS.mex714 = ['/home/users/PEYSSON/Packages/MUMPS_4.10.0/MATLAB714'];
dkepath.PEYSSON(1).shenma113.MUMPS.mex801 = ['/home/users/PEYSSON/Packages/MUMPS_4.10.0/MATLAB801'];
dkepath.PEYSSON(1).shenma113.MUMPS.mex804 = ['/home/users/PEYSSON/Packages/MUMPS_4.10.0/MATLAB804'];
%
% LUKE documentation
%
dkepath.PEYSSON(1).shenma113.graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.PEYSSON(1).shenma113.latex.env = '/usr/bin/';% Latex environment variable
dkepath.PEYSSON(1).shenma113.imagemagick.env = '/usr/bin/';% ImageMagick environment variable
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
% ---------------------------- shenma110-112 -------------------------------
%
dkepath.PEYSSON(1).shenma110 = dkepath.PEYSSON(1).shenma113;
dkepath.PEYSSON(1).shenma111 = dkepath.PEYSSON(1).shenma113;
dkepath.PEYSSON(1).shenma112 = dkepath.PEYSSON(1).shenma113;
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 2, Joan Decker  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.PEYSSON(2) = dkepath.PEYSSON(1);
%
dkepath.PEYSSON(2).remote(1).profilename = 'joan';
%
