%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LAPTOP_JOAN';%Set here the name path parameters (user specific)
%
path.path_id = path_id;
path.computer = 'PCWIN';%machine type and supported OS
path.MUMPS = 'D:/Work/Packages/MUMPS_4.6.1/dke';%Where MUMPS matrix solver is stored
path.PETSC = '';%Where PETSC matrix solver is stored
path.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
path.mex = 'D:/Work/Project_DKE/MEX';
%
eval(['save PATH_',path_id ,'.mat path']);