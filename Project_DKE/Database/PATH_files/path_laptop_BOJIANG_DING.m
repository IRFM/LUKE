function [dkepath] = path_laptop_BOJIANG_DING(luke_ref)
%
% path definitions for laptop of Bojiang Ding
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
dkepath.hostname = 'XXXXXXX';%WARNING: for laptop, may change with connection status.
dkepath.machine = 'laptopbojiang';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
dkepath.path_profile = 1;
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.bojiang(1).luke_root = [pwd,'/'];
dkepath.bojiang(1).local_root = '/opt/';
dkepath.bojiang(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.bojiang(1).mex800 = [dkepath.bojiang(1).luke_root,'Project_DKE/MEX/Bin/laptopbojiang/MATLAB800']; 
%
%dkepath.bojiang(1).MUMPS.mex800 = [dkepath.bojiang(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
%dkepath.bojiang(1).graphviz.dotpath = '';% Graphviz 'dot' command path
%dkepath.bojiang(1).latex.htlatexpath = '';% Latex 'htlatex' command path
%dkepath.bojiang(1).latex.pdflatexpath = '';% Latex 'pdflatex' command path
%dkepath.bojiang(1).latex.env = '';% Latex environment variable
%dkepath.bojiang(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% local
%
dkepath.bojiang(1).remote(1) = remote_ASIPP_SHENMA('torque','bojiang','bojiang');
dkepath.bojiang(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','bojiang','bojiang');
dkepath.bojiang(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','bojiang','bojiang');
