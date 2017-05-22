function dkepath = path_laptop_JOAN_DECKER
%
% path definitions for laptop of Joan Decker 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'laptopjoan';
dkepath.hostname = 'spcpc458';%WARNING: for laptop, may change with connection status.
dkepath.computer = computer;%machine type and supported OS
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
path_root = fileparts(which(mfilename));
dkepath.joan(1).luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
%
dkepath.joan(1).local_root = '/opt/';
dkepath.joan(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.joan(1).mex900 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB900']; 
dkepath.joan(1).mex901 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB901']; 
%
dkepath.joan(1).compiler_opt.helmex = NaN;
dkepath.joan(1).compiler_opt.fopts = '';
dkepath.joan(1).compiler_opt.copts = '';
%
dkepath.joan(1).MUMPS.mex900 = [dkepath.joan(1).local_root,'MUMPS_5.0.2/MATLAB900'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex901 = [dkepath.joan(1).local_root,'MUMPS_5.0.2/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.joan(1).remote(1).remoteid = 'laptop_JOAN_DECKER';
dkepath.joan(1).remote(1).schedulername = 'direct';
dkepath.joan(1).remote(1).profilename = 'joan';
dkepath.joan(1).remote(1).luke_root = dkepath.joan(1).luke_root;% local cluster
dkepath.joan(1).remote(1).link_mode = [];
dkepath.joan(1).remote(1).cvsupdate = true;
dkepath.joan(1).remote(1).cvsrights = '';
%