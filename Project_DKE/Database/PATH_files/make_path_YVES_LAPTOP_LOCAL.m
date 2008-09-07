%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
local_root = [getenv('HOME'),'/CEA/Projets/'];
luke_root = [local_root,'LUKE/'];
%
dkepath.path_id = path_id;
dkepath.computer = computer;%machine type and supported OS
dkepath.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.luke_root = luke_root;
dkepath.local_root = local_root;
%
dkepath.MUMPS.par = [local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
dkepath.MUMPS.seq = [local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_S_GotoBlasg95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%dkepath.MUMPS.mex = [local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_S_GotoBlasg95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.mex = [local_root,'Packages/Bin/MUMPS/MUMPS_4.8.1_S_GotoBlasg95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.PETSc.par = [local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
dkepath.PETSc.seq = [local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_S_g95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%dkepath.PETSc.mex = [local_root,''];%Where PETSc matrix solver is stored (MEX function)
dkepath.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.SUPERLU.mex = [local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.compiler_opt.helmex = '';%Compiling options for HELMEX
%
eval(['save PATH_',path_id ,'.mat dkepath']);