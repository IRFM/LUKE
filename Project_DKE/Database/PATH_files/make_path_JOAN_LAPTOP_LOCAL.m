%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LAPTOP_JOAN';%Set here the name path parameters (user specific)
%
path_root = 'D:/Work/';
%
dkepath.path_id = path_id;
dkepath.computer = 'PCWIN';%machine type and supported OS
dkepath.MUMPS = [path_root,'Packages/MUMPS_4.6.1/dke'];%Where MUMPS matrix solver is stored
dkepath.PETSC = [path_root,'Packages/petsc-2.3.2-p8'];%Where PETSC matrix solver is stored
dkepath.PETSc_DIR = [path_root,'Packages/petsc-2.3.2-p8'];
dkepath.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = [path_root,'Project_DKE/MEX'];
dkepath.variables.input = [path_root,'Packages/petsc-2.3.2-p8/DKE/DKESolver_variables'];%directory where all inout variables are written
dkepath.variables.output = [path_root,'Packages/petsc-2.3.2-p8/DKE/DKESolver_output'];%location directory where the distribution function is written by C program before going back to matlab
dkepath.pathfile = 'setpath_DRFC_JOAN_jd';
%
eval(['save PATH_',path_id ,'.mat dkepath']);
