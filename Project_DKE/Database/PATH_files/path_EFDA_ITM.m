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
[dummy,hostname] = unix('hostname -f');hostname = hostname(1:end-1);%remove extra term
%
efdaitm.hostname = 'itm.rzg.mpg.de';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
efdaitm.machine = 'itm';
efdaitm.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
efdaitm.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
efdaitm.yvesp(1).luke_root = '/pfs/home/yvesp/LUKE_ITM/trunk/LUKE/';
efdaitm.yvesp(1).local_root = ['/pfs/home/yvesp/'];
efdaitm.yvesp(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
ual_path = '/afs/ipp/itm/switm/ual/4.09a.1_R1.0';%UAL path in the ITM gateway. (4.10a.3_R1.0). See the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
efdaitm.yvesp(1).startup{1} = sprintf('%s\n','[lukeversion,matlabversion,matlabrelease] = LUKEversion_jd;');
efdaitm.yvesp(1).startup{2} = sprintf('%s\n',['	javaaddpath ',ual_path,'/jar/ualjava.jar']);%add UAL access to classpath, UAL release 4.09a.1_R1.0
efdaitm.yvesp(1).startup{3} = sprintf('%s\n','	import ualmemory.javainterface.*;%import Java packages');
%
%efdaitm.yvesp(1).cshrc{1} = sprintf('%s\n','#matlab version aliases');
%efdaitm.yvesp(1).cshrc{2} = sprintf('%s\n','alias mat800 ''matlab -nodesktop''');
%efdaitm.yvesp(1).cshrc{4} = sprintf('%s\n','#sourcing the correct UAL version (4.09a, 4.10a, etc). Patch for Matlab R2012b (13/03/2013). See TWIKI pages for details.');
%efdaitm.yvesp(1).cshrc{5} = sprintf('%s\n',['source ',getenv('ITMSCRIPTDIR'),'/ITMv1 kepler test 4.09a.1_R1_DEVMATLAB']);%UAL release 4.09a.1_R1.0
%efdaitm.yvesp(1).cshrc{5} = sprintf('%s\n',['source ',getenv('ITMSCRIPTDIR'),'/ITMv1 kepler test 4.10a.3_R1_DEVMATLAB']);%UAL release 4.10a.3_R1.0
%
efdaitm.yvesp(1).speclibpath.xml_io_tools = [efdaitm.yvesp(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
efdaitm.yvesp(1).speclibpath.ual = ual_path;%Other machine specific libraries -> UAL for ITM: see the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
efdaitm.yvesp(1).mex706 = [efdaitm.yvesp(1).luke_root,'Project_DKE/MEX/Bin/efda/MATLAB706/'];
efdaitm.yvesp(1).compiler_opt.copts = '';
%efdaitm.yvesp(1).compiler_opt.fopts.mex706 = ['-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
%%efdaitm.yvesp(1).compiler_opt.helmex.mex706 = 'FLIBS=''-L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas''';
%efdaitm.yvesp(1).compiler_opt.helmex.mex706 = ['-L/usr/bin/g95 -lf95 -lgcc ',efdaitm.yvesp(1).local_root,'lapack/amd64_g95/lib/liblapack.so ',efdaitm.yvesp(1).local_root,'blas/amd64_g95/lib/libblas.so ',efdaitm.yvesp(1).local_root,'lapack/amd64_g95/lib/libtmglib.so '];% Optional argument for helmex compilation
%efdaitm.yvesp(1).compiler_opt.helmex.mex706 = 'FLIBS=''-L/usr/bin/g95 -lf95 -lgcc -Wl,-rpath-link,/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -L/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -lmx -lmex -lmat -lm -L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas -lguide -lpthread''';
%
efdaitm.yvesp(1).MUMPS.mex706 = [efdaitm.yvesp(1).local_root,'mumps/MUMPS_4.7.3_SEQ/MATLAB2008a/'];%Where MUMPS matrix solver is stored (MEX function)
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
% macproyves (condor)
%
macbookyves.yves(1).remote(3).host = 'tolbachik.hd.free.fr';
macbookyves.yves(1).remote(3).cmd = 'condor_submit';
macbookyves.yves(1).remote(3).get_jobid = {'** Proc ',':'};
macbookyves.yves(1).remote(3).set_jobid = {'condor_q ',''};
%
macbookyves.yves(1).remote(3).env.CONDOR_CONFIG = '/usr/local/condor/etc/condor_config';
macbookyves.yves(1).remote(3).env.PATH = '/usr/local/condor/sbin:/usr/local/condor/bin:${PATH}';
macbookyves.yves(1).remote(3).remotedatapath = '/Users/yvespeysson/condor/';
macbookyves.yves(1).remote(3).luke_root = ['/Users/yvespeysson/Projets/',luke_ref,'/'];
%
%macbookyves.yves(1).remote(3).mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
%macbookyves.yves(1).remote(3).mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
%macbookyves.yves(1).remote(3).matdef = macbookyves.yves(1).remote(3).mat714;%default matlab on remote machine
%
macbookyves.yves(1).remote(3).mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
macbookyves.yves(1).remote(3).mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
macbookyves.yves(1).remote(3).matdef = macbookyves.yves(1).remote(3).mat800;%default matlab on remote machine
%
macbookyves.yves(1).remote(3).yves = 'yvespeysson';
macbookyves.yves(1).remote(3).joan = 'yvespeysson';
macbookyves.yves(1).remote(3).JD211098 = 'yvespeysson';
%
% macproyves (xgrid)
%
macbookyves.yves(1).remote(4).host = 'tolbachik.hd.free.fr';
macbookyves.yves(1).remote(4).cmd = {'xgrid -h ',' -p ',' -job batch '};%
macbookyves.yves(1).remote(4).get_jobid = {'jobIdentifier = ',';'};%
macbookyves.yves(1).remote(4).set_jobid = {'xgrid -h ',' -job attributes -id ','jobStatus = Running','jobStatus = Pending','jobStatus = Finished',' -job results -id ',' -se ',' -so ',' -out ',' -job delete -id '};%
macbookyves.yves(1).remote(4).remotedatapath = '/Users/yvespeysson/xgrid/';
macbookyves.yves(1).remote(4).luke_root = ['/Users/yvespeysson/Projets/',luke_ref,'/'];
%
%macbookyves.yves(1).remote(4).mat714.root = '/Applications/MATLAB_R2012a.app/bin/';
%macbookyves.yves(1).remote(4).mat714.prefdir = '/Users/yvespeysson/.matlab/R2012a';
%macbookyves.yves(1).remote(4).matdef = macbookyves.yves(1).remote(4).mat714;%default matlab on remote machine
%
macbookyves.yves(1).remote(3).mat800.root = '/Applications/MATLAB_R2012b.app/bin/';
macbookyves.yves(1).remote(3).mat800.prefdir = '/Users/yvespeysson/.matlab/R2012b';
macbookyves.yves(1).remote(3).matdef = macbookyves.yves(1).remote(3).mat800;%default matlab on remote machine
%
macbookyves.yves(1).remote(4).password = {'ghm93'};
macbookyves.yves(1).remote(4).yves = 'yvespeysson';
macbookyves.yves(1).remote(4).joan = 'yvespeysson';
%
















