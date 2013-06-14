function [crpp_amerle] = path_laptop_JOAN_DECKER(luke_ref)
%
% path definitions for Antoine Merle's desktop at EPFL
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
crpp_amerle.hostname = 'crpppc371-linux';%WARNING: for laptop, may change with connection status.
crpp_amerle.machine = 'crpp_amerle';
crpp_amerle.computer = 'GLNXA64';%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
crpp_amerle.path_profile = 1;
%
%------------------------------------ Profile number 1, Antoine Merle ------------------------------------
%
crpp_amerle.amerle(1).luke_root = [pwd,'/'];
crpp_amerle.amerle(1).local_root = '/home/amerle/LUKE/';
crpp_amerle.amerle(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
crpp_amerle.amerle(1).mex800 = [crpp_amerle.amerle(1).luke_root,'Project_DKE/MEX/Bin/crpp_amerle/MATLAB800'];
%crpp_amerle.amerle(1).compiler_opt.helmex = '-lblas -llapack';% Optional argument for helmex compilation 
crpp_amerle.amerle(1).compiler_opt.helmex = '-L/home/amerle/libraries/lib -llapack_g95 -lblas_g95';%'';%'-L/home/amerle/libraries/lib -llapack_ifort -lblas_ifort';% Optional argument for helmex compilation 
crpp_amerle.amerle(1).compiler_opt.fopts = '-v FC="ifort"';%'-v FC="g95" ';%
crpp_amerle.amerle(1).compiler_opt.copts = '';
%
%crpp_amerle.amerle(1).MUMPS.mex75 = [crpp_amerle.amerle(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
%crpp_amerle.amerle(1).MUMPS.mex77 = [crpp_amerle.amerle(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
%
