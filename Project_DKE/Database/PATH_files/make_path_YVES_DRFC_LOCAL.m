%************************************** PATH PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
luke_root = '~/LUKE/';
%
dkepath.hostname.saturne = 'saturne';
dkepath.hostname.cephee = 'cephee';
dkepath.hostname.pcluke = 'PC-Luke';
%
local_root.saturne = '/luke/saturne/';
local_root.cephee = '/luke/cephee/';
local_root.pcluke = '/home/lukeuser/Work/';
%
dkepath.id = path_id;
%
dkepath.computer.saturne = 'GLNXA64';%machine type and supported OS
dkepath.computer.cephee = 'GLNXA64';%machine type and supported OS
dkepath.computer.pcluke = 'GLNX86';%machine type and supported OS
%
dkepath.temppathroot.saturne = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.temppathroot.cephee = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.temppathroot.pcluke = '/home/lukeuser/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.luke_root = luke_root;
dkepath.local_root = local_root;
%
%dkepath.MUMPS.par = [local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_P_mpichgfor/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%dkepath.MUMPS.seq = [local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfor/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%
dkepath.MUMPS.saturne.mex71 = [local_root.saturne,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB71'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.saturne.mex75 = [local_root.saturne,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.cephee.mex75 = [local_root.cephee,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.MUMPS.pcluke.mex72 = [local_root.pcluke,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB72'];%Where MUMPS matrix solver is stored (MEX function)
%
%dkepath.MUMPS.mpipath = [''];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
%dkepath.PETSc.par = [local_root,'Packages/Bin/PETSC/petsc-2.3.3-p0_P_mpichf90/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.PETSc.seq = [local_root,''];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%dkepath.PETSc.mex = [local_root,''];%Where PETSc matrix solver is stored (MEX function)
%dkepath.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%
%dkepath.SUPERLU.mex = [local_root,'Packages/Bin/SUPERLU/SuperLU_3.0/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.compiler_opt.saturne.helmex = '';% Optional argument for helmex compilation 
dkepath.compiler_opt.cephee.helmex = '';% Optional argument for helmex compilation 
dkepath.compiler_opt.pcluke.helmex = '';% Optional argument for helmex compilation 
%
eval(['save PATH_',path_id ,'.mat dkepath']);