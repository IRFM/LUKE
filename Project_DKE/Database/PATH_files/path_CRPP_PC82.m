function dkepath = path_CRPP_PC82
%
% path definitions for CRPP (EPFL, Suisse) PC82 computer
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'crpppc82';
dkepath.hostname = 'crpppc82.epfl.ch';% should match the output of hostname_jd on the machine
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'decker';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.decker(1).luke_root = [pwd,filesep];
dkepath.decker(1).local_root = '/home/decker/Packages/';
dkepath.decker(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.decker(1).mex800 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/mat800/'];
dkepath.decker(1).mex801 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/mat801/'];
%
dkepath.decker(1).compiler_opt.helmex.mex800 = 'FLIBS=''-Wl,-rpath-link,/usr/local/MATLAB/R2012b/bin/glnxa64 -L/usr/local/MATLAB/R2012b/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/Packages/lapack-3.4.2 -llapack -lrefblas_gf''';
dkepath.decker(1).compiler_opt.helmex.mex801 = 'FLIBS=''-Wl,-rpath-link,/usr/local/MATLAB/R2013a/bin/glnxa64 -L/usr/local/MATLAB/R2013a/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/Packages/lapack-3.4.2 -llapack -lrefblas_gf''';
%
dkepath.decker(1).compiler_opt.fopts = '';
%
dkepath.decker(1).MUMPS.mex800 = [dkepath.decker(1).local_root,'MUMPS_4.10.0_gf/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.decker(1).MUMPS.mex801 = [dkepath.decker(1).local_root,'MUMPS_4.10.0_gf/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
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
dkepath.decker(1).remote(1).remoteid = 'CRPP_PPB110';
dkepath.decker(1).remote(1).schedulername = 'slurm';
dkepath.decker(1).remote(1).profilename = 'local';
dkepath.decker(1).remote(1).luke_root = '/home/G09625/LUKE/';
%
dkepath.decker(1).remote(2).remoteid = 'CRPP_PPB110';
dkepath.decker(1).remote(2).schedulername = 'direct';
dkepath.decker(1).remote(2).profilename = 'local';
dkepath.decker(1).remote(2).luke_root = '/home/G09625/LUKE/';
%
dkepath.decker(1).remote(3).remoteid = 'CRPP_PC82';
dkepath.decker(1).remote(3).schedulername = 'direct';
dkepath.decker(1).remote(3).profilename = 'local';
dkepath.decker(1).remote(3).luke_root = dkepath.decker(1).luke_root;% local cluster
%
dkepath.decker(1).remote(4).remoteid = 'CRPP_LAC5';
dkepath.decker(1).remote(4).schedulername = 'direct';
dkepath.decker(1).remote(4).profilename = 'local';
dkepath.decker(1).remote(4).luke_root = '/home/decker/LUKE/';
%
dkepath.decker(1).remote(5).remoteid = 'CRPP_LAC1';
dkepath.decker(1).remote(5).schedulername = 'direct';
dkepath.decker(1).remote(5).profilename = 'local';
dkepath.decker(1).remote(5).luke_root = '/home/decker/LUKE/';
%
dkepath.decker(1).remote(6).remoteid = 'CRPP_LAC2';
dkepath.decker(1).remote(6).schedulername = 'direct';
dkepath.decker(1).remote(6).profilename = 'local';
dkepath.decker(1).remote(6).luke_root = '/home/decker/LUKE/';
%
dkepath.decker(1).remote(7).remoteid = 'CRPP_LAC4';
dkepath.decker(1).remote(7).schedulername = 'direct';
dkepath.decker(1).remote(7).profilename = 'local';
dkepath.decker(1).remote(7).luke_root = '/home/decker/LUKE/';
%