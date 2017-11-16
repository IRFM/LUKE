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
dkepath.machine = {'sirrah','naos','pleione'};
dkepath.hostname = {'sirrah','naos','pleione'};
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
dkepath.YP105119(1).luke_root = '/Home/YP105119/luke/LUKE/';
dkepath.YP105119(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- sirrah -------------------------------
%
dkepath.YP105119(1).sirrah.local_root = '/Home/YP105119/Packages/Bin/';
%
dkepath.YP105119(1).sirrah.mex805 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/sirrah/MATLAB805/'];
dkepath.YP105119(1).sirrah.mex902 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/sirrah/MATLAB902/'];
%
dkepath.YP105119(1).sirrah.compiler_opt.copts = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex805 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex805 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex805 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex902 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex902 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex902 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).sirrah.graphviz.env = '';% Graphviz environment variable (dot)
dkepath.YP105119(1).sirrah.latex.env = '/usr/bin/latex';% Latex environment variable (latex)
dkepath.YP105119(1).sirrah.imagemagick.env = '';% ImageMagick environment variable (convert)
%
dkepath.YP105119(1).sirrah.MUMPS.mex805 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB805'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex902 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB902'];%MUMPS_5.0.2
%
% ----------------------- naos and pleione ---------------------------
%
dkepath.YP105119(1).naos = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).pleione = dkepath.YP105119(1).sirrah;
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
