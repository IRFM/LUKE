%************************************** PATH PARAMETERS ********************************************
%***************************************************************************************************
%
% Create the local file PATH_path_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
% warning : matlab versions before 7.5 are no longer supported
%
clear all
dkepath.id = 'LOCAL';%Set here the name path parameters (user specific)
[lukeversion,matver] = LUKEversion_jd;
disp(['--------- The version ',lukeversion,' is installed ---------'])
%
% default paths for unrecognized profiles
%
default.luke_root = [pwd,'/'];
default.local_root = [pwd,'/'];
default.computer = computer;
default.temppathroot = [pwd,'/'];
default.compiler_opt = '';% Optional arguments for compilation 
%
default.(['mex',matver]) = [default.luke_root,'Project_DKE/MEX/Bin/default/MATLAB',matver,'/'];%where compiled mex files are stored for this version of matlab
%
dkepath.default = default;
%
% paths for runs on IRFM saturne cluster
%
dkepath.hostname.saturne = 'saturne';
%
saturne.luke_root = [pwd,'/'];
saturne.local_root = '/home/sccp/gsem/decker/';
saturne.computer = 'GLNXA64';%machine type and supported OS
saturne.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
saturne.maxcompthreads = 'automatic';%For MatLab multithreading
%
saturne.mex75 = [saturne.luke_root,'Project_DKE/MEX/Bin/saturne/MATLAB75/'];
saturne.compiler_opt.copts = '';
saturne.compiler_opt.fopts.mex75 = ['FC=''',saturne.local_root,'bin/saturne/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
saturne.compiler_opt.helmex.mex75 = ['-L',saturne.local_root,'lib/saturne/g95 -lf95 -lgcc -L',saturne.local_root,'Packages/saturne/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
saturne.MUMPS.mex75 = [saturne.local_root,'Packages/saturne/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
saturne.MUMPS.par = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.7.2_P_mpichpgf/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
saturne.MUMPS.seq = ['/home/sccp/gsem/peysson/Packages/Bin/MUMPS/MUMPS_4.6.4_S_g95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
saturne.MUMPS.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
saturne.PETSc.par = ['/home/sccp/gsem/peysson/Packages/Bin/PETSC/petsc-2.3.2-p8_P_mpichpgf/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
saturne.PETSc.mpipath = ['/usr/local/pgi/linux86-64/6.0/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
saturne.SUPERLU.mex = ['/home/sccp/gsem/peysson/Packages/Bin/SUPERLU/SuperLU_3.0-pgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.saturne = saturne;
%
% paths for runs on IRFM cephee cluster
%
dkepath.hostname.cephee = 'cephee';
%
cephee.luke_root = [pwd,'/'];
cephee.local_root = '/home/sccp/gsem/decker/';
cephee.computer = 'GLNXA64';%machine type and supported OS
cephee.temppathroot = '/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
cephee.maxcompthreads = 2;%For MatLab multithreading
%
cephee.mex75 = [cephee.luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
%cephee.compiler_opt.copts = 'CC=''gcc'' CLIBS=''-Wl,-rpath-link,/applications/matlab_2007b/bin/glnxa64 -L/applications/matlab_2007b/bin/glnxa64 -lmx -lmex -lmat -lm''';
cephee.compiler_opt.copts = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
cephee.compiler_opt.fopts.mex75 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',cephee.local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
cephee.compiler_opt.helmex.mex75 = ['-L',cephee.local_root,'lib/cephee/g95 -lf95 -lgcc -L',cephee.local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
cephee.MUMPS.mex75 = [cephee.local_root,'Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.cephee = cephee;
%
% paths for runs on IRFM PC-LUKE workstation
%
dkepath.hostname.pcluke = 'PC-Luke';
%
pcluke.luke_root = [pwd,'/'];
pcluke.local_root = '/home/lukeuser/Work/';
pcluke.computer = 'GLNX86';%machine type and supported OS
pcluke.temppathroot = '/home/lukeuser/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
pcluke.mex72 = [pcluke.luke_root,'Project_DKE/MEX/Bin/pcluke/MATLAB72/'];
pcluke.compiler_opt.helmex = '';% Optional argument for helmex compilation 
%
pcluke.MUMPS.mex72 = [pcluke.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB72/'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.pcluke = pcluke;
%
% paths for runs on Yves Peysson's laptop
%
dkepath.hostname.laptopyves = 'peysson';%WARNING: for laptop, may change with connection status.
%
laptopyves.luke_root = [getenv('HOME'),'/CEA/Projets/LUKE/'];
laptopyves.local_root = [getenv('HOME'),'/CEA/Projets/'];
laptopyves.computer = 'MAC';%machine type and supported OS
laptopyves.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
laptopyves.mex75 = [laptopyves.luke_root,'Project_DKE/MEX/Bin/laptopyves/MATLAB75/'];
laptopyves.compiler_opt.helmex = 'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';% Optional argument for helmex compilation 
laptopyves.compiler_opt.fopts = 'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
%
laptopyves.MUMPS.par = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_P_openmpig95/dke'];%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
laptopyves.MUMPS.seq = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.2_S_GotoBlasg95/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
laptopyves.MUMPS.mex75 = [laptopyves.local_root,'Packages/Bin/MUMPS/MUMPS_4.8.1_S_GotoBlasg95/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
laptopyves.MUMPS.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
laptopyves.PETSc.par = [laptopyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_P_openmpig95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
laptopyves.PETSc.seq = [laptopyves.local_root,'Packages/Bin/PETSC/petsc-2.3.2-p10_S_g95/DKE'];%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
laptopyves.PETSc.mpipath = ['/usr/local/openmpig95/bin/'];%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
laptopyves.SUPERLU.mex = [laptopyves.local_root,'Packages/Bin/SUPERLU/SuperLU_3.0-GotoBlasgcc/MATLAB'];%Where SUPERLU matrix solver is stored (MEX function)
%
dkepath.laptopyves = laptopyves;
%
% paths for runs on ITM gateway
%
dkepath.hostname.efdaitm = 'efda-itm';%WARNING: for laptop, may change with connection status.
%
efdaitm.luke_root = [getenv('HOME'),'/LUKE/'];
efdaitm.local_root = ['/afs/efda-itm.eu/project/switm/'];
efdaitm.computer = 'GLNXA64';%machine type and supported OS
efdaitm.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
efdaitm.maxcompthreads = 'automatic';%For MatLab multithreading
%
efdaitm.speclibpath.xml_io_tools = [efdaitm.luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
%efdaitm.speclibpath.ual = [efdaitm.local_root,'ual/matlabinterface'];%Other machine specific libraries (UAL)
efdaitm.speclibpath.ual = ['/afs/efda-itm.eu/isip/user/buravand/public/matlab/v4.06d'];%Other machine specific libraries (UAL)
%TODO: Adresse temporairede Yves Buravand
%
efdaitm.mex76 = [efdaitm.luke_root,'Project_DKE/MEX/Bin/efdaitm/MATLAB76/'];
efdaitm.compiler_opt.copts = '';
efdaitm.compiler_opt.fopts.mex76 = ['-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
%efdaitm.compiler_opt.helmex.mex76 = 'FLIBS=''-L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas''';
efdaitm.compiler_opt.helmex.mex76 = ['-L/usr/bin/g95 -lf95 -lgcc ',efdaitm.local_root,'lapack/amd64_g95/lib/liblapack.so ',efdaitm.local_root,'blas/amd64_g95/lib/libblas.so ',efdaitm.local_root,'lapack/amd64_g95/lib/libtmglib.so '];% Optional argument for helmex compilation
efdaitm.compiler_opt.helmex.mex76 = 'FLIBS=''-L/usr/bin/g95 -lf95 -lgcc -Wl,-rpath-link,/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -L/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -lmx -lmex -lmat -lm -L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas -lguide -lpthread''';
efdaitm.compiler_opt.helmex.mex75 = NaN;
%
efdaitm.MUMPS.mex76 = [efdaitm.local_root,'mumps/MUMPS_4.7.3_SEQ/MATLAB/'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.efdaitm = efdaitm;
%
% paths for runs on Joan Decker's laptop
%
dkepath.hostname.laptopjoan = 'PC-DECKER-J';%WARNING: for laptop, may change with connection status.
%
laptopjoan.luke_root = [pwd,'/'];
laptopjoan.local_root = '/home/jd211098/Work/LUKE/';
laptopjoan.computer = 'GLNX86';%machine type and supported OS
laptopjoan.temppathroot = '/home/jd211098/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
laptopjoan.mex75 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB75'];
laptopjoan.mex77 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB77'];
laptopjoan.compiler_opt.helmex = '-lblas -llapack';% Optional argument for helmex compilation 
laptopjoan.compiler_opt.fopts = 'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
laptopjoan.compiler_opt.copts = '';
%
laptopjoan.MUMPS.mex75 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.MUMPS.mex77 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.laptopjoan = laptopjoan;
%
% paths for runs on Pramod Sharma's laptop
%
dkepath.hostname.laptoppramod = 'promod';%WARNING: for laptop, may change with connection status.
%
laptoppramod.luke_root = [getenv('HOME'),'/LUKE/'];
laptoppramod.local_root = [getenv('HOME'),'/'];
laptoppramod.computer = 'GLNX86';%machine type and supported OS
laptoppramod.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
laptoppramod.mex75 = [laptoppramod.luke_root,'Project_DKE/MEX/Bin/laptoppramod/MATLAB75/'];
laptoppramod.compiler_opt.helmex = '-v FC=''ifort'' FLIBS=''-Wl,-rpath-link,/home/promod/matlab75/bin/glnx86 -L/home/promod/matlab75/bin/glnx86 -lmx -lmex -lmat -lm -Wl,-rpath,/opt/intel/mkl/10.0.1.014/lib/32 -L/opt/intel/mkl/10.0.1.014/lib/32 -lmkl_lapack -lmkl -lguide -lpthread''';%
%
laptoppramod.MUMPS.mex75 = [laptoppramod.local_root,'Projet_Cronos/libs/MUMPS_4.7.3/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.laptoppramod = laptoppramod;
%
% paths for runs on SUN workstation at IPP-Prag
%
dkepath.hostname.sunipp = 'ipp';
%
sunipp.luke_root = [pwd,'/'];
sunipp.local_root = '/home/luke/';
sunipp.computer = 'GLNXA64';%machine type and supported OS
sunipp.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
sunipp.mex74 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB74'];
sunipp.mex75 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB75'];
sunipp.mex76 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB76'];
sunipp.mex77 = [sunipp.luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB77'];
sunipp.compiler_opt.copts = 'CC="gcc4"';
%sunipp.compiler_opt.fopts = 'FC="gfortran" FFLAGS="-v -largeArrayDims -fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
sunipp.compiler_opt.fopts = 'FC="/opt/g95/0.91_x86_64_32DI/bin/g95" FFLAGS="-v -largeArrayDims -fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
sunipp.compiler_opt.helmex = 'FLIBS=''-Wl,-rpath-link,/opt/matlab/r2008b/bin/glnxa64 -L/opt/matlab/r2008b/bin/glnxa64 -lmx -lmex -lmat -lm  -llapack -lblas -lguide -lpthread''';
%
sunipp.MUMPS.mex75 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
sunipp.MUMPS.mex76 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB76'];%Where MUMPS matrix solver is stored (MEX function)
sunipp.MUMPS.mex77 = [sunipp.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.sunipp = sunipp;
%
% paths for runs on workstation at IPR-Gandhinagar
%
dkepath.hostname.ipr = 'matlab2';
%
ipr.luke_root = [pwd,'/'];
ipr.local_root = '/home/yves/';
ipr.computer = 'GLNX86';%machine type and supported OS
ipr.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
ipr.mex76 = [ipr.luke_root,'Project_DKE/MEX/Bin/ipr/MATLAB76'];
%
ipr.MUMPS.seq = [ipr.local_root,'PACKAGES/Bin/MUMPS_4.7.3/dke'];
ipr.MUMPS.mex76 = [ipr.local_root,'PACKAGES/Bin/MUMPS_4.7.3/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
ipr.compiler_opt.helmex = '-L/home/yves/PACKAGES/Bin/lapack-3.2/ -llapack_LINUX -L/home/yves/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
dkepath.ipr = ipr;
%
% paths for runs on workstation at ASIPP-Heifei - node 0
%
dkepath.hostname.asipp0 = 'node0';
%
asipp0.luke_root = [pwd,'/'];
asipp0.local_root = '/home/bojiangding/';
asipp0.computer = 'GLNXA64';%machine type and supported OS
asipp0.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
asipp0.mex71 = [asipp0.luke_root,'Project_DKE/MEX/Bin/asipp/MATLAB71'];
%
asipp0.MUMPS.seq = [asipp0.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/dke'];
asipp0.MUMPS.mex71 = [asipp0.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
asipp0.compiler_opt.helmex = '-L/home/bojiangding/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
dkepath.asipp0 = asipp0;
%
% paths for runs on workstation at ASIPP-Heifei - node 1
%
dkepath.hostname.asipp1 = 'node1';
%
asipp1.luke_root = [pwd,'/'];
asipp1.local_root = '/home/bojiangding/';
asipp1.computer = 'GLNXA64';%machine type and supported OS
asipp1.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
asipp1.mex71 = [asipp1.luke_root,'Project_DKE/MEX/Bin/asipp/MATLAB71'];
%
asipp1.MUMPS.seq = [asipp1.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/dke'];
asipp1.MUMPS.mex71 = [asipp1.local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
asipp1.compiler_opt.helmex = '-L/home/bojiangding/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
dkepath.asipp1 = asipp1;
%
% paths for runs on CRPP PC 70
%
dkepath.hostname.crpppc70 = 'lac2';
%
crpppc70.luke_root = [pwd,'/'];
crpppc70.local_root = '/home/decker/NoTivoli/';
crpppc70.computer = 'GLNXA64';%machine type and supported OS
crpppc70.temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
crpppc70.mex76 = [crpppc70.luke_root,'Project_DKE/MEX/Bin/crpppc70/MATLAB76'];
crpppc70.compiler_opt.helmex = '-v -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas LDFLAGS="-fPIC -shared" -largeArrayDims';%  -ltmglib Optional argument for helmex compilation
%
crpppc70.MUMPS.mex76 = [crpppc70.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.6'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.crpppc70 = crpppc70;
%
% paths for runs on CRPP PC 51
%
dkepath.hostname.crpppc51 = 'lac3';
%
crpppc51.luke_root = [pwd,'/'];
crpppc51.local_root = '/home/decker/NoTivoli/';
crpppc51.computer = 'GLNXA64';%machine type and supported OS
crpppc51.temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
crpppc51.mex76 = [crpppc51.luke_root,'Project_DKE/MEX/Bin/crpppc51/MATLAB76'];
crpppc51.compiler_opt.helmex = '-v -L/home/decker/NoTivoli/Packages/Bin/lapack-3.2 -llapack -lblas LDFLAGS="-fPIC -shared" -largeArrayDims';%  -ltmglib Optional argument for helmex compilation
%
crpppc51.MUMPS.mex76 = [crpppc51.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_g95/MATLAB_7.6'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.crpppc51 = crpppc51;
%
%***************************************************************************************************
%
save([pwd,'/Project_DKE/Database/PATH_files/PATH_',dkepath.id,'.mat'],'dkepath');
%