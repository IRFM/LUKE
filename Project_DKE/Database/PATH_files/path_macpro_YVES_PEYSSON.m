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
%       - macproyves: path structure
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
macproyves.path_profile.yvespeysson = 1;
%
% Selected user profile for unlisted users
%
macproyves.default = 'yvespeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
macproyves.yvespeysson(1).luke_root = [pwd,filesep];% local path necessary to handle several LUKE versions 
%
% NOTE : It is better to use path_profile than pwd to separate between LUKE
% versions, but this is not yet fully supported by load_strutctures_yp
%
macproyves.yvespeysson(1).local_root = ['/Users/yvespeysson/Shared/'];
macproyves.yvespeysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
macproyves.yvespeysson(1).mex800 = [macproyves.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB800','/'];
macproyves.yvespeysson(1).mex801 = [macproyves.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB801','/'];
%
macproyves.yvespeysson(1).compiler_opt.copts = '';
macproyves.yvespeysson(1).compiler_opt.helmex = NaN;%'-llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
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
macproyves.yvespeysson(1).PARDISO.mex801 = [macproyves.yvespeysson(1).local_root,'Packages/Bin/PARDISO/MATLAB801'];%Where PARDISO matrix solver is stored (MEX function)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
macproyves.yvespeysson(1).TSBASE.mex = [macproyves.yvespeysson(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
% LUKE documentation
%
macproyves.yvespeysson(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable
macproyves.yvespeysson(1).latex.env = '/usr/texbin/';% Latex environment variable
macproyves.yvespeysson(1).imagemagick.env = '/opt/local/bin/';% ImageMagick environment variable
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
macproyves.yvespeysson(1).remote(1) = remote_macpro_YVES_PEYSSON('condor','yves','yvespeysson');
macproyves.yvespeysson(1).remote(1).luke_root = macproyves.yvespeysson(1).luke_root;
%
macproyves.yvespeysson(1).remote(2) = remote_macpro_YVES_PEYSSON('xgrid','yves','yvespeysson');
macproyves.yvespeysson(1).remote(3) = remote_ASIPP_SHENMA('torque','yves','yvespeysson');
%macproyves.yvespeysson(1).remote(4) = remote_CEA_SATURNE('sun','yves','yvespeysson');


