% script setpath_luke_jd
%
% This script sets the path such that the simulations run on the taged LUKE
% version
%
luke_root = '/cgc_data/zineb/data/LUKE/Project_DKE/';
%
addpath([luke_root,'Modules/FEB/Response']);
addpath([luke_root,'Modules/FEB/Pile-up']);
addpath([luke_root,'Modules/FEB']);
addpath([luke_root,'Modules/FEB/MEX/BIN']);
addpath([luke_root,'Modules/Helena']);
addpath([luke_root,'Modules/Helena/MEX/BIN']);
addpath([luke_root,'Modules/R2D2']);
addpath([luke_root,'Modules/R2D2/MEX/BIN']);
addpath([luke_root,'Modules/EFIT']);
addpath([luke_root,'Modules/RT']);
addpath([luke_root,'Modules/RT/MEX/BIN']);
addpath([luke_root,'Modules/Cronos']);
addpath([luke_root,'Packages/MUMPS']);
addpath([luke_root,'Database/PATH_files']);
addpath([luke_root,'Database/DISPLAY_files']);
addpath([luke_root,'Database/DKEPARAM_files']);
addpath([luke_root,'MEX']);
addpath([luke_root,'DKE']);
