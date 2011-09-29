%************************************** PATH PARAMETERS ********************************************
%***************************************************************************************************
%
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
% warning : matlab versions before 7.5 are no longer supported
%
clear all
%
CVSbranch = 'FLUCT';
%
dkepath.id = 'LOCAL';%Set here the name path parameters (user specific)
[lukeversion,matver] = LUKEversion_jd;
%
% For simplifying CVS branch (multiple projects on the same computer)
%
if ~exist('CVSbranch'),
    CVSbranch = '';
else
    if ~isempty(CVSbranch),
        CVSbranch = ['_',CVSbranch];
    end
end
%
% default paths for unrecognized profiles
%
default.luke_root = [pwd,'/'];
default.local_root = [pwd,'/'];
default.computer = computer;
default.temppathroot = [pwd,'/'];
default.compiler_opt = '';% Optional arguments for compilation 
%
default.(['mex',matver]) = [default.luke_root,'Project_DKE/MEX/Bin/default/MATLAB',matver,'/'];%where compiled mex files are stored for this version of matlab
%
dkepath.default = default;
%
% paths for runs on IRFM saturne cluster
%
dkepath.hostname.saturne = 'saturne';
%
saturne.luke_root = [pwd,'/'];
saturne.local_root = '/home/JD211098/';%official saturne package repository for collaborators
saturne.computer = 'GLNXA64';%machine type and supported OS
saturne.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
saturne.maxcompthreads = 'automatic';%For MatLab multithreading
%
saturne.mex705 = [saturne.luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
saturne.compiler_opt.copts = '';
saturne.compiler_opt.fopts.mex705 = [' -largeArrayDims'];
saturne.compiler_opt.helmex.mex705 = [' -L',saturne.local_root,'lib -lf95 -lgcc -llapack -lblas'];% -ltmglib Optional argument for helmex compilation
%
saturne.MUMPS.mex705 = [saturne.local_root,'src/MUMPS_4.7.3/MATLAB_7.5'];%Where MUMPS matrix solver is stored (MEX function)
%
saturne.remote(1).host = '';% empty for local host
saturne.remote(1).nproc = 12;
saturne.remote(1).luke_root = saturne.luke_root;
saturne.remote(1).matlabroot = '';
saturne.remote(1).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
saturne.remote(1).get_jobid = {'Your job ',' '};%str_before,str_after
saturne.remote(1).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
%
dkepath.saturne = saturne;
%
% paths for runs on IRFM cephee cluster
%
dkepath.hostname.cephee = 'cephee';
%
cephee.luke_root = [pwd,'/'];
cephee.local_root = '/home/sccp/gsem/decker/Packages/cephee/';
cephee.computer = 'GLNXA64';%machine type and supported OS
cephee.temppathroot = '/local/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
cephee.maxcompthreads = 2;%For MatLab multithreading
%
cephee.mex705 = [cephee.luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
cephee.mex710 = [cephee.luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
%
cephee.compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
cephee.compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',cephee.local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
cephee.compiler_opt.helmex.mex705 = ['-L',cephee.local_root,'lib/cephee/g95 -lf95 -lgcc -L',cephee.local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
cephee.compiler_opt.copts.mex710 = '';
cephee.compiler_opt.fopts.mex710 = 'FC=''ifort''';
cephee.compiler_opt.helmex.mex710 = ['-L',cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%Where MUMPS matrix solver is stored (MEX function)
cephee.MUMPS.mex705 = [cephee.local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
cephee.MUMPS.mex710 = [cephee.local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%cephee.MUMPS.mex710 = [cephee.local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
%
cephee.remote(1).host = '';% empty for local host
cephee.remote(1).nproc = 28;
cephee.remote(1).luke_root = cephee.luke_root;
cephee.remote(1).matlabroot = '';
cephee.remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
cephee.remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
cephee.remote(1).get_jobid = {'','.cephee'};%str_before,str_after
cephee.remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
%
cephee.remote(2).host = 'saturne1.partenaires.cea.fr';
cephee.remote(2).nproc = 12;
cephee.remote(2).luke_root = ['/home/JD211098/LUKE',CVSbranch,'/'];%official saturne package repository for collaborators
cephee.remote(2).matlabroot = '';
cephee.remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
cephee.remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
cephee.remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
cephee.remote(2).JD211098 = 'JD211098';
cephee.remote(2).YP105119 = 'YP105119';
%
dkepath.cephee = cephee;
%
% paths for runs on IRFM PC-LUKE workstation
%
dkepath.hostname.pcluke = 'PC-Luke';
%
pcluke.luke_root = [pwd,'/'];
pcluke.local_root = '/home/lukeuser/Work/';
pcluke.computer = 'GLNX86';%machine type and supported OS
pcluke.temppathroot = '/home/lukeuser/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
pcluke.mex702 = [pcluke.luke_root,'Project_DKE/MEX/Bin/pcluke/MATLAB72/'];
pcluke.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
pcluke.MUMPS.mex702 = [pcluke.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB72/'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.pcluke = pcluke;
%
% paths for runs on Yves Peysson's powerbook (PPC G4 Motorola)
%
dkepath.hostname.powerbookyves = 'powerbookyves';%WARNING: for laptop, may change with connection status.
%
powerbookyves.luke_root = [pwd,'/'];
powerbookyves.local_root = [getenv('HOME'),'/Travail/Projets/'];
powerbookyves.computer = 'MAC';%machine type and supported OS
powerbookyves.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
powerbookyves.mex705 = [powerbookyves.luke_root,'Project_DKE/MEX/Bin/powerbookyves/MATLAB75/'];
powerbookyves.compiler_opt.helmex = 'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';% Optional argument for helmex compilation 
powerbookyves.compiler_opt.fopts = 'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
%
powerbookyves.MUMPS.par = [powerbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
powerbookyves.MUMPS.seq = [powerbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_S_GotoBlasg95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
powerbookyves.MUMPS.mex705 = [powerbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.8.1_S_GotoBlasg95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
powerbookyves.MUMPS.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
powerbookyves.PETSc.par = [powerbookyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
powerbookyves.PETSc.seq = [powerbookyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_S_g95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
powerbookyves.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
powerbookyves.SUPERLU.mex = [powerbookyves.local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.powerbookyves = powerbookyves;
%
% paths for runs on Yves Peysson's macbook pro 2010 (Core i7 Intel)
%
dkepath.hostname.macbookyves = 'macbookyves';%
%
macbookyves.luke_root = [pwd,'/'];
macbookyves.local_root = [getenv('HOME'),'/Travail/Projets/'];
macbookyves.computer = 'MACI64';%machine type and supported OS
macbookyves.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
macbookyves.mex711 = [macbookyves.luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB711/'];
macbookyves.mex712 = [macbookyves.luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB712/'];
macbookyves.mex713 = [macbookyves.luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB713/'];
macbookyves.compiler_opt.helmex = '-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
macbookyves.compiler_opt.fopts = ' ';%
%
%macbookyves.MUMPS.par = [macbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%macbookyves.MUMPS.seq = [macbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
macbookyves.MUMPS.seq = [macbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%macbookyves.MUMPS.mex712 = [macbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
%macbookyves.MUMPS.mex713 = [macbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/MATLAB713'];%Where MUMPS matrix solver is stored (MEX function)
macbookyves.MUMPS.mex712 = [macbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
macbookyves.MUMPS.mex713 = [macbookyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/MATLAB713'];%Where MUMPS matrix solver is stored (MEX function)
%macbookyves.MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%macbookyves.PETSc.par = [macbookyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
macbookyves.PETSc.seq = [macbookyves.local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%macbookyves.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%macbookyves.SUPERLU.mex =
%[macbookyves.local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
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
macbookyves.remote(1).host = {'macbookyves','macbookyves'};% or empty for local host
macbookyves.remote(1).nproc = 4;
macbookyves.remote(1).luke_root = macbookyves.luke_root;
macbookyves.remote(1).matlabroot = ['/Applications/MATLAB_R2011b.app/bin/'];
macbookyves.remote(1).prefdir = ['/Users/yves/.matlab/R2011b'];
macbookyves.remote(1).cmd = {'xgrid -h ',' -job batch ','xgrid_batch_matlab_'};%
macbookyves.remote(1).mem = [];
macbookyves.remote(1).get_jobid = {'jobIdentifier = ',';'};%
macbookyves.remote(1).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
%
macbookyves.remote(2).host = 'cephee15.intra.cea.fr';
macbookyves.remote(2).nproc = 28;
macbookyves.remote(2).luke_root = ['/home/sccp/gsem/peysson/LUKE',CVSbranch,'/'];
macbookyves.remote(2).matlabroot = '';
macbookyves.remote(2).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
macbookyves.remote(2).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
macbookyves.remote(2).get_jobid = {'','.cephee'};%str_before,str_after
macbookyves.remote(2).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
macbookyves.remote(2).yves = 'YP105119';
%
macbookyves.remote(3).host = 'saturne1.partenaires.cea.fr';
macbookyves.remote(3).nproc = 12;
macbookyves.remote(3).luke_root = ['/home/YP105119/LUKE',CVSbranch,'/'];
macbookyves.remote(3).matlabroot = '';
macbookyves.remote(3).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
macbookyves.remote(3).get_jobid = {'Your job ',' '};%str_before,str_after
macbookyves.remote(3).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
macbookyves.remote(3).yves = 'YP105119';
%
macbookyves.remote(4).host = {'macproyves','82.227.179.204'};% or empty for local host
macbookyves.remote(4).nproc = 12;
macbookyves.remote(4).luke_root = ['/Users/yvespeysson/Travail/Projets/LUKE',CVSbranch,'/'];
macbookyves.remote(4).matlabroot = ['/Applications/MATLAB_R2011b.app/bin/'];
macbookyves.remote(4).prefdir = ['/Users/yvespeysson/.matlab/R2011b'];
macbookyves.remote(4).cmd = {'xgrid -h ',' -job batch ','xgrid_batch_matlab_'};%
macbookyves.remote(4).mem = [];
macbookyves.remote(4).get_jobid = {'jobIdentifier = ',';'};%
macbookyves.remote(4).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
macbookyves.remote(4).yves = 'yvespeysson';% Faire getenv('USER') pour savoir qui je suis !!!!
%
dkepath.macbookyves = macbookyves;
%
% paths for runs on Yves Peysson's mac pro 2011 (Core i7 Intel)
%
dkepath.hostname.macproyves = 'macproyves';%WARNING: for laptop, may change with connection status.
%
macproyves.luke_root = [pwd,'/'];
macproyves.local_root = [getenv('HOME'),'/Shared/'];
macproyves.computer = 'MACI64';%machine type and supported OS
macproyves.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
macproyves.mex712 = [macproyves.luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB712/'];
macproyves.mex713 = [macproyves.luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB713/'];
macproyves.compiler_opt.helmex = '-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
macproyves.compiler_opt.fopts = ' ';%
%
%macproyves.MUMPS.par = [macproyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%macproyves.MUMPS.seq = [macproyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
macproyves.MUMPS.seq = [macproyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%macproyves.MUMPS.mex712 = [macproyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
%macproyves.MUMPS.mex713 = [macproyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_gfortran/MATLAB713'];%Where MUMPS matrix solver is stored (MEX function)
macproyves.MUMPS.mex712 = [macproyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
macproyves.MUMPS.mex713 = [macproyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.9.2_S_ifort/MATLAB713'];%Where MUMPS matrix solver is stored (MEX function)
%
%macproyves.MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%macproyves.PETSc.par = [macproyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
macproyves.PETSc.seq = [macproyves.local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%macproyves.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%macproyves.SUPERLU.mex =
%[macproyves.local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
macproyves.PARDISO.mex712 = [macproyves.local_root,'Packages/Bin/PARDISO/PARDISO/MATLAB712'];%Where PARDISO matrix solver is stored (MEX function)
macproyves.PARDISO.mex713 = [macproyves.local_root,'Packages/Bin/PARDISO/PARDISO/MATLAB713'];%Where PARDISO matrix solver is stored (MEX function)
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
macproyves.remote(1).host = {'macproyves','macproyves'};% or empty for local host
macproyves.remote(1).nproc = 12;
macproyves.remote(1).luke_root = macproyves.luke_root;
macproyves.remote(1).matlabroot = ['/Applications/MATLAB_R2011b.app/bin/'];
macproyves.remote(1).prefdir = ['/Users/yvespeysson/.matlab/R2011b'];
macproyves.remote(1).cmd = {'xgrid -h ',' -job batch ','xgrid_batch_matlab_'};%
macproyves.remote(1).mem = [];
macproyves.remote(1).get_jobid = {'jobIdentifier = ',';'};%
macproyves.remote(1).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
macproyves.remote(1).yves = 'yvespeysson';% Faire getenv('USER') pour savoir qui je suis !!!!
%
dkepath.macproyves = macproyves;
%
% paths for runs on ITM gateway
%
dkepath.hostname.efdaitm = 'efda-itm';%WARNING: for laptop, may change with connection status.
%
efdaitm.luke_root = [getenv('HOME'),'/LUKE/'];
efdaitm.local_root = ['/afs/efda-itm.eu/project/switm/'];
efdaitm.computer = 'GLNXA64';%machine type and supported OS
efdaitm.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
efdaitm.maxcompthreads = 'automatic';%For MatLab multithreading
%
efdaitm.speclibpath.xml_io_tools = [efdaitm.luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
%efdaitm.speclibpath.ual = [efdaitm.local_root,'ual/matlabinterface'];%Other machine specific libraries (UAL)
efdaitm.speclibpath.ual = ['/afs/efda-itm.eu/isip/user/buravand/public/matlab/v4.06d'];%Other machine specific libraries (UAL)
%TODO: Adresse temporairede Yves Buravand
%
efdaitm.mex706 = [efdaitm.luke_root,'Project_DKE/MEX/Bin/efdaitm/MATLAB76/'];
efdaitm.compiler_opt.copts = '';
efdaitm.compiler_opt.fopts.mex76 = ['-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
%efdaitm.compiler_opt.helmex.mex76 = 'FLIBS=''-L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas''';
efdaitm.compiler_opt.helmex.mex76 = ['-L/usr/bin/g95 -lf95 -lgcc ',efdaitm.local_root,'lapack/amd64_g95/lib/liblapack.so ',efdaitm.local_root,'blas/amd64_g95/lib/libblas.so ',efdaitm.local_root,'lapack/amd64_g95/lib/libtmglib.so '];% Optional argument for helmex compilation
efdaitm.compiler_opt.helmex.mex76 = 'FLIBS=''-L/usr/bin/g95 -lf95 -lgcc -Wl,-rpath-link,/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -L/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -lmx -lmex -lmat -lm -L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas -lguide -lpthread''';
efdaitm.compiler_opt.helmex.mex75 = NaN;
%
efdaitm.MUMPS.mex706 = [efdaitm.local_root,'mumps/MUMPS_4.7.3_SEQ/MATLAB/'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.efdaitm = efdaitm;
%
% paths for runs on Joan Decker's laptop
%
dkepath.hostname.laptopjoan = 'CADTS-0096';%WARNING: for laptop, may change with connection status.
%
laptopjoan.luke_root = [pwd,'/'];
laptopjoan.local_root = '/opt/';
laptopjoan.computer = 'GLNXA64';%machine type and supported OS
laptopjoan.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% laptopjoan.mex75 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB75'];
% laptopjoan.mex77 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB77'];
% laptopjoan.mex78 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB78'];
laptopjoan.mex710 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB710']; 
laptopjoan.mex711 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB711']; 
laptopjoan.mex712 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB712']; 
%
% this version compiles but helmex still seems to use libc.so.6 instead of
% libgcc... to continue
%
%laptopjoan.compiler_opt.helmex = '-largeArrayDims FLIBS=''-L/home/joan/lib/g95 -lf95 -lgcc -Wl,-rpath-link,/opt/R2010A/bin/glnxa64 -L/opt/R2010A/bin/glnxa64 -lmx -lmex -lmat -lm -lblas -llapack''';
%
% this version compiles but only separatrice works
%
%laptopjoan.compiler_opt.helmex = '-lblas -llapack -largeArrayDims';%'-largeArrayDims';% Optional argument for helmex compilation 
%
% for separatrice, the code compiles with the new version of the file and
% no option (32 bits)
%
%FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer''  
%
% in fedora, g95 installed but helmex did not work... try again with kubuntu?
%
laptopjoan.compiler_opt.helmex = NaN;%'-v -L/home/joan/lib -llapack_g95_32 -lblas_g95_32';%'-v -largeArrayDims -llapack -lblas -lgfortran FC=''gfortran'' FFLAGS=''-fexceptions -fPIC -fbackslash''';%  
laptopjoan.compiler_opt.fopts = '-v FC="gfortran"';%'';%'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
laptopjoan.compiler_opt.copts = '';
%
% laptopjoan.MUMPS.mex75 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
% laptopjoan.MUMPS.mex77 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
% laptopjoan.MUMPS.mex78 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB78'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.MUMPS.mex710 = [laptopjoan.local_root,'MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.MUMPS.mex711 = [laptopjoan.local_root,'MUMPS_4.9.2/MATLAB711'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.MUMPS.mex712 = [laptopjoan.local_root,'MUMPS_4.9.2/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
%
laptopjoan.remote(1).host = 'cephee15.intra.cea.fr';
laptopjoan.remote(1).nproc = 28;
laptopjoan.remote(1).luke_root = ['/home/sccp/gsem/decker/LUKE',CVSbranch,'/'];
laptopjoan.remote(1).matlabroot = '';
laptopjoan.remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
laptopjoan.remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
laptopjoan.remote(1).get_jobid = {'','.cephee'};%str_before,str_after
laptopjoan.remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
laptopjoan.remote(1).joan = 'JD211098';
%
laptopjoan.remote(2).host = 'saturne1.partenaires.cea.fr';
laptopjoan.remote(2).nproc = 12;
laptopjoan.remote(2).luke_root = ['/home/JD211098/LUKE',CVSbranch,'/'];
laptopjoan.remote(2).matlabroot = '';
laptopjoan.remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
laptopjoan.remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
laptopjoan.remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
laptopjoan.remote(2).joan = 'JD211098';
%
laptopjoan.remote(3).host = 'pleiades2.epfl.ch';
laptopjoan.remote(3).nproc = 48;
laptopjoan.remote(3).luke_root = ['/home/jdecker/LUKE',CVSbranch,'/'];
laptopjoan.remote(3).matlabroot = '';
laptopjoan.remote(3).cmd = 'qsub -l walltime=1:59:00 -l nodes=1:ppn=1';
laptopjoan.remote(3).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
laptopjoan.remote(3).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
laptopjoan.remote(3).joan = 'jdecker';
%
laptopjoan.remote(4).host = {'macproyves','82.227.179.204'};% or empty for local host
laptopjoan.remote(4).nproc = 12;
laptopjoan.remote(4).luke_root = ['/Users/joandecker/Travail/Projets/LUKE',CVSbranch,'/'];
laptopjoan.remote(4).matlabroot = '/Applications/MATLAB_R2011a.app/bin/';
laptopjoan.remote(4).cmd = {'xgrid -h ',' -job batch ','xgrid_batch_matlab_'};%
laptopjoan.remote(4).mem = [];
laptopjoan.remote(4).get_jobid = {'jobIdentifier = ',';'};%
laptopjoan.remote(4).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
laptopjoan.remote(4).joan = 'joandecker';% Faire getenv('USER') pour savoir qui je suis !!!!
%
dkepath.laptopjoan = laptopjoan;
%
% paths for runs on Pramod Sharma's laptop
%
dkepath.hostname.laptoppramod = 'promod';%WARNING: for laptop, may change with connection status.
%
laptoppramod.luke_root = [getenv('HOME'),'/LUKE/'];
laptoppramod.local_root = [getenv('HOME'),'/'];
laptoppramod.computer = 'GLNX86';%machine type and supported OS
laptoppramod.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
laptoppramod.mex705 = [laptoppramod.luke_root,'Project_DKE/MEX/Bin/laptoppramod/MATLAB75/'];
laptoppramod.compiler_opt.helmex = '-v FC=''ifort'' FLIBS=''-Wl,-rpath-link,/home/promod/matlab75/bin/glnx86 -L/home/promod/matlab75/bin/glnx86 -lmx -lmex -lmat -lm -Wl,-rpath,/opt/intel/mkl/10.0.1.014/lib/32 -L/opt/intel/mkl/10.0.1.014/lib/32 -lmkl_lapack -lmkl -lguide -lpthread''';%
%
laptoppramod.MUMPS.mex705 = [laptoppramod.local_root,'Projet_Cronos/libs/MUMPS_4.7.3/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.laptoppramod = laptoppramod;
%
% paths for runs on SUN workstation at IPP-Prag
%
dkepath.hostname.sunipp = 'ipp';
%
sunipp.luke_root = [pwd,'/'];
sunipp.local_root = '/home/luke/';
sunipp.computer = 'GLNXA64';%machine type and supported OS
sunipp.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
sunipp.mex704 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB74'];
sunipp.mex705 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB75'];
sunipp.mex706 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB76'];
sunipp.mex707 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB77'];
sunipp.compiler_opt.copts = 'CC="gcc4"';
%sunipp.compiler_opt.fopts = 'FC="gfortran" FFLAGS="-v -largeArrayDims -fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
sunipp.compiler_opt.fopts = 'FC="/opt/g95/0.91_x86_64_32DI/bin/g95" FFLAGS="-v -largeArrayDims -fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
sunipp.compiler_opt.helmex = 'FLIBS=''-Wl,-rpath-link,/opt/matlab/r2008b/bin/glnxa64 -L/opt/matlab/r2008b/bin/glnxa64 -lmx -lmex -lmat -lm  -llapack -lblas -lguide -lpthread''';
%
sunipp.MUMPS.mex705 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
sunipp.MUMPS.mex706 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB76'];%Where MUMPS matrix solver is stored (MEX function)
sunipp.MUMPS.mex707 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.sunipp = sunipp;
%
% paths for runs on workstation at IPR-Gandhinagar
%
dkepath.hostname.ipr = 'matlab2';
%
ipr.luke_root = [pwd,'/'];
ipr.local_root = '/home/yves/';
ipr.computer = 'GLNX86';%machine type and supported OS
ipr.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
ipr.mex706 = [ipr.luke_root,'Project_DKE/MEX/Bin/ipr/MATLAB76'];
%
ipr.MUMPS.seq = [ipr.local_root,'PACKAGES/Bin/MUMPS_4.7.3/dke'];
ipr.MUMPS.mex706 = [ipr.local_root,'PACKAGES/Bin/MUMPS_4.7.3/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
ipr.compiler_opt.helmex = '-L/home/yves/PACKAGES/Bin/lapack-3.2/ -llapack_LINUX -L/home/yves/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
dkepath.ipr = ipr;
%
% paths for runs on workstation at ASIPP-Heifei - node 0
%
dkepath.hostname.asipp0 = 'node0';
%
asipp0.luke_root = [pwd,'/'];
asipp0.local_root = '/home/bojiangding/';
asipp0.computer = 'GLNXA64';%machine type and supported OS
asipp0.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
asipp0.mex71 = [asipp0.luke_root,'Project_DKE/MEX/Bin/asipp/MATLAB71'];
%
asipp0.MUMPS.seq = [asipp0.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/dke'];
asipp0.MUMPS.mex71 = [asipp0.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
asipp0.compiler_opt.helmex = '-L/home/bojiangding/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
dkepath.asipp0 = asipp0;
%
% paths for runs on workstation at ASIPP-Heifei - node 1
%
dkepath.hostname.asipp1 = 'node1';
%
asipp1.luke_root = [pwd,'/'];
asipp1.local_root = '/home/bojiangding/';
asipp1.computer = 'GLNXA64';%machine type and supported OS
asipp1.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
asipp1.mex701 = [asipp1.luke_root,'Project_DKE/MEX/Bin/asipp/MATLAB71'];
%
asipp1.MUMPS.seq = [asipp1.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/dke'];
asipp1.MUMPS.mex701 = [asipp1.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
asipp1.compiler_opt.helmex = '-L/home/bojiangding/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
dkepath.asipp1 = asipp1;
%
% paths for runs on CRPP PC 70
%
dkepath.hostname.crpppc70 = 'lac2';
%
crpppc70.luke_root = [pwd,'/'];
crpppc70.local_root = '/home/decker/NoTivoli/';
crpppc70.computer = 'GLNXA64';%machine type and supported OS
crpppc70.temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
crpppc70.mex706 = [crpppc70.luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB76'];
crpppc70.mex708 = [crpppc70.luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB78'];
crpppc70.mex709 = [crpppc70.luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB79'];
crpppc70.mex710 = [crpppc70.luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB710'];
crpppc70.compiler_opt.helmex.mex706 = 'FLIBS=''-Wl,-rpath-link,/usr/local/matlab76/bin/glnxa64 -L/usr/local/matlab76/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
%crpppc70.compiler_opt.helmex.mex708 = 'FLIBS=''-Wl,-rpath-link,/usr/local/matlab78/bin/glnxa64 -L/usr/local/matlab78/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
crpppc70.compiler_opt.helmex.mex708 = NaN;
crpppc70.compiler_opt.helmex.mex709 = 'FLIBS=''-Wl,-rpath-link,/usr/local/matlab79/bin/glnxa64 -L/usr/local/matlab79/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas''';%  -ltmglib Optional argument for helmex compilation
crpppc70.compiler_opt.helmex.mex710 = crpppc70.compiler_opt.helmex.mex709;
crpppc70.compiler_opt.fopts = 'FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
%
crpppc70.MUMPS.mex706 = [crpppc70.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.6'];%Where MUMPS matrix solver is stored (MEX function)
%crpppc70.MUMPS.mex708 = [crpppc70.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.8'];%Where MUMPS matrix solver is stored (MEX function)
crpppc70.MUMPS.mex709 = [crpppc70.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.9'];%Where MUMPS matrix solver is stored (MEX function)
crpppc70.MUMPS.mex710 = [crpppc70.local_root,'Packages/MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
%
crpppc70.remote(1).host = 'pleiades2.epfl.ch';
crpppc70.remote(1).nproc = 48;
crpppc70.remote(1).luke_root = ['/home/jdecker/LUKE',CVSbranch,'/'];
crpppc70.remote(1).matlabroot = '';
crpppc70.remote(1).cmd = 'qsub -l walltime=3:59:00 -l nodes=1:ppn=1';
crpppc70.remote(1).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
crpppc70.remote(1).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
crpppc70.remote(1).decker = 'jdecker';
crpppc70.remote(1).curchod = 'lcurchod';
%
dkepath.crpppc70 = crpppc70;
%
% paths for runs on CRPP PC lac4
%
dkepath.hostname.lac4 = 'lac4';
%
dkepath.lac4 = crpppc70;
%
% paths for runs on CRPP PC 51
%
dkepath.hostname.crpppc51 = 'lac3';
%
crpppc51.luke_root = [pwd,'/'];
crpppc51.local_root = '/home/decker/NoTivoli/';
crpppc51.computer = 'GLNXA64';%machine type and supported OS
crpppc51.temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
crpppc51.mex76 = [crpppc51.luke_root,'Project_DKE/MEX/Bin/crpppc51/MATLAB76'];
crpppc51.compiler_opt.helmex = '-v -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas LDFLAGS="-fPIC -shared" -largeArrayDims';%  -ltmglib Optional argument for helmex compilation
%
crpppc51.MUMPS.mex76 = [crpppc51.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.6'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.crpppc51 = crpppc51;
%
%
% paths for runs on IRFM pleione machine
%
dkepath.hostname.pleione = 'pleione';
%
pleione.luke_root = [pwd,'/'];
pleione.local_root = '/home/sccp/gsem/decker/Packages/pleione/';
pleione.computer = 'GLNXA64';%machine type and supported OS
pleione.temppathroot = '/home/sccp/gsem/decker/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
pleione.maxcompthreads = 'automatic';%For MatLab multithreading
%
pleione.mex707 = [pleione.luke_root,'Project_DKE/MEX/Bin/pleione/MATLAB77/'];
pleione.mex710 = [pleione.luke_root,'Project_DKE/MEX/Bin/pleione/MATLAB710/'];
pleione.compiler_opt.copts = '';
pleione.compiler_opt.fopts.mex707 = ['FC=''/home/sccp/gsem/decker/pleione/bin/g95'' '];% FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''
pleione.compiler_opt.helmex.mex707 = ['-largeArrayDims -L/home/sccp/gsem/decker/pleione/lib -lf95 -lgcc -llapack -lblas'];%  -ltmglib Optional argument for helmex compilation
pleione.compiler_opt.fopts.mex710 = ['FC=''/home/sccp/gsem/decker/pleione/bin/g95'' '];% FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''
pleione.compiler_opt.helmex.mex710 = ['-largeArrayDims -L/home/sccp/gsem/decker/pleione/lib -lf95 -lgcc -llapack -lblas'];%  -ltmglib Optional argument for helmex compilation
%
pleione.MUMPS.mex707 = ['/home/sccp/gsem/decker/pleione/src/MUMPS_4.7.3/MATLAB_7.7'];%Where MUMPS matrix solver is stored (MEX function)
pleione.MUMPS.mex710 = [pleione.local_root,'MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
%
pleione.remote(1).host = 'cephee15.intra.cea.fr';
pleione.remote(1).nproc = 28;
pleione.remote(1).luke_root = ['/home/sccp/gsem/decker/LUKE',CVSbranch,'/'];
pleione.remote(1).matlabroot = '';
pleione.remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
pleione.remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
pleione.remote(1).get_jobid = {'','.cephee'};%str_before,str_after
pleione.remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
pleione.remote(1).JD211098 = 'JD211098';
pleione.remote(1).YP105119 = 'YP105119';
%
pleione.remote(2).host = 'saturne1.partenaires.cea.fr';
pleione.remote(2).nproc = 12;
pleione.remote(2).luke_root = ['/home/JD211098/LUKE',CVSbranch,'/'];
pleione.remote(1).matlabroot = '';
pleione.remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
pleione.remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
pleione.remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
pleione.remote(2).JD211098 = 'JD211098';
pleione.remote(2).YP105119 = 'YP105119';
%
dkepath.pleione = pleione;
%
%
% paths for runs on IRFM merope machine
%
dkepath.hostname.merope = 'merope';
%
dkepath.merope = pleione;% identical machine
%
%***************************************************************************************************
%
save([pwd,'/Project_DKE/Database/PATH_files/PATH_',dkepath.id,'.mat'],'dkepath');
disp(['>> The dkepath structure for LUKE',CVSbranch,' is saved in ',pwd,'/Project_DKE/Database/PATH_files/PATH_',dkepath.id,'.mat']);
%