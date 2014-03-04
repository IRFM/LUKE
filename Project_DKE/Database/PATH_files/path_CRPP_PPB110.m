function dkepath = path_CRPP_PPB110
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
dkepath.hostname = 'ws0';
dkepath.machine = 'ppb110';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'decker';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.decker(1).luke_root = [pwd,filesep];
dkepath.decker(1).local_root = '/home/G09625/Packages/';
dkepath.decker(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.decker(1).mex801 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/mat801/'];
%
dkepath.decker(1).compiler_opt.helmex.mex801 = NaN;%'FLIBS=''-Wl,-rpath-link,/usr/local/matlab-8.1/bin/glnxa64 -L/usr/local/matlab-8.1/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/Packages/lapack-3.4.2 -llapack -lrefblas_gf''';
%
dkepath.decker(1).compiler_opt.fopts = '';
%
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
dkepath.decker(1).remote(1).luke_root = dkepath.decker(1).luke_root;% local cluster
%
dkepath.decker(1).remote(2).remoteid = 'CRPP_PPB110';
dkepath.decker(1).remote(2).schedulername = 'direct';
dkepath.decker(1).remote(2).profilename = 'local';
dkepath.decker(1).remote(2).luke_root = dkepath.decker(1).luke_root;% local cluster
%