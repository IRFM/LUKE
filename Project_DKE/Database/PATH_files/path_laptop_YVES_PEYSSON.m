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
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
if nargin == 0, luke_ref = 'LUKE';end
%
[~,matlabversion,matlabrelease] = LUKEversion_jd;
%
[~,hostname] = unix('hostname');hostname = hostname(1:end-1);%remove extra term
%
macbookyves.hostname = hostname;
macbookyves.machine = macbookyves.hostname;
%
% Profile usage (to be consistent with the profiles listed below)
%
macbookyves.user = getenv('USER');
%
%------------------------------------ Profile Yves Peysson ------------------------------------
%
macbookyves.(getenv('USER'))(1).computer = computer;%machine type and supported OS
%
macbookyves.(getenv('USER'))(1).luke_root = [getenv('HOME'),'/Travail/Projets/',luke_ref,'/'];
macbookyves.(getenv('USER'))(1).local_root = [getenv('HOME'),'/Travail/Projets/'];
macbookyves.(getenv('USER'))(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
macbookyves.(getenv('USER'))(1).(['mex',matlabversion]) = [macbookyves.(getenv('USER'))(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB',matlabversion,'/'];
macbookyves.(getenv('USER'))(1).compiler_opt.copts = '';
macbookyves.(getenv('USER'))(1).compiler_opt.helmex = '-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
macbookyves.(getenv('USER'))(1).compiler_opt.fopts = ' ';
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%macbookyves.(getenv('USER'))(1).MUMPS.par = [macbookyves.(getenv('USER'))(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%macbookyves.(getenv('USER'))(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
macbookyves.(getenv('USER'))(1).MUMPS.seq = [macbookyves.(getenv('USER'))(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
macbookyves.(getenv('USER'))(1).MUMPS.seq = [macbookyves.(getenv('USER'))(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
macbookyves.(getenv('USER'))(1).MUMPS.(['mex',matlabversion]) = [macbookyves.(getenv('USER'))(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/MATLAB',matlabversion];%Where MUMPS matrix solver is stored (MEX function)
macbookyves.(getenv('USER'))(1).MUMPS.(['mex',matlabversion]) = [macbookyves.(getenv('USER'))(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/MATLAB',matlabversion];%Where MUMPS matrix solver is stored (MEX function)
%
% PETSc matrix solver (parallel, sequential)
%
%macbookyves.(getenv('USER'))(1).PETSc.par = [macbookyves.(getenv('USER'))(1).local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%macbookyves.(getenv('USER'))(1).PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
macbookyves.(getenv('USER'))(1).PETSc.seq = [macbookyves.(getenv('USER'))(1).local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
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
% MACBOOK PRO Yves (local)
%
macbookyves.(getenv('USER'))(1).remote(1).host = {macbookyves.hostname,macbookyves.hostname};%may be empty for local host
[~,nproc] = unix('sysctl -n hw.ncpu');nproc = nproc(1:end-1);
macbookyves.(getenv('USER'))(1).remote(1).nproc = nproc;%number of cpu
macbookyves.(getenv('USER'))(1).remote(1).matlabroot = ['/Applications/MATLAB_',matlabrelease,'.app/bin/'];%matlab application
macbookyves.(getenv('USER'))(1).remote(1).luke_root = macbookyves.(getenv('USER'))(1).luke_root;%local host LUKE root
macbookyves.(getenv('USER'))(1).remote(1).prefdir = [getenv('MATLAB_PATH'),'/.matlab/',matlabrelease,'/'];%Matlab preference dir
macbookyves.(getenv('USER'))(1).remote(1).cmd = {'xgrid -h ',' -job batch ','xgrid_batch_matlab_'};%
macbookyves.(getenv('USER'))(1).remote(1).mem = [];
macbookyves.(getenv('USER'))(1).remote(1).get_jobid = {'jobIdentifier = ',';'};%
macbookyves.(getenv('USER'))(1).remote(1).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
%
% CEPHEE CEA cluster
%
USER = 'YP105119';
HOST = 'cephee15.intra.cea.fr';
HOME = '/home/sccp/gsem/peysson';
NPROC = 28;
%
display(['Check if remote access to ',USER,'@',HOST,' is working.'])
display('(If the process is blocked, type CTRL-C to escape)');
[remote_access,~] = unix(['ssh ',USER,'@',HOST,' ''ls''']);
if ~remote_access,%test is the remote machine is working with ssh
    [~,HOME] = unix(['ssh ',USER,'@',HOST,' pwd']);
    HOME = HOME(1:end-1);%remove extra term    
    disp(['--> The remote configuation ',USER,'@',HOST,' is available.']);
else
    disp(['WARNING: The remote configuation ',USER,'@',HOST,' is not available.']);
end
%
macbookyves.(getenv('USER'))(1).remote(2).host = HOST;
macbookyves.(getenv('USER'))(1).remote(2).nproc = NPROC;
macbookyves.(getenv('USER'))(1).remote(2).luke_root = [HOME,'/',luke_ref,'/'];
macbookyves.(getenv('USER'))(1).remote(2).matlabroot = '';
macbookyves.(getenv('USER'))(1).remote(2).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
macbookyves.(getenv('USER'))(1).remote(2).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
macbookyves.(getenv('USER'))(1).remote(2).get_jobid = {'','.cephee'};%str_before,str_after
macbookyves.(getenv('USER'))(1).remote(2).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
macbookyves.(getenv('USER'))(1).remote(2).(getenv('USER')) = USER;
%
% SATURNE CEA cluster
%
USER = 'YP105119';
HOST = 'saturne2.partenaires.cea.fr';
HOME = '/home/YP105119';
NPROC = 12;
%
display(['Check if remote access to ',USER,'@',HOST,' is working.']);
display('(If the process is blocked, type CTRL-C to escape)');
[remote_access,~] = unix(['ssh ',USER,'@',HOST,' ''ls''']);
if ~remote_access,,%test is the remote machine is working
    [~,HOME] = unix(['ssh ',USER,'@',HOST,' pwd']);
    HOME = HOME(1:end-1);%remove extra term
    %
    disp(['--> The remote configuation ',USER,'@',HOST,' is available.']);
else
    disp(['WARNING: The remote configuation ',USER,'@',HOST,' is not available.']);
end
%
macbookyves.(getenv('USER'))(1).remote(3).host = HOST;
macbookyves.(getenv('USER'))(1).remote(3).nproc = NPROC;
macbookyves.(getenv('USER'))(1).remote(3).luke_root = [HOME,'/',luke_ref,'/'];
macbookyves.(getenv('USER'))(1).remote(3).matlabroot = '';
macbookyves.(getenv('USER'))(1).remote(3).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
macbookyves.(getenv('USER'))(1).remote(3).get_jobid = {'Your job ',' '};%str_before,str_after
macbookyves.(getenv('USER'))(1).remote(3).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
macbookyves.(getenv('USER'))(1).remote(3).(getenv('USER')) = USER;
%
% MACPRO yves
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
USER = 'yvespeysson';
HOST = '82.227.179.204';
HOME = '/Users/yvespeysson';
APPLICATIONS = 'MATLAB_R2011b';
NPROC = 12;
%
display(['Check if remote access to ',USER,'@',HOST,' is working.']);
display('(If the process is blocked, type CTRL-C to escape)');
[remote_access,~] = unix(['ssh ',USER,'@',HOST,' ''ls''']);
if ~remote_access,,%test is the remote machine is working
    [~,HOME] = unix(['ssh ',USER,'@',HOST,' pwd']);
    HOME = HOME(1:end-1);%remove extra term
    [~,APPLICATIONS] = unix(['ssh ',USER,'@',HOST,' ls /Applications']);
    [~,NPROC] = unix(['ssh ',USER,'@',HOST,' sysctl -n hw.ncpu']);NPROC = NPROC(1:end-1);%number of cpu
    %
    disp(['--> The remote configuation ',USER,'@',HOST,' is available.']);
else
    disp(['WARNING: The remote configuation ',USER,'@',HOST,' is not available.']);
end
%
macbookyves.(getenv('USER'))(1).remote(4).host = {HOST,HOST};
macbookyves.(getenv('USER'))(1).remote(4).nproc = NPROC;
macbookyves.(getenv('USER'))(1).remote(4).luke_root = [HOME,'/Travail/Projets/',luke_ref,'/'];
macbookyves.(getenv('USER'))(1).remote(4).matlabroot = ['/Applications/MATLAB_',APPLICATIONS(strfind(APPLICATIONS,'MATLAB')+7:strfind(APPLICATIONS,'MATLAB')+12),'.app/bin/'];
macbookyves.(getenv('USER'))(1).remote(4).prefdir = [HOME,'/.matlab/',APPLICATIONS(strfind(APPLICATIONS,'MATLAB')+7:strfind(APPLICATIONS,'MATLAB')+12)];
macbookyves.(getenv('USER'))(1).remote(4).cmd = {'xgrid -h ',' -job batch ','xgrid_batch_matlab_'};%
macbookyves.(getenv('USER'))(1).remote(4).mem = [];
macbookyves.(getenv('USER'))(1).remote(4).get_jobid = {'jobIdentifier = ',';'};%
macbookyves.(getenv('USER'))(1).remote(4).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
macbookyves.(getenv('USER'))(1).remote(4).(getenv('USER')) = USER;
