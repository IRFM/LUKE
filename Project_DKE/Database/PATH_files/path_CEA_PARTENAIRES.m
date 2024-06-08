function dkepath = path_CEA_PARTENAIRES
%
% path definitions for the altair, andromede, persee, cephee and rana computers (CEA Partenaires Zone)
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine =  {'andromede1','andromede2','altair','persee','cephee','rana'};
dkepath.hostname = {'andromede1','andromede2','altair','persee','cephee','rana'};% should match the output of hostname_jd on the machine
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
% ---------------------------- andromede1 -------------------------------
%
dkepath.YP105119(1).andromede1.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).andromede1.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB802/'];
dkepath.YP105119(1).andromede1.mex806 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB806/'];
dkepath.YP105119(1).andromede1.mex903 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB903/'];
dkepath.YP105119(1).andromede1.mex907 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB907/'];
dkepath.YP105119(1).andromede1.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB909/'];
dkepath.YP105119(1).andromede1.mex911 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB911/'];
dkepath.YP105119(1).andromede1.mex913 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB913/'];
%
dkepath.YP105119(1).andromede1.compiler_opt.copts = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex806 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex903 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex907 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex911 = '';
dkepath.YP105119(1).andromede1.compiler_opt.copts.cpp.mex913 = '';
%
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex806 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex903 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex907 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex911 = '';
dkepath.YP105119(1).andromede1.compiler_opt.fopts.mex913 = '';
%
dkepath.YP105119(1).andromede1.MUMPS.mex802 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB802'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex806 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex903 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB903'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex907 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB907'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex909 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB909'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex911 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB911'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede1.MUMPS.mex913 = [dkepath.YP105119(1).andromede1.local_root,'MUMPS_4.10.0/MATLAB913'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).andromede1.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).andromede1.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).andromede1.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- other machine of zone partenaires -------------------------------
%
dkepath.YP105119(1).andromede2 = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).altair = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).persee = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).cephee = dkepath.YP105119(1).andromede1;
dkepath.YP105119(1).rana = dkepath.YP105119(1).andromede1;
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
dkepath.YP105119(1).remote(2).remoteid = 'CEA_ALTAIR';
dkepath.YP105119(1).remote(2).schedulername = 'pbs';
dkepath.YP105119(1).remote(2).profilename = 'YP105119';
dkepath.YP105119(1).remote(2).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(3).remoteid = 'CEA_ALTAIR';
dkepath.YP105119(1).remote(3).schedulername = 'direct';
dkepath.YP105119(1).remote(3).profilename = 'YP105119';
dkepath.YP105119(1).remote(3).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(4).remoteid = 'CEA_CEPHEE';
dkepath.YP105119(1).remote(4).schedulername = 'pbs';
dkepath.YP105119(1).remote(4).profilename = 'YP105119';
dkepath.YP105119(1).remote(4).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(5).remoteid = 'CEA_PERSEE';
dkepath.YP105119(1).remote(5).schedulername = 'pbs';
dkepath.YP105119(1).remote(5).profilename = 'YP105119';
dkepath.YP105119(1).remote(5).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(6).remoteid = 'CEA_RANA';
dkepath.YP105119(1).remote(6).schedulername = 'pbs';
dkepath.YP105119(1).remote(6).profilename = 'YP105119';
dkepath.YP105119(1).remote(6).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
%------------------------------------ Other LUKE users ------------------------------
%
dkepath = add_path_cea_users(dkepath,'PARTENAIRES');
%
