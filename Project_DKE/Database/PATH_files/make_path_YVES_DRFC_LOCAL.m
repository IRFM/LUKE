


%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
path_root = '/home/sccp/gsem/peysson/LUKE/';
%
dkepath.path_id = path_id;
dkepath.computer = 'GLNXA64';%machine type and supported OS
dkepath.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = [path_root,'Project_DKE/MEX'];
dkepath.luke_root = path_root;
%
dkepath.MUMPS.par = [path_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_mpichpgf/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
dkepath.MUMPS.seq = [path_root,'Packages/Bin/MUMPS/MUMPS_4.6.4_S_pgf/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.MUMPS.mex = [path_root,'Packages/Bin/MUMPS/MUMPS_4.6.4_S_pgf/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.PETSc.par = [path_root,'Packages/Bin/PETSC/petsc-2.3.2-p8_P_mpichpgf/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.PETSc.seq = [path_root,''];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%dkepath.PETSc.mex = [path_root,''];%Where PETSc matrix solver is stored (MEX function)
dkepath.PETSc.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.SUPERLU.mex = [path_root,'Packages/Bin/SUPERLU/SuperLU_3.0-pgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
eval(['save PATH_',path_id ,'.mat dkepath']);
