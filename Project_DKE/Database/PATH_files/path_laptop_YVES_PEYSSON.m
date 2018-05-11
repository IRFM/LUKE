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
dkepath.yves(1).luke_root = [getenv('HOME'),'/Travail/Projets/LUKE/'];
dkepath.yves(1).local_root = [getenv('HOME'),'/Travail/Projets/'];
dkepath.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.yves(1).mex903 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB903','/'];%R2017b
dkepath.yves(1).mex904 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB904','/'];%R2018a
%
dkepath.yves(1).compiler_opt.libs.gfortran = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.9.0','/',dkepath.machine,'/'];%extra libraries
dkepath.yves(1).compiler_opt.libs.ifort = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/ifort/13.0.0','/',dkepath.machine,'/'];
dkepath.yves(1).compiler_opt.copts = ' ';
dkepath.yves(1).compiler_opt.fopts.mex903 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex903 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex903 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.fopts.mex904 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex904 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex904 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
dkepath.yves(1).MUMPS.seq = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.yves(1).MUMPS.mex903 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2_S_gfortran/MATLAB903'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex904 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2_S_gfortran/MATLAB904'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
dkepath.yves(1).SUPERLU.mex903 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB903'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yves(1).SUPERLU.mex904 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB904'];%Where SUPERLU matrix solver is stored (MEX function)
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
dkepath.yves(1).extrapaths.MDSPLUS = [dkepath.yves(1).local_root,'Packages/Bin/MDSPLUS/mdsplus_bd'];%MDS+ toolbox for mac compiled by Basil Duval (EPFL, Suisse)
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
ir = 1;
dkepath.yves(1).remote(ir).remoteid = 'laptop_YVES_PEYSSON';
dkepath.yves(1).remote(ir).schedulername = 'condor';
dkepath.yves(1).remote(ir).profilename = 'yves';
dkepath.yves(1).remote(ir).luke_root = dkepath.yves(1).luke_root;% local cluster
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /Users/Yves/Travail/Projets/*;git pull;echo "* update done";';
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'x58ud7_YVES_PEYSSON';
dkepath.yves(1).remote(ir).schedulername = 'condor';
dkepath.yves(1).remote(ir).profilename = 'ypeysson';
dkepath.yves(1).remote(ir).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/ypeysson/luke/*;git pull;';%
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'nuc_YVES_PEYSSON';
dkepath.yves(1).remote(ir).schedulername = 'condor';
dkepath.yves(1).remote(ir).profilename = 'yvespeysson';
dkepath.yves(1).remote(ir).luke_root = '/home/yvespeysson/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/yvespeysson/luke/*;git pull;';%
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'CEA_ANDROMEDE';
dkepath.yves(1).remote(ir).schedulername = 'pbs';
dkepath.yves(1).remote(ir).profilename = 'YP105119';
dkepath.yves(1).remote(ir).luke_root = '/Applications/LUKE/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /Applications/LUKE/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'CEA_SIRRAH';
dkepath.yves(1).remote(ir).schedulername = 'pbs';
dkepath.yves(1).remote(ir).profilename = 'YP105119';
dkepath.yves(1).remote(ir).luke_root = '/Home/YP105119/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /Home/YP105119/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'IPP_ABACUS';
dkepath.yves(1).remote(ir).schedulername = 'pbs';
dkepath.yves(1).remote(ir).profilename = 'peysson';
dkepath.yves(1).remote(ir).luke_root = '/compass/Shared/Common/IT/projects/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /compass/Shared/Common/IT/projects/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'EFDA_ITM';
dkepath.yves(1).remote(ir).schedulername = 'sge';
dkepath.yves(1).remote(ir).profilename = 'yvesp';
dkepath.yves(1).remote(ir).luke_root = '/pfs/home/yvesp/public/LUKE/';
dkepath.yves(1).remote(ir).link_mode = 2;
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /pfs/home/yvesp/public/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'GA_IRIS';
dkepath.yves(1).remote(ir).schedulername = 'slurm';
dkepath.yves(1).remote(ir).profilename = 'peyssony';
dkepath.yves(1).remote(ir).luke_root = '/home/peyssony/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/peyssony/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'PSFC_EOFE7';
dkepath.yves(1).remote(ir).schedulername = 'slurm';
dkepath.yves(1).remote(ir).profilename = 'ypeysson';
dkepath.yves(1).remote(ir).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/ypeysson/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'PSFC_CMODWS85';
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).profilename = 'ypeysson';
dkepath.yves(1).remote(ir).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = true;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/ypeysson/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'ASIPP_SHENMA';
dkepath.yves(1).remote(ir).schedulername = 'torque';
dkepath.yves(1).remote(ir).profilename = 'PEYSSON';
dkepath.yves(1).remote(ir).luke_root = '/project/LUKE/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /project/LUKE/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'SWIP_CLUSTER02';
dkepath.yves(1).remote(ir).schedulername = 'torque';
dkepath.yves(1).remote(ir).profilename = 'Yves';
dkepath.yves(1).remote(ir).luke_root = '/home/Yves/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/Yves/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'IPR_SCYLLA';
dkepath.yves(1).remote(ir).schedulername = 'torque';
dkepath.yves(1).remote(ir).profilename = 'peysson';
dkepath.yves(1).remote(ir).luke_root = '/home/code/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/code/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'SPCPC483';
dkepath.yves(1).remote(ir).schedulername = 'slurm';
dkepath.yves(1).remote(ir).profilename = 'yves';
dkepath.yves(1).remote(ir).luke_root = '/home/peysson/luke/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/peysson/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'CRPP_LAC1';
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).profilename = 'local';
dkepath.yves(1).remote(ir).luke_root = '/home/decker/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';% lac911 gateway
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = '';
%
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'CRPP_LAC5';
dkepath.yves(1).remote(ir).schedulername = 'slurm';
dkepath.yves(1).remote(ir).profilename = 'local';
dkepath.yves(1).remote(ir).luke_root = '/home/decker/LUKE/';
dkepath.yves(1).remote(ir).link_mode = '';% lac911 gateway
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = '';
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%



