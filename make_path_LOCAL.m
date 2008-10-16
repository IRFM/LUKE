%************************************** PATH PARAMETERS ********************************************
%***************************************************************************************************
%
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
dkepath.id = 'LOCAL';%Set here the name path parameters (user specific)
%
dkepath.hostname.saturne = 'saturne';
dkepath.hostname.cephee = 'cephee';
dkepath.hostname.pcluke = 'PC-Luke';
dkepath.hostname.laptopyves = 'peysson';%WARNING: for laptop, may change with connection status.
dkepath.hostname.laptopjoan = 'PC-DECKER-J';%WARNING: for laptop, may change with connection status.
dkepath.hostname.sunipp = 'ipp';
%
% default paths for unrecognized profiles
%
default.luke_root = [pwd,'/'];
default.local_root = [pwd,'/'];
default.computer = computer;
default.temppathroot = [pwd,'/'];
%
matver = version;
matver = matver([1,3]);
default.(['mex',matver]) = [default.luke_root,'Project_DKE/MEX/Bin/default/MATLAB',matver,'/'];%where compiled mex files are stored for this version of matlab
%
dkepath.default = default;
%
% paths for runs on IRFM saturne cluster
%
saturne.luke_root = [cd,'/'];
saturne.local_root = '/home/sccp/gsem/decker/saturne/';
saturne.computer = 'GLNXA64';%machine type and supported OS
saturne.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
saturne.mex71 = [saturne.luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB71/'];
saturne.mex75 = [saturne.luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
saturne.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
saturne.MUMPS.mex71 = [saturne.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB71'];%Where MUMPS matrix solver is stored (MEX function)
saturne.MUMPS.mex75 = [saturne.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
saturne.MUMPS.par = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.7.2_P_mpichpgf/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
saturne.MUMPS.seq = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.6.4_S_g95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
saturne.MUMPS.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
saturne.PETSc.par = ['/home/sccp/gsem/peysson/Packages/Bin/PETSC/petsc-2.3.2-p8_P_mpichpgf/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
saturne.PETSc.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
saturne.SUPERLU.mex = ['/home/sccp/gsem/peysson/Packages/Bin/SUPERLU/SuperLU_3.0-pgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.saturne = saturne;
%
% paths for runs on IRFM cephee cluster
%
cephee.luke_root = [cd,'/'];
cephee.local_root = '/home/sccp/gsem/decker/cephee/';
cephee.computer = 'GLNXA64';%machine type and supported OS
cephee.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
cephee.mex75 = [cephee.luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
cephee.compiler_opt.copts = 'CC=''gcc'' CLIBS=''-Wl,-rpath-link,/applications/matlab_2007b/bin/glnxa64 -L/applications/matlab_2007b/bin/glnxa64 -lmx -lmex -lmat -lm''';
%cephee.compiler_opt.fopts = 'FC=''/luke/cephee/Packages/Bin/G95/g95-install/bin/x86_64-suse-linux-gnu-g95''';
%cephee.compiler_opt.helmex = '-L/luke/cephee/Packages/Bin/G95/g95-install/lib/gcc-lib/x86_64-suse-linux-gnu/4.0.3 -lf95 -lgcc -L/luke/cephee/Packages/Bin/LAPACK/lapack-3.1.1/ -lblas_g95 -llapack_g95 -ltmglib_g95';% Optional argument for helmex compilation 
%
cephee.MUMPS.mex75 = [cephee.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.cephee = cephee;
%
% paths for runs on IRFM PC-LUKE workstation
%
pcluke.luke_root = [cd,'/'];
pcluke.local_root = '/home/lukeuser/Work/';
pcluke.computer = 'GLNX86';%machine type and supported OS
pcluke.temppathroot = '/home/lukeuser/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
pcluke.mex72 = [pcluke.luke_root,'Project_DKE/MEX/Bin/pcluke/MATLAB72/'];
pcluke.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
pcluke.MUMPS.mex72 = [pcluke.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB72/'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.pcluke = pcluke;
%
% paths for runs on Yves Peysson's laptop
%
laptopyves.luke_root = [cd,'/'];
laptopyves.local_root = [getenv('HOME'),'/CEA/Projets/'];
laptopyves.computer = 'MAC';%machine type and supported OS
laptopyves.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
laptopyves.mex75 = [laptopyves.luke_root,'Project_DKE/MEX/Bin/laptopyves/MATLAB75/'];
laptopyves.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
laptopyves.MUMPS.par = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
laptopyves.MUMPS.seq = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_S_GotoBlasg95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
laptopyves.MUMPS.mex75 = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.8.1_S_GotoBlasg95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
laptopyves.MUMPS.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
laptopyves.PETSc.par = [laptopyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
laptopyves.PETSc.seq = [laptopyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_S_g95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
laptopyves.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
laptopyves.SUPERLU.mex = [laptopyves.local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.laptopyves = laptopyves;
%
% paths for runs on Joan Decker's laptop
%
laptopjoan.luke_root = [cd,'/'];
laptopjoan.local_root = '/home/jd211098/Work/LUKE/';
laptopjoan.computer = 'GLNX86';%machine type and supported OS
laptopjoan.temppathroot = '/home/jd211098/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
laptopjoan.mex75 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB75'];
laptopjoan.compiler_opt.helmex = '-lblas -llapack';% Optional argument for helmex compilation 
%
laptopjoan.MUMPS.mex75 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.laptopjoan = laptopjoan;
%
% paths for runs on SUN workstation at IPP-Prag
%
sunipp.luke_root = [cd,'/'];
sunipp.local_root = '/home/vader/';
sunipp.computer = 'GLNXA64';%machine type and supported OS
sunipp.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
sunipp.mex75 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB75'];
%
sunipp.MUMPS.seq = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/dke'];
sunipp.MUMPS.mex75 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.sunipp = sunipp;
%
%***************************************************************************************************
%
save([pwd,'/Project_DKE/Database/PATH_files/PATH_',dkepath.id,'.mat'],'dkepath');
%