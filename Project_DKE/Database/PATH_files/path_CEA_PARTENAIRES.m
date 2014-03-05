function dkepath = path_CEA_ANDROMEDE
%
% path definitions for the ANDROMEDE cluster 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
%
dkepath.machine = 'andromede';
dkepath.hostname = 'andromede';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%------------------------------------ Profile number 1, JD211098 Decker ------------------------------------
%
dkepath.JD211098(1).luke_root = [pwd,filesep];
dkepath.JD211098(1).local_root = '/home/JD211098/Packages/andromede/';
dkepath.JD211098(1).temppathroot = '/data/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.JD211098(1).mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
%
dkepath.JD211098(1).compiler_opt.copts = '';
dkepath.JD211098(1).compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.JD211098(1).compiler_opt.fopts.mex800 = '';
dkepath.JD211098(1).compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex800 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.JD211098(1).graphviz.env = '/home/YP105119/bin/';% Graphviz environment variable
dkepath.JD211098(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.JD211098(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.JD211098(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.JD211098(1).remote(1).schedulername = 'pbs';
dkepath.JD211098(1).remote(1).profilename = 'local';
dkepath.JD211098(1).remote(1).luke_root = dkepath.JD211098(1).luke_root;% local cluster
%
dkepath.JD211098(1).remote(2).remoteid = 'macpro_YVES_PEYSSON';
dkepath.JD211098(1).remote(2).schedulername = 'condor';
dkepath.JD211098(1).remote(2).profilename = 'joan';
dkepath.JD211098(1).remote(2).luke_root.LUKE_1_10_0 = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
dkepath.JD211098(1).remote(2).luke_root.LUKE_default = '/Users/yvespeysson/joandecker/Work/LUKE/';
%
dkepath.JD211098(1).remote(3) = dkepath.JD211098(1).remote(2);
dkepath.JD211098(1).remote(3).schedulername = 'xgrid';
%
dkepath.JD211098(1).remote(4) = dkepath.JD211098(1).remote(2);
dkepath.JD211098(1).remote(4).schedulername = 'direct';
%
dkepath.JD211098(1).remote(5).remoteid = 'ASIPP_SHENMA';
dkepath.JD211098(1).remote(5).schedulername = 'torque';
dkepath.JD211098(1).remote(5).profilename = 'joan';
dkepath.JD211098(1).remote(5).luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
%------------------------------------ Profile number 1, YP105119 Peysson ------------------------------------
%
dkepath.YP105119(1).luke_root = [pwd,filesep];
dkepath.YP105119(1).local_root = '/home/JD211098/Packages/andromede/';
dkepath.YP105119(1).temppathroot = '/data/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.YP105119(1).mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
%
dkepath.YP105119(1).compiler_opt = dkepath.JD211098(1).compiler_opt;
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).MUMPS.mex710 = [dkepath.YP105119(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).MUMPS.mex800 = [dkepath.YP105119(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).graphviz.env = '/home/YP105119/bin/';% Graphviz environment variable
dkepath.YP105119(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.YP105119(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
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
dkepath.YP105119(1).remote(2).remoteid = 'macpro_YVES_PEYSSON';
dkepath.YP105119(1).remote(2).schedulername = 'condor';
dkepath.YP105119(1).remote(2).profilename = 'yves';
dkepath.YP105119(1).remote(2).luke_root = '/Users/yvespeysson/Projets/LUKE/';
dkepath.YP105119(1).remote(2).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(2).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(2).luke_root];%CVS command
%
dkepath.YP105119(1).remote(3) = dkepath.YP105119(1).remote(2);
dkepath.YP105119(1).remote(3).schedulername = 'xgrid';
%
dkepath.YP105119(1).remote(4) = dkepath.YP105119(1).remote(2);
dkepath.YP105119(1).remote(4).schedulername = 'direct';
%
dkepath.YP105119(1).remote(5).remoteid = 'ASIPP_SHENMA';
dkepath.YP105119(1).remote(5).schedulername = 'torque';
dkepath.YP105119(1).remote(5).profilename = 'yves';
dkepath.YP105119(1).remote(5).luke_root = '/home/PEYSSON/LUKE/';
dkepath.YP105119(1).remote(5).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(5).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(5).luke_root];%CVS command
%
%------------------------------------ Profile number 1, EN232106 Nilsson ------------------------------------
%
dkepath.EN232106(1).luke_root = [pwd,filesep];
dkepath.EN232106(1).local_root = '/home/JD211098/Packages/andromede/';
dkepath.EN232106(1).temppathroot = '/data/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.EN232106(1).mex710 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.EN232106(1).mex800 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
%
dkepath.EN232106(1).compiler_opt = dkepath.JD211098(1).compiler_opt;
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.EN232106(1).MUMPS.mex710 = [dkepath.EN232106(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.EN232106(1).MUMPS.mex800 = [dkepath.EN232106(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.EN232106(1).graphviz.env = '/home/YP105119/bin/';% Graphviz environment variable
dkepath.EN232106(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.EN232106(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.EN232106(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.EN232106(1).remote(1).schedulername = 'pbs';
dkepath.EN232106(1).remote(1).profilename = 'EN232106';
dkepath.EN232106(1).remote(1).luke_root = dkepath.EN232106(1).luke_root;% local cluster
%
dkepath.EN232106(1).remote(2).remoteid = 'macpro_YVES_PEYSSON';
dkepath.EN232106(1).remote(2).schedulername = 'condor';
dkepath.EN232106(1).remote(2).profilename = 'emelie';
dkepath.EN232106(1).remote(2).luke_root = '/Users/yvespeysson/emelienilsson/LUKE/';
%
dkepath.EN232106(1).remote(3) = dkepath.EN232106(1).remote(2);
dkepath.EN232106(1).remote(3).schedulername = 'xgrid';
%
dkepath.EN232106(1).remote(4) = dkepath.EN232106(1).remote(2);
dkepath.EN232106(1).remote(4).schedulername = 'direct';
%


