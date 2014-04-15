function dkepath = path_SWIP_CLUSTER02
%
% path definitions for SWIP cluster CLUSTER02 (Chengdu, China) 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'cluster02';
dkepath.hostname = 'mgmt.chess';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'Yves';
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
dkepath.Yves(1).luke_root = [pwd,filesep];
dkepath.Yves(1).local_root = '/home/Yves/Packages/';
dkepath.Yves(1).temppathroot = '/home/Yves/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.Yves(1).localdatapath = dkepath.Yves(1).temppathroot;
%
dkepath.Yves(1).mex714 = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB714/'];
%
dkepath.Yves(1).compiler_opt.copts.mex714 = '';
dkepath.Yves(1).compiler_opt.fopts.mex714 = 'FC=''gfortran''';
dkepath.Yves(1).compiler_opt.helmex.mex714= NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.Yves(1).MUMPS.mex714 = [dkepath.Yves(1).local_root,'MUMPS_4.10.0/MATLAB714'];
%
% LUKE documentation
%
%dkepath.Yves(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
%dkepath.Yves(1).latex.env = '/usr/bin/';% Latex environment variable
%dkepath.Yves(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.Yves(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.Yves(1).remote(1).schedulername = 'torque';
dkepath.Yves(1).remote(1).profilename = 'local';
dkepath.Yves(1).remote(1).luke_root = dkepath.Yves(1).luke_root;% local cluster
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 2, Joan Decker  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.Yves(2) = dkepath.Yves(1);
dkepath.Yves(2).remote(1).profilename = 'joan';
%
