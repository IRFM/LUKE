function [asipp] = path_ASIPP_SHENMA(luke_ref)
%
% path definitions for ASIPP cluster SHENMA (Heifei, China) 
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
dkepath.hostname = 'shenma';
dkepath.machine = 'shenma';
dkepath.computer = computer;%machine type and supported OS
%
% Selected default user profile 
%
dkepath.path_profile.bjding = 1;
dkepath.path_profile.PEYSSON = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'bjding';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Bojiang Ding ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.bjding(1).luke_root = ['/home/bjding/',luke_ref,'/'];
dkepath.bjding(1).local_root = '/home/bjding/Packages/';
dkepath.bjding(1).temppathroot = '/local/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.bjding(1).mex800 = [dkepath.bjding(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB800/'];
%
dkepath.bjding(1).compiler_opt.copts.mex800 = '';
dkepath.bjding(1).compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.bjding(1).compiler_opt.helmex.mex800 = ['-L',dkepath.bjding(1).local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.bjding(1).compiler_opt.helmex.mex800 = ['-L',dkepath.bjding(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.bjding(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.bjding(1).MUMPS.mex800 = [dkepath.bjding(1).local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.10.0 not compatible with matlab 8.0
%
%--------------------------- Distributed computing -----------------------------
%
%dkepath.bjding(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
%dkepath.bjding(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
%
% local (shenma)
%
dkepath.bjding(1).remote(1) = remote_ASIPP_SHENMA('torque','bojiang','bjding');
dkepath.bjding(1).remote(1).host = '';% empty for local host
dkepath.bjding(1).remote(1).luke_root = dkepath.bjding(1).luke_root;
%
% macproyves (condor)
%
dkepath.bjding(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','bojiang','bjding');
%
% macproyves (xgrid)
%
dkepath.bjding(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','bojiang','bjding');
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
dkepath.PEYSSON(1).luke_root = ['/home/PEYSSON/',luke_ref,'/'];
dkepath.PEYSSON(1).local_root = '/home/PEYSSON/Packages/';
dkepath.PEYSSON(1).temppathroot = '/local/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.PEYSSON(1).mex800 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB800/'];
%
dkepath.PEYSSON(1).compiler_opt.copts.mex800 = '';
dkepath.PEYSSON(1).compiler_opt.fopts.mex800 = 'FC=''ifort''';
%dkepath.PEYSSON(1).compiler_opt.helmex.mex800 = ['-L',dkepath.PEYSSON(1).local_root,'lapack-3.4.2/ -llapack -lrefblas'];% Optional argument for helmex compilation
%dkepath.PEYSSON(1).compiler_opt.helmex.mex800 = ['-L',dkepath.PEYSSON(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.PEYSSON(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
dkepath.PEYSSON(1).MUMPS.mex800 = [dkepath.PEYSSON(1).local_root,'MUMPS_4.10.0/MATLAB800'];%MUMPS_4.9.2 not compatible with matlab 7.5
%
%--------------------------- Distributed computing -----------------------------
%
%dkepath.PEYSSON(1).configurations.localconfig = '/local/mdce/configurations/localconfig.mat';
%dkepath.PEYSSON(1).configurations.pbsproconfig = '/local/mdce/configurations/pbsproconfig.mat';
%
%--------------------------- Remote computing -----------------------------
% 
% local (shenma)
%
dkepath.PEYSSON(1).remote(1) = remote_ASIPP_SHENMA('torque','yves','PEYSSON');
dkepath.PEYSSON(1).remote(1).host = '';% empty for local host
dkepath.PEYSSON(1).remote(1).luke_root = dkepath.PEYSSON(1).luke_root;
%
% macproyves (condor)
%
dkepath.PEYSSON(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','yves','PEYSSON');
%
% macproyves (xgrid)
%
dkepath.PEYSSON(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','yves','PEYSSON');
%
%asipp.bojiangding(1).MUMPS.seq = [asipp.bojiangding(1).local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/dke'];
%asipp.bojiangding(1).MUMPS.mex710 = [asipp.bojiangding(1).local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
%asipp.bojiangding(1).compiler_opt.helmex = '-L/home/bojiangding/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
