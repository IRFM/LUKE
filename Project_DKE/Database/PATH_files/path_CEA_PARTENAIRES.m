function dkepath = path_CEA_PARTENAIRES
%
% path definitions for the andromede and cephee computers (CEA Partenaires Zone)
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'andromede1','andromede2','andromede3','andromede4','andromede5','andromede6','cephee'};%andromede5 is called by default from CEA intranet
dkepath.hostname = {'andromede1.partenaires.cea.fr','andromede2','p-andromede03','p-andromede04','p-andromede05','p-andromede06','cephee'};% should match the output of hostname_jd on the machine
%
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'YP105119';
%
%------------------------------------ Profile number 1, YP105119 Peysson ------------------------------------
%
dkepath.YP105119(1).luke_root = '/home/YP105119/LUKE/';
dkepath.YP105119(1).temppathroot = '/data/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- andromede 1 -------------------------------
%
dkepath.YP105119(1).andromede1.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).andromede1.mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.YP105119(1).andromede1.mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
dkepath.YP105119(1).andromede1.mex801 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB801/'];
dkepath.YP105119(1).andromede1.mex805 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB805/'];
dkepath.YP105119(1).andromede1.mex806 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB806/'];
%
dkepath.YP105119(1).andromede1.compiler_opt.copts = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex800 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex801 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex805 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex806 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex800 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex801 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex805 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex806 = '';
dkepath.YP105119(1).andromede1.compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede1.compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede1.compiler_opt.helmex.mex801 = ['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede1.compiler_opt.helmex.mex805 = ['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede1.compiler_opt.helmex.mex806 = ['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).andromede1.MUMPS.mex710 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex800 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex801 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex805 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex806 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).andromede1.extrapaths.LUKE_ITM = '/home/YP105119/LUKE_ITM/trunk';% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.YP105119(1).andromede1.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).andromede1.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).andromede1.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- andromede 2-5 -------------------------------
%
dkepath.YP105119(1).andromede1 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede2 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede3 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede4 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede5 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).andromede6 = dkepath.YP105119(1).andromede1;
%
% ---------------------------- cephee -------------------------------
%
dkepath.YP105119(1).cephee.local_root = '/home/YP105119/Packages/cephee/';
%
dkepath.YP105119(1).cephee.mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.YP105119(1).cephee.mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
dkepath.YP105119(1).cephee.mex801 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB801/'];
%
dkepath.YP105119(1).cephee.compiler_opt.copts = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex800 = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex801 = '';
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex801 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).cephee.MUMPS.mex710 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).cephee.MUMPS.mex800 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).cephee.MUMPS.mex801 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).cephee.extrapaths.LUKE_ITM = '/home/YP105119/LUKE_ITM/trunk';% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.YP105119(1).cephee.graphviz.env = '';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).cephee.latex.env = '';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).cephee.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.YP105119(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.YP105119(1).remote(1).schedulername = 'pbs';
dkepath.YP105119(1).remote(1).profilename = 'YP105119';
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
%------------------------------------ Profile number 2, JA132999 Artaud ------------------------------------
%
dkepath.JA132999(1).luke_root = '/donnees/JA132999/public/luke/LUKE/';
dkepath.JA132999(1).temppathroot = '/data/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- andromede 1 -------------------------------
%
dkepath.JA132999(1).andromede1.local_root = '/donnees/JA132999/public/luke/Packages/andromede/';
%
dkepath.JA132999(1).andromede1.mex800 = [dkepath.JA132999(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
dkepath.JA132999(1).andromede1.mex801 = [dkepath.JA132999(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB801/'];
dkepath.JA132999(1).andromede1.mex805 = [dkepath.JA132999(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB805/'];
dkepath.JA132999(1).andromede1.mex806 = [dkepath.JA132999(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB806/'];
%
dkepath.JA132999(1).andromede1.compiler_opt.copts = '';
dkepath.JA132999(1).andromede1.compiler_opt.copts.cpp.mex805 = '-f /donnees/JA132999/public/luke/LUKE/Project_DKE/MEX/Bin/andromede/MATLAB805/g++_glnxa64.xml';
dkepath.JA132999(1).andromede1.compiler_opt.copts.cpp.mex806 = '-f /donnees/JA132999/public/luke/LUKE/Project_DKE/MEX/Bin/andromede/MATLAB806/g++_glnxa64.xml';
dkepath.JA132999(1).andromede1.compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.JA132999(1).andromede1.compiler_opt.fopts.mex800 = '';
dkepath.JA132999(1).andromede1.compiler_opt.fopts.mex801 = '';
dkepath.JA132999(1).andromede1.compiler_opt.fopts.mex805 = '';
dkepath.JA132999(1).andromede1.compiler_opt.fopts.mex806 = '';
dkepath.JA132999(1).andromede1.compiler_opt.helmex.mex800 = ['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JA132999(1).andromede1.compiler_opt.helmex.mex801 = ['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JA132999(1).andromede1.compiler_opt.helmex.mex805 = ['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JA132999(1).andromede1.compiler_opt.helmex.mex806 = ['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JA132999(1).andromede1.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JA132999(1).andromede1.MUMPS.mex800 = [dkepath.JA132999(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JA132999(1).andromede1.MUMPS.mex801 = [dkepath.JA132999(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JA132999(1).andromede1.MUMPS.mex805 = [dkepath.JA132999(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JA132999(1).andromede1.MUMPS.mex806 = [dkepath.JA132999(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.JA132999(1).andromede1.extrapaths.LUKE_ITM = '/donnees/JA132999/public/luke/LUKE_ITM/trunk';% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.JA132999(1).andromede1.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.JA132999(1).andromede1.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.JA132999(1).andromede1.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- andromede 2-5 -------------------------------
%
dkepath.JA132999(1).andromede01 = dkepath.JA132999(1).andromede1;
dkepath.JA132999(1).andromede02 = dkepath.JA132999(1).andromede1;
dkepath.JA132999(1).andromede03 = dkepath.JA132999(1).andromede1;
dkepath.JA132999(1).andromede04 = dkepath.JA132999(1).andromede1;
dkepath.JA132999(1).andromede05 = dkepath.JA132999(1).andromede1;
dkepath.JA132999(1).andromede06 = dkepath.JA132999(1).andromede1;
%
% ---------------------------- cephee -------------------------------
%
dkepath.JA132999(1).cephee.local_root = '/donnees/JA132999/public/luke/Packages/cephee/';
%
dkepath.JA132999(1).cephee.mex800 = [dkepath.JA132999(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
dkepath.JA132999(1).cephee.mex801 = [dkepath.JA132999(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB801/'];
%
dkepath.JA132999(1).cephee.compiler_opt.copts = '';
dkepath.JA132999(1).cephee.compiler_opt.fopts.mex800 = '';
dkepath.JA132999(1).cephee.compiler_opt.fopts.mex801 = '';
dkepath.JA132999(1).cephee.compiler_opt.helmex.mex800 = ['-L',dkepath.JA132999(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JA132999(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JA132999(1).cephee.compiler_opt.helmex.mex801 = ['-L',dkepath.JA132999(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JA132999(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JA132999(1).cephee.MUMPS.mex800 = [dkepath.JA132999(1).cephee.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JA132999(1).cephee.MUMPS.mex801 = [dkepath.JA132999(1).cephee.local_root,'MUMPS_4.10.0/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.JA132999(1).cephee.extrapaths.LUKE_ITM = '/donnees/JA132999/public/luke/LUKE_ITM/trunk';% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.JA132999(1).cephee.graphviz.env = '';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.JA132999(1).cephee.latex.env = '';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.JA132999(1).cephee.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.JA132999(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.JA132999(1).remote(1).schedulername = 'pbs';
dkepath.JA132999(1).remote(1).profilename = 'JA132999';
dkepath.JA132999(1).remote(1).luke_root = dkepath.JA132999(1).luke_root;% local cluster
