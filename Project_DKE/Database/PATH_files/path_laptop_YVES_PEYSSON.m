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
macbookyves.path_profile.yves = 1;
%
% Selected user profile for unlisted users
%
macbookyves.default = 'yves';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
macbookyves.yves(1).luke_root = [getenv('HOME'),'/Projets/',luke_ref,'/'];
macbookyves.yves(1).local_root = [getenv('HOME'),'/Projets/'];
macbookyves.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
macbookyves.yves(1).startup{1} = [];
%
macbookyves.yves(1).cshrc{1} = [];
%
macbookyves.yves(1).mex801 = [macbookyves.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB801','/'];
%
macbookyves.yves(1).compiler_opt.copts = '';
macbookyves.yves(1).compiler_opt.helmex = NaN;%'  -llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
macbookyves.yves(1).compiler_opt.fopts = ' -largeArrayDims';
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%macbookyves.yves(1).MUMPS.par = [macbookyves.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%macbookyves.yves(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
macbookyves.yves(1).MUMPS.seq = [macbookyves.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
macbookyves.yves(1).MUMPS.mex801 = [macbookyves.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
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
% LUKE documentation
%
macbookyves.yves(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable
macbookyves.yves(1).latex.env = '/usr/texbin/';% Latex environment variable
macbookyves.yves(1).imagemagick.env = '/usr/local/bin/';% ImageMagick environment variable
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
% For testing the availablity of remote calculations, move to the folder
% ~/LUKE_xxx/Project_DKE/Packages/MDCE/testremotebatch and type
% testremotebatch(remote_laptop_YVES_PEYSSON('condor','yves','yves')) for
% any of the remote computers listed below.
%
macbookyves.yves(1).remote(1) = remote_laptop_YVES_PEYSSON('condor','yves','yves');
macbookyves.yves(1).remote(1).luke_root = macbookyves.yves(1).luke_root;
%
macbookyves.yves(1).remote(2) = remote_laptop_YVES_PEYSSON('xgrid','yves','yves');
macbookyves.yves(1).remote(3) = remote_macpro_YVES_PEYSSON('condor','yves','yves');
macbookyves.yves(1).remote(4) = remote_macpro_YVES_PEYSSON('xgrid','yves','yves');
macbookyves.yves(1).remote(5) = remote_ASIPP_SHENMA('torque','yves','yves');
macbookyves.yves(1).remote(6) = remote_CEA_CEPHEE('pbs','yves','yves');
macbookyves.yves(1).remote(7) = remote_CEA_ANDROMEDE('pbs','yves','yves');
%macbookyves.yves(1).remote(8) = remote_CEA_PLEIONE('pbs','yves','yves');
%macbookyves.yves(1).remote(9) = remote_CEA_SATURNE('sun','yves','yves');
%macbookyves.yves(1).remote(10) = remote_CEA_TIMDESKTOP('torque','yves','yves');






