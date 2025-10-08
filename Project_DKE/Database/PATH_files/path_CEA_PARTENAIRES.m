function dkepath = path_CEA_PARTENAIRES
%
% path definitions for the altair, persee, cephee and rana computers (CEA Partenaires Zone)
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine =  {'altair','persee','cephee15','cephee16','ursaminor','marfik'};
dkepath.hostname = {'altair','persee','cephee15','cephee16','ursaminor','marfik'};% should match the output of hostname_jd on the machine
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
dkepath.YP105119(1).luke_project = luke_root(sep(end-1)+1:sep(end)-1);
dkepath.YP105119(1).luke_gitbranch = '';%default local luke git branch. Empty no specific git branch is enforced.
%
dkepath.YP105119(1).temppathroot = '/data/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- persee -------------------------------
%
dkepath.YP105119(1).persee.local_root = '/home/YP105119/Packages/';
%
dkepath.YP105119(1).persee.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB802/'];
dkepath.YP105119(1).persee.mex806 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB806/'];
dkepath.YP105119(1).persee.mex907 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB907/'];
dkepath.YP105119(1).persee.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB909/'];
dkepath.YP105119(1).persee.mex913 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB913/'];
%
dkepath.YP105119(1).persee.compiler_opt.copts = '';
dkepath.YP105119(1).persee.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).persee.compiler_opt.copts.cpp.mex806 = '';
dkepath.YP105119(1).persee.compiler_opt.copts.cpp.mex907 = '';
dkepath.YP105119(1).persee.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).persee.compiler_opt.copts.cpp.mex913 = '';
%
dkepath.YP105119(1).persee.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).persee.compiler_opt.fopts.mex806 = '';
dkepath.YP105119(1).persee.compiler_opt.fopts.mex907 = '';
dkepath.YP105119(1).persee.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).persee.compiler_opt.fopts.mex913 = '';
%
dkepath.YP105119(1).persee.MUMPS.mex802 = [dkepath.YP105119(1).persee.local_root,'Bin/MUMPS/MUMPS_5.8.0_S_gfortran/MATLAB802'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).persee.MUMPS.mex806 = [dkepath.YP105119(1).persee.local_root,'Bin/MUMPS/MUMPS_5.8.0_S_gfortran/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).persee.MUMPS.mex907 = [dkepath.YP105119(1).persee.local_root,'Bin/MUMPS/MUMPS_5.8.0_S_gfortran/MATLAB907'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).persee.MUMPS.mex909 = [dkepath.YP105119(1).persee.local_root,'Bin/MUMPS/MUMPS_5.8.0_S_gfortran/MATLAB909'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).persee.MUMPS.mex913 = [dkepath.YP105119(1).persee.local_root,'Bin/MUMPS/MUMPS_5.8.0_S_gfortran/MATLAB913'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).persee.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).persee.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).persee.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- other machine of zone partenaires -------------------------------
%
dkepath.YP105119(1).altair = dkepath.YP105119(1).persee;
dkepath.YP105119(1).cephee15 = dkepath.YP105119(1).persee;
dkepath.YP105119(1).cephee16 = dkepath.YP105119(1).persee;
dkepath.YP105119(1).ursaminor = dkepath.YP105119(1).persee;
dkepath.YP105119(1).marfik = dkepath.YP105119(1).persee;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
ir = 1;
dkepath.YP105119(1).remote(ir).remoteid = 'CEA_ALTAIR';
dkepath.YP105119(1).remote(ir).schedulername = 'slurm';
dkepath.YP105119(1).remote(ir).profilename = 'YP105119';
dkepath.YP105119(1).remote(ir).luke_root = ['/home/YP105119/luke/',dkepath.YP105119(1).luke_project,'/'];
dkepath.YP105119(1).remote(ir).link_mode = '';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir) = dkepath.YP105119(1).remote(ir-1);
dkepath.YP105119(1).remote(ir).schedulername = 'direct';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir).remoteid = 'CEA_PERSEE';
dkepath.YP105119(1).remote(ir).schedulername = 'slurm';
dkepath.YP105119(1).remote(ir).profilename = 'YP105119';
dkepath.YP105119(1).remote(ir).luke_root = ['/home/YP105119/luke/',dkepath.YP105119(1).luke_project,'/'];
dkepath.YP105119(1).remote(ir).link_mode = '';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir) = dkepath.YP105119(1).remote(ir-1);
dkepath.YP105119(1).remote(ir).schedulername = 'direct';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir).remoteid = 'CEA_CEPHEE15';
dkepath.YP105119(1).remote(ir).schedulername = 'slurm';
dkepath.YP105119(1).remote(ir).profilename = 'YP105119';
dkepath.YP105119(1).remote(ir).luke_root = ['/home/YP105119/luke/',dkepath.YP105119(1).luke_project,'/'];
dkepath.YP105119(1).remote(ir).link_mode = '';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir) = dkepath.YP105119(1).remote(ir-1);
dkepath.YP105119(1).remote(ir).schedulername = 'direct';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir).remoteid = 'CEA_CEPHEE16';
dkepath.YP105119(1).remote(ir).schedulername = 'slurm';
dkepath.YP105119(1).remote(ir).profilename = 'YP105119';
dkepath.YP105119(1).remote(ir).luke_root = ['/home/YP105119/luke/',dkepath.YP105119(1).luke_project,'/'];
dkepath.YP105119(1).remote(ir).link_mode = '';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir) = dkepath.YP105119(1).remote(ir-1);
dkepath.YP105119(1).remote(ir).schedulername = 'direct';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir).remoteid = 'CEA_URSAMINOR';
dkepath.YP105119(1).remote(ir).schedulername = 'slurm';
dkepath.YP105119(1).remote(ir).profilename = 'YP105119';
dkepath.YP105119(1).remote(ir).luke_root = ['/home/YP105119/luke/',dkepath.YP105119(1).luke_project,'/'];
dkepath.YP105119(1).remote(ir).link_mode = '';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir) = dkepath.YP105119(1).remote(ir-1);
dkepath.YP105119(1).remote(ir).schedulername = 'direct';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir).remoteid = 'CEA_MARFIK';
dkepath.YP105119(1).remote(ir).schedulername = 'slurm';
dkepath.YP105119(1).remote(ir).profilename = 'YP105119';
dkepath.YP105119(1).remote(ir).luke_root = ['/home/YP105119/luke/',dkepath.YP105119(1).luke_project,'/'];
dkepath.YP105119(1).remote(ir).link_mode = '';
%
ir = ir + 1;
dkepath.YP105119(1).remote(ir) = dkepath.YP105119(1).remote(ir-1);
dkepath.YP105119(1).remote(ir).schedulername = 'direct';%
