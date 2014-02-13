function dkepath = path_CEA_PLEIONE
%
% path definitions for CEA PLEIONE workstation
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.hostname = 'pleione';
dkepath.machine = 'pleione';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.JD211098(1).luke_root = [pwd,filesep];
dkepath.JD211098(1).local_root = '/home/sccp/gsem/decker/Packages/nunki/';
dkepath.JD211098(1).temppathroot = '/home/sccp/gsem/decker/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB710/'];
dkepath.JD211098(1).mex712 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB712/'];
dkepath.JD211098(1).mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB800/'];
%
dkepath.JD211098(1).compiler_opt.copts = '';
dkepath.JD211098(1).compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.JD211098(1).compiler_opt.fopts.mex712 = 'FC=''gfortran''';
dkepath.JD211098(1).compiler_opt.fopts.mex800 = '';
dkepath.JD211098(1).compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).compiler_opt.helmex.mex712 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex712 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex800 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.JD211098(1).graphviz.env = '';% Graphviz environment variable
dkepath.JD211098(1).latex.env = '';% Latex environment variable
dkepath.JD211098(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster).
%
dkepath.JD211098(1).remote(1) = remote_CEA_PLEIONE('pbs','joan');
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
dkepath.JD211098(1).remote(6).env.luke_root = dkepath.JD211098(1).remote(1).env.luke_root;% same FS as nunki
%
% cephee
%
dkepath.JD211098(1).remote(7) = remote_CEA_CEPHEE('pbs','joan');
dkepath.JD211098(1).remote(7).env.luke_root = dkepath.JD211098(1).remote(1).env.luke_root;% same FS as nunki
%
% saturne (sun)
%
dkepath.JD211098(1).remote(8) = remote_CEA_SATURNE('sun','joan');
dkepath.JD211098(1).remote(8).env.luke_root = dkepath.JD211098(1).remote(2).env.luke_root;% same FS as andromede
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.YP105119(1).luke_root = [pwd,filesep];
dkepath.YP105119(1).local_root = '/home/sccp/gsem/decker/Packages/nunki/';
dkepath.YP105119(1).temppathroot = '/home/sccp/gsem/peysson/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB710/'];
dkepath.YP105119(1).mex712 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB712/'];
dkepath.YP105119(1).mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/nunki/MATLAB800/'];
%
dkepath.YP105119(1).compiler_opt.copts = '';
dkepath.YP105119(1).compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.YP105119(1).compiler_opt.fopts.mex712 = 'FC=''gfortran''';
dkepath.YP105119(1).compiler_opt.fopts.mex800 = '';
dkepath.YP105119(1).compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).compiler_opt.helmex.mex712 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).MUMPS.mex712 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).MUMPS.mex800 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).graphviz.env = '';% Graphviz environment variable
dkepath.YP105119(1).latex.env = '';% Latex environment variable
dkepath.YP105119(1).imagemagick.env = '';% ImageMagick environment variable
%
%
%--------------------------- Remote computing -----------------------------
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster).
%
dkepath.YP105119(1).remote(1) = remote_CEA_PLEIONE('pbs','yves');
dkepath.YP105119(1).remote(1).host = '';% empty for local host
dkepath.YP105119(1).remote(1).env.luke_root = dkepath.YP105119(1).luke_root;
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