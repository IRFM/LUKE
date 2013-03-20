function [dkepath] = path_CEA_CEPHEE(luke_ref)
%
% path definitions for CEA cluster CEPHEE
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,1]
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
if nargin == 0, 
    luke_ref = 'LUKE';
end
%
dkepath.hostname = 'cephee';
dkepath.machine = 'cephee';
dkepath.computer = computer;%machine type and supported OS
%
% Selected default user profile 
%
dkepath.path_profile.YP105119 = 1;
dkepath.path_profile.JD211098 = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
dkepath.YP105119(1).luke_root = ['/home/sccp/gsem/peysson/',luke_ref,'/'];
dkepath.YP105119(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.YP105119(1).temppathroot = '/local/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).mex705 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.YP105119(1).mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
%
dkepath.YP105119(1).compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
dkepath.YP105119(1).compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.YP105119(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.YP105119(1).compiler_opt.helmex.mex705 = ['-L',dkepath.YP105119(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.YP105119(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).compiler_opt.copts.mex710 = '';
dkepath.YP105119(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.YP105119(1).compiler_opt.helmex.mex710 = ['-L',dkepath.YP105119(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).MUMPS.mex705 = [dkepath.YP105119(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).MUMPS.mex710 = [dkepath.YP105119(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.YP105119(1).MUMPS.mex710 = [dkepath.YP105119(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
%
%--------------------------- Distributed computing -----------------------------
%
dkepath.YP105119(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.YP105119(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
dkepath.YP105119(1).remote(1).host = '';% empty for local host
dkepath.YP105119(1).remote(1).nproc = 28;
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;
dkepath.YP105119(1).remote(1).matlabroot = '';
dkepath.YP105119(1).remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
dkepath.YP105119(1).remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
dkepath.YP105119(1).remote(1).get_jobid = {'','.cephee'};%str_before,str_after
dkepath.YP105119(1).remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
%
dkepath.YP105119(1).remote(2).host = {'saturne1.partenaires.cea.fr'};
dkepath.YP105119(1).remote(2).nproc = 12;
dkepath.YP105119(1).remote(2).luke_root = ['/home/JD211098/',luke_ref,'/'];%official saturne package repository for collaborators
dkepath.YP105119(1).remote(2).matlabroot = '';
dkepath.YP105119(1).remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
dkepath.YP105119(1).remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
dkepath.YP105119(1).remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
dkepath.YP105119(1).remote(2).YP105119 = 'YP105119';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.JD211098(1).luke_root = ['/home/sccp/gsem/decker/',luke_ref,'/'];
dkepath.JD211098(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.JD211098(1).temppathroot = '/local/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex705 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.JD211098(1).mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.JD211098(1).mex712 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
%
dkepath.JD211098(1).compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
dkepath.JD211098(1).compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.JD211098(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.JD211098(1).compiler_opt.helmex.mex705 = ['-L',dkepath.JD211098(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.JD211098(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).compiler_opt.copts.mex710 = '';
dkepath.JD211098(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.JD211098(1).compiler_opt.helmex.mex710 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).compiler_opt.copts.mex712 = '';
dkepath.JD211098(1).compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.JD211098(1).compiler_opt.helmex.mex712 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex705 = [dkepath.JD211098(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
dkepath.JD211098(1).MUMPS.mex712 = [dkepath.JD211098(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
%
%--------------------------- Distributed computing -----------------------------
%
dkepath.JD211098(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.JD211098(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
dkepath.JD211098(1).remote(1) = remote_CEA_CEPHEE('pbs','joan','JD211098');
dkepath.JD211098(1).remote(1).host = '';% empty for local host
dkepath.JD211098(1).remote(1).luke_root = dkepath.JD211098(1).luke_root;
%
% dkepath.JD211098(1).remote(2).host = 'saturne1.partenaires.cea.fr';
% dkepath.JD211098(1).remote(2).nproc = 12;
% dkepath.JD211098(1).remote(2).luke_root = ['/home/JD211098/',luke_ref,'/'];%official saturne package repository for collaborators
% dkepath.JD211098(1).remote(2).matlabroot = '';
% dkepath.JD211098(1).remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
% dkepath.JD211098(1).remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
% dkepath.JD211098(1).remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
% dkepath.JD211098(1).remote(2).JD211098 = 'JD211098';
% %
% % The computer cadts-0412 (Timothee's computer) shares the same filesystem as cephee
% %
% dkepath.JD211098(1).remote(3).host = 'cadts-0412.intra.cea.fr';% empty for local host
% dkepath.JD211098(1).remote(3).nproc = 12;
% dkepath.JD211098(1).remote(3).cmd = 'qsub';
% dkepath.JD211098(1).remote(3).get_jobid = {'','.cadts-0412'};%str_before,str_after
% dkepath.JD211098(1).remote(3).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
% dkepath.JD211098(1).remote(3).walltime = 24;%walltime necessary or one hour imposed
% dkepath.JD211098(1).remote(3).mat710 = dkepath.JD211098(1).remote(1).mat710;
% dkepath.JD211098(1).remote(3).matdef = dkepath.JD211098(1).remote(1).matdef;%default matlab on remote machine
% dkepath.JD211098(1).remote(3).JD211098 = 'joan';
% dkepath.JD211098(1).remote(3).luke_root = dkepath.JD211098(1).remote(1).luke_root;
% %
% % The cluster nunki shares the same filesystem as cephee
% %
% dkepath.JD211098(1).remote(4).host = 'nunki.intra.cea.fr';% empty for local host
% dkepath.JD211098(1).remote(4).nproc = 48;
% dkepath.JD211098(1).remote(4).cmd = 'qsub';
% dkepath.JD211098(1).remote(4).get_jobid = {'','.pleione'};%str_before,str_after
% dkepath.JD211098(1).remote(4).set_jobid = {'qstat ','.pleione','Unknown Job Id'};%str_before,str_after,str_check
% dkepath.JD211098(1).remote(4).walltime = 24;%walltime necessary or one hour imposed
% dkepath.JD211098(1).remote(4).mat710.root = '/Applications/Matlab_2010A/bin/';
% dkepath.JD211098(1).remote(4).mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
% dkepath.JD211098(1).remote(4).mat712.root = '/Applications/Matlab_2011A/bin/';
% dkepath.JD211098(1).remote(4).mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
% dkepath.JD211098(1).remote(4).luke_root = dkepath.JD211098(1).remote(1).luke_root;
% %
% % The cluster andromede shares the same filesystem as cephee
% %
% dkepath.JD211098(1).remote(5).host = 'andromede1.intra.cea.fr';% empty for local host
% dkepath.JD211098(1).remote(5).nproc = 12;
% dkepath.JD211098(1).remote(5).cmd = 'qsub';
% dkepath.JD211098(1).remote(5).get_jobid = {'','.andromede1'};%str_before,str_after
% dkepath.JD211098(1).remote(5).set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
% dkepath.JD211098(1).remote(5).walltime = 24;%walltime necessary or one hour imposed
% dkepath.JD211098(1).remote(5).mat710.root = '/Applications/Matlab_2010A/bin/';
% dkepath.JD211098(1).remote(5).mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
% dkepath.JD211098(1).remote(5).mat712.root = '/Applications/Matlab_2011A/bin/';
% dkepath.JD211098(1).remote(5).mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
% dkepath.JD211098(1).remote(5).luke_root = dkepath.JD211098(1).remote(1).luke_root;
% %
% dkepath.JD211098(1).remote(6) = dkepath.JD211098(1).remote(5);
% dkepath.JD211098(1).remote(6).host = 'andromede2.intra.cea.fr';% empty for local host
% dkepath.JD211098(1).remote(6).get_jobid{2} = '.andromede2';%str_before,str_after
% dkepath.JD211098(1).remote(6).set_jobid{2} = '.andromede2';%str_before,str_after,str_check
% %
% dkepath.JD211098(1).remote(7) = dkepath.JD211098(1).remote(5);
% dkepath.JD211098(1).remote(7).host = 'andromede3.intra.cea.fr';% empty for local host
% dkepath.JD211098(1).remote(7).get_jobid{2} = '.andromede3';%str_before,str_after
% dkepath.JD211098(1).remote(7).set_jobid{2} = '.andromede3';%str_before,str_after,str_check
% %
% dkepath.JD211098(1).remote(8) = dkepath.JD211098(1).remote(5);
% dkepath.JD211098(1).remote(8).host = 'andromede4.intra.cea.fr';% empty for local host
% dkepath.JD211098(1).remote(8).get_jobid{2} = '.andromede4';%str_before,str_after
% dkepath.JD211098(1).remote(8).set_jobid{2} = '.andromede4';%str_before,str_after,str_check
%
% macproyves (condor)
%
dkepath.JD211098(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan','JD211098');
%
% macproyves (xgrid)
%
dkepath.JD211098(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan','JD211098');
%
%------------------------------------ Profile number 1, Yves Buravand ------------------------------------
%
dkepath.YB109156(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
dkepath.YB109156(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.YB109156(1).temppathroot = '/local/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YB109156(1).mex705 = [dkepath.YB109156(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.YB109156(1).mex710 = [dkepath.YB109156(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.YB109156(1).mex712 = [dkepath.YB109156(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
%
dkepath.YB109156(1).compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
dkepath.YB109156(1).compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.YB109156(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.YB109156(1).compiler_opt.helmex.mex705 = ['-L',dkepath.YB109156(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.YB109156(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.YB109156(1).compiler_opt.copts.mex710 = '';
dkepath.YB109156(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.YB109156(1).compiler_opt.helmex.mex710 = ['-L',dkepath.YB109156(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YB109156(1).compiler_opt.copts.mex712 = '';
dkepath.YB109156(1).compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.YB109156(1).compiler_opt.helmex.mex712 = ['-L',dkepath.YB109156(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
dkepath.YB109156(1).MUMPS.mex705 = [dkepath.YB109156(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YB109156(1).MUMPS.mex710 = [dkepath.YB109156(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.YB109156(1).MUMPS.mex710 = [dkepath.YB109156(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
dkepath.YB109156(1).MUMPS.mex712 = [dkepath.YB109156(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
%
%--------------------------- Distributed computing -----------------------------
%
dkepath.YB109156(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.YB109156(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
dkepath.YB109156(1).remote(1).host = '';% empty for local host
dkepath.YB109156(1).remote(1).nproc = 28;
dkepath.YB109156(1).remote(1).luke_root = dkepath.YB109156(1).luke_root;
dkepath.YB109156(1).remote(1).matlabroot = '';
dkepath.YB109156(1).remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
dkepath.YB109156(1).remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
dkepath.YB109156(1).remote(1).get_jobid = {'','.cephee'};%str_before,str_after
dkepath.YB109156(1).remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
%
dkepath.YB109156(1).remote(2).host = 'saturne1.partenaires.cea.fr';
dkepath.YB109156(1).remote(2).nproc = 12;
dkepath.YB109156(1).remote(2).luke_root = ['/home/YB109156/',luke_ref,'/'];%official saturne package repository for collaborators
dkepath.YB109156(1).remote(2).matlabroot = '';
dkepath.YB109156(1).remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
dkepath.YB109156(1).remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
dkepath.YB109156(1).remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
dkepath.YB109156(1).remote(2).YB109156 = 'YB109156';
%


