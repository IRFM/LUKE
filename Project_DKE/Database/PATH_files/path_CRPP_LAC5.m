function [lac5] = path_CRPP_LAC5(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) lac5 computer
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
LUKEversion_jd;
%
lac5.hostname = 'lac5.epfl.ch';
lac5.machine = 'lac5';
lac5.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
lac5.path_profile.decker = 1;
%
% Selected user profile for unlisted users
%
lac5.default = 'decker';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
lac5.decker(1).luke_root = ['/home/decker/',luke_ref,'/'];
lac5.decker(1).local_root = '/home/decker/NoTivoli/Packages/lac5/';
lac5.decker(1).temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
lac5.decker(1).mex710 = [lac5.decker(1).luke_root,'Project_DKE/MEX/Bin/lac5/MATLAB710'];
lac5.decker(1).mex800 = [lac5.decker(1).luke_root,'Project_DKE/MEX/Bin/lac5/MATLAB800'];
lac5.decker(1).compiler_opt.helmex.mex710 = NaN;%'FLIBS=''-Wl,-rpath-link,/usr/local/matlab710/bin/glnxa64 -L/usr/local/matlab710/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
lac5.decker(1).compiler_opt.helmex.mex800 = NaN;%'FLIBS=''-Wl,-rpath-link,/usr/local/matlab710/bin/glnxa64 -L/usr/local/matlab710/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
lac5.decker(1).compiler_opt.fopts.mex710 = '-v FC=gfortran';%'FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
lac5.decker(1).compiler_opt.fopts.mex800 = '-v';%'FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
%
lac5.decker(1).MUMPS.mex710 = [lac5.decker(1).local_root,'MUMPS_4.10.0_ifort/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
lac5.decker(1).MUMPS.mex800 = [lac5.decker(1).local_root,'MUMPS_4.10.0_ifort/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
lac5.decker(1).graphviz.env = '';% Graphviz environment variable
lac5.decker(1).latex.env = '';% Latex environment variable
lac5.decker(1).imagemagick.env = '';% ImageMagick environment variable
%
% pleiades2 (pbs)
%
lac5.decker(1).remote(1).host = 'pleiades2.epfl.ch';
lac5.decker(1).remote(1).hostname = 'pleiades2';% case where hostname must be specified as variable
lac5.decker(1).remote(1).nproc = 48;
lac5.decker(1).remote(1).memory = NaN;%no memory spec sent to remote host
lac5.decker(1).remote(1).ppn = 1;
lac5.decker(1).remote(1).cmd = 'qsub';% -l walltime=3:59:00 -l nodes=1:ppn=1
lac5.decker(1).remote(1).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
lac5.decker(1).remote(1).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
lac5.decker(1).remote(1).walltime = 24;%walltime necessary or one hour imposed
lac5.decker(1).remote(1).mat711.root = '/usr/local/matlab-7.11.0/bin/';
lac5.decker(1).remote(1).mat711.prefdir = '/home/jdecker/.matlab/R2010b';
lac5.decker(1).remote(1).matdef = lac5.decker(1).remote(1).mat711;%default matlab on remote machine
lac5.decker(1).remote(1).luke_root = ['/home/jdecker/',luke_ref,'/'];
lac5.decker(1).remote(1).decker = 'jdecker';
%
