function [dkepath] = path_CRPP_LAC2(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) lac2 computer
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,m]
%         (default: 'LUKE')
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.hostname = 'crpppc70.epfl.ch';
dkepath.machine = 'lac2';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
dkepath.path_profile.decker = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'decker';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.decker(1).luke_root = [pwd,'/'];
dkepath.decker(1).local_root = '/home/decker/NoTivoli/Packages/lac2/';
dkepath.decker(1).temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.decker(1).mex710 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/lac2/MATLAB710'];
dkepath.decker(1).compiler_opt.helmex.mex710 = NaN;%'FLIBS=''-Wl,-rpath-link,/usr/local/matlab710/bin/glnxa64 -L/usr/local/matlab710/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
dkepath.decker(1).compiler_opt.fopts.mex710 = '';%'FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
%
dkepath.decker(1).MUMPS.mex710 = [dkepath.decker(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.decker(1).graphviz.env = '';% Graphviz environment variable
dkepath.decker(1).latex.env = '';% Latex environment variable
dkepath.decker(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% pleiades2 (pbs)
%
dkepath.decker(1).remote(1) = remote_CRPP_PLEIADES2('torque','joan','decker');
%
% macproyves (condor)
%
dkepath.decker(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan','decker');
%
% macproyves (xgrid)
%
dkepath.decker(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan','decker');
%
% andromede (pbs).
%
dkepath.decker(1).remote(4) = remote_CEA_PARTENAIRES_ANDROMEDE('pbs','joan','decker');
%
% saturne (sun)
%
dkepath.decker(1).remote(5) = remote_CEA_SATURNE('sun','joan','decker');
%
% shenma (torque)
%
dkepath.decker(1).remote(6) = remote_ASIPP_SHENMA('torque','joan','decker');
%
