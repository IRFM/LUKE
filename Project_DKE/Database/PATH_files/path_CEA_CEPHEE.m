function dkepath = path_CEA_CEPHEE
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
dkepath.hostname = 'cephee';
dkepath.machine = 'cephee';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.YP105119(1).luke_root = [pwd,filesep];
dkepath.YP105119(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.YP105119(1).temppathroot = '/local/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).mex705 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.YP105119(1).mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.YP105119(1).mex712 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
dkepath.YP105119(1).mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
%
dkepath.YP105119(1).compiler_opt.copts.mex705 = ['-f',dkepath.YP105119(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh'];
dkepath.YP105119(1).compiler_opt.fopts.mex705 = ['-f',dkepath.YP105119(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.YP105119(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.YP105119(1).compiler_opt.helmex.mex705 = ['-L',dkepath.YP105119(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.YP105119(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).compiler_opt.copts.mex710 = '';
dkepath.YP105119(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.YP105119(1).compiler_opt.helmex.mex710 = ['-L',dkepath.YP105119(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).compiler_opt.copts.mex712 = '';
dkepath.YP105119(1).compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.YP105119(1).compiler_opt.helmex.mex712 = ['-L',dkepath.YP105119(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).compiler_opt.copts.mex800 = '';
dkepath.YP105119(1).compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.YP105119(1).compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.YP105119(1).compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).MUMPS.mex705 = [dkepath.YP105119(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).MUMPS.mex710 = [dkepath.YP105119(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.YP105119(1).MUMPS.mex710 = [dkepath.YP105119(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
dkepath.YP105119(1).MUMPS.mex712 = [dkepath.YP105119(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.YP105119(1).MUMPS.mex800 = [dkepath.YP105119(1).local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.10.0 not compatible with matlab 8.0
%
% LUKE documentation
%
dkepath.YP105119(1).graphviz.env = '/home/sccp/gsem/peysson/bin/';% Graphviz environment variable
dkepath.YP105119(1).latex.env = '';% Latex environment variable
dkepath.YP105119(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Distributed computing -----------------------------
%
dkepath.YP105119(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.YP105119(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
% local (pbs)
%
dkepath.YP105119(1).remote(1) = remote_CEA_CEPHEE('pbs','yves');
dkepath.YP105119(1).remote(1).host = '';% empty for local host
dkepath.YP105119(1).remote(1).env.luke_root = dkepath.YP105119(1).luke_root;
%
%
% macproyves (condor)
%
dkepath.YP105119(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','yves');
dkepath.YP105119(1).remote(2).env.luke_root = '/Users/yvespeysson/Projets/LUKE/';
dkepath.YP105119(1).remote(2).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(2).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(2).env.luke_root];%CVS command
%
% macproyves (xgrid)
%
dkepath.YP105119(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','yves');
dkepath.YP105119(1).remote(3).env.luke_root = dkepath.YP105119(1).remote(2).env.luke_root;
dkepath.YP105119(1).remote(3).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(3).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(3).env.luke_root];%CVS command
%
% shenma (torque)
%
dkepath.YP105119(1).remote(4) = remote_ASIPP_SHENMA('torque','yves');
dkepath.YP105119(1).remote(4).env.luke_root = '/home/PEYSSON/LUKE/';
dkepath.YP105119(1).remote(4).cvs.CVSROOT = ':pserver:YP105119:Peys#4Yv@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(4).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(4).env.luke_root];%CVS command
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
dkepath.JD211098(1).luke_root = [pwd,filesep];
dkepath.JD211098(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.JD211098(1).temppathroot = '/local/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex705 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.JD211098(1).mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.JD211098(1).mex712 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
dkepath.JD211098(1).mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
%
dkepath.JD211098(1).compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
dkepath.JD211098(1).compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.JD211098(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.JD211098(1).compiler_opt.helmex.mex705 = ['-L',dkepath.JD211098(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.JD211098(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).compiler_opt.copts.mex710 = '';
dkepath.JD211098(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.JD211098(1).compiler_opt.helmex.mex710 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).compiler_opt.copts.mex712 = '';
dkepath.JD211098(1).compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.JD211098(1).compiler_opt.helmex.mex712 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.JD211098(1).compiler_opt.copts.mex800 = '';
dkepath.JD211098(1).compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.JD211098(1).compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.JD211098(1).compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex705 = [dkepath.JD211098(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
%dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
%dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.JD211098(1).MUMPS.mex712 = [dkepath.JD211098(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.JD211098(1).MUMPS.mex712 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.JD211098(1).MUMPS.mex800 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.9.2 not compatible with matlab 7.5
%
% LUKE documentation
%
dkepath.JD211098(1).graphviz.env = '/home/sccp/gsem/peysson/bin/';% Graphviz environment variable
dkepath.JD211098(1).latex.env = '';% Latex environment variable
dkepath.JD211098(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Distributed computing -----------------------------
%
dkepath.JD211098(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.JD211098(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.JD211098(1).remote(1) = remote_CEA_CEPHEE('pbs','joan');
dkepath.JD211098(1).remote(1).host = '';% empty for local host
dkepath.JD211098(1).remote(1).env.luke_root = dkepath.JD211098(1).luke_root;
%
% andromede (pbs)
%
dkepath.JD211098(1).remote(2) = remote_CEA_ANDROMEDE('pbs','joan');
dkepath.JD211098(1).remote(2).env.luke_root = '/home/JD211098/LUKE/';
%
% macproyves (condor)
%
dkepath.JD211098(1).remote(3) = remote_macpro_YVES_PEYSSON('condor','joan');
dkepath.JD211098(1).remote(3).env.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
%
% macproyves (xgrid)
%
dkepath.JD211098(1).remote(4) = remote_macpro_YVES_PEYSSON('xgrid','joan');
dkepath.JD211098(1).remote(4).env.luke_root = dkepath.JD211098(1).remote(3).env.luke_root;
%
% shenma (torque)
%
dkepath.JD211098(1).remote(5) = remote_ASIPP_SHENMA('torque','joan');
dkepath.JD211098(1).remote(5).env.luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
% cadts-0412 (torque, Timothee's computer)
%
dkepath.JD211098(1).remote(6) = remote_CEA_TIMDESKTOP('torque','joan');
dkepath.JD211098(1).remote(6).env.luke_root = dkepath.JD211098(1).remote(1).env.luke_root;% same FS as cephee
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster).
%
dkepath.JD211098(1).remote(7) = remote_CEA_PLEIONE('pbs','joan');
dkepath.JD211098(1).remote(7).env.luke_root = dkepath.JD211098(1).remote(1).env.luke_root;% same FS as cephee
%
% saturne (sun)
%
dkepath.JD211098(1).remote(8) = remote_CEA_SATURNE('sun','joan');
dkepath.JD211098(1).remote(8).env.luke_root = dkepath.JD211098(1).remote(2).env.luke_root;% same FS as andromede
%
%---------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Buravand ------------------------------------
%---------------------------------------------------------------------------------------------------------
%
dkepath.YB109156(1).luke_root = [pwd,filesep];
dkepath.YB109156(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.YB109156(1).temppathroot = '/local/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YB109156(1).mex705 = [dkepath.YB109156(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.YB109156(1).mex710 = [dkepath.YB109156(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.YB109156(1).mex712 = [dkepath.YB109156(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
dkepath.YB109156(1).mex800 = [dkepath.YB109156(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
%
dkepath.YB109156(1).compiler_opt.copts.mex705 = '-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh';
dkepath.YB109156(1).compiler_opt.fopts.mex705 = ['-f /home/sccp/gsem/decker/Packages/cephee/MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.YB109156(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.YB109156(1).compiler_opt.helmex.mex705 = ['-L',dkepath.YB109156(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.YB109156(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.YB109156(1).compiler_opt.copts.mex710 = '';
dkepath.YB109156(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.YB109156(1).compiler_opt.helmex.mex710 = ['-L',dkepath.YB109156(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YB109156(1).compiler_opt.copts.mex712 = '';
dkepath.YB109156(1).compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.YB109156(1).compiler_opt.helmex.mex712 = ['-L',dkepath.YB109156(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YB109156(1).compiler_opt.copts.mex800 = '';
dkepath.YB109156(1).compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.YB109156(1).compiler_opt.helmex.mex800 = ['-L',dkepath.YB109156(1).local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.YB109156(1).compiler_opt.helmex.mex800 = ['-L',dkepath.YB109156(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YB109156(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
dkepath.YB109156(1).MUMPS.mex705 = [dkepath.YB109156(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YB109156(1).MUMPS.mex710 = [dkepath.YB109156(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.YB109156(1).MUMPS.mex710 = [dkepath.YB109156(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
dkepath.YB109156(1).MUMPS.mex712 = [dkepath.YB109156(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.YB109156(1).MUMPS.mex800 = [dkepath.YB109156(1).local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.9.2 not compatible with matlab 7.5
%
% LUKE documentation
%
dkepath.YB109156(1).graphviz.env = '/home/sccp/gsem/peysson/bin/';% Graphviz environment variable
dkepath.YB109156(1).latex.env = '';% Latex environment variable
dkepath.YB109156(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Distributed computing -----------------------------
%
dkepath.YB109156(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.YB109156(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
%
% local
%
dkepath.YB109156(1).remote(1) = remote_CEA_CEPHEE('pbs','yvesb');
dkepath.YB109156(1).remote(1).host = '';% empty for local host
dkepath.YB109156(1).remote(1).env.luke_root = dkepath.YB109156(1).luke_root;
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster).
%
dkepath.YB109156(1).remote(2) = remote_CEA_PLEIONE('pbs','yvesb');
dkepath.YB109156(1).remote(2).env.luke_root = dkepath.YB109156(1).remote(1).env.luke_root;% same FS as cephee
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Emelie Nilsson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.EN232106(1).luke_root = [pwd,filesep];
dkepath.EN232106(1).local_root = '/home/sccp/gsem/decker/Packages/cephee/';
dkepath.EN232106(1).temppathroot = '/home/sccp/gchf/EN290612/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.EN232106(1).mex705 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB75/'];
dkepath.EN232106(1).mex710 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.EN232106(1).mex712 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB712/'];
dkepath.EN232106(1).mex800 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
%
dkepath.EN232106(1).compiler_opt.copts.mex705 = ['-f',dkepath.EN232106(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh'];
dkepath.EN232106(1).compiler_opt.fopts.mex705 = ['-f',dkepath.EN232106(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75/gccopts.sh FC=''',dkepath.EN232106(1).local_root,'bin/cephee/g95'' FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
dkepath.EN232106(1).compiler_opt.helmex.mex705 = ['-L',dkepath.EN232106(1).local_root,'lib/cephee/g95 -lf95 -lgcc -L',dkepath.EN232106(1).local_root,'Packages/cephee/lapack-3.1.1/ -llapack_g95 -lblas_g95 -ltmglib_g95'];% Optional argument for helmex compilation
%
dkepath.EN232106(1).compiler_opt.copts.mex710 = '';
dkepath.EN232106(1).compiler_opt.fopts.mex710 = 'FC=''ifort''';
dkepath.EN232106(1).compiler_opt.helmex.mex710 = ['-L',dkepath.EN232106(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.EN232106(1).compiler_opt.copts.mex712 = '';
dkepath.EN232106(1).compiler_opt.fopts.mex712 = 'FC=''ifort''';
dkepath.EN232106(1).compiler_opt.helmex.mex712 = ['-L',dkepath.EN232106(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.EN232106(1).compiler_opt.copts.mex800 = '';
dkepath.EN232106(1).compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.EN232106(1).compiler_opt.helmex.mex800 = ['-L',dkepath.EN232106(1).local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.EN232106(1).compiler_opt.helmex.mex800 = ['-L',dkepath.EN232106(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.EN232106(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.EN232106(1).MUMPS.mex705 = [dkepath.EN232106(1).local_root,'MUMPS_4.7.3_S_g95/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.EN232106(1).MUMPS.mex710 = [dkepath.EN232106(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB710'];%MUMPS_4.9.2 not compatible with matlab 7.5
%dkepath.EN232106(1).MUMPS.mex710 = [dkepath.EN232106(1).local_root,'MUMPS_4.9.2_S_g95/MATLAB710'];%alternative option
dkepath.EN232106(1).MUMPS.mex712 = [dkepath.EN232106(1).local_root,'MUMPS_4.9.2_S_ifort/MATLAB712'];%MUMPS_4.9.2 not compatible with matlab 7.5
dkepath.EN232106(1).MUMPS.mex800 = [dkepath.EN232106(1).local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.10.0 not compatible with matlab 8.0
%
% LUKE documentation
%
dkepath.EN232106(1).graphviz.env = '/home/sccp/gsem/peysson/bin/';% Graphviz environment variable
dkepath.EN232106(1).latex.env = '';% Latex environment variable
dkepath.EN232106(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Distributed computing -----------------------------
%
dkepath.EN232106(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
dkepath.EN232106(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
%
% local
%
dkepath.EN232106(1).remote(1) = remote_CEA_CEPHEE('pbs','emelie');
dkepath.EN232106(1).remote(1).host = '';% empty for local host
dkepath.EN232106(1).remote(1).env.luke_root = dkepath.EN232106(1).luke_root;
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster).
%
dkepath.EN232106(1).remote(2) = remote_CEA_PLEIONE('pbs','emelie');
dkepath.EN232106(1).remote(2).env.luke_root = dkepath.EN232106(1).remote(1).env.luke_root;% same FS as cephee
%
