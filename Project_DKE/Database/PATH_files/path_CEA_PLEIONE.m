function [dkepath] = path_CEA_PLEIONE(luke_ref)
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
if nargin == 0, 
    luke_ref = 'LUKE';
end
%
dkepath.hostname = 'pleione';
dkepath.machine = 'pleione';
dkepath.computer = computer;%machine type and supported OS
%
% Selected default user profile 
%
dkepath.path_profile.YP105119 = 1;
dkepath.path_profile.JD211098 = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.JD211098(1).luke_root = ['/home/sccp/gsem/decker/',luke_ref,'/'];
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
dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex712 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex800 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Remote computing -----------------------------
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster). Shares the same filesystem as cephee
%
dkepath.JD211098(1).remote(1) = remote_CEA_PLEIONE('pbs','joan','JD211098');
dkepath.JD211098(1).remote(1).host = '';% empty for local host
dkepath.JD211098(1).remote(1).luke_root = dkepath.JD211098(1).luke_root;
%
% macproyves (condor)
%
dkepath.JD211098(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan','JD211098');
%
% macproyves (xgrid)
%
dkepath.JD211098(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan','JD211098');
%
% cadts-0412 (torque, Timothee's computer). Shares the same filesystem as pleione
%
dkepath.JD211098(1).remote(4) = remote_CEA_TIMDESKTOP('torque','joan','JD211098');
dkepath.JD211098(1).remote(4).luke_root = dkepath.JD211098(1).luke_root;
%
% cephee (pbs). Shares the same filesystem as pleione
%
dkepath.JD211098(1).remote(5) = remote_CEA_CEPHEE('pbs','joan','JD211098');
dkepath.JD211098(1).remote(5).luke_root = dkepath.JD211098(1).luke_root;
%
% andromede (pbs). Shares the same filesystem as pleione
%
dkepath.JD211098(1).remote(6) = remote_CEA_ANDROMEDE('pbs','joan','JD211098');
dkepath.JD211098(1).remote(6).luke_root = dkepath.JD211098(1).luke_root;
%
% saturne (sun)
%
dkepath.JD211098(1).remote(7) = remote_CEA_SATURNE('sun','joan','JD211098');
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.YP105119(1).luke_root = ['/home/sccp/gsem/peysson/',luke_ref,'/'];
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
%--------------------------- Remote computing -----------------------------
%
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster). Shares the same filesystem as cephee
%
dkepath.YP105119(1).remote(1) = remote_CEA_PLEIONE('pbs','yves','YP105119');
dkepath.YP105119(1).remote(1).host = '';% empty for local host
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;
%
% macproyves (condor)
%
dkepath.YP105119(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','yves','YP105119');
%
% macproyves (xgrid)
%
dkepath.YP105119(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','yves','YP105119');
%
% cadts-0412 (torque, Timothee's computer). Shares the same filesystem as pleione
%
dkepath.YP105119(1).remote(4) = remote_CEA_TIMDESKTOP('torque','yves','YP105119');
dkepath.YP105119(1).remote(4).luke_root = dkepath.YP105119(1).luke_root;
%
% cephee (pbs). Shares the same filesystem as pleione
%
dkepath.YP105119(1).remote(5) = remote_CEA_CEPHEE('pbs','yves','YP105119');
dkepath.YP105119(1).remote(5).luke_root = dkepath.YP105119(1).luke_root;
%
% andromede (pbs). Shares the same filesystem as pleione
%
dkepath.YP105119(1).remote(6) = remote_CEA_ANDROMEDE('pbs','yves','YP105119');
dkepath.YP105119(1).remote(6).luke_root = dkepath.YP105119(1).luke_root;
%
% saturne (sun)
%
dkepath.YP105119(1).remote(7) = remote_CEA_SATURNE('sun','yves','YP105119');





