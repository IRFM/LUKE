%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'PC_DRFC_YVES';%Set here the name path parameters (user specific)
%
path.path_id = path_id;
path.computer = 'GLNXA64';%machine type and supported OS
path.MUMPS = '/home/sccp/gsem/peysson/Packages/MUMPS_4.6.1/dke';%Where MUMPS matrix solver is stored
path.PETSC = '/home/sccp/gsem/peysson/Packages/petsc-2.3.2-p0/DKE';%Where PETSC matrix solver is stored
path.temppath = '/scratch';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
path.mex = '/home/sccp/gsem/peysson/Project_DKE/MEX';
%
eval(['save PATH_',path_id ,'.mat path']);