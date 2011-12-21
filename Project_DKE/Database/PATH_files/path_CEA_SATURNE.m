function [saturne] = path_SATURNE(luke_ref)
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
if nargin == 0, luke_ref = 'LUKE';end
%
[dummy,matlabversion,matlabrelease] = LUKEversion_jd;
%
saturne.hostname = 'saturne';
saturne.machine = 'saturne';
saturne.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
saturne.path_profile = 1;
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
saturne.JD211098(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
saturne.JD211098(1).local_root = getenv('HOME');;%official saturne package repository for collaborators
saturne.JD211098(1).temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
saturne.JD211098(1).mex705 = [saturne.JD211098(1).luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
saturne.JD211098(1).compiler_opt.copts = '';
saturne.JD211098(1).compiler_opt.fopts.mex705 = [' -largeArrayDims'];
saturne.JD211098(1).compiler_opt.helmex.mex705 = [' -L',saturne.JD211098(1).local_root,'lib -lf95 -lgcc -llapack -lblas'];% -ltmglib Optional argument for helmex compilation
%
saturne.JD211098(1).MUMPS.mex705 = [saturne.JD211098(1).local_root,'src/MUMPS_4.7.3/MATLAB_7.5'];%Where MUMPS matrix solver is stored (MEX function)
%
saturne.JD211098(1).remote(1).host = '';% empty for local host
saturne.JD211098(1).remote(1).nproc = 12;
saturne.JD211098(1).remote(1).luke_root = saturne.JD211098(1).luke_root;
saturne.JD211098(1).remote(1).matlabroot = '';
saturne.JD211098(1).remote(1).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
saturne.JD211098(1).remote(1).get_jobid = {'Your job ',' '};%str_before,str_after
saturne.JD211098(1).remote(1).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
saturne.YP105119(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
saturne.YP105119(1).local_root = getenv('HOME');%official saturne package repository for collaborators
saturne.YP105119(1).temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
saturne.YP105119(1).mex705 = [saturne.YP105119(1).luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
saturne.YP105119(1).compiler_opt.copts = '';
saturne.YP105119(1).compiler_opt.fopts.mex705 = [' -largeArrayDims'];
saturne.YP105119(1).compiler_opt.helmex.mex705 = [' -L',saturne.YP105119(1).local_root,'lib -lf95 -lgcc -llapack -lblas'];% -ltmglib Optional argument for helmex compilation
%
saturne.YP105119(1).MUMPS.mex705 = [saturne.YP105119(1).local_root,'src/MUMPS_4.7.3/MATLAB_7.5'];%Where MUMPS matrix solver is stored (MEX function)
%
saturne.YP105119(1).remote(1).host = '';% empty for local host
saturne.YP105119(1).remote(1).nproc = 12;
saturne.YP105119(1).remote(1).luke_root = saturne.YP105119(1).luke_root;
saturne.YP105119(1).remote(1).matlabroot = '';
saturne.YP105119(1).remote(1).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
saturne.YP105119(1).remote(1).get_jobid = {'Your job ',' '};%str_before,str_after
saturne.YP105119(1).remote(1).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
%

