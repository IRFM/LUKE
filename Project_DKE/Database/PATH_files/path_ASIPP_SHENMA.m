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
dkepath.machine = {'login110','login111','login112','login113','shenma101','shenma102','shenma103','shenma104','shenma105','shenma106','shenma107','shenma108','shenma109','shenma110'};%
dkepath.hostname = {'login110','login111','login112','login113','shenma101','shenma102','shenma103','shenma104','shenma105','shenma106','shenma107','shenma108','shenma109','shenma110'};% should match the output of hostname_jd on the machine
%
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
dkepath.PEYSSON(1).temppathroot = '/scratch/PEYSSON/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.PEYSSON(1).localdatapath = dkepath.PEYSSON(1).temppathroot;
%
% ---------------------------- shenma -------------------------------
%
dkepath.PEYSSON(1).login110.local_root = '/home/users/PEYSSON/Packages/';
%
dkepath.PEYSSON(1).login110.mex714 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB714/'];
dkepath.PEYSSON(1).login110.mex801 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB801/'];
dkepath.PEYSSON(1).login110.mex900 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB900/'];
%
dkepath.PEYSSON(1).login110.compiler_opt.libs.gfortran = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.7','/',dkepath.machine,'/'];%extra libraries
dkepath.PEYSSON(1).login110.compiler_opt.copts = '';
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex714 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).login110.compiler_opt.separatrice.mex714 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.helmex.mex714 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex714 = ' ';%-largeArrayDims';
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).login110.compiler_opt.separatrice.mex801 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.helmex.mex801 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex900 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).login110.compiler_opt.separatrice.mex900 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.helmex.mex900 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex900 = ' ';%-largeArrayDims;
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.PEYSSON(1).login110.MUMPS.mex714 = ['/home/users/PEYSSON/Packages/MUMPS_4.10.0/MATLAB714'];
dkepath.PEYSSON(1).login110.MUMPS.mex801 = ['/home/users/PEYSSON/Packages/MUMPS_4.10.0/MATLAB801'];
dkepath.PEYSSON(1).login110.MUMPS.mex900 = ['/home/users/PEYSSON/Packages/MUMPS_4.10.0/MATLAB900'];
%
% LUKE documentation
%
dkepath.PEYSSON(1).login110.graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.PEYSSON(1).login110.latex.env = '/usr/bin/';% Latex environment variable
dkepath.PEYSSON(1).login110.imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
% ---------------------------- login 111-113 shenma 101-110 -------------------------------
%
dkepath.PEYSSON(1).login111 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).login112 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).login113 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma101 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma102 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma103 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma104 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma105 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma106 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma107 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma108 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma109 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma110 = dkepath.PEYSSON(1).login110;
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
