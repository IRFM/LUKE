function [dkepath] = path_CEA_ANDROMEDE1(luke_ref)
%
% path definitions for the ANDROMEDE cluster 
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,1]
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
dkepath.hostname = 'andromede1';
dkepath.machine = 'andromede1';
dkepath.computer = computer;%machine type and supported OS
%
% Selected default user profile 
%
dkepath.path_profile.JD211098 = 1;
dkepath.path_profile.YP105119 = 1;
dkepath.path_profile.EN232106 = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'JD211098';
%
%------------------------------------ Profile number 1, JD211098 Decker ------------------------------------
%
dkepath.JD211098(1).luke_root = ['/home/JD211098/',luke_ref,'/'];
dkepath.JD211098(1).local_root = '/home/JD211098/Packages/andromede/';
dkepath.JD211098(1).temppathroot = '/data/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.JD211098(1).mex710 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.JD211098(1).mex800 = [dkepath.JD211098(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
%
dkepath.JD211098(1).compiler_opt.copts = '';
dkepath.JD211098(1).compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.JD211098(1).compiler_opt.fopts.mex800 = '';
dkepath.JD211098(1).compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.JD211098(1).compiler_opt.helmex.mex800 = ['-L',dkepath.JD211098(1).local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.JD211098(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.JD211098(1).MUMPS.mex710 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.JD211098(1).MUMPS.mex800 = [dkepath.JD211098(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.JD211098(1).graphviz.env = '/home/YP105119/bin/';% Graphviz environment variable
dkepath.JD211098(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.JD211098(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.JD211098(1).remote(1) = remote_CEA_PARTENAIRES_ANDROMEDE('pbs','joan','JD211098');
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
% saturne (sun)
%
dkepath.JD211098(1).remote(4) = remote_CEA_SATURNE('sun','joan','JD211098');
%
% pleiades2 (pbs)
%
dkepath.JD211098(1).remote(5) = remote_CRPP_PLEIADES2('torque','joan','JD211098');
%
% shenma (torque)
%
dkepath.JD211098(1).remote(6) = remote_ASIPP_SHENMA('torque','joan','JD211098');
%
%------------------------------------ Profile number 1, YP105119 Decker ------------------------------------
%
dkepath.YP105119(1).luke_root = ['/home/YP105119/',luke_ref,'/'];
dkepath.YP105119(1).local_root = '/home/JD211098/Packages/andromede/';
dkepath.YP105119(1).temppathroot = '/data/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.YP105119(1).mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.YP105119(1).mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
%
dkepath.YP105119(1).compiler_opt = dkepath.JD211098(1).compiler_opt;
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).MUMPS.mex710 = [dkepath.YP105119(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).MUMPS.mex800 = [dkepath.YP105119(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.YP105119(1).graphviz.env = '/home/YP105119/bin/';% Graphviz environment variable
dkepath.YP105119(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.YP105119(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.YP105119(1).remote(1) = remote_CEA_PARTENAIRES_ANDROMEDE('pbs','yves','YP105119');
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
% saturne (sun)
%
dkepath.YP105119(1).remote(4) = remote_CEA_SATURNE('sun','yves','YP105119');
%
% shenma (torque)
%
dkepath.YP105119(1).remote(5) = remote_ASIPP_SHENMA('torque','yves','YP105119');
%
%------------------------------------ Profile number 1, EN232106 Nilsson ------------------------------------
%
dkepath.EN232106(1).luke_root = ['/home/EN290612/',luke_ref,'/'];
dkepath.EN232106(1).local_root = '/home/JD211098/Packages/andromede/';
dkepath.EN232106(1).temppathroot = '/data/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.EN232106(1).mex710 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.EN232106(1).mex800 = [dkepath.EN232106(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
%
dkepath.EN232106(1).compiler_opt = dkepath.JD211098(1).compiler_opt;
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.EN232106(1).MUMPS.mex710 = [dkepath.EN232106(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.EN232106(1).MUMPS.mex800 = [dkepath.EN232106(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.EN232106(1).graphviz.env = '/home/YP105119/bin/';% Graphviz environment variable
dkepath.EN232106(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.EN232106(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.EN232106(1).remote(1) = remote_CEA_PARTENAIRES_ANDROMEDE('pbs','emelie','EN232106');
dkepath.EN232106(1).remote(1).host = '';% empty for local host
dkepath.EN232106(1).remote(1).luke_root = dkepath.EN232106(1).luke_root;
%
% macproyves (condor)
%
dkepath.EN232106(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','emelie','EN232106');
%
% macproyves (xgrid)
%
dkepath.EN232106(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','emelie','EN232106');
%
% saturne (sun)
%
dkepath.EN232106(1).remote(4) = remote_CEA_SATURNE('sun','yves','EN232106');




