function [macbookyves] = path_laptop_YVES_PEYSSON(luke_ref)
%
% path definitions for macbook pro 2010 (Core i7 Intel) of Yves Peysson 
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
macbookyves.hostname = 'macbookyves';
macbookyves.machine = 'macbookyves';
macbookyves.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
macbookyves.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
macbookyves.yves(1).luke_root = [getenv('HOME'),'/Projets/',luke_ref,'/'];
macbookyves.yves(1).local_root = [getenv('HOME'),'/Projets/'];
macbookyves.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
macbookyves.yves(1).startup{1} = [];
%
macbookyves.yves(1).cshrc{1} = [];
%
macbookyves.yves(1).mex800 = [macbookyves.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB800','/'];
macbookyves.yves(1).mex801 = [macbookyves.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB801','/'];
%
macbookyves.yves(1).compiler_opt.copts = '';
macbookyves.yves(1).compiler_opt.helmex = '  -llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
macbookyves.yves(1).compiler_opt.fopts = ' -largeArrayDims';
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%macbookyves.yves(1).MUMPS.par = [macbookyves.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%macbookyves.yves(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
macbookyves.yves(1).MUMPS.seq = [macbookyves.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
macbookyves.yves(1).MUMPS.mex800 = [macbookyves.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
macbookyves.yves(1).MUMPS.mex801 = [macbookyves.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
macbookyves.yves(1).SUPERLU.mex800 = [macbookyves.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB800'];%Where SUPERLU matrix solver is stored (MEX function)
macbookyves.yves(1).SUPERLU.mex801 = [macbookyves.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB801'];%Where SUPERLU matrix solver is stored (MEX function)
%
% PETSc matrix solver (parallel, sequential)
%
%macbookyves.yves(1).PETSc.par = [macbookyves.yves(1).local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%macbookyves.yves(1).PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%macbookyves.yves(1).PETSc.seq = [macbookyves.yves(1).local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
macbookyves.yves(1).TSBASE.mex = [macbookyves.yves(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
%--------------------------- Distributed computing -----------------------------
%
%
%--------------------------- Remote computing -----------------------------
%
% For remote computing with Matlab, an automatic login from local host A to
% the remote host B is need. This is the first prior requirement:
% !ssh login@remote_host should give directly the prompt of the remote machine 
% (not asking the password)
%
% Each remote machine must have a working scheduler (PBS, XGRID, CONDOR, etc). The local
% machine may have one for local check of the program or using multicores
% capabilities. In that case, the self automatic login with ssh should be
% setup from local host to local host. If the program does not work
% locally, it won't work remotely ! 
%
% WARNING: the setup of the scheduler may be complicated and is usually
% machine dependent. 
%
macbookyves.yves(1).remote(1) = remote_laptop_YVES_PEYSSON('condor','yves','yves');
macbookyves.yves(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','yves','yves');
macbookyves.yves(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','yves','yves');

if 0
%
% CEPHEE CEA cluster (pbs)
%
macbookyves.yves(1).remote(2).host = 'cephee15.intra.cea.fr';
macbookyves.yves(1).remote(2).nproc = 28;
macbookyves.yves(1).remote(2).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
macbookyves.yves(1).remote(2).get_jobid = {'','.cephee'};%str_before,str_after
macbookyves.yves(1).remote(2).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
macbookyves.yves(1).remote(2).luke_root = ['/home/sccp/gsem/decker/',luke_ref,'/'];
macbookyves.yves(1).remote(2).yves = 'YP105119';
%
% MACPRO yves (macproyves:xgrid)
%
% WARNING about Xgrid scheduler for mac OSX (> 10.5.x)
% Xgrid runs tasks using the "sandbox" facility. Tasks running as 'nobody' ie, 
% any task where either the submitting client or the receiving agent 
% are NOT using Kerberos authentication) have very restricted access to the
% filesystem. To by-pass this strong protection (no password) on a local
% cluster or a multi-core multi-processor machine, go to
% /usr/share/sandbox/xgridagentd_task_nobody.sb file (root rights needed)
% then, comment the following line (with a ';' at the beginning of the line):
% (allow process* sysctl* mach* network* system-socket)
% and replace it by
% (allow process* sysctl* mach* file-read* file-write* network* system-socket)
% omment the following lines (with a ';' at the beginning of the line):
% (allow file-read* (regex "^/(bin|dev|(private/)?(etc|tmp|var)|usr|System|Library)(/|$)"))
% (allow file-read* file-write* (regex "^/(private/)?(tmp|var)(/|$)"))
% and replace it by
% (allow file-read* file-write* (regex "^/all(/|$)"))
%
% NOTE that it should be done each time the system is updated.
% furthermore, all *.m and *.mex* files must be read by anybody.
% This lack of protection make the cluster more vulnerable to an external
% attack, but on a personal computer, this risk is limited.
%
% Furthermore, on the remote session, before any calculation, it is
% necessary to create a folder named 'xgrid' (~/xgrid)
% that will contain all the files for the remote calculations. The owner is the
% USER , and the group is 'nobody(-2)'. The rights are 777. It is also
% necessary to done it the same for the Matlab_R20xx_y application (all the
% package and inside) in such a way Matlab can write in the ~/xgrid folder.
%
% The IP address of the hostname must be given in the file /etc/hosts
%
% WARNING: most of the problems come from the SSH without login
% authentication, rights of the target directory and Matlab !
%
% macproyves (condor)
%
macbookyves.yves(1).remote(3).host = 'tolbachik.hd.free.fr';
macbookyves.yves(1).remote(3).cmd = 'condor_submit';
macbookyves.yves(1).remote(3).get_jobid = {'** Proc ',':'};
macbookyves.yves(1).remote(3).set_jobid = {'condor_q ',''};
%
macbookyves.yves(1).remote(3).env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
macbookyves.yves(1).remote(3).env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
macbookyves.yves(1).remote(3).remotedatapath = '/Users/yvespeysson/condor/';
macbookyves.yves(1).remote(3).luke_root = ['/Users/yvespeysson/Projets/',luke_ref,'/'];
%
%macbookyves.yves(1).remote(3).mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
%macbookyves.yves(1).remote(3).mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
%macbookyves.yves(1).remote(3).matdef = macbookyves.yves(1).remote(3).mat714;%default matlab on remote machine
%
macbookyves.yves(1).remote(3).mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
macbookyves.yves(1).remote(3).mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
macbookyves.yves(1).remote(3).matdef = macbookyves.yves(1).remote(3).mat800;%default matlab on remote machine
%
macbookyves.yves(1).remote(3).yves = 'yvespeysson';
macbookyves.yves(1).remote(3).joan = 'yvespeysson';
macbookyves.yves(1).remote(3).JD211098 = 'yvespeysson';
%
% macproyves (xgrid)
%
macbookyves.yves(1).remote(4).host = 'tolbachik.hd.free.fr';
macbookyves.yves(1).remote(4).cmd = {'xgrid -h ',' -p ',' -job batch '};%
macbookyves.yves(1).remote(4).get_jobid = {'jobIdentifier = ',';'};%
macbookyves.yves(1).remote(4).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
macbookyves.yves(1).remote(4).remotedatapath = '/Users/yvespeysson/xgrid/';
macbookyves.yves(1).remote(4).luke_root = ['/Users/yvespeysson/Projets/',luke_ref,'/'];
%
%macbookyves.yves(1).remote(4).mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
%macbookyves.yves(1).remote(4).mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
%macbookyves.yves(1).remote(4).matdef = macbookyves.yves(1).remote(4).mat714;%default matlab on remote machine
%
macbookyves.yves(1).remote(4).mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
macbookyves.yves(1).remote(4).mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
macbookyves.yves(1).remote(4).matdef = macbookyves.yves(1).remote(3).mat800;%default matlab on remote machine
%
macbookyves.yves(1).remote(4).password = {'ghm93'};
macbookyves.yves(1).remote(4).yves = 'yvespeysson';
macbookyves.yves(1).remote(4).joan = 'yvespeysson';
end
%
% SATURNE CEA cluster
%
% USER = 'YP105119';
% CLUSTER = 'saturne';
% HOST = 'saturne1.partenaires.cea.fr';
% HOME = '/home/YP105119';
% NPROC = 12;
% %
% macbookyves.yves(1).remote(5).host = {HOST};
% macbookyves.yves(1).remote(5).cluster = CLUSTER;
% macbookyves.yves(1).remote(5).nproc = NPROC;
% macbookyves.yves(1).remote(5).home = [HOME,'/'];
% macbookyves.yves(1).remote(5).luke_root = [HOME,'/',luke_ref,'/'];
% macbookyves.yves(1).remote(5).matlabroot = '';
% macbookyves.yves(1).remote(5).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
% macbookyves.yves(1).remote(5).get_jobid = {'Your job ',' '};%str_before,str_after
% macbookyves.yves(1).remote(5).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
% macbookyves.yves(1).remote(5).password = {''};
% macbookyves.yves(1).remote(5).(getenv('USER')) = USER;


