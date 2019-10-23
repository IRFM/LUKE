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
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.yves(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.yves(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.yves(1).local_root = [getenv('HOME'),'/Travail/Projets/'];
dkepath.yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.yves(1).mex904 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB904','/'];%R2018a
dkepath.yves(1).mex907 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookyves/MATLAB907','/'];%R2019b
%
dkepath.yves(1).compiler_opt.libs.gfortran = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.9.0','/',dkepath.machine,'/'];%extra libraries
dkepath.yves(1).compiler_opt.libs.ifort = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Libs/ifort/19.0.4','/',dkepath.machine,'/'];
dkepath.yves(1).compiler_opt.copts = ' ';
dkepath.yves(1).compiler_opt.fopts.mex904 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex904 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex904 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.fopts.mex907 = ' ';%-largeArrayDims';
dkepath.yves(1).compiler_opt.separatrice.mex907 = [' -largeArrayDims  /Users/yves/Travail/Projets/Packages/Bin/LAPACK/lapack-3.8.0_gfortran/librefblas.a    /Users/yves/Travail/Projets/Packages/Bin/LAPACK/lapack-3.8.0_gfortran/liblapack.a  ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yves(1).compiler_opt.helmex.mex907 = [' -compatibleArrayDims  /Users/yves/Travail/Projets/Packages/Bin/LAPACK/lapack-3.8.0_gfortran/librefblas.a    /Users/yves/Travail/Projets/Packages/Bin/LAPACK/lapack-3.8.0_gfortran/liblapack.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.yves(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.yves(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
dkepath.yves(1).MUMPS.seq = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.yves(1).MUMPS.mex904 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2_S_gfortran/MATLAB904'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.yves(1).MUMPS.mex907 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.2.1_S_gfortran/MATLAB907'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.yves(1).MUMPS.mex907 = [dkepath.yves(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2_S_ifort/MATLAB907'];%Where MUMPS matrix solver is stored (MEX function)
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
dkepath.yves(1).extrapaths.TSBASE = [dkepath.yves(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%remote_tsbase.m script
%
% IMAS database (WEST and other machines, like ITER)
%
dkepath.yves(1).extrapaths.IMAS = [dkepath.yves(1).luke_root,'Project_DKE/Database/EXTERNAL_files/IMAS'];%remote_imas.m script
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
dkepath.yves(1).remote(ir).luke_root = ['/home/ypeysson/luke/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'CEA_ANDROMEDE';
dkepath.yves(1).remote(ir).schedulername = 'pbs';
dkepath.yves(1).remote(ir).profilename = 'YP105119';
dkepath.yves(1).remote(ir).luke_root = ['/Applications/LUKE/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir).luke_root = ['/Home/YP105119/luke/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir).luke_root = ['/compass/Shared/Common/IT/projects/luke/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir).remoteid = 'IPP_SOROBAN';
dkepath.yves(1).remote(ir).schedulername = 'pbs';
dkepath.yves(1).remote(ir).profilename = 'peysson';
dkepath.yves(1).remote(ir).luke_root = ['/compass/Shared/Common/IT/projects/luke/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir).remoteid = 'IFJ_KLASTER';
dkepath.yves(1).remote(ir).schedulername = 'torque';
dkepath.yves(1).remote(ir).profilename = 'yves';
dkepath.yves(1).remote(ir).luke_root = ['/home/111-LUKE/',dkepath.yves(1).luke_branch,'/'];
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/111-LUKE/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir) = dkepath.yves(1).remote(ir-1);
dkepath.yves(1).remote(ir).schedulername = 'direct';
dkepath.yves(1).remote(ir).gitupdate = true;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'CYFRONET_PROMETHEUS';
dkepath.yves(1).remote(ir).schedulername = 'slurm';
dkepath.yves(1).remote(ir).profilename = 'plgypeysson';
dkepath.yves(1).remote(ir).luke_root = ['/net/people/plgypeysson/luke/',dkepath.yves(1).luke_branch,'/'];
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;
dkepath.yves(1).remote(ir).gitupdate = false;
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'EUROFUSION_ITM';
dkepath.yves(1).remote(ir).schedulername = 'slurm';
dkepath.yves(1).remote(ir).profilename = 'g2yvesp';
dkepath.yves(1).remote(ir).luke_root = ['/marconi/eufus_gw/home/g2yvesp/public/',dkepath.yves(1).luke_branch,'/'];
dkepath.yves(1).remote(ir).link_mode = 2;
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = false;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /marconi/eufus_gw/home/g2yvesp/public/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
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
dkepath.yves(1).remote(ir).luke_root = ['/home/peyssony/luke/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir).luke_root = ['/home/ypeysson/luke/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir).luke_root = ['/home/ypeysson/luke/',dkepath.yves(1).luke_branch,'/'];
dkepath.yves(1).remote(ir).link_mode = '';
dkepath.yves(1).remote(ir).cvsupdate = false;% update done in 'direct' mode
dkepath.yves(1).remote(ir).gitupdate = true;
dkepath.yves(1).remote(ir).gitmode.cmd = 'cd /home/ypeysson/luke/*;git pull;';%'*' will be replaced dynamically by MatTools, MatRemote, MatHelp and LUKE
%
ir = ir + 1;
dkepath.yves(1).remote(ir).remoteid = 'ASIPP_SHENMA';
dkepath.yves(1).remote(ir).schedulername = 'torque';
dkepath.yves(1).remote(ir).profilename = 'PEYSSON';
dkepath.yves(1).remote(ir).luke_root = ['/project/LUKE/',dkepath.yves(1).luke_branch,'/'];
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
dkepath.yves(1).remote(ir).luke_root = ['/home/Yves/',dkepath.yves(1).luke_branch,'/'];
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



