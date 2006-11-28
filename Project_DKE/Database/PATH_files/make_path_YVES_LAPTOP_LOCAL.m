%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LAPTOP_YVES';%Set here the name path parameters (user specific)
%
path.path_id = path_id;
path.computer = 'MAC';%machine type and supported OS
path.MUMPS = '/Users/Yves/CEA/Projets/Packages/MUMPS_4.6.2_seq/dke';%Where MUMPS matrix solver is stored
path.PETSC = '';%Where PETSC matrix solver is stored
path.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
path.mex = '/Users/Yves/CEA/Projets/Project_DKE/MEX';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
eval(['save PATH_',path_id ,'.mat path']);