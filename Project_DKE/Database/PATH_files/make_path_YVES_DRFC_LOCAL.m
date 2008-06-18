


%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file local_local_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
local_id = 'LOCAL';%Set here the name path parameters (user specific)
%
local_root = [getenv('HOME'),'/'];
luke_root = [local_root,'LUKE/'];
%
dkepath.path_id = local_id;
dkepath.computer = computer;%machine type and supported OS
dkepath.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.luke_root = luke_root;
dkepath.local_root = local_root;
%
dkepath.MUMPS.par = [local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_mpichpgf/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
dkepath.MUMPS.seq = [local_root,'Packages/Bin/MUMPS/MUMPS_4.6.4_S_g95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.MUMPS.mex = ['/luke/Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.mex74 = [local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfor/MATLAB.r2007a'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.mex75 = ['/home/sccp/gsem/PH214199/AO_sauve/Projet_Cronos/libs/MUMPS_4.7.3/MATLAB'];
dkepath.MUMPS.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.PETSc.par = [local_root,'Packages/Bin/PETSC/petsc-2.3.2-p8_P_mpichpgf/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.PETSc.seq = [local_root,''];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%dkepath.PETSc.mex = [local_root,''];%Where PETSc matrix solver is stored (MEX function)
dkepath.PETSc.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.SUPERLU.mex = [local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-pgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.compiler_opt.helmex = '';
%
eval(['save PATH_',local_id ,'.mat dkepath']);
