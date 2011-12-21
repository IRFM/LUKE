function [ipr] = path_IPR(luke_ref)
%
% path definitions for IPR (Gandhinagar, Gujarat, India) computer
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
[dummy,matlabversion,matlabrelease] = LUKEversion_jd;
%
ipr.hostname = 'matlab2';
ipr.machine = 'matlab2';
ipr.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
ipr.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
ipr.yves(1).luke_root = [pwd,'/'];
ipr.yves(1).local_root = '/home/yves/';
ipr.yves(1).computer = 'GLNX86';%machine type and supported OS
ipr.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
ipr.yves(1).mex706 = [ipr.yves(1).luke_root,'Project_DKE/MEX/Bin/ipr/MATLAB76'];
%
ipr.yves(1).MUMPS.seq = [ipr.yves(1).local_root,'PACKAGES/Bin/MUMPS_4.7.3/dke'];
ipr.yves(1).MUMPS.mex706 = [ipr.yves(1).local_root,'PACKAGES/Bin/MUMPS_4.7.3/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
ipr.yves(1).compiler_opt.helmex = '-L/home/yves/PACKAGES/Bin/lapack-3.2/ -llapack_LINUX -L/home/yves/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
