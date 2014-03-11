function dkepath = path_CEA_INTRA
%
% path definitions for CEA cluster CEPHEE
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'cephee','nunki','pleione','timdesktop'};
dkepath.hostname = {'cephee','nunki','pleione','cadts-0412'};
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
dkepath.JD211098(1).luke_root = [pwd,filesep];
%
% ---------------------------- cephee -------------------------------
%
dkepath.JD211098(1).cephee.local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.JD211098(1).cephee.temppathroot = '/local/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).cephee.mex705 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.JD211098(1).cephee.mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.JD211098(1).cephee.mex712 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
dkepath.JD211098(1).cephee.mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
%
dkepath.JD211098(1).cephee.compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
dkepath.JD211098(1).cephee.compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.JD211098(1).cephee.local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.JD211098(1).cephee.compiler_opt.helmex.mex705 = ['-L',dkepath.JD211098(1).cephee.local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.JD211098(1).cephee.local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).cephee.compiler_opt.copts.mex710 = '';
dkepath.JD211098(1).cephee.compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.JD211098(1).cephee.compiler_opt.helmex.mex710 = ['-L',dkepath.JD211098(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).cephee.compiler_opt.copts.mex712 = '';
dkepath.JD211098(1).cephee.compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.JD211098(1).cephee.compiler_opt.helmex.mex712 = ['-L',dkepath.JD211098(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).cephee.compiler_opt.copts.mex800 = '';
dkepath.JD211098(1).cephee.compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.JD211098(1).cephee.compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).cephee.local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.JD211098(1).cephee.compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).cephee.compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
dkepath.JD211098(1).cephee.MUMPS.mex705 = [dkepath.JD211098(1).cephee.local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.JD211098(1).cephee.MUMPS.mex710 = [dkepath.JD211098(1).cephee.local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
%dkepath.JD211098(1).cephee.MUMPS.mex710 = [dkepath.JD211098(1).cephee.local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.JD211098(1).cephee.MUMPS.mex710 = [dkepath.JD211098(1).cephee.local_root,'MUMPS_4.10.0/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.JD211098(1).cephee.MUMPS.mex712 = [dkepath.JD211098(1).cephee.local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.JD211098(1).cephee.MUMPS.mex712 = [dkepath.JD211098(1).cephee.local_root,'MUMPS_4.10.0/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.JD211098(1).cephee.MUMPS.mex800 = [dkepath.JD211098(1).cephee.local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.9.2 not compatible with matlab 7.5
%
dkepath.JD211098(1).cephee.graphviz.env = '/home/sccp/gsem/peysson/bin/';% Graphviz environment variable
dkepath.JD211098(1).cephee.latex.env = '';% Latex environment variable
dkepath.JD211098(1).cephee.imagemagick.env = '';% ImageMagick environment variable
%
dkepath.JD211098(1).cephee.configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.JD211098(1).cephee.configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
% ---------------------------- nunki -------------------------------
%
dkepath.JD211098(1).nunki.local_root = '/home/sccp/gsem/decker/Packages/nunki/';
dkepath.JD211098(1).nunki.temppathroot = '/home/sccp/gsem/decker/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).nunki.mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB710/'];
dkepath.JD211098(1).nunki.mex712 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB712/'];
dkepath.JD211098(1).nunki.mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB800/'];
%
dkepath.JD211098(1).nunki.compiler_opt.copts = '';
dkepath.JD211098(1).nunki.compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.JD211098(1).nunki.compiler_opt.fopts.mex712 = 'FC=''gfortran''';
dkepath.JD211098(1).nunki.compiler_opt.fopts.mex800 = '';
dkepath.JD211098(1).nunki.compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).nunki.compiler_opt.helmex.mex712 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).nunki.compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).nunki.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).nunki.MUMPS.mex710 = [dkepath.JD211098(1).nunki.local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).nunki.MUMPS.mex712 = [dkepath.JD211098(1).nunki.local_root,'MUMPS_4.10.0/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).nunki.MUMPS.mex800 = [dkepath.JD211098(1).nunki.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.JD211098(1).nunki.graphviz.env = '';% Graphviz environment variable
dkepath.JD211098(1).nunki.latex.env = '';% Latex environment variable
dkepath.JD211098(1).nunki.imagemagick.env = '';% ImageMagick environment variable
%
% ---------------------------- pleione -------------------------------
%
dkepath.JD211098(1).pleione = dkepath.JD211098(1).nunki;% both machines have identical configurations
%
% ---------------------------- timdesktop -------------------------------
%
dkepath.JD211098(1).timdesktop.local_root = '/home/joan/Packages/cadts-0412/';%'/home/sccp/gsem/decker/Packages/cadts-0412/';
dkepath.JD211098(1).timdesktop.temppathroot = '/home/joan/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).timdesktop.mex77 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB77'];
dkepath.JD211098(1).timdesktop.mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB710']; 
dkepath.JD211098(1).timdesktop.mex712 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB712']; 
dkepath.JD211098(1).timdesktop.mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB800']; 
%
dkepath.JD211098(1).timdesktop.compiler_opt.copts = '';
dkepath.JD211098(1).timdesktop.compiler_opt.fopts.mex77 = 'FC=''ifort''';
dkepath.JD211098(1).timdesktop.compiler_opt.fopts.mex710 = '';
dkepath.JD211098(1).timdesktop.compiler_opt.fopts.mex712 = '';
dkepath.JD211098(1).timdesktop.compiler_opt.fopts.mex800 = '';
dkepath.JD211098(1).timdesktop.compiler_opt.helmex.mex77 = NaN;% Optional argument for helmex compilation
dkepath.JD211098(1).timdesktop.compiler_opt.helmex.mex710 = NaN;% Optional argument for helmex compilation
dkepath.JD211098(1).timdesktop.compiler_opt.helmex.mex712 = ['-L',dkepath.JD211098(1).timdesktop.local_root,'lapack-3.4.2 -llapack -lrefblas'];% Optional argument for helmex compilation
dkepath.JD211098(1).timdesktop.compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).timdesktop.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).timdesktop.MUMPS.mex77 = '/home/joan/MUMPS_4.9.2/MATLAB77';%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).timdesktop.MUMPS.mex710 = [dkepath.JD211098(1).timdesktop.local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).timdesktop.MUMPS.mex712 = [dkepath.JD211098(1).timdesktop.local_root,'MUMPS_4.10.0/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).timdesktop.MUMPS.mex800 = [dkepath.JD211098(1).timdesktop.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.JD211098(1).timdesktop.graphviz.env = '';% Graphviz environment variable
dkepath.JD211098(1).timdesktop.latex.env = '';% Latex environment variable
dkepath.JD211098(1).timdesktop.imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.JD211098(1).remote(1).remoteid = 'CEA_CEPHEE';
dkepath.JD211098(1).remote(1).schedulername = 'pbs';
dkepath.JD211098(1).remote(1).profilename = 'joan';
dkepath.JD211098(1).remote(1).luke_root = dkepath.JD211098(1).luke_root;% local filesystem
%
dkepath.JD211098(1).remote(2).remoteid = 'CEA_TIMDESKTOP';
dkepath.JD211098(1).remote(2).schedulername = 'torque';
dkepath.JD211098(1).remote(2).profilename = 'joan';
dkepath.JD211098(1).remote(2).luke_root = dkepath.JD211098(1).luke_root;% local filesystem
%
dkepath.JD211098(1).remote(3).remoteid = 'CEA_PLEIONE';% pleione, merope, nashira, newpegase, nunki cluster
dkepath.JD211098(1).remote(3).schedulername = 'pbs';
dkepath.JD211098(1).remote(3).profilename = 'joan';
dkepath.JD211098(1).remote(3).luke_root = dkepath.JD211098(1).luke_root;% local filesystem
%
dkepath.JD211098(1).remote(4).remoteid = 'CEA_ANDROMEDE';
dkepath.JD211098(1).remote(4).schedulername = 'pbs';
dkepath.JD211098(1).remote(4).profilename = 'JD211098';
dkepath.JD211098(1).remote(4).luke_root = '/home/JD211098/LUKE/';
%
dkepath.JD211098(1).remote(5).remoteid = 'macpro_YVES_PEYSSON';
dkepath.JD211098(1).remote(5).schedulername = 'condor';
dkepath.JD211098(1).remote(5).profilename = 'joan';
dkepath.JD211098(1).remote(5).luke_root.LUKE_1_10_0 = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
dkepath.JD211098(1).remote(5).luke_root.LUKE_default = '/Users/yvespeysson/joandecker/Work/LUKE/';
%
dkepath.JD211098(1).remote(6) = dkepath.JD211098(1).remote(5);
dkepath.JD211098(1).remote(6).schedulername = 'xgrid';
%
dkepath.JD211098(1).remote(7) = dkepath.JD211098(1).remote(5);
dkepath.JD211098(1).remote(7).schedulername = 'direct';
%
dkepath.JD211098(1).remote(8).remoteid = 'ASIPP_SHENMA';
dkepath.JD211098(1).remote(8).schedulername = 'torque';
dkepath.JD211098(1).remote(8).profilename = 'joan';
dkepath.JD211098(1).remote(8).luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
dkepath.JD211098(1).remote(9).remoteid = 'CEA_SATURNE';
dkepath.JD211098(1).remote(9).schedulername = 'sun';
dkepath.JD211098(1).remote(9).profilename = 'joan';
dkepath.JD211098(1).remote(9).luke_root = dkepath.JD211098(1).remote(4).luke_root;% same FS as andromede
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.YP105119(1).luke_root = [pwd,filesep];
%
% ---------------------------- cephee -------------------------------
%
dkepath.YP105119(1).cephee.local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.YP105119(1).cephee.temppathroot = '/local/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).cephee.mex705 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.YP105119(1).cephee.mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.YP105119(1).cephee.mex712 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
dkepath.YP105119(1).cephee.mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
%
dkepath.YP105119(1).cephee.compiler_opt.copts.mex705 = ['-f',dkepath.YP105119(1).cephee.local_root,'MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh'];
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex705 = ['-f',dkepath.YP105119(1).cephee.local_root,'MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.YP105119(1).cephee.local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex705 = ['-L',dkepath.YP105119(1).cephee.local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.YP105119(1).cephee.local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).cephee.compiler_opt.copts.mex710 = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex710 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).cephee.compiler_opt.copts.mex712 = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex712 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).cephee.compiler_opt.copts.mex800 = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.YP105119(1).cephee.compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.YP105119(1).cephee.compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
dkepath.YP105119(1).cephee.MUMPS.mex705 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).cephee.MUMPS.mex710 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.YP105119(1).cephee.MUMPS.mex710 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
dkepath.YP105119(1).cephee.MUMPS.mex712 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.YP105119(1).cephee.MUMPS.mex800 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.10.0 not compatible with matlab 8.0
%
dkepath.YP105119(1).cephee.graphviz.env = '/home/sccp/gsem/peysson/bin/';% Graphviz environment variable
dkepath.YP105119(1).cephee.latex.env = '';% Latex environment variable
dkepath.YP105119(1).cephee.imagemagick.env = '';% ImageMagick environment variable
%
dkepath.YP105119(1).cephee.configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.YP105119(1).cephee.configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.YP105119(1).remote(1).remoteid = 'CEA_CEPHEE';
dkepath.YP105119(1).remote(1).schedulername = 'pbs';
dkepath.YP105119(1).remote(1).profilename = 'yves';
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;% local filesystem
%
dkepath.YP105119(1).remote(2).remoteid = 'CEA_ANDROMEDE';
dkepath.YP105119(1).remote(2).schedulername = 'pbs';
dkepath.YP105119(1).remote(2).profilename = 'YP105119';
dkepath.YP105119(1).remote(2).luke_root = '/home/YP105119/LUKE/';
%
dkepath.YP105119(1).remote(3).remoteid = 'macpro_YVES_PEYSSON';
dkepath.YP105119(1).remote(3).schedulername = 'condor';
dkepath.YP105119(1).remote(3).profilename = 'yves';
dkepath.YP105119(1).remote(3).luke_root = '/Users/yvespeysson/Projets/LUKE/';
%
dkepath.YP105119(1).remote(4) = dkepath.YP105119(1).remote(3);
dkepath.YP105119(1).remote(4).schedulername = 'xgrid';
%
dkepath.YP105119(1).remote(5) = dkepath.YP105119(1).remote(3);
dkepath.YP105119(1).remote(5).schedulername = 'direct';
%
dkepath.YP105119(1).remote(6).remoteid = 'ASIPP_SHENMA';
dkepath.YP105119(1).remote(6).schedulername = 'torque';
dkepath.YP105119(1).remote(6).profilename = 'yves';
dkepath.YP105119(1).remote(6).luke_root = '/home/PEYSSON/LUKE/';
%
dkepath.YP105119(1).remote(7).remoteid = 'EFDA_ITM';
dkepath.YP105119(1).remote(7).schedulername = 'sge';
dkepath.YP105119(1).remote(7).profilename = 'yvesp';
dkepath.YP105119(1).remote(7).luke_root = '/pfs/home/yvesp/public/LUKE_ITM/trunk/LUKE/';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Emelie Nilsson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.EN232106(1).luke_root = [pwd,filesep];
%
% ---------------------------- cephee -------------------------------
%
dkepath.EN232106(1).cephee = dkepath.JD211098(1).cephee;
dkepath.EN232106(1).temppathroot = '/home/sccp/gchf/EN290612/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.EN232106(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.EN232106(1).remote(1).schedulername = 'pbs';
dkepath.EN232106(1).remote(1).profilename = 'EN290612';
dkepath.EN232106(1).remote(1).luke_root = '/home/EN290612/LUKE/';
%
