function [bjdingLinux] = path_laptop_BOJIANG_DING(luke_ref)
%
% path definitions for laptop of Bojiang Ding
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,m]
%         (default: 'LUKE')
%
%	Output:
%
%       - bjdingLinux: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin == 0, luke_ref = 'LUKE';end
%
[dummy,matlabversion,matlabrelease] = LUKEversion_jd;
%
bjdingLinux.hostname = 'bjdingLinux';%WARNING: for laptop, may change with connection status.
bjdingLinux.machine = 'bjdingLinux';
bjdingLinux.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
bjdingLinux.default = 'bjding';
bjdingLinux.path_profile.bjding = 1;
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
bjdingLinux.bjding(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
bjdingLinux.bjding(1).local_root = '/home/bjding/Packages/';
bjdingLinux.bjding(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
bjdingLinux.bjding(1).mex714 = [bjdingLinux.bjding(1).luke_root,'Project_DKE/MEX/Bin/laptopbojiang/MATLAB714']; 
%
bjdingLinux.bjding(1).compiler_opt.copts = '';
bjdingLinux.bjding(1).compiler_opt.helmex = NaN;%'-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
macbookyves.yves(1).compiler_opt.fopts = '';
%
bjdingLinux.bjding(1).MUMPS.mex714 = [bjdingLinux.bjding(1).local_root,'MUMPS_4.10.0/MATLAB714'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
bjdingLinux.bjding(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
bjdingLinux.bjding(1).latex.env = '/usr/bin/';% Latex environment variable
bjdingLinux.bjding(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
bjdingLinux.bjding(1).remote(1) = remote_ASIPP_SHENMA('torque','bojiang','bjding');
bjdingLinux.bjding(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','bojiang','bjding');
bjdingLinux.bjding(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','bojiang','bjding');

