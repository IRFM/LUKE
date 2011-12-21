function [laptoppramod] = path_laptop_PRAMOD_SHARMA(luke_ref)
%
% path definitions for laptop of Pramod Sharma
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
laptoppramod.hostname = 'promod';
laptoppramod.machine = 'laptoppramod';
laptoppramod.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
laptoppramod.path_profile = 1;
%
%------------------------------------ Profile number 1, Pramod Sharma ------------------------------------
%
laptoppramod.promod(1).luke_root = [getenv('HOME'),'/LUKE/'];
laptoppramod.promod(1).local_root = [getenv('HOME'),'/'];
laptoppramod.promod(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
laptoppramod.promod(1).mex705 = [laptoppramod.promod(1).luke_root,'Project_DKE/MEX/Bin/laptoppramod/MATLAB75/'];
laptoppramod.promod(1).compiler_opt.helmex = '-v FC=''ifort'' FLIBS=''-Wl,-rpath-link,/home/promod/matlab75/bin/glnx86 -L/home/promod/matlab75/bin/glnx86 -lmx -lmex -lmat -lm -Wl,-rpath,/opt/intel/mkl/10.0.1.014/lib/32 -L/opt/intel/mkl/10.0.1.014/lib/32 -lmkl_lapack -lmkl -lguide -lpthread''';%
%
laptoppramod.promod(1).MUMPS.mex705 = [laptoppramod.promod(1).local_root,'Projet_Cronos/libs/MUMPS_4.7.3/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
