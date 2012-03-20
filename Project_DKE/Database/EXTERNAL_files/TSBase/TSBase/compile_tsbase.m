function [] = compile_tsbase(fname)
%
%   Compilation of mexfile for loading experimental data of Tore Supra tokamak (tsbase, tsmat, tsdernier_choc)
%
%	Input: 
%       - fname: function name -> 'tsbase', 'tsmat' or 'tsdernier_choc' [1,n]
%           (default = empty or none, all are build)
%
%	Output: None
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 0, fname = '';end
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
if isempty(fname),
    mex -v tsbase.c tsignit.c tsparse.c -L../TSLib/ -lTS
    mex -v tsmat.c tsignit.c tsparse.c -L../TSLib/ -lTS
    mex -v tsdernier_choc.c tsignit.c tsparse.c -L../TSLib/ -lTS
else
    eval(['mex -v ',fname,'.c tsignit.c tsparse.c -L../TSLib/ -lTS']);   
end
cd ..
%
cd(dirinit)