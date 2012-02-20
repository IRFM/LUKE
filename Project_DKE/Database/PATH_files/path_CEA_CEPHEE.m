function [cephee] = path_CEPHEE(luke_ref)
%
% path definitions for CEA CEPHEE cluster
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
cephee.hostname = 'cephee';
cephee.machine = 'cephee';
cephee.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
cephee.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
cephee.YP105119(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
cephee.YP105119(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
cephee.YP105119(1).temppathroot = '/local/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
cephee.YP105119(1).mex705 = [cephee.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
cephee.YP105119(1).mex710 = [cephee.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
%
cephee.YP105119(1).compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
cephee.YP105119(1).compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',cephee.YP105119(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
cephee.YP105119(1).compiler_opt.helmex.mex705 = ['-L',cephee.YP105119(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',cephee.YP105119(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
cephee.YP105119(1).compiler_opt.copts.mex710 = '';
cephee.YP105119(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
cephee.YP105119(1).compiler_opt.helmex.mex710 = ['-L',cephee.YP105119(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%Where MUMPS matrix solver is stored (MEX function)
cephee.YP105119(1).MUMPS.mex705 = [cephee.YP105119(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
cephee.YP105119(1).MUMPS.mex710 = [cephee.YP105119(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%cephee.YP105119(1).MUMPS.mex710 = [cephee.YP105119(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
%
%--------------------------- Distributed computing -----------------------------
%
cephee.YP105119(1).scheduler.local.configfile = '';%'/local/mdce/configurations/localconfig.mat';
cephee.YP105119(1).scheduler.local.mode = 3;%No parallel computing
cephee.YP105119(1).scheduler.local.timeout = 20;%100 s time out for job submission
cephee.YP105119(1).scheduler.local.clustersize = 8;%One core or processor
cephee.YP105119(1).scheduler.local.memory = 1600;%no memory requirements
cephee.YP105119(1).scheduler.local.temppathroot = cephee.YP105119(1).temppathroot;
cephee.YP105119(1).scheduler.local.display = 0;
%
cephee.YP105119(1).scheduler.pbsproconfig.configfile = '/local/mdce/configurations/pbsproconfig.mat';
cephee.YP105119(1).scheduler.pbsproconfig.mode = 3;%No parallel computing
cephee.YP105119(1).scheduler.pbsproconfig.timeout = 20;%100 s time out for job submission
cephee.YP105119(1).scheduler.pbsproconfig.clustersize = 8*14;%One core or processor
cephee.YP105119(1).scheduler.pbsproconfig.memory = 1600;%no memory requirements
cephee.YP105119(1).scheduler.pbsproconfig.temppathroot = cephee.YP105119(1).temppathroot;
cephee.YP105119(1).scheduler.pbsproconfig.display = 0;
%
%--------------------------- Remote computing -----------------------------
%
cephee.YP105119(1).remote(1).host = '';% empty for local host
cephee.YP105119(1).remote(1).nproc = 28;
cephee.YP105119(1).remote(1).luke_root = cephee.YP105119(1).luke_root;
cephee.YP105119(1).remote(1).matlabroot = '';
cephee.YP105119(1).remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
cephee.YP105119(1).remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
cephee.YP105119(1).remote(1).get_jobid = {'','.cephee'};%str_before,str_after
cephee.YP105119(1).remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
%
cephee.YP105119(1).remote(2).host = {'saturne1.partenaires.cea.fr'};
cephee.YP105119(1).remote(2).nproc = 12;
cephee.YP105119(1).remote(2).luke_root = ['/home/JD211098/',luke_ref,'/'];%official saturne package repository for collaborators
cephee.YP105119(1).remote(2).matlabroot = '';
cephee.YP105119(1).remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
cephee.YP105119(1).remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
cephee.YP105119(1).remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
cephee.YP105119(1).remote(2).YP105119 = 'YP105119';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
cephee.JD211098(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
cephee.JD211098(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
cephee.JD211098(1).temppathroot = '/local/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
cephee.JD211098(1).mex705 = [cephee.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
cephee.JD211098(1).mex710 = [cephee.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
cephee.JD211098(1).mex712 = [cephee.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
%
cephee.JD211098(1).compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
cephee.JD211098(1).compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',cephee.JD211098(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
cephee.JD211098(1).compiler_opt.helmex.mex705 = ['-L',cephee.JD211098(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',cephee.JD211098(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
cephee.JD211098(1).compiler_opt.copts.mex710 = '';
cephee.JD211098(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
cephee.JD211098(1).compiler_opt.helmex.mex710 = ['-L',cephee.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
cephee.JD211098(1).compiler_opt.copts.mex712 = '';
cephee.JD211098(1).compiler_opt.fopts.mex712 = 'FC=''ifort''';
cephee.JD211098(1).compiler_opt.helmex.mex712 = ['-L',cephee.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
cephee.JD211098(1).MUMPS.mex705 = [cephee.JD211098(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
cephee.JD211098(1).MUMPS.mex710 = [cephee.JD211098(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%cephee.JD211098(1).MUMPS.mex710 = [cephee.JD211098(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
cephee.JD211098(1).MUMPS.mex712 = [cephee.JD211098(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
%
%--------------------------- Distributed computing -----------------------------
%
cephee.JD211098(1).scheduler.local.configfile = '';%'/local/mdce/configurations/localconfig.mat';
cephee.JD211098(1).scheduler.local.mode = 3;%No parallel computing
cephee.JD211098(1).scheduler.local.timeout = 20;%100 s time out for job submission
cephee.JD211098(1).scheduler.local.clustersize = 8;%One core or processor
cephee.JD211098(1).scheduler.local.memory = 1600;%no memory requirements
cephee.JD211098(1).scheduler.local.temppathroot = cephee.JD211098(1).temppathroot;
cephee.JD211098(1).scheduler.local.display = 0;
%
cephee.JD211098(1).scheduler.pbsproconfig.configfile = '';%'/local/mdce/configurations/pbsproconfig.mat';
cephee.JD211098(1).scheduler.pbsproconfig.mode = 3;%No parallel computing
cephee.JD211098(1).scheduler.pbsproconfig.timeout = 20;%100 s time out for job submission
cephee.JD211098(1).scheduler.pbsproconfig.clustersize = 8*14;%One core or processor
cephee.JD211098(1).scheduler.pbsproconfig.memory = 1600;%no memory requirements
cephee.JD211098(1).scheduler.pbsproconfig.temppathroot = cephee.JD211098(1).temppathroot;
cephee.JD211098(1).scheduler.pbsproconfig.display = 0;
%
%--------------------------- Remote computing -----------------------------
%
cephee.JD211098(1).remote(1).host = '';% empty for local host
cephee.JD211098(1).remote(1).nproc = 28;
cephee.JD211098(1).remote(1).luke_root = cephee.JD211098(1).luke_root;
cephee.JD211098(1).remote(1).matlabroot = '';
cephee.JD211098(1).remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
cephee.JD211098(1).remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
cephee.JD211098(1).remote(1).get_jobid = {'','.cephee'};%str_before,str_after
cephee.JD211098(1).remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
%
cephee.JD211098(1).remote(2).host = 'saturne1.partenaires.cea.fr';
cephee.JD211098(1).remote(2).nproc = 12;
cephee.JD211098(1).remote(2).luke_root = ['/home/JD211098/',luke_ref,'/'];%official saturne package repository for collaborators
cephee.JD211098(1).remote(2).matlabroot = '';
cephee.JD211098(1).remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
cephee.JD211098(1).remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
cephee.JD211098(1).remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
cephee.JD211098(1).remote(2).JD211098 = 'JD211098';
%

