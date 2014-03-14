function dkepath = path_CRPP_BELLATRIX
%
% path definitions for CRPP (EPFL, Suisse) BELLATRIX cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'bellatrix';
dkepath.hostname = 'bellatrix.cluster';% should match the output of hostname_jd on the machine
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'kamleitn';
%
%------------------------------------ Profile number 1, Josef Kamleitner ------------------------------------
%
dkepath.kamleitn(1).luke_root = [pwd,filesep];
dkepath.kamleitn(1).local_root = '/home//kamleitn/Packages/';
dkepath.kamleitn(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.kamleitn(1).mex800 = [dkepath.kamleitn(1).luke_root,'Project_DKE/MEX/Bin/mat800/'];
%
dkepath.kamleitn(1).compiler_opt.helmex.mex800 = NaN;%'FLIBS=''-Wl,-rpath-link,/usr/local/matlab-8.1/bin/glnxa64 -L/usr/local/matlab-8.1/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/kamleitn/Packages/lapack-3.4.2 -llapack -lrefblas_gf''';
%
dkepath.kamleitn(1).compiler_opt.fopts = '';
%
dkepath.kamleitn(1).MUMPS.mex800 = [dkepath.kamleitn(1).local_root,'MUMPS_4.10.0_gf/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.kamleitn(1).graphviz.env = '';% Graphviz environment variable
dkepath.kamleitn(1).latex.env = '';% Latex environment variable
dkepath.kamleitn(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.kamleitn(1).remote(1).remoteid = 'CRPP_BELLATRIX';
dkepath.kamleitn(1).remote(1).schedulername = 'pbs';
dkepath.kamleitn(1).remote(1).profilename = 'kamleitn';
dkepath.kamleitn(1).remote(1).luke_root = dkepath.kamleitn(1).luke_root;% local cluster
%
dkepath.kamleitn(1).remote(end+1) = dkepath.kamleitn(1).remote(1);
dkepath.kamleitn(1).remote(end).schedulername = 'direct';
%