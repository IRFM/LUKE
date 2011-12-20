%
% paths for runs on Joan Decker's laptop
%
dkepath.hostname.laptopjoan = 'CADTS-0096';%WARNING: for laptop, may change with connection status.
%
laptopjoan.luke_root = [pwd,'/'];
laptopjoan.local_root = '/opt/';
laptopjoan.computer = 'GLNXA64';%machine type and supported OS
laptopjoan.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% laptopjoan.mex75 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB75'];
% laptopjoan.mex77 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB77'];
% laptopjoan.mex78 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB78'];
laptopjoan.mex710 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB710']; 
laptopjoan.mex711 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB711']; 
laptopjoan.mex712 = [laptopjoan.luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB712']; 
%
% this version compiles but helmex still seems to use libc.so.6 instead of
% libgcc... to continue
%
%laptopjoan.compiler_opt.helmex = '-largeArrayDims FLIBS=''-L/home/joan/lib/g95 -lf95 -lgcc -Wl,-rpath-link,/opt/R2010A/bin/glnxa64 -L/opt/R2010A/bin/glnxa64 -lmx -lmex -lmat -lm -lblas -llapack''';
%
% this version compiles but only separatrice works
%
%laptopjoan.compiler_opt.helmex = '-lblas -llapack -largeArrayDims';%'-largeArrayDims';% Optional argument for helmex compilation 
%
% for separatrice, the code compiles with the new version of the file and
% no option (32 bits)
%
%FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer''  
%
% in fedora, g95 installed but helmex did not work... try again with kubuntu?
%
laptopjoan.compiler_opt.helmex = NaN;%'-v -L/home/joan/lib -llapack_g95_32 -lblas_g95_32';%'-v -largeArrayDims -llapack -lblas -lgfortran FC=''gfortran'' FFLAGS=''-fexceptions -fPIC -fbackslash''';%  
laptopjoan.compiler_opt.fopts = '-v FC="gfortran"';%'';%'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
laptopjoan.compiler_opt.copts = '';
%
% laptopjoan.MUMPS.mex75 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
% laptopjoan.MUMPS.mex77 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
% laptopjoan.MUMPS.mex78 = [laptopjoan.local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB78'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.MUMPS.mex710 = [laptopjoan.local_root,'MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.MUMPS.mex711 = [laptopjoan.local_root,'MUMPS_4.9.2/MATLAB711'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.MUMPS.mex712 = [laptopjoan.local_root,'MUMPS_4.9.2/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
%
laptopjoan.remote(1).host = 'cephee15.intra.cea.fr';
laptopjoan.remote(1).nproc = 28;
laptopjoan.remote(1).luke_root = ['/home/sccp/gsem/decker/LUKE',CVSbranch,'/'];
laptopjoan.remote(1).matlabroot = '';
laptopjoan.remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
laptopjoan.remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
laptopjoan.remote(1).get_jobid = {'','.cephee'};%str_before,str_after
laptopjoan.remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
laptopjoan.remote(1).joan = 'JD211098';
%
laptopjoan.remote(2).host = 'saturne1.partenaires.cea.fr';
laptopjoan.remote(2).nproc = 12;
laptopjoan.remote(2).luke_root = ['/home/JD211098/LUKE',CVSbranch,'/'];
laptopjoan.remote(2).matlabroot = '';
laptopjoan.remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
laptopjoan.remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
laptopjoan.remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
laptopjoan.remote(2).joan = 'JD211098';
%
laptopjoan.remote(3).host = 'pleiades2.epfl.ch';
laptopjoan.remote(3).nproc = 48;
laptopjoan.remote(3).luke_root = ['/home/jdecker/LUKE',CVSbranch,'/'];
laptopjoan.remote(3).matlabroot = '';
laptopjoan.remote(3).cmd = 'qsub -l walltime=1:59:00 -l nodes=1:ppn=1';
laptopjoan.remote(3).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
laptopjoan.remote(3).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
laptopjoan.remote(3).joan = 'jdecker';
%
laptopjoan.remote(4).host = {'macproyves','82.227.179.204'};% or empty for local host
laptopjoan.remote(4).nproc = 12;
laptopjoan.remote(4).luke_root = ['/Users/joandecker/Travail/Projets/LUKE',CVSbranch,'/'];
laptopjoan.remote(4).matlabroot = '/Applications/MATLAB_R2011a.app/bin/';
laptopjoan.remote(4).cmd = {'xgrid -h ',' -job batch ','xgrid_batch_matlab_'};%
laptopjoan.remote(4).mem = [];
laptopjoan.remote(4).get_jobid = {'jobIdentifier = ',';'};%
laptopjoan.remote(4).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
laptopjoan.remote(4).joan = 'joandecker';% Faire getenv('USER') pour savoir qui je suis !!!!
%
dkepath.laptopjoan = laptopjoan;