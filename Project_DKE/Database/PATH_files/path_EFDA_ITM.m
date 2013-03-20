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
efdaitm.hostname = 'itm.rzg.mpg.de';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
efdaitm.machine = 'efdaitm';
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
efdaitm.yvesp(1).startup{1} = sprintf('%s\n','[lukeversion,matlabversion,matlabrelease] = LUKEversion_jd;');
%
%efdaitm.yvesp(1).speclibpath.xml_io_tools = [efdaitm.yvesp(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
efdaitm.yvesp(1).speclibpath.ual = getenv('UAL');%UAL path in the ITM gateway. See the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
efdaitm.yvesp(1).mex800 = [efdaitm.yvesp(1).luke_root,'Project_DKE/MEX/Bin/efda/MATLAB800/'];
efdaitm.yvesp(1).compiler_opt.copts = '';
%
%efdaitm.yvesp(1).MUMPS.mex800 = [efdaitm.yvesp(1).local_root,'mumps/MUMPS_4.7.3_SEQ/MATLAB2012b/'];%Where MUMPS matrix solver is stored (MEX function)
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
efdaitm.yvesp(1).remote(1) = remote_macpro_YVES_PEYSSON('condor','yves');
efdaitm.yvesp(1).remote(2) = remote_macpro_YVES_PEYSSON('xgrid','yves');
















