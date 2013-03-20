function [macproyves] = path_macpro_YVES_PEYSSON(luke_ref)
%
% path definitions for macpro 2011 (Core i7 Intel) of Yves Peysson 
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
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
if nargin == 0, luke_ref = 'LUKE';end
%
[dummy,matlabversion,matlabrelease] = LUKEversion_jd;
%
macproyves.hostname = 'macproyves';
macproyves.machine = 'macproyves';
macproyves.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
macproyves.default = 'yvespeysson';
macproyves.path_profile.yvespeysson = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
%macproyves.yvespeysson(1).luke_root = [getenv('HOME'),'/Travail/Projets/',luke_ref,'/'];
macproyves.yvespeysson(1).luke_root = [pwd,'/'];
%
% NOTE : It is better to use path_profile than pwd to separate between LUKE
% versions, but this is not yet fully supported by load_strutctures_yp
%
macproyves.yvespeysson(1).local_root = [getenv('HOME'),'/Shared/'];
macproyves.yvespeysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
macproyves.yvespeysson(1).mex800 = [macproyves.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB800','/'];
macproyves.yvespeysson(1).mex801 = [macproyves.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB801','/'];
%
macproyves.yvespeysson(1).compiler_opt.copts = '';
macproyves.yvespeysson(1).compiler_opt.helmex = '-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
macproyves.yvespeysson(1).compiler_opt.fopts = ' ';
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%macproyves.yvespeysson(1).MUMPS.par = [macproyves.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%macproyves.yvespeysson(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
macproyves.yvespeysson(1).MUMPS.seq = [macproyves.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
macproyves.yvespeysson(1).MUMPS.mex800 = [macproyves.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
macproyves.yvespeysson(1).MUMPS.mex801 = [macproyves.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
macproyves.yvespeysson(1).SUPERLU.mex800 = [macproyves.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB800'];%Where SUPERLU matrix solver is stored (MEX function)
macproyves.yvespeysson(1).SUPERLU.mex801 = [macproyves.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB801'];%Where SUPERLU matrix solver is stored (MEX function)
%
% PETSc matrix solver (parallel, sequential)
%
%macproyves.yvespeysson(1).PETSc.par = [macproyves.yvespeysson(1).local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%macproyves.yvespeysson(1).PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%macproyves.yvespeysson(1).PETSc.seq = [macproyves.yvespeysson(1).local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%
% PARDISO matrix solver (mex)
%
%macproyves.yvespeysson(1).PARDISO.(['mex',matlabversion]) = [macproyves.yvespeysson(1).local_root,'Packages/Bin/PARDISO/PARDISO/MATLAB',matlabversion];%Where PARDISO matrix solver is stored (MEX function)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
macproyves.yvespeysson(1).TSBASE.mex = [macproyves.yvespeysson(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
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
% Each remote machine must have a working scheduler (PBS, XGRID, etc). The local
% machine may have one for local check of the program or using multicores
% capabilities. In that case, the self automatic login with ssh should be
% setup from local host to local host. If the program does not work
% locally, it won't work remotely ! 
%
% WARNING: the setup of the scheduler may be complicated and is usually
% machine dependent. 
%
% Xgrid and Matlab set-up
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
% package and inside) in such a way Matlab can write in the ~/xgrid folder,
% and all the files in the directory 'Packages' which contain external tools (mexfiles,...)
%
% The IP address of the hostname can be given in the file /etc/hosts 
%
% WARNING: most of the problems come from the SSH without login
% authentication, rights of the target directory, Matlab and Packages ! Use
% the debug mode for identifying the problem.
%
% LOCAL # 1 - CONDOR
%
macproyves.yvespeysson(1).remote(1) = remote_macpro_YVES_PEYSSON('condor','yves');
macproyves.yvespeysson(1).remote(2) = remote_macpro_YVES_PEYSSON('xgrid','yves');




if 0,
macproyves.yvespeysson(1).remote(1).host = '';
macproyves.yvespeysson(1).remote(1).nproc = feature('numCores');%number of cpu
macproyves.yvespeysson(1).remote(1).cmd = 'condor_submit';
macproyves.yvespeysson(1).remote(1).get_jobid = {'** Proc ',':'};
macproyves.yvespeysson(1).remote(1).set_jobid = {'condor_q ',''};
macproyves.yvespeysson(1).remote(1).luke_root = macproyves.yvespeysson(1).luke_root;%local host LUKE root
macproyves.yvespeysson(1).remote(1).env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
macproyves.yvespeysson(1).remote(1).env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
%
% LOCAL # 2 - XGRID
%
macproyves.yvespeysson(1).remote(2).host = 'tolbachik.hd.free.fr';
macproyves.yvespeysson(1).remote(2).nproc = 6;
macproyves.yvespeysson(1).remote(2).cmd = {'xgrid -h ',' -p ',' -job batch '};
macproyves.yvespeysson(1).remote(2).get_jobid = {'jobIdentifier = ',';'};
macproyves.yvespeysson(1).remote(2).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
macproyves.yvespeysson(1).remote(2).remotedatapath = '/Users/yvespeysson/xgrid/';
macproyves.yvespeysson(1).remote(2).mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
macproyves.yvespeysson(1).remote(2).mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
macproyves.yvespeysson(1).remote(2).matdef = macproyves.yvespeysson(1).remote(2).mat800;%default matlab on remote machine
macproyves.yvespeysson(1).remote(2).luke_root = ['/Users/yvespeysson/Travail/Projets/',luke_ref,'/'];
macproyves.yvespeysson(1).remote(2).password = {'ghm93'};
macproyves.yvespeysson(1).remote(2).(getenv('USER')) = 'yvespeysson';
%
% SATURNE CEA cluster
%
USER = 'YP105119';
CLUSTER = 'saturne';
HOST = 'saturne1.partenaires.cea.fr';
HOME = '/home/YP105119';
NPROC = 12;
%
macproyves.yvespeysson(1).remote(3).host = {HOST};
macproyves.yvespeysson(1).remote(3).cluster = CLUSTER;
macproyves.yvespeysson(1).remote(3).nproc = NPROC;
macproyves.yvespeysson(1).remote(3).home = [HOME,'/'];
macproyves.yvespeysson(1).remote(3).luke_root = [HOME,'/',luke_ref,'/'];
macproyves.yvespeysson(1).remote(3).matlabroot = '';
macproyves.yvespeysson(1).remote(3).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
macproyves.yvespeysson(1).remote(3).get_jobid = {'Your job ',' '};%str_before,str_after
macproyves.yvespeysson(1).remote(3).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
macproyves.yvespeysson(1).remote(3).password = {''};
macproyves.yvespeysson(1).remote(3).(getenv('USER')) = USER;
end
%

