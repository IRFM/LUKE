function dkepath = path_CEA_PARTENAIRES
%
% path definitions for the altair, andromede and cephee computers (CEA Partenaires Zone)
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine =  {'persee','altair','andromede1','andromede2','andromede3','andromede4','andromede5','andromede6','cephee','rana'};
dkepath.hostname = {'persee','altair','andromede1','andromede2','andromede3','andromede4','andromede5','andromede6','cephee','rana'};% should match the output of hostname_jd on the machine
%
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'YP105119';
%
%------------------------------------ Profile number 1, YP105119 Peysson ------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.YP105119(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.YP105119(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.YP105119(1).temppathroot = '/data/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- persee -------------------------------
%
dkepath.YP105119(1).persee.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).persee.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/persee/MATLAB802/'];
dkepath.YP105119(1).persee.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/persee/MATLAB909/'];
%
dkepath.YP105119(1).persee.compiler_opt.copts = '';
dkepath.YP105119(1).persee.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).persee.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).persee.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).persee.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).persee.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).persee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).persee.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).persee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).persee.MUMPS.mex802 = [dkepath.YP105119(1).persee.local_root,'MUMPS_4.10.0/MATLAB802'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).persee.MUMPS.mex909 = [dkepath.YP105119(1).persee.local_root,'MUMPS_4.10.0/MATLAB909'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).persee.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).persee.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).persee.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- altair -------------------------------
%
dkepath.YP105119(1).altair.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).altair.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/altair/MATLAB802/'];
dkepath.YP105119(1).altair.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/altair/MATLAB909/'];
%
dkepath.YP105119(1).altair.compiler_opt.copts = '';
dkepath.YP105119(1).altair.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).altair.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).altair.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).altair.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).altair.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).altair.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).altair.MUMPS.mex802 = [dkepath.YP105119(1).altair.local_root,'MUMPS_4.10.0/MATLAB802'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).altair.MUMPS.mex909 = [dkepath.YP105119(1).altair.local_root,'MUMPS_4.10.0/MATLAB909'];%Where MUMPS matrix solver is stored (MEX function)
%
%dkepath.YP105119(1).altair.extrapaths.LUKE_ITM = '/home/YP105119/LUKE_ITM/trunk';% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.YP105119(1).altair.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).altair.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).altair.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- andromede 1-5 -------------------------------
%
dkepath.YP105119(1).andromede1.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).andromede1.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB802/'];
dkepath.YP105119(1).andromede1.mex903 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB903/'];
%
dkepath.YP105119(1).andromede1.compiler_opt.copts = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex802 = '';
kepath.YP105119(1).andromede1.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).andromede1.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede1.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).andromede1.MUMPS.mex802 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB802'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex909 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB909'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).andromede1.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).andromede1.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).andromede1.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
dkepath.YP105119(1).andromede2 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede3 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede4 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede5 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede6 = dkepath.YP105119(1).andromede1;
%
% ---------------------------- cephee -------------------------------
%
dkepath.YP105119(1).cephee.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).cephee.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB802/'];
dkepath.YP105119(1).cephee.mex903 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB903/'];
dkepath.YP105119(1).cephee.mex907 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB907/'];
dkepath.YP105119(1).cephee.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB909/'];
%
dkepath.YP105119(1).cephee.compiler_opt.copts = '';
dkepath.YP105119(1).cephee.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).cephee.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).cephee.MUMPS.mex802 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB802'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).cephee.MUMPS.mex909 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB909'];%Where MUMPS matrix solver is stored (MEX function)
%
%dkepath.YP105119(1).cephee.extrapaths.LUKE_ITM = '/home/YP105119/LUKE_ITM/trunk';% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.YP105119(1).cephee.graphviz.env = '';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).cephee.latex.env = '';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).cephee.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- rana -------------------------------
%
dkepath.YP105119(1).rana.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).rana.compiler_opt.copts = '';
dkepath.YP105119(1).rana.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).rana.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).rana.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).rana.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).rana.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).rana.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).rana.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).rana.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).altair.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).rana.MUMPS.mex802 = [dkepath.YP105119(1).rana.local_root,'MUMPS_4.10.0/MATLAB802'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).rana.MUMPS.mex909 = [dkepath.YP105119(1).rana.local_root,'MUMPS_4.10.0/MATLAB909'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).rana.graphviz.env = '';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).rana.latex.env = '';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).rana.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.YP105119(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.YP105119(1).remote(1).schedulername = 'pbs';
dkepath.YP105119(1).remote(1).profilename = 'YP105119';
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%{
dkepath.YP105119(1).remote(2).remoteid = 'CEA_ALTAIR';
dkepath.YP105119(1).remote(2).schedulername = 'pbs';
dkepath.YP105119(1).remote(2).profilename = 'YP105119';
dkepath.YP105119(1).remote(2).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(3).remoteid = 'CEA_CEPHEE';
dkepath.YP105119(1).remote(3).schedulername = 'pbs';
dkepath.YP105119(1).remote(3).profilename = 'YP105119';
dkepath.YP105119(1).remote(3).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(4).remoteid = 'CEA_PERSEE';
dkepath.YP105119(1).remote(4).schedulername = 'pbs';
dkepath.YP105119(1).remote(4).profilename = 'YP105119';
dkepath.YP105119(1).remote(4).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(5).remoteid = 'CEA_RANA';
dkepath.YP105119(1).remote(5).schedulername = 'pbs';
dkepath.YP105119(1).remote(5).profilename = 'YP105119';
dkepath.YP105119(1).remote(5).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%}
%------------------------------------ Other LUKE users ------------------------------
%
dkepath.JA132999(1) = dkepath.YP105119(1);% Jean-François Artaud
dkepath.JA132999(1).luke_root = '/home/JA132999/luke/LUKE_LHCD/';
dkepath.JA132999(1).remote(1).luke_root = dkepath.JA132999(1).luke_root;
dkepath.JA132999(1).remote(1).profilename = 'JA132999';
%
dkepath.CB165101(1) = dkepath.YP105119(1);%Clarisse Bourdelle
dkepath.CB165101(1).luke_root = '/home/CB165101/luke/LUKE_LHCD/';
dkepath.CB165101(1).remote(1).luke_root = dkepath.CB165101(1).luke_root;
dkepath.CB165101(1).remote(1).profilename = 'CB165101';
%
dkepath.MG100063(1) = dkepath.YP105119(1);%Marc Goniche
dkepath.MG100063(1).luke_root = '/home/MG100063/luke/LUKE_LHCD/';
dkepath.MG100063(1).remote(1).luke_root = dkepath.MG100063(1).luke_root;
dkepath.MG100063(1).remote(1).profilename = 'MG100063';
%
dkepath.VO259454(1) = dkepath.YP105119(1);%Valeria Ostuni
dkepath.VO259454(1).luke_root = '/home/VO259454/luke/LUKE_LHCD/';
dkepath.VO259454(1).remote(1).luke_root = dkepath.VO259454(1).luke_root;
dkepath.VO259454(1).remote(1).profilename = 'VO259454';
%
dkepath.JM240179(1) = dkepath.YP105119(1);%Jorge Morales
dkepath.JM240179(1).luke_root = '/home/JM240179/luke/LUKE_LHCD/';
dkepath.JM240179(1).remote(1).luke_root = dkepath.JM240179(1).luke_root;
dkepath.JM240179(1).remote(1).profilename = 'JM240179';
%
dkepath.TB263881(1) = dkepath.YP105119(1);%Tullio Barbui
dkepath.TB263881(1).luke_root = '/home/TB263881/luke/LUKE_LHCD/';
dkepath.TB263881(1).remote(1).luke_root = dkepath.TB263881(1).luke_root;
dkepath.TB263881(1).remote(1).profilename = 'TB263881';









