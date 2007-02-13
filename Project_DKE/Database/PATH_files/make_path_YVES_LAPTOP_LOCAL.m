%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LAPTOP_YVES';%Set here the name path parameters (user specific)
%
dkepath.path_id = path_id;
dkepath.computer = 'MAC';%machine type and supported OS
dkepath.MUMPS = '/Users/Yves/CEA/Projets/Packages/MUMPS_4.6.2_seq/dke';%Where MUMPS matrix solver is stored
dkepath.PETSC = '';%Where PETSC matrix solver is stored
dkepath.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = '/Users/Yves/CEA/Projets/Project_DKE/MEX';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.variables.input='';%directory where all inout variables are written
dkepath.variables.output='';%location directory where the distribution function is written by C program before going back to matlab
%
eval(['save PATH_',path_id ,'.mat dkepath']);