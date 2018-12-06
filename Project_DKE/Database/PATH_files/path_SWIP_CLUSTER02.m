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
%dkepath.Yves(1).luke_root = '/home/Yves/LUKE/';
%dkepath.Yves(1).local_root = '/home/Yves/Packages/';
dkepath.Yves(1).luke_root = '/opt/TOKAMAK_CODE/luke/LUKE/';
dkepath.Yves(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';

dkepath.Yves(1).temppathroot = '/home/Yves/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.Yves(1).localdatapath = dkepath.Yves(1).temppathroot;
%
dkepath.Yves(1).mex801 = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.Yves(1).compiler_opt.libs.gfortran = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.Yves(1).compiler_opt.copts = '';
kepath.Yves(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.Yves(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.Yves(1).MUMPS.mex801 = [dkepath.Yves(1).local_root,'MUMPS_4.10.0/MATLAB801'];
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
dkepath.mazy(1).luke_root = '/opt/TOKAMAK_CODE/luke/LUKE/';
dkepath.mazy(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';
%
dkepath.mazy(1).temppathroot = '/home/mazy/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.mazy(1).localdatapath = dkepath.mazy(1).temppathroot;
%
dkepath.mazy(1).mex801 = [dkepath.mazy(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.mazy(1).compiler_opt.libs.gfortran = [dkepath.mazy(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.mazy(1).compiler_opt.copts = '';
dkepath.mazy(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.mazy(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.mazy(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.mazy(1).MUMPS.mex801 = [dkepath.mazy(1).local_root,'MUMPS_5.1.2/MATLAB801'];
%
% LUKE documentation
%
dkepath.mazy(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.mazy(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.mazy(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.mazy(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.mazy(1).remote(1).schedulername = 'torque';
dkepath.mazy(1).remote(1).profilename = 'local';
dkepath.mazy(1).remote(1).luke_root = dkepath.mazy(1).luke_root;% local cluster
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 3, Lei Xue ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.xuelei(1).luke_root = '/opt/TOKAMAK_CODE/luke/LUKE/';
dkepath.xuelei(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';
%
dkepath.xuelei(1).temppathroot = '/home/xuelei/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.xuelei(1).localdatapath = dkepath.xuelei(1).temppathroot;
%
dkepath.xuelei(1).mex801 = [dkepath.xuelei(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.xuelei(1).compiler_opt.libs.gfortran = [dkepath.xuelei(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.xuelei(1).compiler_opt.copts = '';
dkepath.xuelei(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.xuelei(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.xuelei(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.xuelei(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.xuelei(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.xuelei(1).MUMPS.mex801 = [dkepath.xuelei(1).local_root,'MUMPS_5.1.2/MATLAB801'];
%
% LUKE documentation
%
dkepath.xuelei(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.xuelei(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.xuelei(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.xuelei(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.xuelei(1).remote(1).schedulername = 'torque';
dkepath.xuelei(1).remote(1).profilename = 'local';
dkepath.xuelei(1).remote(1).luke_root = dkepath.xuelei(1).luke_root;% local cluster
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 4, Yipo Zhang  ---------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.zhangyp(1).luke_root = '/opt/TOKAMAK_CODE/luke/LUKE/';
dkepath.zhangyp(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';
%
dkepath.zhangyp(1).temppathroot = '/home/zhangyp/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.zhangyp(1).localdatapath = dkepath.zhangyp(1).temppathroot;
%
dkepath.zhangyp(1).mex801 = [dkepath.zhangyp(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.zhangyp(1).compiler_opt.libs.gfortran = [dkepath.zhangyp(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.zhangyp(1).compiler_opt.copts = '';
dkepath.zhangyp(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.zhangyp(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.zhangyp(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.zhangyp(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.zhangyp(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.zhangyp(1).MUMPS.mex801 = [dkepath.zhangyp(1).local_root,'MUMPS_5.1.2/MATLAB801'];
%
% LUKE documentation
%
dkepath.zhangyp(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.zhangyp(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.zhangyp(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.zhangyp(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.zhangyp(1).remote(1).schedulername = 'torque';
dkepath.zhangyp(1).remote(1).profilename = 'local';
dkepath.zhangyp(1).remote(1).luke_root = dkepath.zhangyp(1).luke_root;% local cluster
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 5, Jie Zhang  ----------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.zhangjie(1).luke_root = '/opt/TOKAMAK_CODE/luke/LUKE/';
dkepath.zhangjie(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';
%
dkepath.zhangjie(1).temppathroot = '/home/zhangjie/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.zhangjie(1).localdatapath = dkepath.zhangjie(1).temppathroot;
%
dkepath.zhangjie(1).mex801 = [dkepath.zhangjie(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.zhangjie(1).compiler_opt.libs.gfortran = [dkepath.zhangjie(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.zhangjie(1).compiler_opt.copts = '';
dkepath.zhangjie(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.zhangjie(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.zhangjie(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.zhangjie(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.zhangjie(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.zhangjie(1).MUMPS.mex801 = [dkepath.zhangjie(1).local_root,'MUMPS_5.1.2/MATLAB801'];
%
% LUKE documentation
%
dkepath.zhangjie(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.zhangjie(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.zhangjie(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.zhangjie(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.zhangjie(1).remote(1).schedulername = 'torque';
dkepath.zhangjie(1).remote(1).profilename = 'local';
dkepath.zhangjie(1).remote(1).luke_root = dkepath.zhangjie(1).luke_root;% local cluster
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 6, Xingyu Bai ----------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.baixy(1).luke_root = '/opt/TOKAMAK_CODE/luke/LUKE/';
dkepath.baixy(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';
%
dkepath.baixy(1).temppathroot = '/home/baixy/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.baixy(1).localdatapath = dkepath.baixy(1).temppathroot;
%
dkepath.baixy(1).mex801 = [dkepath.baixy(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.baixy(1).compiler_opt.libs.gfortran = [dkepath.baixy(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.baixy(1).compiler_opt.copts = '';
dkepath.baixy(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.baixy(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.baixy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.baixy(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.baixy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.baixy(1).MUMPS.mex801 = [dkepath.baixy(1).local_root,'MUMPS_5.1.2/MATLAB801'];
%
% LUKE documentation
%
dkepath.baixy(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.baixy(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.baixy(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.baixy(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.baixy(1).remote(1).schedulername = 'torque';
dkepath.baixy(1).remote(1).profilename = 'local';
dkepath.baixy(1).remote(1).luke_root = dkepath.baixy(1).luke_root;% local cluster


