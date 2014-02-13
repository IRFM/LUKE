function dkepath = path_CEA_SATURNE
%
% path definitions for CEA SATURNE cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.hostname = 'saturne';
dkepath.machine = 'saturne';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.JD211098(1).luke_root = [pwd,filesep];
dkepath.JD211098(1).local_root = ['/home/JD211098',filesep];%official saturne package repository for collaborators
dkepath.JD211098(1).temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex705 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
dkepath.JD211098(1).compiler_opt.copts = '';
dkepath.JD211098(1).compiler_opt.fopts.mex705 = ' -largeArrayDims';
dkepath.JD211098(1).compiler_opt.helmex.mex705 = [' -L',dkepath.JD211098(1).local_root,'lib -lf95 -lgcc -llapack -lblas'];% -ltmglib Optional argument for helmex compilation
%
dkepath.JD211098(1).MUMPS.mex705 = [dkepath.JD211098(1).local_root,'src/MUMPS_4.7.3/MATLAB_7.5'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.JD211098(1).graphviz.env = '';% Graphviz environment variable
dkepath.JD211098(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.JD211098(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.JD211098(1).remote(1) = remote_CEA_SATURNE('pbs','joan');
dkepath.JD211098(1).remote(1).host = '';% empty for local host
dkepath.JD211098(1).remote(1).env.luke_root = dkepath.JD211098(1).luke_root;
%
% macproyves (condor)
%
dkepath.JD211098(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan');
dkepath.JD211098(1).remote(2).env.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
%
% macproyves (xgrid)
%
dkepath.JD211098(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan');
dkepath.JD211098(1).remote(3).env.luke_root = dkepath.JD211098(1).remote(2).env.luke_root;
%
% shenma (torque)
%
dkepath.JD211098(1).remote(4) = remote_ASIPP_SHENMA('torque','joan');
dkepath.JD211098(1).remote(4).env.luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
% andromede (pbs)
%
dkepath.JD211098(1).remote(5) = remote_CEA_ANDROMEDE('pbs','joan');
dkepath.JD211098(1).remote(5).env.luke_root = dkepath.JD211098(1).remote(1).env.luke_root;% same TS as saturne
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
dkepath.YP105119(1).luke_root = [pwd,filesep];
dkepath.YP105119(1).local_root = ['/home/YP105119',filesep];%official saturne package repository for collaborators
dkepath.YP105119(1).temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).mex705 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
dkepath.YP105119(1).compiler_opt.copts = '';
dkepath.YP105119(1).compiler_opt.fopts.mex705 = ' -largeArrayDims';
dkepath.YP105119(1).compiler_opt.helmex.mex705 = [' -L',dkepath.JD211098(1).local_root,'lib -lf95 -lgcc -llapack -lblas'];% -ltmglib Optional argument for helmex compilation
%
dkepath.YP105119(1).MUMPS.mex705 = dkepath.JD211098(1).MUMPS.mex705;%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).graphviz.env = '';% Graphviz environment variable
dkepath.YP105119(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.YP105119(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.YP105119(1).remote(1) = remote_CEA_SATURNE('pbs','yves');
dkepath.YP105119(1).remote(1).host = '';% empty for local host
dkepath.YP105119(1).remote(1).env.luke_root = dkepath.YP105119(1).luke_root;
%
% macproyves (condor)
%
dkepath.YP105119(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','yves');
dkepath.YP105119(1).remote(2).env.luke_root = '/Users/yvespeysson/Projets/LUKE/';
dkepath.YP105119(1).remote(2).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(2).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(2).env.luke_root];%CVS command
%
% macproyves (xgrid)
%
dkepath.YP105119(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','yves');
dkepath.YP105119(1).remote(3).env.luke_root = dkepath.YP105119(1).remote(2).env.luke_root;
dkepath.YP105119(1).remote(3).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(3).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(3).env.luke_root];%CVS command
%
% shenma (torque)
%
dkepath.YP105119(1).remote(4) = remote_ASIPP_SHENMA('torque','yves');
dkepath.YP105119(1).remote(4).env.luke_root = '/home/PEYSSON/LUKE/';
dkepath.YP105119(1).remote(4).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(4).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(4).env.luke_root];%CVS command
