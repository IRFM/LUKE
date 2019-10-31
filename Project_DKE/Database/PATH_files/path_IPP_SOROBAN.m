function dkepath = path_IPP_SOROBAN
%
% path definitions for IPP SOROBAN cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'soroban-front-01','soroban-node-01','soroban-node-02','soroban-node-03'};%
dkepath.hostname = {'soroban-front-01','soroban-node-01','soroban-node-02','soroban-node-03'};% should match the output of hostname_jd on the machine
%
dkepath.computer = computer;%machine type and supported OS
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.peysson(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.peysson(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.peysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.peysson(1).abacus.local_root = '/compass/Shared/Common/IT/projects/luke/Packages/';
%
dkepath.peysson(1).abacus.mex902 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/abacus/MATLAB902/'];%r2017a
%
dkepath.peysson(1).abacus.compiler_opt.libs.gfortran = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
dkepath.peysson(1).abacus.compiler_opt.copts = '';
dkepath.peysson(1).abacus.compiler_opt.fopts.mex902 = 'FC=''gfortran''';%
dkepath.peysson(1).abacus.compiler_opt.separatrice.mex902 = [' -largeArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.helmex.mex902 = [' -compatibleArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.fopts.mex902 = ' ';%-largeArrayDims';
%
dkepath.peysson(1).abacus.MUMPS.mex902 = [dkepath.peysson(1).abacus.local_root,'MUMPS_5.12.0/MATLAB804'];;%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.peysson(1).abacus.graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.peysson(1).abacus.latex.env = '/usr/bin/';% Latex environment variable
dkepath.peysson(1).abacus.imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
% -------------------------- abacus 01-02-03 -----------------------------
%

%TODO: fix node name issue
%dkepath.peysson(1).soroban-node-01 = dkepath.peysson(1).soroban-front-01;
%dkepath.peysson(1).soroban-node-02 = dkepath.peysson(1).soroban-front-01;
%dkepath.peysson(1).soroban-node-03 = dkepath.peysson(1).soroban-front-01;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.peysson(1).remote(1).remoteid = 'IPP_SOROBAN';
dkepath.peysson(1).remote(1).schedulername = 'pbs';
dkepath.peysson(1).remote(1).profilename = 'local';
dkepath.peysson(1).remote(1).luke_root = dkepath.peysson(1).luke_root;% local cluster

