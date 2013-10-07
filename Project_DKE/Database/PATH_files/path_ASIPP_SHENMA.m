function [dkepath] = path_ASIPP_SHENMA(luke_ref)
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
dkepath.bjding(1).local_root = '/home/PEYSSON/Packages/';
dkepath.bjding(1).temppathroot = '/scratch/bjding/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.bjding(1).mex800 = [dkepath.bjding(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB800/'];
%
dkepath.bjding(1).compiler_opt.copts.mex800 = '';
dkepath.bjding(1).compiler_opt.fopts.mex800 = 'FC=''gfortran''';
dkepath.bjding(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.bjding(1).MUMPS.mex800 = [dkepath.bjding(1).local_root,'MUMPS_4.10.0/MATLAB800'];
%
% LUKE documentation
%
dkepath.bjding(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.bjding(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.bjding(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
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
dkepath.PEYSSON(1).luke_root = [pwd,'/'];
dkepath.PEYSSON(1).local_root = '/home/PEYSSON/Packages/';
dkepath.PEYSSON(1).temppathroot = '/scratch/PEYSSON/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.PEYSSON(1).mex800 = [dkepath.PEYSSON(1).luke_root,'Project_DKE/MEX/Bin/shenma/MATLAB800/'];
%
dkepath.PEYSSON(1).compiler_opt.copts.mex800 = '';
dkepath.PEYSSON(1).compiler_opt.fopts.mex800 = 'FC=''gfortran''';
dkepath.PEYSSON(1).compiler_opt.helmex.mex800 = NaN;% Optional argument for helmex compilation
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.PEYSSON(1).MUMPS.mex800 = [dkepath.PEYSSON(1).local_root,'MUMPS_4.10.0/MATLAB800'];
%
% LUKE documentation
%
dkepath.PEYSSON(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.PEYSSON(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.PEYSSON(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
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

