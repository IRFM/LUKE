function [pcluke] = path_CEA_PC_LUKE(luke_ref)
%
% path definitions for CEA PC LUKE computer
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
if nargin == 0, luke_ref = 'LUKE';end
%
[~,matlabversion,matlabrelease] = LUKEversion_jd;
%
[~,hostname] = unix('hostname');hostname = hostname(1:end-1);%remove extra term
%
pcluke.hostname = 'PC-Luke';
pcluke.machine = 'pcluke';
pcluke.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
pcluke.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
pcluke.lukeuser(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];;
pcluke.lukeuser(1).local_root = '/home/lukeuser/Work/';
pcluke.lukeuser(1).temppathroot = '/home/lukeuser/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
pcluke.lukeuser(1).mex702 = [pcluke.lukeuser(1).luke_root,'Project_DKE/MEX/Bin/pcluke/MATLAB72/'];
pcluke.lukeuser(1).compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
pcluke.lukeuser(1).MUMPS.mex702 = [pcluke.lukeuser(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB72/'];%Where MUMPS matrix solver is stored (MEX function)
