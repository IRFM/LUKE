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
dkepath.default = default;
%
% paths for runs on IRFM saturne cluster
%
saturne.luke_root = [getenv('HOME'),'/LUKE/'];
saturne.local_root = '/home/sccp/gsem/decker/saturne/';
saturne.computer = 'GLNXA64';%machine type and supported OS
saturne.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
saturne.MUMPS.mex71 = [saturne.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB71'];%Where MUMPS matrix solver is stored (MEX function)
saturne.MUMPS.mex75 = [saturne.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
saturne.MUMPS.par = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.7.2_P_mpichpgf/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
saturne.MUMPS.seq = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.6.4_S_g95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
saturne.MUMPS.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
saturne.PETSc.par = ['/home/sccp/gsem/peysson/Packages/Bin/PETSC/petsc-2.3.2-p8_P_mpichpgf/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
saturne.PETSc.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
saturne.SUPERLU.mex = ['/home/sccp/gsem/peysson/Packages/Bin/SUPERLU/SuperLU_3.0-pgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
saturne.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
dkepath.saturne = saturne;
%
% paths for runs on IRFM cephee cluster
%
cephee.luke_root = [getenv('HOME'),'/LUKE/'];
cephee.local_root = '/home/sccp/gsem/decker/cephee/';
cephee.computer = 'GLNXA64';%machine type and supported OS
cephee.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
cephee.MUMPS.mex75 = [cephee.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
cephee.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
dkepath.cephee = cephee;
%
% paths for runs on IRFM PC-LUKE workstation
%
pcluke.luke_root = [getenv('HOME'),'/LUKE/'];
pcluke.local_root = '/home/lukeuser/Work/';
pcluke.computer = 'GLNX86';%machine type and supported OS
pcluke.temppathroot = '/home/lukeuser/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
pcluke.MUMPS.mex72 = [pcluke.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB72'];%Where MUMPS matrix solver is stored (MEX function)
pcluke.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
dkepath.pcluke = pcluke;
%
% paths for runs on Yves Peysson's laptop
%
laptopyves.luke_root = [getenv('HOME'),'/CEA/Projets/LUKE/'];
laptopyves.local_root = [getenv('HOME'),'/CEA/Projets/'];
laptopyves.computer = 'MAC';%machine type and supported OS
laptopyves.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
laptopyves.MUMPS.par = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
laptopyves.MUMPS.seq = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_S_GotoBlasg95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
laptopyves.MUMPS.mex75 = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.8.1_S_GotoBlasg95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
laptopyves.MUMPS.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
laptopyves.PETSc.par = [laptopyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
laptopyves.PETSc.seq = [laptopyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_S_g95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
laptopyves.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
laptopyves.SUPERLU.mex = [laptopyves.local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
laptopyves.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
dkepath.laptopyves = laptopyves;
%
% paths for runs on Joan Decker's laptop
%
laptopjoan.luke_root = '/home/jd211098/Work/LUKE/';
laptopjoan.local_root = '/home/jd211098/Work/LUKE/';
laptopjoan.computer = 'GLNX86';%machine type and supported OS
laptopjoan.temppathroot = '/home/jd211098/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
laptopjoan.MUMPS.mex75 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.compiler_opt.helmex = '-lblas -llapack';% Optional argument for helmex compilation 
%
dkepath.laptopjoan = laptopjoan;
%
% paths for runs on SUN workstation at IPP-Prag
%
sunipp.luke_root = '/home/vader/LUKE/';
sunipp.local_root = '/home/vader/';
sunipp.computer = 'GLNXA64';%machine type and supported OS
sunipp.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
sunipp.MUMPS.seq = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/dke'];
sunipp.MUMPS.mex75 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.sunipp = sunipp;
%
%***************************************************************************************************
%
save([pwd,'/Project_DKE/Database/PATH_files/PATH_',dkepath.id,'.mat'],'dkepath');
%