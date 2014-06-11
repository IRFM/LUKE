function [dkepath] = path_laptop_BOJIANG_DING
%
% path definitions for laptop of Bojiang Ding
%
%	Input: none
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.hostname = 'bjdingLinux';%WARNING: for laptop, may change with connection status.
dkepath.machine = 'bjdingLinux';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'bjding';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.bjding(1).luke_root = [pwd,filesep];
dkepath.bjding(1).local_root = '/home/bjding/Packages/';
dkepath.bjding(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.bjding(1).mex714 = [dkepath.bjding(1).luke_root,'Project_DKE/MEX/Bin/laptopbojiang/MATLAB714']; 
%
dkepath.bjding(1).compiler_opt.copts = '';
dkepath.bjding(1).compiler_opt.fopts.mex714 = ' ';%-largeArrayDims';
dkepath.bjding(1).compiler_opt.helmex.mex714 = NaN;%'-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
dkepath.bjding(1).MUMPS.mex714 = [dkepath.bjding(1).local_root,'MUMPS_4.10.0/MATLAB714'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.bjding(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.bjding(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.bjding(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.bjding(1).remote(1).remoteid = 'ASIPP_SHENMA';
dkepath.bjding(1).remote(1).schedulername = 'torque';
dkepath.bjding(1).remote(1).profilename = 'bjding';
dkepath.bjding(1).remote(1).luke_root = '/home/PEYSSON/LUKE/';
dkepath.bjding(1).remote(1).link_mode = 0;
%


