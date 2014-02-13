function dkepath = default_path_profile
%
% default path definitions for laptop of Joan Decker 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
[~,matver] = LUKEversion_jd;
%
[~,dkepath.hostname] = system('hostname -f');
dkepath.machine = 'default';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'default';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.default(1).luke_root = [pwd,filesep];
dkepath.default(1).local_root = [pwd,filesep];
dkepath.default(1).temppathroot = [pwd,filesep];
%
dkepath.default(1).(['mex',matver]) = [dkepath.default(1).luke_root,'Project_DKE/MEX/Bin/default/MATLAB',matver]; 
%
dkepath.default(1).compiler_opt.helmex = NaN;  
dkepath.default(1).compiler_opt.fopts = '';
dkepath.default(1).compiler_opt.copts = '';
%
dkepath.default(1).remote = [];
%
