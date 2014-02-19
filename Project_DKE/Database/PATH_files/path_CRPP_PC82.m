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
dkepath.hostname = 'crpppc82';
dkepath.machine = 'crpppc82';
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
% local
%
dkepath.decker(1).remote(1) = remote_CRPP_PC82('bash','joan');
dkepath.decker(1).remote(1).host = '';% empty for local host
dkepath.decker(1).remote(1).env.luke_root = dkepath.decker(1).luke_root;
%
% CEA andromede (pbs)
%
dkepath.decker(1).remote(2) = remote_CEA_ANDROMEDE('pbs','joan');
dkepath.decker(1).remote(2).env.luke_root = '/home/JD211098/LUKE_CRONOS/';
%
% macproyves (condor)
%
dkepath.decker(1).remote(3) = remote_macpro_YVES_PEYSSON('condor','joan');
dkepath.decker(1).remote(3).env.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
%
% macproyves (xgrid)
%
dkepath.decker(1).remote(4) = remote_macpro_YVES_PEYSSON('xgrid','joan');
dkepath.decker(1).remote(4).env.luke_root = dkepath.decker(1).remote(3).env.luke_root;
%
% shenma (torque)
%
dkepath.decker(1).remote(5) = remote_ASIPP_SHENMA('torque','joan');
dkepath.decker(1).remote(5).env.luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%