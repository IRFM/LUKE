function [lac2] = path_CRPP_LAC2(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) lac2 computer
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
lac2.hostname = 'lac2.epfl.ch';
lac2.machine = 'lac2';
lac2.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
lac2.path_profile.decker = 1;
%
% Selected user profile for unlisted users
%
lac2.default = 'decker';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
lac2.decker(1).luke_root = ['/home/decker/',luke_ref,'/'];
lac2.decker(1).local_root = '/home/decker/NoTivoli/Packages/lac2/';
lac2.decker(1).temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
lac2.decker(1).mex710 = [lac2.decker(1).luke_root,'Project_DKE/MEX/Bin/lac2/MATLAB710'];
lac2.decker(1).compiler_opt.helmex.mex710 = NaN;%'FLIBS=''-Wl,-rpath-link,/usr/local/matlab710/bin/glnxa64 -L/usr/local/matlab710/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
lac2.decker(1).compiler_opt.fopts.mex710 = '';%'FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
%
lac2.decker(1).MUMPS.mex710 = [lac2.decker(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
%
% pleiades2 (pbs)
%
lac2.decker(1).remote(1).host = 'pleiades2.epfl.ch';
lac2.decker(1).remote(1).hostname = 'pleiades2';% case where hostname must be specified as variable
lac2.decker(1).remote(1).nproc = 48;
lac2.decker(1).remote(1).memory = NaN;%no memory spec sent to remote host
lac2.decker(1).remote(1).ppn = 1;
lac2.decker(1).remote(1).cmd = 'qsub';% -l walltime=3:59:00 -l nodes=1:ppn=1
lac2.decker(1).remote(1).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
lac2.decker(1).remote(1).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
lac2.decker(1).remote(1).walltime = 24;%walltime necessary or one hour imposed
lac2.decker(1).remote(1).mat711.root = '/usr/local/matlab-7.11.0/bin/';
lac2.decker(1).remote(1).mat711.prefdir = '/home/jdecker/.matlab/R2010b';
lac2.decker(1).remote(1).matdef = lac2.decker(1).remote(1).mat711;%default matlab on remote machine
lac2.decker(1).remote(1).luke_root = ['/home/jdecker/',luke_ref,'/'];
lac2.decker(1).remote(1).decker = 'jdecker';
%
