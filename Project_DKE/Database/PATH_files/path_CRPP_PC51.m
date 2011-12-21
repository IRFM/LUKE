function [crpppc51] = path_CRPP_PC51(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) PC51 computer
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
crpppc51.hostname = 'lac3';
crpppc51.machine = 'crpppc51';
crpppc51.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
crpppc51.path_profile = 1;
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
crpppc51.joan(1).luke_root = [pwd,'/'];
crpppc51.joan(1).local_root = '/home/decker/NoTivoli/';
crpppc51.joan(1).temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
crpppc51.joan(1).mex76 = [crpppc51.joan(1).luke_root,'Project_DKE/MEX/Bin/crpppc51/MATLAB76'];
crpppc51.joan(1).compiler_opt.helmex = '-v -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas LDFLAGS="-fPIC -shared" -largeArrayDims';%  -ltmglib Optional argument for helmex compilation
%
crpppc51.joan(1).MUMPS.mex76 = [crpppc51.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.6'];%Where MUMPS matrix solver is stored (MEX function)
