function [dkepath] = path_CEA_SATURNE(luke_ref)
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
dkepath.hostname = 'saturne';
dkepath.machine = 'saturne';
dkepath.computer = computer;%machine type and supported OS
%
% Selected default user profile 
%
dkepath.path_profile.YP105119 = 1;
dkepath.path_profile.JD211098 = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.JD211098(1).luke_root = ['/home/JD211098',filesep,luke_ref,'/'];
dkepath.JD211098(1).local_root = ['/home/JD211098',filesep];%official saturne package repository for collaborators
dkepath.JD211098(1).temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex705 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
dkepath.JD211098(1).compiler_opt.copts = '';
dkepath.JD211098(1).compiler_opt.fopts.mex705 = ' -largeArrayDims';
dkepath.JD211098(1).compiler_opt.helmex.mex705 = [' -L',dkepath.JD211098(1).local_root,'lib -lf95 -lgcc -llapack -lblas'];% -ltmglib Optional argument for helmex compilation
%
dkepath.JD211098(1).MUMPS.mex705 = [dkepath.JD211098(1).local_root,'src/MUMPS_4.7.3/MATLAB_7.5'];%Where MUMPS matrix solver is stored (MEX function)
%
% local
%
dkepath.JD211098(1).remote(1) = remote_CEA_SATURNE('sun','joan','JD211098');
dkepath.JD211098(1).remote(1).host = '';% empty for local host
dkepath.JD211098(1).remote(1).luke_root = dkepath.JD211098(1).luke_root;
%
% macpro
%
dkepath.JD211098(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan','JD211098');
dkepath.JD211098(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan','JD211098');
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
dkepath.YP105119(1).luke_root = ['/home/YP105119',filesep,luke_ref,'/'];
dkepath.YP105119(1).local_root = ['/home/YP105119',filesep];%official saturne package repository for collaborators
dkepath.YP105119(1).temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).mex705 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
dkepath.YP105119(1).compiler_opt.copts = '';
dkepath.YP105119(1).compiler_opt.fopts.mex705 = ' -largeArrayDims';
dkepath.YP105119(1).compiler_opt.helmex.mex705 = [' -L',dkepath.JD211098(1).local_root,'lib -lf95 -lgcc -llapack -lblas'];% -ltmglib Optional argument for helmex compilation
%
dkepath.YP105119(1).MUMPS.mex705 = dkepath.JD211098(1).MUMPS.mex705;%Where MUMPS matrix solver is stored (MEX function)
%
% local
%
dkepath.YP105119(1).remote(1) = remote_CEA_SATURNE('sun','yves','YP105119');
dkepath.YP105119(1).remote(1).host = '';
%
% macpro
%
dkepath.YP105119(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','yves','YP105119');
dkepath.YP105119(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','yves','YP105119');%

