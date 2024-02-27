function dkepath = path_CEA_INTRA
%
% path definitions for CEA cluster in INTRA zone
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'sirrah','talitha','gemma','naos','spica','pollux'};%'pleione' 'nashira'
dkepath.hostname = {'sirrah','talitha','gemma','naos','spica','pollux'};%'pleione' 'nashira'
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'YP105119'; 
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.YP105119(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.YP105119(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.YP105119(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- sirrah -------------------------------
%
dkepath.YP105119(1).sirrah.local_root = '/Home/YP105119/Packages/Bin/';
%
dkepath.YP105119(1).sirrah.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB802/'];
dkepath.YP105119(1).sirrah.mex806 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB806/'];
dkepath.YP105119(1).sirrah.mex903 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB903/'];
dkepath.YP105119(1).sirrah.mex907 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB907/'];
dkepath.YP105119(1).sirrah.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB909/'];
dkepath.YP105119(1).sirrah.mex911 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB911/'];
dkepath.YP105119(1).sirrah.mex913 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB913/'];
%
dkepath.YP105119(1).sirrah.compiler_opt.copts = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex806 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex903 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex907 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex911 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex913 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex806 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex903 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex907 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex911 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex913 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex806 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex903 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex907 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex911 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex913 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).sirrah.MUMPS.mex802 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB802'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex806 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB806'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex903 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB903'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex907 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB907'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex909 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB909'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex911 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB911'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex913 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB913'];%MUMPS_5.0.2
%
% LUKE documentation
%
dkepath.YP105119(1).sirrah.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).sirrah.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).sirrah.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- other machine of zone intra -------------------------------
%
dkepath.YP105119(1).gemma = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).naos = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).spica = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).talitha = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).pollux = dkepath.YP105119(1).sirrah;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.YP105119(1).remote(1).remoteid = 'CEA_SIRRAH';
dkepath.YP105119(1).remote(1).schedulername = 'pbs';
dkepath.YP105119(1).remote(1).profilename = 'YP105119';
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(2).remoteid = 'CEA_TALITHA';
dkepath.YP105119(1).remote(2).schedulername = 'pbs';
dkepath.YP105119(1).remote(2).profilename = 'YP105119';
dkepath.YP105119(1).remote(2).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(3).remoteid = 'CEA_NAOS';
dkepath.YP105119(1).remote(3).schedulername = 'direct';
dkepath.YP105119(1).remote(3).profilename = 'YP105119';
dkepath.YP105119(1).remote(3).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(4).remoteid = 'CEA_GEMMA';
dkepath.YP105119(1).remote(4).schedulername = 'pbs';
dkepath.YP105119(1).remote(4).profilename = 'YP105119';
dkepath.YP105119(1).remote(4).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(5).remoteid = 'CEA_SPICA';
dkepath.YP105119(1).remote(5).schedulername = 'pbs';
dkepath.YP105119(1).remote(5).profilename = 'YP105119';
dkepath.YP105119(1).remote(5).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(6).remoteid = 'CEA_POLLUX';
dkepath.YP105119(1).remote(6).schedulername = 'pbs';
dkepath.YP105119(1).remote(6).profilename = 'YP105119';
dkepath.YP105119(1).remote(6).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
%------------------------------------ Other LUKE users ------------------------------
%
dkepath = add_path_cea_users(dkepath,'INTRA');
%