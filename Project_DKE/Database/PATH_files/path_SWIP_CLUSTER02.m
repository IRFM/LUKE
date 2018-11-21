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
dkepath.hostname = 'mgmt';
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
dkepath.Yves(1).luke_root = '/home/Yves/LUKE/';
dkepath.Yves(1).local_root = '/home/Yves/Packages/';
dkepath.Yves(1).temppathroot = '/home/Yves/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.Yves(1).localdatapath = dkepath.Yves(1).temppathroot;
%
dkepath.Yves(1).mex714 = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB714/'];
dkepath.Yves(1).mex801 = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
dkepath.Yves(1).mex802 = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB802/'];
%
dkepath.Yves(1).compiler_opt.libs.gfortran = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.Yves(1).compiler_opt.copts = '';
dkepath.Yves(1).compiler_opt.fopts.mex714 = 'FC=''gfortran''';%
%dkepath.Yves(1).compiler_opt.separatrice.mex714 = [' -largeArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%dkepath.Yves(1).compiler_opt.helmex.mex714 = [' -compatibleArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.separatrice.mex714 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.helmex.mex714 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.Yves(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.fopts.mex802 = 'FC=''gfortran''';%
dkepath.Yves(1).compiler_opt.separatrice.mex802 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.Yves(1).compiler_opt.helmex.mex802 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.Yves(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.Yves(1).MUMPS.mex714 = [dkepath.Yves(1).local_root,'MUMPS_4.10.0/MATLAB714'];
dkepath.Yves(1).MUMPS.mex801 = [dkepath.Yves(1).local_root,'MUMPS_4.10.0/MATLAB801'];
dkepath.Yves(1).MUMPS.mex802 = [dkepath.Yves(1).local_root,'MUMPS_4.10.0/MATLAB802'];
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
dkepath.mazy(1).luke_root = '/home/mazy/LUKE/';
dkepath.mazy(1).local_root = '/home/Yves/Packages/';
dkepath.mazy(1).temppathroot = '/home/mazy/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.mazy(1).localdatapath = dkepath.mazy(1).temppathroot;
%
dkepath.mazy(1).mex714 = [dkepath.mazy(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB714/'];
dkepath.mazy(1).mex801 = [dkepath.mazy(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
dkepath.mazy(1).mex802 = [dkepath.mazy(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB802/'];
%
dkepath.mazy(1).compiler_opt.libs.gfortran = [dkepath.mazy(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.mazy(1).compiler_opt.copts = '';
dkepath.mazy(1).compiler_opt.fopts.mex714 = 'FC=''gfortran''';%
%dkepath.mazy(1).compiler_opt.separatrice.mex714 = [' -largeArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%dkepath.mazy(1).compiler_opt.helmex.mex714 = [' -compatibleArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.mazy(1).compiler_opt.separatrice.mex714 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.mazy(1).compiler_opt.helmex.mex714 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.mazy(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.mazy(1).compiler_opt.separatrice.mex801 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.mazy(1).compiler_opt.helmex.mex801 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.mazy(1).compiler_opt.fopts.mex802 = 'FC=''gfortran''';%
dkepath.mazy(1).compiler_opt.separatrice.mex802 = NaN;%[' -largeArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.mazy(1).compiler_opt.helmex.mex802 = NaN;%[' -compatibleArrayDims -lgfortran -L',dkepath.mazy(1).local_root,'lapack-3.4.2-gfortran -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.mazy(1).MUMPS.mex714 = [dkepath.mazy(1).local_root,'MUMPS_4.10.0/MATLAB714'];
dkepath.mazy(1).MUMPS.mex801 = [dkepath.mazy(1).local_root,'MUMPS_4.10.0/MATLAB801'];
dkepath.mazy(1).MUMPS.mex802 = [dkepath.mazy(1).local_root,'MUMPS_4.10.0/MATLAB802'];
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
%
