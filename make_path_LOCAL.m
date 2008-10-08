%************************************** PATH PARAMETERS ********************************************
%***************************************************************************************************
%
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
dkepath.hostname.saturne = 'saturne';
dkepath.hostname.cephee = 'cephee';
dkepath.hostname.pcluke = 'PC-Luke';
dkepath.hostname.laptopyves = 'peysson';%WARNING: for laptop, may change with connection status.
%
luke_root.saturne = '~/LUKE/';
luke_root.cephee = '~/LUKE/';
luke_root.pcluke = '~/LUKE/';
luke_root.laptopyves = [getenv('HOME'),'/CEA/Projets/LUKE/'];
%
local_root.saturne = '/home/sccp/gsem/decker/saturne/';
local_root.cephee = '/home/sccp/gsem/decker/cephee/';
local_root.pcluke = '/home/lukeuser/Work/';
local_root.laptopyves = [getenv('HOME'),'/CEA/Projets/'];
%
dkepath.id = path_id;
%
dkepath.computer.saturne = 'GLNXA64';%machine type and supported OS
dkepath.computer.cephee = 'GLNXA64';%machine type and supported OS
dkepath.computer.pcluke = 'GLNX86';%machine type and supported OS
dkepath.computer.laptopyves = 'MAC';%machine type and supported OS
%
dkepath.temppathroot.saturne = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.temppathroot.cephee = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.temppathroot.pcluke = '/home/lukeuser/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.temppathroot.laptopyves = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.luke_root = luke_root;
dkepath.local_root = local_root;
%
dkepath.MUMPS.saturne.mex71 = [local_root.saturne,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB71'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.saturne.mex75 = [local_root.saturne,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.saturne.par = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.7.2_P_mpichpgf/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
dkepath.MUMPS.saturne.seq = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.6.4_S_g95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.MUMPS.saturne.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
dkepath.MUMPS.cephee.mex75 = [local_root.cephee,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.pcluke.mex72 = [local_root.pcluke,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB72'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.laptopyves.par = [local_root.laptopyves,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
dkepath.MUMPS.laptopyves.seq = [local_root.laptopyves,'Packages/Bin/MUMPS/MUMPS_4.7.2_S_GotoBlasg95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.MUMPS.laptopyves.mex75 = [local_root.laptopyves,'Packages/Bin/MUMPS/MUMPS_4.8.1_S_GotoBlasg95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.laptopyves.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.PETSc.saturne.par = ['/home/sccp/gsem/peysson/Packages/Bin/PETSC/petsc-2.3.2-p8_P_mpichpgf/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
dkepath.PETSc.saturne.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
dkepath.PETSc.laptopyves.par = [local_root.laptopyves,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
dkepath.PETSc.laptopyves.seq = [local_root.laptopyves,'Packages/Bin/PETSC/petsc-2.3.2-p10_S_g95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
dkepath.PETSc.laptopyves.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
dkepath.SUPERLU.saturne.mex = ['/home/sccp/gsem/peysson/Packages/Bin/SUPERLU/SuperLU_3.0-pgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.SUPERLU.laptopyves.mex = [local_root.laptopyves,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.compiler_opt.saturne.helmex = '';% Optional argument for helmex compilation 
dkepath.compiler_opt.cephee.helmex = '';% Optional argument for helmex compilation 
dkepath.compiler_opt.pcluke.helmex = '';% Optional argument for helmex compilation 
dkepath.compiler_opt.laptopyves.helmex = '';% Optional argument for helmex compilation 
%
eval(['save PATH_',path_id ,'.mat dkepath']);