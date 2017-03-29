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
dkepath.yves(1).luke_root = '/Users/yves/Projets/LUKE/';
dkepath.yves(1).local_root = [getenv('HOME'),'/Projets/'];
dkepath.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.yves(1).mex900 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB900','/'];
dkepath.yves(1).mex901 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB901','/'];
%
dkepath.yves(1).compiler_opt.libs.gfortran = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.9.0','/',dkepath.machine,'/'];%extra libraries
dkepath.yves(1).compiler_opt.libs.ifort = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/ifort/13.0.0','/',dkepath.machine,'/'];
dkepath.yves(1).compiler_opt.copts = ' ';
dkepath.yves(1).compiler_opt.fopts.mex900 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex900 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex900 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
dkepath.yves(1).MUMPS.seq = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
%dkepath.yves(1).MUMPS.mex900 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB900'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex901 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex901 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.0.2_S_ifort/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex901 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.0.2_S_gfortran/MATLAB901'];%Where MUMPS matrix solver is stored (MEX function)
%
% SUPERLU matrix solver (parallel, sequential)
%
dkepath.yves(1).SUPERLU.mex900 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB900'];%Where SUPERLU matrix solver is stored (MEX function)
dkepath.yves(1).SUPERLU.mex901 = [dkepath.yves(1).local_root,'Packages/Bin/SUPERLU/SuperLU_4.3_gcc/MATLAB901'];%Where SUPERLU matrix solver is stored (MEX function)
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
dkepath.yves(1).remote(1).remoteid = 'laptop_YVES_PEYSSON';
dkepath.yves(1).remote(1).schedulername = 'condor';
dkepath.yves(1).remote(1).profilename = 'yves';
dkepath.yves(1).remote(1).luke_root = dkepath.yves(1).luke_root;% local cluster
dkepath.yves(1).remote(1).link_mode = '';
dkepath.yves(1).remote(1).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(1).gitupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(1).gitmode.cmd = 'cd /Users/Yves/Projets/*;git pull;echo "* update done";';
%
dkepath.yves(1).remote(2) = dkepath.yves(1).remote(1);
dkepath.yves(1).remote(2).schedulername = 'direct';
dkepath.yves(1).remote(2).gitupdate = true;
%
dkepath.yves(1).remote(3).remoteid = 'x58ud7_YVES_PEYSSON';
dkepath.yves(1).remote(3).schedulername = 'condor';
dkepath.yves(1).remote(3).profilename = 'ypeysson';
dkepath.yves(1).remote(3).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.yves(1).remote(3).link_mode = '';
dkepath.yves(1).remote(3).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(3).gitupdate = false;
dkepath.yves(1).remote(3).gitmode.cmd = 'cd /home/ypeysson/luke/*;git pull;';%
%
dkepath.yves(1).remote(4) = dkepath.yves(1).remote(3);
dkepath.yves(1).remote(4).schedulername = 'direct';
dkepath.yves(1).remote(4).gitupdate = true;
%
dkepath.yves(1).remote(5).remoteid = 'CEA_ANDROMEDE';
dkepath.yves(1).remote(5).schedulername = 'pbs';
dkepath.yves(1).remote(5).profilename = 'YP105119';
dkepath.yves(1).remote(5).luke_root = '/home/YP105119/LUKE/';
dkepath.yves(1).remote(5).link_mode = '';
dkepath.yves(1).remote(5).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(5).gitupdate = false;
dkepath.yves(1).remote(5).gitmode.cmd = 'cd /home/YP105119/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(6) = dkepath.yves(1).remote(5);
dkepath.yves(1).remote(6).schedulername = 'direct';
dkepath.yves(1).remote(6).gitupdate = true;
%
dkepath.yves(1).remote(7).remoteid = 'EFDA_ITM';
dkepath.yves(1).remote(7).schedulername = 'sge';
dkepath.yves(1).remote(7).profilename = 'yvesp';
dkepath.yves(1).remote(7).luke_root = '/pfs/home/yvesp/public/LUKE/';
dkepath.yves(1).remote(7).link_mode = 2;
dkepath.yves(1).remote(7).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(7).gitupdate = false;
dkepath.yves(1).remote(7).gitmode.cmd = 'cd /pfs/home/yvesp/public/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(8) = dkepath.yves(1).remote(7);
dkepath.yves(1).remote(8).schedulername = 'direct';
dkepath.yves(1).remote(8).gitupdate = true;
%
dkepath.yves(1).remote(9).remoteid = 'ASIPP_SHENMA';
dkepath.yves(1).remote(9).schedulername = 'torque';
dkepath.yves(1).remote(9).profilename = 'PEYSSON';
dkepath.yves(1).remote(9).luke_root = '/project/LUKE/LUKE/';
dkepath.yves(1).remote(9).link_mode = '';
dkepath.yves(1).remote(9).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(9).gitupdate = false;
dkepath.yves(1).remote(9).gitmode.cmd = 'cd /project/LUKE/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(10) = dkepath.yves(1).remote(9);
dkepath.yves(1).remote(10).schedulername = 'direct';
dkepath.yves(1).remote(10).gitupdate = true;
%
dkepath.yves(1).remote(11).remoteid = 'SWIP_CLUSTER02';
dkepath.yves(1).remote(11).schedulername = 'torque';
dkepath.yves(1).remote(11).profilename = 'Yves';
dkepath.yves(1).remote(11).luke_root = '/home/Yves/LUKE/';
dkepath.yves(1).remote(11).link_mode = '';
dkepath.yves(1).remote(11).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(11).gitupdate = false;
dkepath.yves(1).remote(11).gitmode.cmd = 'cd /home/Yves/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(12) = dkepath.yves(1).remote(11);
dkepath.yves(1).remote(12).schedulername = 'direct';
dkepath.yves(1).remote(12).gitupdate = true;
%
dkepath.yves(1).remote(13).remoteid = 'IPP_ABACUS';
dkepath.yves(1).remote(13).schedulername = 'pbs';
dkepath.yves(1).remote(13).profilename = 'peysson';
dkepath.yves(1).remote(13).luke_root = '/compass/Shared/Common/IT/projects/luke/LUKE/';
dkepath.yves(1).remote(13).link_mode = '';
dkepath.yves(1).remote(13).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(13).gitupdate = false;
dkepath.yves(1).remote(13).gitmode.cmd = 'cd /compass/Shared/Common/IT/projects/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(14) = dkepath.yves(1).remote(13);
dkepath.yves(1).remote(14).schedulername = 'direct';
dkepath.yves(1).remote(14).gitupdate = true;
%
dkepath.yves(1).remote(15).remoteid = 'CRPP_LAC5';
dkepath.yves(1).remote(15).schedulername = 'slurm';
dkepath.yves(1).remote(15).profilename = 'local';
dkepath.yves(1).remote(15).luke_root = '/home/decker/LUKE/';
dkepath.yves(1).remote(15).link_mode = '';% lac911 gateway
dkepath.yves(1).remote(15).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(15).gitupdate = false;
dkepath.yves(1).remote(15).gitmode.cmd = '';
%
dkepath.yves(1).remote(16) = dkepath.yves(1).remote(15);
dkepath.yves(1).remote(16).schedulername = 'direct';
dkepath.yves(1).remote(16).gitupdate = true;
%
dkepath.yves(1).remote(17).remoteid = 'GA_LOHAN14';
dkepath.yves(1).remote(17).schedulername = 'direct';
dkepath.yves(1).remote(17).profilename = 'peyssony';
dkepath.yves(1).remote(17).luke_root = '/usc-data/d/luke/LUKE/';
dkepath.yves(1).remote(17).link_mode = '';
dkepath.yves(1).remote(17).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(17).gitupdate = true;
dkepath.yves(1).remote(17).gitmode.cmd = 'cd /usc-data/d/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(18).remoteid = 'PSFC_LOKI';
dkepath.yves(1).remote(18).schedulername = 'pbs';
dkepath.yves(1).remote(18).profilename = 'ypeysson';
dkepath.yves(1).remote(18).luke_root = '/home/ypeysson/LUKE/';
dkepath.yves(1).remote(18).link_mode = '';
dkepath.yves(1).remote(18).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(18).gitupdate = false;
dkepath.yves(1).remote(18).gitmode.cmd = 'cd *;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(19) = dkepath.yves(1).remote(18);
dkepath.yves(1).remote(19).schedulername = 'direct';
dkepath.yves(1).remote(19).gitupdate = true;
%
dkepath.yves(1).remote(20).remoteid = 'PSFC_CMODWS85';
dkepath.yves(1).remote(20).schedulername = 'direct';
dkepath.yves(1).remote(20).profilename = 'ypeysson';
dkepath.yves(1).remote(20).luke_root = '/home/ypeysson/luke/LUKE/';
dkepath.yves(1).remote(20).link_mode = '';
dkepath.yves(1).remote(20).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(20).gitupdate = true;
dkepath.yves(1).remote(20).gitmode.cmd = 'cd /home/ypeysson/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(21).remoteid = 'nuc_YVES_PEYSSON';
dkepath.yves(1).remote(21).schedulername = 'condor';
dkepath.yves(1).remote(21).profilename = 'yvespeysson';
dkepath.yves(1).remote(21).luke_root = '/home/yvespeysson/luke/LUKE/';
dkepath.yves(1).remote(21).link_mode = '';
dkepath.yves(1).remote(21).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(21).gitupdate = false;
dkepath.yves(1).remote(21).gitmode.cmd = 'cd /home/yvespeysson/luke/*;git pull;';%
%
dkepath.yves(1).remote(22) = dkepath.yves(1).remote(21);
dkepath.yves(1).remote(22).schedulername = 'direct';
dkepath.yves(1).remote(22).gitupdate = true;
%
dkepath.yves(1).remote(23).remoteid = 'IPR_SCYLLA';
dkepath.yves(1).remote(23).schedulername = 'torque';
dkepath.yves(1).remote(23).profilename = 'peysson';
dkepath.yves(1).remote(23).luke_root = '/home/code/luke/LUKE/';
dkepath.yves(1).remote(23).link_mode = '';
dkepath.yves(1).remote(23).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(23).gitupdate = false;
dkepath.yves(1).remote(23).gitmode.cmd = 'cd /home/code/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(24) = dkepath.yves(1).remote(23);
dkepath.yves(1).remote(24).schedulername = 'direct';
dkepath.yves(1).remote(24).gitupdate = true;
%
dkepath.yves(1).remote(25).remoteid = 'SPCPC483';
dkepath.yves(1).remote(25).schedulername = 'slurm';
dkepath.yves(1).remote(25).profilename = 'yves';
dkepath.yves(1).remote(25).luke_root = '/home/peysson/luke/LUKE/';
dkepath.yves(1).remote(25).link_mode = '';
dkepath.yves(1).remote(25).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(25).gitupdate = false;
dkepath.yves(1).remote(25).gitmode.cmd = 'cd /home/peysson/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
dkepath.yves(1).remote(26) = dkepath.yves(1).remote(25);
dkepath.yves(1).remote(26).schedulername = 'direct';
dkepath.yves(1).remote(26).gitupdate = true;
%
%
dkepath.yves(1).remote(27).remoteid = 'CRPP_LAC1';
dkepath.yves(1).remote(27).schedulername = 'direct';
dkepath.yves(1).remote(27).profilename = 'local';
dkepath.yves(1).remote(27).luke_root = '/home/decker/LUKE/';
dkepath.yves(1).remote(27).link_mode = '';% lac911 gateway
dkepath.yves(1).remote(27).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(27).gitupdate = false;
dkepath.yves(1).remote(27).gitmode.cmd = '';
%





