function dkepath = path_macpro_YVES_PEYSSON
%
% path definitions for macpro 2011 (Core i7 Intel) of Yves Peysson 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
dkepath.machine = 'macproyves';
dkepath.hostname = 'macproyves';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'yvespeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yvespeysson(1).luke_root = '/Users/yvespeysson/Projets/LUKE/';% local path necessary to handle several LUKE versions 
%
% NOTE : It is better to use path_profile than pwd to separate between LUKE
% versions, but this is not yet fully supported by load_strutctures_yp
%
dkepath.yvespeysson(1).local_root = '/Users/yvespeysson/Shared/';
dkepath.yvespeysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.yvespeysson(1).mex800 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB800','/'];
dkepath.yvespeysson(1).mex801 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB801','/'];
dkepath.yvespeysson(1).mex803 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB803','/'];
dkepath.yvespeysson(1).mex804 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB804','/'];
dkepath.yvespeysson(1).mex805 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB805','/'];
dkepath.yvespeysson(1).mex806 = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Bin/macproyves/MATLAB806','/'];
%
dkepath.yvespeysson(1).compiler_opt.libs.gfortran = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.9.0','/',dkepath.machine,'/'];%extra libraries
dkepath.yvespeysson(1).compiler_opt.libs.ifort = [dkepath.yvespeysson(1).luke_root,'Project_DKE/MEX/Libs/ifort/13.0.0','/',dkepath.machine,'/'];
dkepath.yvespeysson(1).compiler_opt.copts = '';
dkepath.yvespeysson(1).compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
dkepath.yvespeysson(1).compiler_opt.separatrice.mex801 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.helmex.mex801 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.fopts.mex803 = ' ';%-largeArrayDims';
dkepath.yvespeysson(1).compiler_opt.separatrice.mex803 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.helmex.mex803 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.fopts.mex804 = ' ';%-largeArrayDims';
dkepath.yvespeysson(1).compiler_opt.separatrice.mex804 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.helmex.mex804 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.fopts.mex805 = ' ';%-largeArrayDims';
dkepath.yvespeysson(1).compiler_opt.separatrice.mex805 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.helmex.mex805 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.fopts.mex806 = ' ';%-largeArrayDims';
dkepath.yvespeysson(1).compiler_opt.separatrice.mex806 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvespeysson(1).compiler_opt.helmex.mex806 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yvespeysson(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
%dkepath.yvespeysson(1).MUMPS.par = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yvespeysson(1).MUMPS.mpipath = ['/usr/local/openmpigfortran/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
dkepath.yvespeysson(1).MUMPS.seq = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%dkepath.yvespeysson(1).MUMPS.mex800 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yvespeysson(1).MUMPS.mex801 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yvespeysson(1).MUMPS.mex803 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB803'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yvespeysson(1).MUMPS.mex803 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB803'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yvespeysson(1).MUMPS.mex804 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB804'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yvespeysson(1).MUMPS.mex804 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB804'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yvespeysson(1).MUMPS.mex805 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yvespeysson(1).MUMPS.mex805 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yvespeysson(1).MUMPS.mex806 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yvespeysson(1).MUMPS.mex806 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.0.1_S_gfortran/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
%
%
% SUPERLU matrix solver (parallel, sequential)
%
dkepath.yvespeysson(1).SUPERLU.mex800 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB800'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yvespeysson(1).SUPERLU.mex801 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB801'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yvespeysson(1).SUPERLU.mex803 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB803'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yvespeysson(1).SUPERLU.mex804 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB804'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yvespeysson(1).SUPERLU.mex805 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB805'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yvespeysson(1).SUPERLU.mex806 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB806'];%Where SUPERLU matrix solver is stored (MEX function)
%
% PETSc matrix solver (parallel, sequential)
%
%dkepath.yvespeysson(1).PETSc.par = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
%dkepath.yvespeysson(1).PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
%dkepath.yvespeysson(1).PETSc.seq = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PETSC/petsc-3.1-p4_S_gfortran/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
%
% PARDISO matrix solver (mex)
%
dkepath.yvespeysson(1).PARDISO.mex801 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PARDISO/MATLAB801'];%Where PARDISO matrix solver is stored (MEX function)
dkepath.yvespeysson(1).PARDISO.mex803 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PARDISO/MATLAB803'];%Where PARDISO matrix solver is stored (MEX function)
dkepath.yvespeysson(1).PARDISO.mex804 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PARDISO/MATLAB804'];%Where PARDISO matrix solver is stored (MEX function)
dkepath.yvespeysson(1).PARDISO.mex805 = [dkepath.yvespeysson(1).local_root,'Packages/Bin/PARDISO/MATLAB805'];%Where PARDISO matrix solver is stored (MEX function)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
dkepath.yvespeysson(1).TSBASE.mex = [dkepath.yvespeysson(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
% Extra paths to add
%
dkepath.yvespeysson(1).extrapaths.LUKE_ITM = '/Users/yvespeysson/Projets/LUKE_ITM/trunk';% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.yvespeysson(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable
dkepath.yvespeysson(1).latex.env = '/usr/texbin/';% Latex environment variable
dkepath.yvespeysson(1).imagemagick.env = '/opt/local/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.yvespeysson(1).remote(1).remoteid = 'macpro_YVES_PEYSSON';
dkepath.yvespeysson(1).remote(1).schedulername = 'condor';
dkepath.yvespeysson(1).remote(1).profilename = 'yvespeysson';
dkepath.yvespeysson(1).remote(1).luke_root = dkepath.yvespeysson(1).luke_root;% local cluster
dkepath.yvespeysson(1).remote(1).link_mode = [];
dkepath.yvespeysson(1).remote(1).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(1).gitupdate = false;% update done in 'direct' mode
%
dkepath.yvespeysson(1).remote(2) = dkepath.yvespeysson(1).remote(1);
dkepath.yvespeysson(1).remote(2).schedulername = 'direct';
dkepath.yvespeysson(1).remote(2).gitupdate = true;
dkepath.yvespeysson(1).remote(2).gitmode.cmd1 = 'cd /Users/yvespeysson/Projets/*;git pull;echo "* secondary repository synchronization done";';%
%
dkepath.yvespeysson(1).remote(3).remoteid = 'ASIPP_SHENMA';
dkepath.yvespeysson(1).remote(3).schedulername = 'torque';
dkepath.yvespeysson(1).remote(3).profilename = 'PEYSSON';
dkepath.yvespeysson(1).remote(3).luke_root = '/project/LUKE/LUKE/';
dkepath.yvespeysson(1).remote(3).link_mode = [];
dkepath.yvespeysson(1).remote(3).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(3).gitupdate = false;% update done in 'direct' mode
%
dkepath.yvespeysson(1).remote(4) = dkepath.yvespeysson(1).remote(3);
dkepath.yvespeysson(1).remote(4).schedulername = 'direct';
dkepath.yvespeysson(1).remote(4).gitupdate = true;
dkepath.yvespeysson(1).remote(4).gitmode.cmd1 = 'cd /project/LUKE;git archive --format tar --remote ssh://git@tolbachik.hd.free.fr:2222/home/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yvespeysson(1).remote(5).remoteid = 'CEA_ANDROMEDE';
dkepath.yvespeysson(1).remote(5).schedulername = 'pbs';
dkepath.yvespeysson(1).remote(5).profilename = 'YP105119';
dkepath.yvespeysson(1).remote(5).luke_root = '/home/YP105119/LUKE/';
dkepath.yvespeysson(1).remote(5).link_mode = [];
dkepath.yvespeysson(1).remote(5).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(5).gitupdate = false;% update done in 'direct' mode
%
dkepath.yvespeysson(1).remote(6) = dkepath.yvespeysson(1).remote(5);
dkepath.yvespeysson(1).remote(6).schedulername = 'direct';
dkepath.yvespeysson(1).remote(6).gitupdate = true;
dkepath.yvespeysson(1).remote(6).gitmode.cmd1 = 'ssh YP105119@altair "cd /usr/local/git/*.git;git fetch -q;cd ..;";echo "* secondary repository synchronization done";';%for syncronizing first secondary repository from the main one. '*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
dkepath.yvespeysson(1).remote(6).gitmode.cmd2 = 'git archive --format tar --remote ssh://YP105119@altair/usr/local/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yvespeysson(1).remote(7).remoteid = 'EFDA_ITM';
dkepath.yvespeysson(1).remote(7).schedulername = 'sge';
dkepath.yvespeysson(1).remote(7).profilename = 'yvesp';
dkepath.yvespeysson(1).remote(7).luke_root = '/pfs/home/yvesp/public/LUKE/';
dkepath.yvespeysson(1).remote(7).link_mode = [];
dkepath.yvespeysson(1).remote(7).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(7).gitupdate = false;% update done in 'direct' mode
%
dkepath.yvespeysson(1).remote(8) = dkepath.yvespeysson(1).remote(7);
dkepath.yvespeysson(1).remote(8).schedulername = 'direct';
dkepath.yvespeysson(1).remote(8).gitupdate = true;
dkepath.yvespeysson(1).remote(8).gitmode.cmd1 = 'cd /pfs/home/yvesp/public;git archive --format tar --remote ssh://git@tolbachik.hd.free.fr:2222/home/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yvespeysson(1).remote(9).remoteid = 'SWIP_CLUSTER02';
dkepath.yvespeysson(1).remote(9).schedulername = 'torque';
dkepath.yvespeysson(1).remote(9).profilename = 'Yves';
dkepath.yvespeysson(1).remote(9).luke_root = '/home/Yves/LUKE/';
dkepath.yvespeysson(1).remote(9).link_mode = [];
dkepath.yvespeysson(1).remote(9).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(9).gitupdate = false;% update done in 'direct' mode
%
dkepath.yvespeysson(1).remote(10) = dkepath.yvespeysson(1).remote(9);
dkepath.yvespeysson(1).remote(10).schedulername = 'direct';
dkepath.yvespeysson(1).remote(10).gitupdate = true;
dkepath.yvespeysson(1).remote(10).gitmode.cmd1 = 'cd /home/Yves;git archive --format tar --remote ssh://git@tolbachik.hd.free.fr:2222/home/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yvespeysson(1).remote(11).remoteid = 'IPP_ABACUS';
dkepath.yvespeysson(1).remote(11).schedulername = 'pbs';
dkepath.yvespeysson(1).remote(11).profilename = 'peysson';
dkepath.yvespeysson(1).remote(11).luke_root = '/compass/home/peysson/LUKE/';
dkepath.yvespeysson(1).remote(11).link_mode = [];
dkepath.yvespeysson(1).remote(11).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(11).gitupdate = false;% update done in 'direct' mode
%
dkepath.yvespeysson(1).remote(12) = dkepath.yvespeysson(1).remote(11);
dkepath.yvespeysson(1).remote(12).schedulername = 'direct';
dkepath.yvespeysson(1).remote(12).gitupdate = true;
dkepath.yvespeysson(1).remote(12).gitmode.cmd1 = 'cd /compass/Shared/Common/IT/projects/luke;git archive --format tar --remote ssh://git@tolbachik.hd.free.fr:2222/home/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yvespeysson(1).remote(13).remoteid = 'CRPP_PPB110';
dkepath.yvespeysson(1).remote(13).schedulername = 'slurm';
dkepath.yvespeysson(1).remote(13).profilename = 'local';
dkepath.yvespeysson(1).remote(13).luke_root = '/home/decker/LUKE/';
dkepath.yvespeysson(1).remote(13).link_mode = [];% lac911 gateway
dkepath.yvespeysson(1).remote(13).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(13).gitupdate = false;% update done in 'direct' mode
%
dkepath.yvespeysson(1).remote(14).remoteid = 'GA_LOHAN14';
dkepath.yvespeysson(1).remote(14).schedulername = 'direct';
dkepath.yvespeysson(1).remote(14).profilename = 'peyssony';
dkepath.yvespeysson(1).remote(14).luke_root = '/usc-data/d/luke/LUKE/';
dkepath.yvespeysson(1).remote(14).link_mode = [];
dkepath.yvespeysson(1).remote(14).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(14).gitupdate = true;
dkepath.yvespeysson(1).remote(14).gitmode.cmd1 = 'cd /usc-data/d/luke;git archive --format tar --remote ssh://git@tolbachik.hd.free.fr:2222/home/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yvespeysson(1).remote(15).remoteid = 'PSFC_LOKI';
dkepath.yvespeysson(1).remote(15).schedulername = 'pbs';
dkepath.yvespeysson(1).remote(15).profilename = 'ypeysson';
dkepath.yvespeysson(1).remote(15).luke_root = '/home/ypeysson/LUKE/';
dkepath.yvespeysson(1).remote(15).link_mode = [];
dkepath.yvespeysson(1).remote(15).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(15).gitupdate = false;
%
dkepath.yvespeysson(1).remote(16) = dkepath.yvespeysson(1).remote(15);
dkepath.yvespeysson(1).remote(16).schedulername = 'direct';
dkepath.yvespeysson(1).remote(16).gitupdate = true;
dkepath.yvespeysson(1).remote(16).gitmode.cmd1 = 'cd /home/ypeysson;git archive --format tar --remote ssh://git@tolbachik.hd.free.fr:2222/home/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yvespeysson(1).remote(17).remoteid = 'PSFC_CMODWS85';
dkepath.yvespeysson(1).remote(17).schedulername = 'direct';
dkepath.yvespeysson(1).remote(17).profilename = 'ypeysson';
dkepath.yvespeysson(1).remote(17).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.yvespeysson(1).remote(17).link_mode = [];
dkepath.yvespeysson(1).remote(17).cvsupdate = false;% update done in 'direct' mode
dkepath.yvespeysson(1).remote(17).gitupdate = true;
dkepath.yvespeysson(1).remote(17).gitmode.cmd1 = 'cd /home/ypeysson/luke;git archive --format tar --remote ssh://git@tolbachik.hd.free.fr:2222/home/git/*.git HEAD > *.tgz;mkdir -p *;tar -xf *.tgz --overwrite -C *;rm -f *.tgz;chmod -R 777 *;echo "* update done";';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 2, Joan Decker  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yvespeysson(2) = dkepath.yvespeysson(1);
%
dkepath.yvespeysson(2).remote(1).profilename = 'joan';%local
dkepath.yvespeysson(2).remote(1).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(2).profilename = 'joan';%local
dkepath.yvespeysson(2).remote(2).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(3).profilename = 'joan';%shenma
dkepath.yvespeysson(2).remote(3).luke_root = '/project/LUKE/JoanDecker/LUKE/';
dkepath.yvespeysson(2).remote(3).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(4).profilename = 'joan';%shenma
dkepath.yvespeysson(2).remote(4).luke_root = '/project/LUKE/JoanDecker/LUKE/';
dkepath.yvespeysson(2).remote(4).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(5).profilename = 'JD211098';%andromede
dkepath.yvespeysson(2).remote(5).luke_root = '/home/JD211098/LUKE/';
dkepath.yvespeysson(2).remote(5).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(6).profilename = 'JD211098';%andromede
dkepath.yvespeysson(2).remote(6).luke_root = '/home/JD211098/LUKE/';
dkepath.yvespeysson(2).remote(6).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(7).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(8).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(9).profilename = 'joan';%swip
dkepath.yvespeysson(2).remote(9).luke_root = '/home/Yves/joandecker/LUKE/';
dkepath.yvespeysson(2).remote(9).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(10).profilename = 'joan';%swip
dkepath.yvespeysson(2).remote(10).luke_root = '/home/Yves/joandecker/LUKE/';
dkepath.yvespeysson(2).remote(10).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(11).profilename = 'decker';%abacus
dkepath.yvespeysson(2).remote(11).luke_root = '/compass/Shared/Common/IT/projects/luke/LUKE/';
dkepath.yvespeysson(2).remote(11).cvsupdate = false;% update done from joan's laptop
%
dkepath.yvespeysson(2).remote(12).profilename = 'decker';%abacus
dkepath.yvespeysson(2).remote(12).luke_root = '/compass/Shared/Common/IT/projects/luke/LUKE/';
dkepath.yvespeysson(2).remote(12).cvsupdate = false;% update done from joan's laptop
%
