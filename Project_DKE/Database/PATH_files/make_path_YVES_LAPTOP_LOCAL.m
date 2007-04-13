%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LAPTOP_YVES';%Set here the name path parameters (user specific)
%
path_root = '/Users/Yves/CEA/Projets/LUKE/';
%
dkepath.path_id = path_id;
dkepath.computer = 'MAC';%machine type and supported OS
%dkepath.MUMPS = [path_root,'Packages/MUMPS_4.7.0_S_absoft/dke'];%Where script MUMPS matrix solver is stored
dkepath.MUMPS = [path_root,'Packages/MUMPS_4.7.0_S_g95/dke'];%Where MUMPS matrix solver (independent program) is stored
dkepath.MUMPSMEX = [path_root,'Packages/MUMPS_4.7.0_S_g95/MATLAB'];%Where MUMPS matrix solver (independent program) is stored
dkepath.SUPERLUMEX = [path_root,'Packages/SuperLU_3.0/MATLAB'];%Where MUMPS matrix solver (independent program) is stored
dkepath.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = [path_root,'Project_DKE/MEX'];%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.luke_root = path_root;
%
eval(['save PATH_',path_id ,'.mat dkepath']);
