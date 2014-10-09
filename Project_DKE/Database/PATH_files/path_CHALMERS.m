function [dkepath] = path_CHALMERS
%
% path definitions for Chalmers gateway computer
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,m]
%         (default: 'LUKE')
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.hostname = 'ft';%WARNING: for laptop, may change with connection status.
dkepath.machine = 'chalmers';
dkepath.computer = computer;%machine type and supported OS
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.decker(1).luke_root = [pwd,filesep];
dkepath.decker(1).local_root = '/home/decker/Packages/';
dkepath.decker(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.decker(1).mex714 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/dkepath/MATLAB714']; 
%
dkepath.decker(1).compiler_opt.helmex = NaN;
dkepath.decker(1).compiler_opt.fopts = ' LD_LIBRARY_PATH="" ';%'FC="gfortran"';
dkepath.decker(1).compiler_opt.copts = ' LD_LIBRARY_PATH="" ';
%
dkepath.decker(1).MUMPS.mex714 = [dkepath.decker(1).local_root,'MUMPS_4.10.0_lapack/MATLAB714'];%Where MUMPS matrix solver is stored (MEX function)
%
%
% LUKE documentation
%
dkepath.decker(1).graphviz.env = '';% Graphviz environment variable
dkepath.decker(1).latex.env = '';% Latex environment variable
dkepath.decker(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.decker(1).remote(1).remoteid = 'CHALMERS_FT';
dkepath.decker(1).remote(1).schedulername = 'direct';
dkepath.decker(1).remote(1).profilename = 'local';
dkepath.decker(1).remote(1).luke_root = '/home/decker/LUKE/';
%
dkepath.decker(1).remote(2) = dkepath.decker(1).remote(1);
dkepath.decker(1).remote(2).schedulername = 'torque';
%
