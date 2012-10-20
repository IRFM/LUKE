function [laptopjoan] = path_laptop_JOAN_DECKER(luke_ref)
%
% path definitions for laptop of Joan Decker 
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
laptopjoan.hostname = 'CADTS-0096';%WARNING: for laptop, may change with connection status.
laptopjoan.machine = 'laptopjoan';
laptopjoan.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
laptopjoan.path_profile = 1;
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
laptopjoan.joan(1).luke_root = [pwd,'/'];
laptopjoan.joan(1).local_root = '/opt/';
laptopjoan.joan(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% laptopjoan.joan(1).mex75 = [laptopjoan.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB75'];
% laptopjoan.joan(1).mex77 = [laptopjoan.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB77'];
% laptopjoan.joan(1).mex78 = [laptopjoan.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB78'];
laptopjoan.joan(1).mex710 = [laptopjoan.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB710']; 
laptopjoan.joan(1).mex711 = [laptopjoan.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB711']; 
laptopjoan.joan(1).mex712 = [laptopjoan.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB712']; 
%
% this version compiles but helmex still seems to use libc.so.6 instead of
% libgcc... to continue
%
%laptopjoan.joan(1).compiler_opt.helmex = '-largeArrayDims FLIBS=''-L/home/joan/lib/g95 -lf95 -lgcc -Wl,-rpath-link,/opt/R2010A/bin/glnxa64 -L/opt/R2010A/bin/glnxa64 -lmx -lmex -lmat -lm -lblas -llapack''';
%
% this version compiles but only separatrice works
%
%laptopjoan.joan(1).compiler_opt.helmex = '-lblas -llapack -largeArrayDims';%'-largeArrayDims';% Optional argument for helmex compilation 
%
% for separatrice, the code compiles with the new version of the file and
% no option (32 bits)
%
%FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer''  
%
% in fedora, g95 installed but helmex did not work... try again with kubuntu?
%
laptopjoan.joan(1).compiler_opt.helmex = NaN;%'-v -L/home/joan/lib -llapack_g95_32 -lblas_g95_32';%'-v -largeArrayDims -llapack -lblas -lgfortran FC=''gfortran'' FFLAGS=''-fexceptions -fPIC -fbackslash''';%  
laptopjoan.joan(1).compiler_opt.fopts = '-v FC="gfortran"';%'';%'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
laptopjoan.joan(1).compiler_opt.copts = '';
%
% laptopjoan.joan(1).MUMPS.mex75 = [laptopjoan.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
% laptopjoan.joan(1).MUMPS.mex77 = [laptopjoan.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
% laptopjoan.joan(1).MUMPS.mex78 = [laptopjoan.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB78'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.joan(1).MUMPS.mex710 = [laptopjoan.joan(1).local_root,'MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.joan(1).MUMPS.mex711 = [laptopjoan.joan(1).local_root,'MUMPS_4.9.2/MATLAB711'];%Where MUMPS matrix solver is stored (MEX function)
laptopjoan.joan(1).MUMPS.mex712 = [laptopjoan.joan(1).local_root,'MUMPS_4.9.2/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
%
% macproyves (condor)
%
laptopjoan.joan(1).remote(1).host = 'tolbachik.hd.free.fr';
laptopjoan.joan(1).remote(1).cmd = 'condor_submit';
laptopjoan.joan(1).remote(1).get_jobid = {'** Proc ',':'};
laptopjoan.joan(1).remote(1).set_jobid = {'condor_q ',''};
%
laptopjoan.joan(1).remote(1).env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
laptopjoan.joan(1).remote(1).env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
laptopjoan.joan(1).remote(1).matlabroot.mat712 = '/Applications/MATLAB_R2012a.app/bin/';
laptopjoan.joan(1).remote(1).matlabroot.default = laptopjoan.joan(1).remote(1).matlabroot.mat712;
laptopjoan.joan(1).remote(1).luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
%
laptopjoan.joan(1).remote(1).yves = 'yvespeysson';
laptopjoan.joan(1).remote(1).joan = 'yvespeysson';%'joandecker';
laptopjoan.joan(1).remote(1).JD211098 = 'yvespeysson';%'joandecker';
%
return
%
laptopjoan.joan(1).remote(2).host = 'cephee15.intra.cea.fr';
laptopjoan.joan(1).remote(2).nproc = 28;
laptopjoan.joan(1).remote(2).luke_root = ['/home/sccp/gsem/decker/LUKE/'];
laptopjoan.joan(1).remote(2).matlabroot = '';
laptopjoan.joan(1).remote(2).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
laptopjoan.joan(1).remote(2).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
laptopjoan.joan(1).remote(2).get_jobid = {'','.cephee'};%str_before,str_after
laptopjoan.joan(1).remote(2).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
laptopjoan.joan(1).remote(2).joan = 'JD211098';
%
laptopjoan.joan(1).remote(3).host = 'pleiades2.epfl.ch';
laptopjoan.joan(1).remote(3).nproc = 48;
laptopjoan.joan(1).remote(3).luke_root = ['/home/jdecker/LUKE/'];
laptopjoan.joan(1).remote(3).matlabroot = '';
laptopjoan.joan(1).remote(3).cmd = 'qsub -l walltime=1:59:00 -l nodes=1:ppn=1';
laptopjoan.joan(1).remote(3).get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
laptopjoan.joan(1).remote(3).set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
laptopjoan.joan(1).remote(3).joan = 'jdecker';
%
% macproyves (Xgrid)
%
USER = 'joandecker';
HOST = 'macproyves';
HOME = '/Users/joandecker';
APPLICATIONS = 'MATLAB_R2011b';
NPROC = 12;
%
laptopjoan.joan(1).remote(4).host = {HOST,laptopjoan.hostname};
laptopjoan.joan(1).remote(4).nproc = NPROC;
laptopjoan.joan(1).remote(4).luke_root = [HOME,'/Travail/Projets/',luke_ref,'/'];
laptopjoan.joan(1).remote(4).matlabroot = ['/Applications/',APPLICATIONS,'.app/bin/'];
laptopjoan.joan(1).remote(4).prefdir = [HOME,'/.matlab/',APPLICATIONS(strfind(APPLICATIONS,'MATLAB')+7:strfind(APPLICATIONS,'MATLAB')+12)];
laptopjoan.joan(1).remote(4).cmd = {'xgrid -h ',' -p ',' -job batch ','xgrid_batch_matlab_'};%
laptopjoan.joan(1).remote(4).mem = [];
laptopjoan.joan(1).remote(4).get_jobid = {'jobIdentifier = ',';'};%
laptopjoan.joan(1).remote(4).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
laptopjoan.joan(1).remote(4).password = {'chatel00'};
laptopjoan.joan(1).remote(4).(getenv('USER')) = USER;
%
laptopjoan.joan(1).remote(5).host = 'saturne1.partenaires.cea.fr';
laptopjoan.joan(1).remote(5).nproc = 12;
laptopjoan.joan(1).remote(5).luke_root = ['/home/JD211098/LUKE/'];
laptopjoan.joan(1).remote(5).matlabroot = '';
laptopjoan.joan(1).remote(5).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
laptopjoan.joan(1).remote(5).get_jobid = {'Your job ',' '};%str_before,str_after
laptopjoan.joan(1).remote(5).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
laptopjoan.joan(1).remote(5).joan = 'JD211098';
