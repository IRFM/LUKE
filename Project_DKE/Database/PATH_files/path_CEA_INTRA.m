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
dkepath.machine = {'sirrah','naos','pleione','spica'};
dkepath.hostname = {'sirrah','naos','pleione','spica'};
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
remote.pbs.YP105119.matver.mat802 = '/usr/local/matlab/R2013b/bin/matlab';
remote.pbs.YP105119.matver.mat903 = '/usr/local/matlab/R2017b/bin/matlab';
remote.pbs.YP105119.matver.mat905 = '/usr/local/matlab/R2018b/bin/matlab';
remote.pbs.YP105119.matver.mat907 = '/usr/local/matlab/R2019b/bin/matlab';
remote.pbs.YP105119.matver.mat909 = '/usr/local/matlab/R2020b/bin/matlab';

%
dkepath.YP105119(1).sirrah.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/sirrah/MATLAB802/'];
dkepath.YP105119(1).sirrah.mex903 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/sirrah/MATLAB903/'];%R2017B
dkepath.YP105119(1).sirrah.mex905 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/sirrah/MATLAB905/'];%R2018B
dkepath.YP105119(1).sirrah.mex907 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/sirrah/MATLAB907/'];%R2019B
dkepath.YP105119(1).sirrah.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/sirrah/MATLAB909/'];%R2020B
%
dkepath.YP105119(1).sirrah.compiler_opt.copts = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex903 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex903 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex903 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex905 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex905 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex905 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex907 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex907 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex907 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).sirrah.graphviz.env = '';% Graphviz environment variable (dot)
dkepath.YP105119(1).sirrah.latex.env = '/usr/bin/latex';% Latex environment variable (latex)
dkepath.YP105119(1).sirrah.imagemagick.env = '';% ImageMagick environment variable (convert)
%
dkepath.YP105119(1).sirrah.MUMPS.mex802 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB802'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex903 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB903'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex905 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB905'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex907 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB907'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex909 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB909'];%MUMPS_5.0.2
%
% ----------------------- naos and pleione ---------------------------
%
dkepath.YP105119(1).naos = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).pleione = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).spica = dkepath.YP105119(1).sirrah;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.YP105119(1).remote(1).remoteid = 'CEA_SIRRAH';
dkepath.YP105119(1).remote(1).schedulername = 'pbs';
dkepath.YP105119(1).remote(1).profilename = 'YP105119';
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;% local cluster
dkepath.YP105119(1).remote(1).link_mode = '';
dkepath.YP105119(1).remote(1).cvsupdate = false;% update done in 'direct' mode
dkepath.YP105119(1).remote(1).gitupdate = false;% update done in 'direct' mode
dkepath.YP105119(1).remote(1).gitmode.cmd = 'cd /Home/YP105119/luke/*;git pull;echo "* update done";';
%
dkepath.YP105119(1).remote(2) = dkepath.YP105119(1).remote(1);
dkepath.YP105119(1).remote(2).schedulername = 'direct';
dkepath.YP105119(1).remote(2).gitupdate = true;
%
%
%------------------------------------ Other LUKE users ------------------------------
%
dkepath.JA132999(1) = dkepath.YP105119(1);% Jean-François Artaud
dkepath.JA132999(1).remote(1).profilename = 'JA132999';
dkepath.JA132999(1).remote(2).profilename = 'JA132999';
%
dkepath.CB165101(1) = dkepath.YP105119(1);%Clarisse Bourdelle
dkepath.CB165101(1).remote(1).profilename = 'CB165101';
dkepath.CB165101(1).remote(2).profilename = 'CB165101';
%
dkepath.MG100063(1) = dkepath.YP105119(1);%Marc Goniche
dkepath.MG100063(1).remote(1).profilename = 'MG100063';
dkepath.MG100063(1).remote(2).profilename = 'MG100063';
%
dkepath.VO259454(1) = dkepath.YP105119(1);%Valeria Ostuni
dkepath.VO259454(1).remote(1).profilename = 'VO259454';
dkepath.VO259454(1).remote(2).profilename = 'VO259454';
%
dkepath.JM240179(1) = dkepath.YP105119(1);%Jorge Morales
dkepath.JM240179(1).remote(1).profilename = 'JM240179';
dkepath.JM240179(1).remote(2).profilename = 'JM240179';
%
