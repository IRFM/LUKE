%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'PC_CMOD_JOAN';%Set here the name path parameters (user specific)
%
dkepath.path_id = path_id;
dkepath.computer = 'GLNX86';%machine type and supported OS
dkepath.MUMPS = '/home/decker/Packages/MUMPS_4.6.1/dke';%Where MUMPS matrix solver is stored
dkepath.PETSC = '';%Where PETSC matrix solver is stored
dkepath.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = '/home/decker/Project_DKE/MEX';
%
eval(['save PATH_',path_id ,'.mat dkepath']);