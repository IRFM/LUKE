%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LUKE_DRFC';%Set here the name path parameters (user specific)
%
path_root = '/cgc_data/zineb/data/LUKE/';
%
dkepath.path_id = path_id;
dkepath.computer = 'GLNXA64';%machine type and supported OS
dkepath.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = [path_root,'Project_DKE/MEX'];
dkepath.luke_root = path_root;
%
dkepath.MUMPS.par = [path_root,'Packages/MUMPS_4.6.4_P_pgf/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
dkepath.MUMPS.seq = [path_root,'Packages/MUMPS_4.7.2_S_pgf/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.MUMPS.mex = [path_root,'Packages/MUMPS_4.6.4_S_pgf/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.PETSc.par = [path_root,'Packages/petsc-2.3.2-p8_P_pgf/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.PETSc.seq = [path_root,''];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%dkepath.PETSc.mex = [path_root,''];%Where PETSc matrix solver is stored (MEX function)
%
dkepath.SUPERLU.mex = [path_root,'Packages/SuperLU_3.0/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
eval(['save PATH_',path_id ,'.mat dkepath']);