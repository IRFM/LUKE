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
dkepath.luke_root = [pwd,filesep];
dkepath.local_root = [pwd,filesep];
dkepath.temppathroot = [pwd,filesep];
%
dkepath.(['mex',matver]) = [dkepath.luke_root,'Project_DKE/MEX/Bin/default/MATLAB',matver]; 
%
dkepath.compiler_opt.helmex = NaN;  
dkepath.compiler_opt.fopts = '';
dkepath.compiler_opt.copts = '';
%
dkepath.remote = [];
%
