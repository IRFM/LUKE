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
dkepath.Yves(1).luke_root = '/opt/TOKAMAK_CODE/luke/LUKE/';
dkepath.Yves(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';

dkepath.Yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.Yves(1).localdatapath = dkepath.Yves(1).temppathroot;
%
dkepath.Yves(1).mex801 = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.Yves(1).compiler_opt.libs.gfortran = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.Yves(1).compiler_opt.copts = '';
dkepath.Yves(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.Yves(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.Yves(1).MUMPS.mex801 = [dkepath.Yves(1).local_root,'MUMPS_5.1.2/MATLAB801'];
%
% LUKE documentation
%
dkepath.Yves(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.Yves(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.Yves(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
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
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 2, Pony Ma  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.mazy(1) = dkepath.Yves(1);
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 3, Lei Xue ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.xuelei(1) = dkepath.Yves(1);
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 4, Yipo Zhang  ---------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.zhangyp(1) = dkepath.Yves(1);
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 5, Jie Zhang  ----------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.zhangjie(1) = dkepath.Yves(1);
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 6, Xingyu Bai ----------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.baixy(1) = dkepath.Yves(1);

