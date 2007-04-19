%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
path_root = '/Users/Yves/CEA/Projets/LUKE/';
%
dkepath.path_id = path_id;
dkepath.computer = 'MAC';%machine type and supported OS
dkepath.temppathroot = '/scratch';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = [path_root,'Project_DKE/MEX'];%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.luke_root = path_root;
%
%dkepath.MUMPS.par = [path_root,''];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
dkepath.MUMPS.seq = [path_root,'Packages/MUMPS_4.7.2_S_g95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%dkepath.MUMPS.seq = [path_root,'Packages/MUMPS_4.7.2_S_absoft/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.MUMPS.mex = [path_root,'Packages/MUMPS_4.7.2_S_g95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%
%dkepath.PETSc.par = [path_root,'P'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
dkepath.PETSc.seq = [path_root,'Packages/petsc-2.3.2-p10_S_g95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%dkepath.PETSc.mex = [path_root,''];%Where PETSc matrix solver is stored (MEX function)
dkepath.PETSc.variables.input = [dkepath.temppathroot,'/DKESolver_variables'];%directory where all inout variables are written by PETSc
dkepath.PETSc.variables.output = [dkepath.temppathroot,'/DKESolver_output'];%location directory where the distribution function is written by C PETSc program before going back to matlab
%
dkepath.SUPERLU.mex = [path_root,'Packages/SuperLU_3.0/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
%
eval(['save PATH_',path_id ,'.mat dkepath']);
