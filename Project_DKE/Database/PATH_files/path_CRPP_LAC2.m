function [dkepath] = path_CRPP_LAC2
%
% path definitions for CRPP (EPFL, Suisse) lac2 computer
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
% Selected user profile for unlisted users
%
dkepath.default = 'decker';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.decker(1).luke_root = [pwd,filesep];
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
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.decker(1).remote(1).remoteid = 'CRPP_LAC2';
dkepath.decker(1).remote(1).schedulername = 'direct';
dkepath.decker(1).remote(1).profilename = 'local';
dkepath.decker(1).remote(1).luke_root = dkepath.decker(1).luke_root;% local cluster
%
dkepath.decker(1).remote(2).remoteid = 'CRPP_PPB110';
dkepath.decker(1).remote(2).schedulername = 'slurm';
dkepath.decker(1).remote(2).profilename = 'local';
dkepath.decker(1).remote(2).luke_root = '/home/G09625/LUKE/';
%
dkepath.decker(1).remote(3).remoteid = 'CRPP_PPB110';
dkepath.decker(1).remote(3).schedulername = 'direct';
dkepath.decker(1).remote(3).profilename = 'local';
dkepath.decker(1).remote(3).luke_root = '/home/G09625/LUKE/';
%
dkepath.decker(1).remote(4).remoteid = 'CRPP_LAC5';
dkepath.decker(1).remote(4).schedulername = 'direct';
dkepath.decker(1).remote(4).profilename = 'local';
dkepath.decker(1).remote(4).luke_root = dkepath.decker(1).luke_root;% same filesystem
%
dkepath.decker(1).remote(5).remoteid = 'CRPP_LAC1';
dkepath.decker(1).remote(5).schedulername = 'direct';
dkepath.decker(1).remote(5).profilename = 'local';
dkepath.decker(1).remote(5).luke_root = dkepath.decker(1).luke_root;% local cluster
%
dkepath.decker(1).remote(6).remoteid = 'CRPP_LAC4';
dkepath.decker(1).remote(6).schedulername = 'direct';
dkepath.decker(1).remote(6).profilename = 'local';
dkepath.decker(1).remote(6).luke_root = dkepath.decker(1).luke_root;% same filesystem
%
dkepath.decker(1).remote(7).remoteid = 'CRPP_PC82';
dkepath.decker(1).remote(7).schedulername = 'direct';
dkepath.decker(1).remote(7).profilename = 'local';
dkepath.decker(1).remote(7).luke_root = '/home/decker/LUKE/';
%