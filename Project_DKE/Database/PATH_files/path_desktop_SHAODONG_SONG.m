function dkepath = path_SWIP_CLUSTER02
%
% path definitions for desktop computer of Shaodong Song (Chengdu, China) 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'sd';
dkepath.hostname = 'sd';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'sd';
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
dkepath.sd(1).luke_root = '/home/songsd/luke/LUKE/';
dkepath.sd(1).local_root = '/home/songsd/Packages/';
dkepath.sd(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.sd(1).localdatapath = dkepath.sd(1).temppathroot;
%
dkepath.sd(1).mex801 = [dkepath.sd(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.sd(1).compiler_opt.libs.gfortran = [dkepath.sd(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.8.4','/',dkepath.machine,'/'];%extra libraries
dkepath.sd(1).compiler_opt.copts = '';
dkepath.sd(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.sd(1).compiler_opt.separatrice.mex801 = [' -largeArrayDims -lgfortran -L',dkepath.sd(1).local_root,'lapack-3.6.1 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.sd(1).compiler_opt.helmex.mex801 = [' -compatibleArrayDims -lgfortran -L',dkepath.sd(1).local_root,'lapack-3.6.1 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.sd(1).MUMPS.mex801 = [dkepath.sd(1).local_root,'MUMPS_4.10.0/MATLAB'];
%
% LUKE documentation
%
dkepath.sd(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.sd(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.sd(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.sd(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.sd(1).remote(1).schedulername = 'torque';
dkepath.sd(1).remote(1).profilename = 'sd';
dkepath.sd(1).remote(1).luke_root = '/home/sd/LUKE/';%-----------------Put the LUKE path or symbolic link from your session
dkepath.sd(1).remote(1).link_mode = '';
dkepath.sd(1).remote(1).cvsupdate = false;% update done in 'direct' mode
dkepath.sd(1).remote(1).gitupdate = false;
%
