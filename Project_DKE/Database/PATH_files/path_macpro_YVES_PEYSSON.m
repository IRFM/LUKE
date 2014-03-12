function dkepath = path_macpro_YVES_PEYSSON
%
% path definitions for macpro 2011 (Core i7 Intel) of Yves Peysson 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
dkepath.machine = 'macproyves';
dkepath.hostname = 'macproyves';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'yvespeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yvespeysson(1).luke_root = [pwd,filesep];% local path necessary to handle several LUKE versions 
%
% NOTE : It is better to use path_profile than pwd to separate between LUKE
% versions, but this is not yet fully supported by load_strutctures_yp
%
dkepath.yvespeysson(1).local_root = '/Users/yvespeysson/Shared/';
dkepath.yvespeysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.yvespeysson(1).mex800 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB800','/'];
dkepath.yvespeysson(1).mex801 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB801','/'];
%
dkepath.yvespeysson(1).compiler_opt.copts = '';
dkepath.yvespeysson(1).compiler_opt.helmex = NaN;%'-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.fopts = ' ';
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%dkepath.yvespeysson(1).MUMPS.par = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yvespeysson(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
dkepath.yvespeysson(1).MUMPS.seq = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.yvespeysson(1).MUMPS.mex800 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yvespeysson(1).MUMPS.mex801 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
dkepath.yvespeysson(1).SUPERLU.mex800 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB800'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yvespeysson(1).SUPERLU.mex801 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB801'];%Where SUPERLU matrix solver is stored (MEX function)
%
% PETSc matrix solver (parallel, sequential)
%
%dkepath.yvespeysson(1).PETSc.par = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yvespeysson(1).PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%dkepath.yvespeysson(1).PETSc.seq = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%
% PARDISO matrix solver (mex)
%
dkepath.yvespeysson(1).PARDISO.mex801 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PARDISO/MATLAB801'];%Where PARDISO matrix solver is stored (MEX function)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
dkepath.yvespeysson(1).TSBASE.mex = [dkepath.yvespeysson(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
% LUKE documentation
%
dkepath.yvespeysson(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable
dkepath.yvespeysson(1).latex.env = '/usr/texbin/';% Latex environment variable
dkepath.yvespeysson(1).imagemagick.env = '/opt/local/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.yvespeysson(1).remote(1).remoteid = 'macpro_YVES_PEYSSON';
dkepath.yvespeysson(1).remote(1).schedulername = 'condor';
dkepath.yvespeysson(1).remote(1).profilename = 'yves';
dkepath.yvespeysson(1).remote(1).luke_root = dkepath.yvespeysson(1).luke_root;% local cluster
%
dkepath.yvespeysson(1).remote(2) = dkepath.yvespeysson(1).remote(1);
dkepath.yvespeysson(1).remote(2).schedulername = 'xgrid';
%
dkepath.yvespeysson(1).remote(3) = dkepath.yvespeysson(1).remote(1);
dkepath.yvespeysson(1).remote(3).schedulername = 'direct';
%
dkepath.yvespeysson(1).remote(4).remoteid = 'ASIPP_SHENMA';
dkepath.yvespeysson(1).remote(4).schedulername = 'torque';
dkepath.yvespeysson(1).remote(4).profilename = 'yves';
dkepath.yvespeysson(1).remote(4).luke_root = '/home/PEYSSON/LUKE/';
dkepath.yvespeysson(1).remote(4).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.yvespeysson(1).remote(4).cvs.cmd = ['update -d ',dkepath.yvespeysson(1).remote(4).luke_root];%CVS command
%
dkepath.yvespeysson(1).remote(5).remoteid = 'CEA_ANDROMEDE';
dkepath.yvespeysson(1).remote(5).schedulername = 'pbs';
dkepath.yvespeysson(1).remote(5).profilename = 'YP105119';
dkepath.yvespeysson(1).remote(5).luke_root = '/home/YP105119/LUKE/';
%
dkepath.yvespeysson(1).remote(6).remoteid = 'EFDA_ITM';
dkepath.yvespeysson(1).remote(6).schedulername = 'sge';
dkepath.yvespeysson(1).remote(6).profilename = 'yvesp';
dkepath.yvespeysson(1).remote(6).luke_root = '/pfs/home/yvesp/public/LUKE_ITM/trunk/LUKE/';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 2, Joan Decker  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yvespeysson(2) = dkepath.yvespeysson(1);
%
dkepath.yvespeysson(2).remote(1).profilename = 'joan';
dkepath.yvespeysson(2).remote(2).profilename = 'joan';
dkepath.yvespeysson(2).remote(3).profilename = 'joan';
%
dkepath.yvespeysson(2).remote(4).profilename = 'joan';
dkepath.yvespeysson(2).remote(4).luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
dkepath.yvespeysson(2).remote(5).profilename = 'JD211098';
dkepath.yvespeysson(2).remote(5).luke_root = '/home/JD211098/LUKE/';
%
%
dkepath.yvespeysson(2).remote(6).remoteid = 'EFDA_ITM';
dkepath.yvespeysson(2).remote(6).schedulername = 'sge';
dkepath.yvespeysson(2).remote(6).profilename = 'yvesp';
dkepath.yvespeysson(2).remote(6).luke_root = '/pfs/home/yvesp/public/LUKE_ITM/trunk/LUKE/';
%
