function dkepath = path_SPCSRV26
%
% path definitions for spcsrv26 server
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'spcsrv26';
dkepath.hostname = 'spcsrv26.epfl.ch';%WARNING: for laptop, may change with connection status.
dkepath.computer = computer;%machine type and supported OS
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
%
sep = strfind(luke_root,'/');
luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.decker(1).luke_root = luke_root;
dkepath.decker(1).luke_branch = luke_branch;
dkepath.decker(1).local_root = '/opt/';
dkepath.decker(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.decker(1).mex910 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/spcsrv26/MATLAB910']; 
%
dkepath.decker(1).compiler_opt.helmex = ['-L',dkepath.decker(1).local_root,'lapack-3.9.1 -lrefblas'];%NaN;
dkepath.decker(1).compiler_opt.fopts = '';
dkepath.decker(1).compiler_opt.copts = '';
%
dkepath.decker(1).MUMPS.mex910 = [dkepath.decker(1).local_root,'MUMPS_5.4.0/MATLAB910'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
%
remote(1).remoteid = 'SPCSRV26';
remote(1).schedulername = 'direct';
remote(1).profilename = 'decker';
remote(1).luke_root = dkepath.decker(1).luke_root;% local cluster
remote(1).link_mode = [];
%
% -------------- profiles selection, Yves Peysson ------------
%
remote_selection = [1];
dkepath.decker(1).remote = remote(remote_selection);
%
%------------------------------------ Profile number 2, Yves Peysson ------------------------------------
%
dkepath.peysson(1).luke_root = luke_root;
dkepath.peysson(1).luke_branch = luke_branch;
dkepath.peysson(1).local_root = '/opt/';
dkepath.peysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.peysson(1).mex910 = [dkepath.peysson(1).luke_root,'Project_DKE/MEX/Bin/spcsrv26/MATLAB910']; 
%
dkepath.peysson(1).compiler_opt.helmex = ['-L',dkepath.decker(1).local_root,'lapack-3.9.1 -lrefblas'];%NaN;
dkepath.peysson(1).compiler_opt.fopts = '';
dkepath.peysson(1).compiler_opt.copts = '';
%
dkepath.peysson(1).MUMPS.mex910 = [dkepath.decker(1).local_root,'MUMPS_5.4.0/MATLAB910'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
%
remote(1).remoteid = 'SPCSRV26';
remote(1).schedulername = 'direct';
remote(1).profilename = 'peysson';
remote(1).luke_root = dkepath.peysson(1).luke_root;% local cluster
remote(1).link_mode = [];
%




