function [dkepath] = path_CEA_ALTAIR(luke_ref)
%
% path definitions for CEA SATURNE cluster
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,m]
%         (default: 'LUKE')
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin == 0, 
    luke_ref = 'LUKE';
end
%
dkepath.hostname = 'altair';
dkepath.machine = 'altair';
dkepath.computer = computer;%machine type and supported OS
%
% Selected default user profile 
%
dkepath.path_profile.JD211098 = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.JD211098(1).luke_root = ['/home/JD211098',filesep,luke_ref,'/'];
dkepath.JD211098(1).local_root = '/home/JD211098/altair/';%official saturne package repository for collaborators
dkepath.JD211098(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex707 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/altair/MATLAB77/'];
dkepath.JD211098(1).compiler_opt.copts = '';
dkepath.JD211098(1).compiler_opt.fopts.mex707 = ' -largeArrayDims FC="gfortran"';
dkepath.JD211098(1).compiler_opt.helmex = NaN;% -ltmglib Optional argument for helmex compilation
%
dkepath.JD211098(1).MUMPS.mex707 = [dkepath.JD211098(1).local_root,'src/MUMPS_4.7.3/MATLAB_7.7'];%Where MUMPS matrix solver is stored (MEX function)
%
% local
%
dkepath.JD211098(1).remote(1) = remote_CEA_SATURNE('sun','joan','JD211098');
dkepath.JD211098(1).remote(1).luke_root = dkepath.JD211098(1).luke_root;
%
% macpro
%
dkepath.JD211098(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan','JD211098');
dkepath.JD211098(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan','JD211098');
%