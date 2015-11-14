function dkepath = path_laptop_YVES_PEYSSON
%
% path definitions for macbook pro 2010 (Core i7 Intel) of Yves Peysson 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'macbookyves';
dkepath.hostname = 'macbookyves';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'yves';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yves(1).luke_root = [pwd,filesep];
dkepath.yves(1).local_root = [getenv('HOME'),'/Projets/'];
dkepath.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.yves(1).mex801 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB801','/'];
dkepath.yves(1).mex803 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB803','/'];
dkepath.yves(1).mex804 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB804','/'];
dkepath.yves(1).mex805 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB805','/'];
dkepath.yves(1).mex806 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB806','/'];
%
dkepath.yves(1).compiler_opt.libs.gfortran = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.9.0','/',dkepath.machine,'/'];%extra libraries
dkepath.yves(1).compiler_opt.libs.ifort = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/ifort/13.0.0','/',dkepath.machine,'/'];
dkepath.yves(1).compiler_opt.copts = '';
dkepath.yves(1).compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex801 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex801 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.fopts.mex803 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex803 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex803 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.fopts.mex804 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex804 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex804 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.fopts.mex805 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex805 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex805 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.fopts.mex806 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex806 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex806 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%dkepath.yves(1).MUMPS.par = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yves(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
dkepath.yves(1).MUMPS.seq = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%dkepath.yves(1).MUMPS.mex801 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yves(1).MUMPS.mex803 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB803'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yves(1).MUMPS.mex804 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB804'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yves(1).MUMPS.mex801 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex803 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB803'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex804 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB804'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex805 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex806 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
dkepath.yves(1).SUPERLU.mex801 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB801'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yves(1).SUPERLU.mex803 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB803'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yves(1).SUPERLU.mex804 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB804'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yves(1).SUPERLU.mex805 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB805'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yves(1).SUPERLU.mex806 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB806'];%Where SUPERLU matrix solver is stored (MEX function)
%
% PETSc matrix solver (parallel, sequential)
%
%dkepath.yves(1).PETSc.par = [dkepath.yves(1).local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yves(1).PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%dkepath.yves(1).PETSc.seq = [dkepath.yves(1).local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%
% Extra paths to add
%
dkepath.yves(1).extrapaths.LUKE_ITM = [dkepath.yves(1).local_root,'LUKE_ITM/trunk'];% LUKE <-> ITM toolbox 
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
dkepath.yves(1).TSBASE.mex = [dkepath.yves(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
% LUKE documentation
%
dkepath.yves(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.yves(1).latex.env = '/usr/texbin/';% Latex environment variable ('which latex' and 'latex -v')
dkepath.yves(1).imagemagick.env = '/usr/local/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.yves(1).remote(1).remoteid = 'laptop_YVES_PEYSSON';
dkepath.yves(1).remote(1).schedulername = 'condor';
dkepath.yves(1).remote(1).profilename = 'yves';
dkepath.yves(1).remote(1).luke_root = dkepath.yves(1).luke_root;% local cluster
dkepath.yves(1).remote(1).link_mode = [];
dkepath.yves(1).remote(1).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(2) = dkepath.yves(1).remote(1);
dkepath.yves(1).remote(2).schedulername = 'direct';
dkepath.yves(1).remote(2).cvsupdate = true;
dkepath.yves(1).remote(2).cvsrights = 'chmod -R a+rx ./';
%
dkepath.yves(1).remote(3).remoteid = 'macpro_YVES_PEYSSON';
dkepath.yves(1).remote(3).schedulername = 'condor';
dkepath.yves(1).remote(3).profilename = 'yvespeysson';
dkepath.yves(1).remote(3).luke_root = '/Users/yvespeysson/Projets/LUKE/';
dkepath.yves(1).remote(3).link_mode = [];
dkepath.yves(1).remote(3).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(4) = dkepath.yves(1).remote(3);
dkepath.yves(1).remote(4).schedulername = 'direct';
dkepath.yves(1).remote(4).cvsupdate = true;% update done in 'direct' mode
dkepath.yves(1).remote(4).cvsrights = 'chmod -R a+rx ./';
%
dkepath.yves(1).remote(5).remoteid = 'CEA_ANDROMEDE';
dkepath.yves(1).remote(5).schedulername = 'pbs';
dkepath.yves(1).remote(5).profilename = 'YP105119';
dkepath.yves(1).remote(5).luke_root = '/home/YP105119/LUKE/';
dkepath.yves(1).remote(5).link_mode = [];
dkepath.yves(1).remote(5).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(6) = dkepath.yves(1).remote(5);
dkepath.yves(1).remote(6).schedulername = 'direct';
dkepath.yves(1).remote(6).cvsupdate = true;% update done in 'direct' mode
dkepath.yves(1).remote(6).cvsrights = 'chmod -R a+rx ./';
%
dkepath.yves(1).remote(7).remoteid = 'EFDA_ITM';
dkepath.yves(1).remote(7).schedulername = 'sge';
dkepath.yves(1).remote(7).profilename = 'yvesp';
dkepath.yves(1).remote(7).luke_root = '/pfs/home/yvesp/public/LUKE/';
dkepath.yves(1).remote(7).link_mode = 2;
dkepath.yves(1).remote(7).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(8) = dkepath.yves(1).remote(7);
dkepath.yves(1).remote(8).schedulername = 'direct';
dkepath.yves(1).remote(8).cvsupdate = true;% update done in 'direct' mode
dkepath.yves(1).remote(8).cvsrights = 'chmod -R a+rx ./';
%
dkepath.yves(1).remote(9).remoteid = 'ASIPP_SHENMA';
dkepath.yves(1).remote(9).schedulername = 'torque';
dkepath.yves(1).remote(9).profilename = 'PEYSSON';
dkepath.yves(1).remote(9).luke_root = '/scratch/project/LUKE/LUKE/';
dkepath.yves(1).remote(9).link_mode = [];
dkepath.yves(1).remote(9).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(10) = dkepath.yves(1).remote(9);
dkepath.yves(1).remote(10).schedulername = 'direct';
dkepath.yves(1).remote(10).cvsupdate = true;% update done in 'direct' mode
dkepath.yves(1).remote(10).cvsrights = 'chmod -R a+rx ./';
%
dkepath.yves(1).remote(11).remoteid = 'SWIP_CLUSTER02';
dkepath.yves(1).remote(11).schedulername = 'torque';
dkepath.yves(1).remote(11).profilename = 'Yves';
dkepath.yves(1).remote(11).luke_root = '/home/Yves/LUKE/';
dkepath.yves(1).remote(11).link_mode = [];
dkepath.yves(1).remote(11).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(12) = dkepath.yves(1).remote(11);
dkepath.yves(1).remote(12).schedulername = 'direct';
dkepath.yves(1).remote(12).cvsupdate = true;% update done in 'direct' mode
dkepath.yves(1).remote(12).cvsrights = 'chmod -R a+rx ./';
%
dkepath.yves(1).remote(13).remoteid = 'IPP_ABACUS';
dkepath.yves(1).remote(13).schedulername = 'pbs';
dkepath.yves(1).remote(13).profilename = 'peysson';
dkepath.yves(1).remote(13).luke_root = '/compass/Shared/Common/IT/projects/luke/LUKE/';
dkepath.yves(1).remote(13).link_mode = [];
dkepath.yves(1).remote(13).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(14) = dkepath.yves(1).remote(13);
dkepath.yves(1).remote(14).schedulername = 'direct';
dkepath.yves(1).remote(14).cvsupdate = true;% update done in 'direct' mode
dkepath.yves(1).remote(14).cvsrights = 'chmod -R a+rx ./';
%
dkepath.yves(1).remote(15).remoteid = 'ASIPP_SHENMA';
dkepath.yves(1).remote(15).schedulername = 'torque';
dkepath.yves(1).remote(15).profilename = 'bjding';
dkepath.yves(1).remote(15).luke_root = '/scratch/project/LUKE/LUKE/';
dkepath.yves(1).remote(15).link_mode = 0;
dkepath.yves(1).remote(15).cvsupdate = false;% update done in 'direct' mode
%
dkepath.yves(1).remote(16).remoteid = 'CRPP_PPB110';
dkepath.yves(1).remote(16).schedulername = 'slurm';
dkepath.yves(1).remote(16).profilename = 'local';
dkepath.yves(1).remote(16).luke_root = '/home/decker/LUKE/';
dkepath.yves(1).remote(16).link_mode = [];% lac911 gateway
dkepath.yves(1).remote(16).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(16).cvsrights = '';
