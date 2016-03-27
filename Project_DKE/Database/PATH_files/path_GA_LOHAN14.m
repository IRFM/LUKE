function dkepath = path_GA_LOHAN14
%
% path definitions for GA cluster LOHAN14 workstation (San Diego, California, USA) 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'lohan14';
dkepath.hostname = 'lohan14';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'peyssony';
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
dkepath.peyssony(1).luke_root = '/usc-data/d/luke/LUKE/';
dkepath.peyssony(1).local_root = '/usc-data/d/luke/Packages/';
dkepath.peyssony(1).temppathroot = '/scratch/luke/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.peyssony(1).localdatapath = dkepath.peyssony(1).temppathroot;
%
dkepath.peyssony(1).mex804 = [dkepath.peyssony(1).luke_root,'Project_DKE/MEX/Bin/lohan14/MATLAB804/'];
%
dkepath.peyssony(1).compiler_opt.libs.gfortran = [dkepath.peyssony(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.7','/',dkepath.machine,'/'];%extra libraries
dkepath.peyssony(1).compiler_opt.copts = '';
dkepath.peyssony(1).compiler_opt.fopts.mex804 = 'FC=''gfortran''';%
dkepath.peyssony(1).compiler_opt.separatrice.mex804 = [' -largeArrayDims -lgfortran -L',dkepath.peyssony(1).local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peyssony(1).compiler_opt.helmex.mex804 = [' -compatibleArrayDims -lgfortran -L',dkepath.peyssony(1).local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peyssony(1).compiler_opt.fopts.mex804 = ' ';%-largeArrayDims';
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.peyssony(1).MUMPS.mex804 = ['/usc-data/d/luke/Packages/MUMPS_4.10.0/MATLAB804'];
%
% LUKE documentation
%
dkepath.peyssony(1).graphviz.env = '';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.peyssony(1).latex.env = '/usr/bin/';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.peyssony(1).imagemagick.env = '';% ImageMagick environment variable ('which convert' and 'convert -v')
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
%dkepath.peyssony(1).remote(1).remoteid = '';
%dkepath.peyssony(1).remote(1).schedulername = '';
%dkepath.peyssony(1).remote(1).profilename = 'local';
%dkepath.peyssony(1).remote(1).luke_root = dkepath.peyssony(1).luke_root;% local cluster
%

