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
dkepath.machine = {'login110','login111','login112','login113','shenma059','shenma060','shenma061','shenma062','shenma063','shenma064','shenma065','shenma066','shenma067','shenma068'};%
dkepath.hostname = {'login110','login111','login112','login113','shenma059','shenma060','shenma061','shenma062','shenma063','shenma064','shenma065','shenma066','shenma067','shenma068'};% should match the output of hostname_jd on the machine
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
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
sep = strfind(luke_root,'/');
luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.PEYSSON(1).luke_root = luke_root;
dkepath.PEYSSON(1).luke_branch = luke_branch;
dkepath.PEYSSON(1).local_root = '/gpfs-home/';
dkepath.PEYSSON(1).temppathroot = '/scratch/PEYSSON/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- shenma -------------------------------
%
dkepath.PEYSSON(1).login110.local_root = [dkepath.PEYSSON(1).local_root,'/project/LUKE/Packages/'];
%
dkepath.PEYSSON(1).login110.mex903 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB903/'];
%
dkepath.PEYSSON(1).login110.compiler_opt.copts = '';
%
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex903 = 'FC=''gfortran''';%
dkepath.PEYSSON(1).login110.compiler_opt.separatrice.mex903 = [' -largeArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.helmex.mex903 = [' -compatibleArrayDims -lgfortran -L',dkepath.PEYSSON(1).login110.local_root,'LAPACK/lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.PEYSSON(1).login110.compiler_opt.fopts.mex903 = ' ';%-largeArrayDims;
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.PEYSSON(1).login110.MUMPS.mex903 = [dkepath.PEYSSON(1).local_root,'project/LUKE/Packages/MUMPS/MUMPS_5.1.2/MATLAB903'];%Where MUMPS matrix solver is stored (MEX function)
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
dkepath.PEYSSON(1).shenma059 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma060 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma061 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma062 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma063 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma064 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma065 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma066 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma067 = dkepath.PEYSSON(1).login110;
dkepath.PEYSSON(1).shenma068 = dkepath.PEYSSON(1).login110;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.PEYSSON(1).remote(1).remoteid = 'ASIPP_SHENMA';
dkepath.PEYSSON(1).remote(1).schedulername = 'torque';
dkepath.PEYSSON(1).remote(1).profilename = 'PEYSSON';%'local'
dkepath.PEYSSON(1).remote(1).luke_root = dkepath.PEYSSON(1).luke_root;% local cluster
%
dkepath.PEYSSON(1).remote(2) = dkepath.PEYSSON(1).remote(1);
dkepath.PEYSSON(1).remote(2).schedulername = 'direct';
%
%------------------------------------ Other LUKE users ------------------------------
%
dkepath.limiaohui(1) = dkepath.PEYSSON(1);
dkepath.JA132999(1).luke_root = '/home/users/limiaohui/luke/LUKE_LHCD';
dkepath.limiaohui(1).remote(1).profilename = 'limiaohui';
dkepath.JA132999(1).remote(1).luke_root = dkepath.JA132999(1).luke_root;
%