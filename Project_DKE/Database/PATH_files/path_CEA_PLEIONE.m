function [pleione] = path_CEA_PLEIONE(luke_ref)
%
% path definitions for CEA PLEIONE workstation
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
[~,matlabversion,matlabrelease] = LUKEversion_jd;
%
[~,hostname] = unix('hostname');hostname = hostname(1:end-1);%remove extra term
%
pleione.hostname = 'pleione.intra.cea.fr';
pleione.machine = 'pleione';
pleione.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(pathref).xxx)
%
pleione.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
pleione.YP105119(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
pleione.YP105119(1).local_root = '/home/sccp/gsem/decker/Packages/pleione/';
pleione.YP105119(1).computer = 'GLNXA64';%machine type and supported OS
pleione.YP105119(1).temppathroot = '/home/sccp/gsem/decker/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
pleione.YP105119(1).maxcompthreads = 'automatic';%For MatLab multithreading
%
pleione.YP105119(1).mex707 = [pleione.YP105119(1).luke_root,'Project_DKE/MEX/Bin/pleione/MATLAB77/'];
pleione.YP105119(1).mex710 = [pleione.YP105119(1).luke_root,'Project_DKE/MEX/Bin/pleione/MATLAB710/'];
pleione.YP105119(1).compiler_opt.copts = '';
pleione.YP105119(1).compiler_opt.fopts.mex707 = ['FC=''/home/sccp/gsem/decker/pleione/bin/g95'' '];% FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''
pleione.YP105119(1).compiler_opt.helmex.mex707 = ['-largeArrayDims -L/home/sccp/gsem/decker/pleione/lib -lf95 -lgcc -llapack -lblas'];%  -ltmglib Optional argument for helmex compilation
pleione.YP105119(1).compiler_opt.fopts.mex710 = ['FC=''/home/sccp/gsem/decker/pleione/bin/g95'' '];% FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''
pleione.YP105119(1).compiler_opt.helmex.mex710 = ['-largeArrayDims -L/home/sccp/gsem/decker/pleione/lib -lf95 -lgcc -llapack -lblas'];%  -ltmglib Optional argument for helmex compilation
%
pleione.YP105119(1).MUMPS.mex707 = ['/home/sccp/gsem/decker/pleione/src/MUMPS_4.7.3/MATLAB_7.7'];%Where MUMPS matrix solver is stored (MEX function)
pleione.YP105119(1).MUMPS.mex710 = [pleione.YP105119(1).local_root,'MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
%
pleione.YP105119(1).remote(1).host = 'cephee15.intra.cea.fr';
pleione.YP105119(1).remote(1).nproc = 28;
pleione.YP105119(1).remote(1).luke_root = ['/home/sccp/gsem/decker/LUKE/'];
pleione.YP105119(1).remote(1).matlabroot = '';
pleione.YP105119(1).remote(1).cmd = 'qsub -l inter=false,ncpus=2';% -l walltime=1:59:00 -l nodes=1:ppn=1
pleione.YP105119(1).remote(1).mem = {',mem=','mb','7000','14000'};% -l select=1:inter=false:ncpus=1:mem=4000mb
pleione.YP105119(1).remote(1).get_jobid = {'','.cephee'};%str_before,str_after
pleione.YP105119(1).remote(1).set_jobid = {'qstat ','.cephee','Unknown Job Id'};%str_before,str_after,str_check
pleione.YP105119(1).remote(1).YP105119 = 'YP105119';
%
pleione.YP105119(1).remote(2).host = 'saturne2.partenaires.cea.fr';
pleione.YP105119(1).remote(2).nproc = 12;
pleione.YP105119(1).remote(2).luke_root = ['/home/JD211098/LUKE/'];
pleione.YP105119(1).remote(1).matlabroot = '';
pleione.YP105119(1).remote(2).cmd = 'qsub -q batch.q';% -l walltime=1:59:00 -l nodes=1:ppn=1
pleione.YP105119(1).remote(2).get_jobid = {'Your job ',' '};%str_before,str_after
pleione.YP105119(1).remote(2).set_jobid = {'qstat -j ','','Following jobs do not exist'};%str_before,str_after,str_check
pleione.YP105119(1).remote(2).YP105119 = 'YP105119';