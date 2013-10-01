function [pleiades2] = path_CRPP_PLEIADES2(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) Pleiades2 cluster 
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
pleiades2.hostname = 'pleiades2';
pleiades2.machine = 'pleiades2';
pleiades2.computer = 'GLNXA64';%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
pleiades2.path_profile = 1;
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
pleiades2.jdecker(1).luke_root = [pwd,'/'];
pleiades2.jdecker(1).local_root = '/home/jdecker/';
pleiades2.jdecker(1).temppathroot = '/scratch2/jdecker/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
pleiades2.jdecker(1).mex705 = [pleiades2.jdecker(1).luke_root,'Project_DKE/MEX/Bin/pleiades2/MATLAB75'];
pleiades2.jdecker(1).mex711 = [pleiades2.jdecker(1).luke_root,'Project_DKE/MEX/Bin/pleiades2/MATLAB711'];
%
pleiades2.jdecker(1).compiler_opt.fopts = 'FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
pleiades2.jdecker(1).compiler_opt.helmex = NaN;%' -v -L/home/jdecker/Packages/Bin/lapack-3.1.1 -lblas_LINUX_G95 -llapack_LINUX_G95 -ltmglib_LINUX_G95';%-L/usr/local/src/g95-install/lib/gcc-lib/x86_64-suse-linux-gnu/4.0.3 -lf95 -lgcc
%
pleiades2.jdecker(1).MUMPS.mex705 = [pleiades2.jdecker(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
pleiades2.jdecker(1).MUMPS.mex711 = [pleiades2.jdecker(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB711'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.jdecker(1).graphviz.env = '';% Graphviz environment variable
dkepath.jdecker(1).latex.env = '';% Latex environment variable
dkepath.jdecker(1).imagemagick.env = '';% ImageMagick environment variable
%
pleiades2.jdecker(1).remote(1).host = '';
pleiades2.jdecker(1).remote(1).nproc = 48;
pleiades2.jdecker(1).remote(1).ppn = 1;
pleiades2.jdecker(1).remote(1).cmd = 'qsub';
pleiades2.jdecker(1).remote(1).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
pleiades2.jdecker(1).remote(1).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
pleiades2.jdecker(1).remote(1).mat705.root = '/usr/local/matlab-7.5.2/bin/';
pleiades2.jdecker(1).remote(1).mat705.prefdir = '/home/jdecker/.matlab/R207b';
pleiades2.jdecker(1).remote(1).mat711.root = '/usr/local/matlab-7.11.0/bin/';
pleiades2.jdecker(1).remote(1).mat711.prefdir = '/home/jdecker/.matlab/R2010b';
pleiades2.jdecker(1).remote(1).matdef = pleiades2.jdecker(1).remote(1).mat711;%default matlab on remote machine
pleiades2.jdecker(1).remote(1).luke_root = pleiades2.jdecker(1).luke_root;

