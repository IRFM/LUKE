function [crpppc70] = path_CRPP_PC70(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) PC70 computer
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
crpppc70.hostname = 'lac2';
crpppc70.machine = 'crpppc70';
crpppc70.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
crpppc70.path_profile = 1;
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
crpppc70.joan(1).luke_root = [pwd,'/'];
crpppc70.joan(1).local_root = '/home/decker/NoTivoli/';
crpppc70.joan(1).temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
crpppc70.joan(1).mex706 = [crpppc70.joan(1).luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB76'];
crpppc70.joan(1).mex708 = [crpppc70.joan(1).luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB78'];
crpppc70.joan(1).mex709 = [crpppc70.joan(1).luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB79'];
crpppc70.joan(1).mex710 = [crpppc70.joan(1).luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB710'];
crpppc70.joan(1).compiler_opt.helmex.mex706 = 'FLIBS=''-Wl,-rpath-link,/usr/local/matlab76/bin/glnxa64 -L/usr/local/matlab76/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
%crpppc70.joan(1).compiler_opt.helmex.mex708 = 'FLIBS=''-Wl,-rpath-link,/usr/local/matlab78/bin/glnxa64 -L/usr/local/matlab78/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
crpppc70.joan(1).compiler_opt.helmex.mex708 = NaN;
crpppc70.joan(1).compiler_opt.helmex.mex709 = 'FLIBS=''-Wl,-rpath-link,/usr/local/matlab79/bin/glnxa64 -L/usr/local/matlab79/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
crpppc70.joan(1).compiler_opt.helmex.mex710 = crpppc70.joan(1).compiler_opt.helmex.mex709;
crpppc70.joan(1).compiler_opt.fopts = 'FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
%
crpppc70.joan(1).MUMPS.mex706 = [crpppc70.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.6'];%Where MUMPS matrix solver is stored (MEX function)
%crpppc70.joan(1).MUMPS.mex708 = [crpppc70.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.8'];%Where MUMPS matrix solver is stored (MEX function)
crpppc70.joan(1).MUMPS.mex709 = [crpppc70.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.9'];%Where MUMPS matrix solver is stored (MEX function)
crpppc70.joan(1).MUMPS.mex710 = [crpppc70.joan(1).local_root,'Packages/MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
%
crpppc70.joan(1).remote(1).host = 'pleiades2.epfl.ch';
crpppc70.joan(1).remote(1).nproc = 48;
crpppc70.joan(1).remote(1).luke_root = ['/home/jdecker/LUKE/'];
crpppc70.joan(1).remote(1).matlabroot = '';
crpppc70.joan(1).remote(1).cmd = 'qsub -l walltime=3:59:00 -l nodes=1:ppn=1';
crpppc70.joan(1).remote(1).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
crpppc70.joan(1).remote(1).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
crpppc70.joan(1).remote(1).decker = 'jdecker';
crpppc70.joan(1).remote(1).curchod = 'lcurchod';

