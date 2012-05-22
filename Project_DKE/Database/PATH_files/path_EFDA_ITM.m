function [efdaitm] = path_EFDA_ITM(luke_ref)
%
% path definitions for EFDA ITM cluster
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
[dummy,hostname] = unix('hostname');hostname = hostname(1:end-1);%remove extra term
%
efdaitm.hostname = 'efda-itm.eu';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
efdaitm.machine = 'efda';
efdaitm.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
efdaitm.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
efdaitm.peysson(1).luke_root = [getenv('HOME'),'/LUKE_ITM/trunk/'];
efdaitm.peysson(1).local_root = ['/afs/efda-itm.eu/project/switm/'];
efdaitm.peysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
efdaitm.peysson(1).speclibpath.xml_io_tools = [efdaitm.peysson(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
efdaitm.peysson(1).speclibpath.ual = getenv('UAL');%Other machine specific libraries (UAL for ITM: see the .cshrc file on the gateway to have the correct UAL version)
%
efdaitm.peysson(1).mex706 = [efdaitm.peysson(1).luke_root,'Project_DKE/MEX/Bin/efda/MATLAB706/'];
efdaitm.peysson(1).mex713 = [efdaitm.peysson(1).luke_root,'Project_DKE/MEX/Bin/efda/MATLAB713/'];
efdaitm.peysson(1).compiler_opt.copts = '';
efdaitm.peysson(1).compiler_opt.fopts.mex706 = ['-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
%efdaitm.peysson(1).compiler_opt.helmex.mex706 = 'FLIBS=''-L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas''';
efdaitm.peysson(1).compiler_opt.helmex.mex706 = ['-L/usr/bin/g95 -lf95 -lgcc ',efdaitm.peysson(1).local_root,'lapack/amd64_g95/lib/liblapack.so ',efdaitm.peysson(1).local_root,'blas/amd64_g95/lib/libblas.so ',efdaitm.peysson(1).local_root,'lapack/amd64_g95/lib/libtmglib.so '];% Optional argument for helmex compilation
efdaitm.peysson(1).compiler_opt.helmex.mex706 = 'FLIBS=''-L/usr/bin/g95 -lf95 -lgcc -Wl,-rpath-link,/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -L/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -lmx -lmex -lmat -lm -L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas -lguide -lpthread''';
%
efdaitm.peysson(1).MUMPS.mex706 = [efdaitm.peysson(1).local_root,'mumps/MUMPS_4.7.3_SEQ/MATLAB2008b/'];%Where MUMPS matrix solver is stored (MEX function) (Warning, it is for Matlab R2008a, but the directory has a wrong name !)
efdaitm.peysson(1).MUMPS.mex713 = [efdaitm.peysson(1).local_root,'mumps/MUMPS_4.7.3_SEQ/MATLAB2011b/'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Distributed computing -----------------------------
%
%
%--------------------------- Remote computing -----------------------------
%
% MACPRO yves
%
% WARNING about Xgrid scheduler for mac OSX (> 10.5.x)
% Xgrid runs tasks using the "sandbox" facility. Tasks running as 'nobody' ie, 
% any task where either the submitting client or the receiving agent 
% are NOT using Kerberos authentication) have very restricted access to the
% filesystem. To by-pass this strong protection (no password) on a local
% cluster or a multi-core multi-processor machine, go to
% /usr/share/sandbox/xgridagentd_task_nobody.sb file (root rights needed)
% then, comment the following line (with a ';' at the beginning of the line):
% (allow process* sysctl* mach* network* system-socket)
% and replace it by
% (allow process* sysctl* mach* file-read* file-write* network* system-socket)
% omment the following lines (with a ';' at the beginning of the line):
% (allow file-read* (regex "^/(bin|dev|(private/)?(etc|tmp|var)|usr|System|Library)(/|$)"))
% (allow file-read* file-write* (regex "^/(private/)?(tmp|var)(/|$)"))
% and replace it by
% (allow file-read* file-write* (regex "^/all(/|$)"))
%
% NOTE that it should be done each time the system is updated.
% furthermore, all *.m and *.mex* files must be read by anybody.
% This lack of protection make the cluster more vulnerable to an external
% attack, but on a personal computer, this risk is limited.
%
% Furthermore, on the remote session, before any calculation, it is
% necessary to create a folder named 'xgrid' (~/xgrid)
% that will contain all the files for the remote calculations. The owner is the
% USER , and the group is 'nobody(-2)'. The rights are 777. It is also
% necessary to done it the same for the Matlab_R20xx_y application (all the
% package and inside) in such a way Matlab can write in the ~/xgrid folder.
%
% The IP address of the hostname must be given in the file /etc/hosts
%
% WARNING: most of the problems come from the SSH without login
% authentication, rights of the target directory and Matlab !
%
%
USER = 'yvespeysson';
CLUSTER = 'macproyves';
HOST = 'tolbachik.hd.free.fr';%
HOME = '/Users/yvespeysson';
APPLICATIONS = 'MATLAB_R2012a';
NPROC = 6;
%
efdaitm.peysson(1).remote(1).host = {HOST,efdaitm.hostname};
efdaitm.peysson(1).remote(1).cluster = CLUSTER;
efdaitm.peysson(1).remote(1).nproc = NPROC;
efdaitm.peysson(1).remote(1).luke_root = [HOME,'/Travail/Projets/LUKE/'];
efdaitm.peysson(1).remote(1).matlabroot = ['/Applications/',APPLICATIONS,'.app/bin/'];
efdaitm.peysson(1).remote(1).prefdir = [HOME,'/.matlab/',APPLICATIONS(strfind(APPLICATIONS,'MATLAB')+7:strfind(APPLICATIONS,'MATLAB')+12)];
efdaitm.peysson(1).remote(1).cmd = {'xgrid -h ',' -p ',' -job batch ','xgrid_batch_matlab_'};%
efdaitm.peysson(1).remote(1).mem = [];
efdaitm.peysson(1).remote(1).get_jobid = {'jobIdentifier = ',';'};%
efdaitm.peysson(1).remote(1).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
efdaitm.peysson(1).remote(1).password = {'ghm93'};
efdaitm.peysson(1).remote(1).(getenv('USER')) = USER;
%
