function dkepath = path_laptop_YVES_PEYSSON
%
% path definitions for macbook pro 2010 (Core i7 Intel) of Yves Peysson 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'macbookyves';
dkepath.hostname = 'macbookyves';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'yves';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yves(1).luke_root = [pwd,filesep];
dkepath.yves(1).local_root = [getenv('HOME'),'/Projets/'];
dkepath.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%%%dkepath.yves(1).startup{1} = [];
%
%%%dkepath.yves(1).cshrc{1} = [];
%
dkepath.yves(1).mex801 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB801','/'];
%
dkepath.yves(1).compiler_opt.copts = '';
dkepath.yves(1).compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.helmex.mex801 = ' -llapack -lblas';%-O2 -fdefault-real-8 -fdefault-double-8 -lgfortran';%'  -llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%dkepath.yves(1).MUMPS.par = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yves(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
dkepath.yves(1).MUMPS.seq = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.yves(1).MUMPS.mex801 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
dkepath.yves(1).SUPERLU.mex801 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB801'];%Where SUPERLU matrix solver is stored (MEX function)
%
% PETSc matrix solver (parallel, sequential)
%
%dkepath.yves(1).PETSc.par = [dkepath.yves(1).local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yves(1).PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%dkepath.yves(1).PETSc.seq = [dkepath.yves(1).local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
dkepath.yves(1).TSBASE.mex = [dkepath.yves(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
% LUKE documentation
%
dkepath.yves(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable
dkepath.yves(1).latex.env = '/usr/texbin/';% Latex environment variable
dkepath.yves(1).imagemagick.env = '/usr/local/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.yves(1).remote(1).remoteid = 'laptop_YVES_PEYSSON';
dkepath.yves(1).remote(1).schedulername = 'condor';
dkepath.yves(1).remote(1).profilename = 'yves';
dkepath.yves(1).remote(1).luke_root = dkepath.yves(1).luke_root;% local cluster
%
dkepath.yves(1).remote(2) = dkepath.yves(1).remote(1);
dkepath.yves(1).remote(2).schedulername = 'xgrid';
%
dkepath.yves(1).remote(3) = dkepath.yves(1).remote(1);
dkepath.yves(1).remote(3).schedulername = 'direct';
%
dkepath.yves(1).remote(4).remoteid = 'macpro_YVES_PEYSSON';
dkepath.yves(1).remote(4).schedulername = 'condor';
dkepath.yves(1).remote(4).profilename = 'yves';
dkepath.yves(1).remote(4).luke_root = '/Users/yvespeysson/Projets/LUKE/';
%
dkepath.yves(1).remote(5) = dkepath.yves(1).remote(4);
dkepath.yves(1).remote(5).schedulername = 'xgrid';
%
dkepath.yves(1).remote(6) = dkepath.yves(1).remote(4);
dkepath.yves(1).remote(6).schedulername = 'direct';
%
dkepath.yves(1).remote(7).remoteid = 'CEA_ANDROMEDE';
dkepath.yves(1).remote(7).schedulername = 'pbs';
dkepath.yves(1).remote(7).profilename = 'YP105119';
dkepath.yves(1).remote(7).luke_root = '/home/YP105119/LUKE/';
%
dkepath.yves(1).remote(8).remoteid = 'ASIPP_SHENMA';
dkepath.yves(1).remote(8).schedulername = 'torque';
dkepath.yves(1).remote(8).profilename = 'yves';
dkepath.yves(1).remote(8).luke_root = '/home/PEYSSON/LUKE/';
%
dkepath.yves(1).remote(9).remoteid = 'EFDA_ITM';
dkepath.yves(1).remote(9).schedulername = 'sge';
dkepath.yves(1).remote(9).profilename = 'yvesp';
dkepath.yves(1).remote(9).luke_root = '/pfs/home/yvesp/public/LUKE_ITM/trunk/LUKE/';
%




