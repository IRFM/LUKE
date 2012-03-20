function [] = compile_tsbase
%
%   Compilation of mexfile for loading experimental data of Tore Supra tokamak (tsbase, tsmat, tsdernier_choc)
%
%	Input: None
%
%	Output: None
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
[dkepath] = load_structures_yp('dkepath','','');
dirinit = pwd;
cd([dkepath.luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase']);
%
% compilation of the TSLib first
%
cd TSLib
! make
cd ..
%
% build mexfiles
%
cd TSBase
mex -v tsbase.c tsignit.c tsparse.c -L../TSLib/ -lTS
mex -v tsmat.c tsignit.c tsparse.c -L../TSLib/ -lTS
mex -v tsdernier_choc.c tsignit.c tsparse.c -L../TSLib/ -lTS
cd ..
%
cd(dirinit)