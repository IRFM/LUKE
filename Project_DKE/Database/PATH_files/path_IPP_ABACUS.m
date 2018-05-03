function dkepath = path_IPP_ABACUS
%
% path definitions for IPP ABACUS cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'abacus','abacus01','abacus02','abacus03'};%andromede5 is called by default from CEA intranet
dkepath.hostname = {'abacus','abacus01','abacus02','abacus03'};% should match the output of hostname_jd on the machine
%
dkepath.computer = computer;%machine type and supported OS
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.peysson(1).luke_root = '/compass/Shared/Common/IT/projects/luke/LUKE/';
dkepath.peysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.peysson(1).abacus.local_root = '/compass/Shared/Common/IT/projects/luke/Packages/';
%
dkepath.peysson(1).abacus.mex800 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/abacus/MATLAB800/'];%r2012b
dkepath.peysson(1).abacus.mex801 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/abacus/MATLAB801/'];%r2013a
dkepath.peysson(1).abacus.mex803 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/abacus/MATLAB803/'];%r2014a
dkepath.peysson(1).abacus.mex804 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/abacus/MATLAB804/'];%r2014b
dkepath.peysson(1).abacus.mex902 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/abacus/MATLAB902/'];%r2017a
%
dkepath.peysson(1).abacus.compiler_opt.libs.gfortran = [dkepath.peysson(1).abacus.luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
dkepath.peysson(1).abacus.compiler_opt.copts = '';
dkepath.peysson(1).abacus.compiler_opt.fopts.mex800 = 'FC=''gfortran''';%
dkepath.peysson(1).abacus.compiler_opt.separatrice.mex800 = [' -largeArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.helmex.mex800 = [' -compatibleArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.fopts.mex800 = ' ';%-largeArrayDims';
dkepath.peysson(1).abacus.compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
dkepath.peysson(1).abacus.compiler_opt.separatrice.mex801 = [' -largeArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.helmex.mex801 = [' -compatibleArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
dkepath.peysson(1).abacus.compiler_opt.fopts.mex803 = 'FC=''gfortran''';%
dkepath.peysson(1).abacus.compiler_opt.separatrice.mex803 = [' -largeArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.helmex.mex803 = [' -compatibleArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.fopts.mex803 = ' ';%-largeArrayDims';
dkepath.peysson(1).abacus.compiler_opt.fopts.mex804 = 'FC=''gfortran''';%
dkepath.peysson(1).abacus.compiler_opt.separatrice.mex804 = [' -largeArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.helmex.mex804 = [' -compatibleArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.4.2 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.fopts.mex804 = ' ';%-largeArrayDims';
dkepath.peysson(1).abacus.compiler_opt.fopts.mex902 = 'FC=''gfortran''';%
dkepath.peysson(1).abacus.compiler_opt.separatrice.mex902 = [' -largeArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.helmex.mex902 = [' -compatibleArrayDims -lgfortran -L',dkepath.peysson(1).abacus.local_root,'lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.peysson(1).abacus.compiler_opt.fopts.mex902 = ' ';%-largeArrayDims';
%
dkepath.peysson(1).abacus.MUMPS.mex800 = [dkepath.peysson(1).abacus.local_root,'MUMPS_4.10.0/MATLAB800'];;%Where MUMPS matrix solver is stored (MEX function)
dkepath.peysson(1).abacus.MUMPS.mex801 = [dkepath.peysson(1).abacus.local_root,'MUMPS_4.10.0/MATLAB801'];;%Where MUMPS matrix solver is stored (MEX function)
dkepath.peysson(1).abacus.MUMPS.mex803 = [dkepath.peysson(1).abacus.local_root,'MUMPS_4.10.0/MATLAB803'];;%Where MUMPS matrix solver is stored (MEX function)
dkepath.peysson(1).abacus.MUMPS.mex804 = [dkepath.peysson(1).abacus.local_root,'MUMPS_4.10.0/MATLAB804'];;%Where MUMPS matrix solver is stored (MEX function)
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
dkepath.peysson(1).abacus01 = dkepath.peysson(1).abacus;
dkepath.peysson(1).abacus02 = dkepath.peysson(1).abacus;
dkepath.peysson(1).abacus03 = dkepath.peysson(1).abacus;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.peysson(1).remote(1).remoteid = 'IPP_ABACUS';
dkepath.peysson(1).remote(1).schedulername = 'pbs';
dkepath.peysson(1).remote(1).profilename = 'local';
dkepath.peysson(1).remote(1).luke_root = dkepath.peysson(1).luke_root;% local cluster
%
%------------------------------------ Profile number 1, Jakub Urban ------------------------------------
%
dkepath.urban(1) = dkepath.peysson(1);
%
%------------------------------------ Profile number 1, Richard Paprok ------------------------------------
%
dkepath.paprok(1) = dkepath.peysson(1);


