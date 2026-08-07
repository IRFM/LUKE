% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function dkepath = path_UYORK
%
% path definitions for the research1 computers (University of York)
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Savoye-Peysson (CEA/DSM/IRFM, yves.savoye-peysson@cea.fr) 
%
dkepath.machine =  {'research1'};
dkepath.hostname = {'research1'};% should match the output of hostname_jd on the machine
%
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'pll543';
%
%------------------------------------ Profile number 1, YP105119 Peysson ------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.pll543(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.pll543(1).luke_project = luke_root(sep(end-1)+1:sep(end)-1);
dkepath.pll543(1).luke_gitbranch = '';%default local luke git branch. Empty no specific git branch is enforced. 
%
dkepath.pll543(1).temppathroot = '/shared/storage/plasma/STEP/LUKE/LUKE-CEA/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- research1 -------------------------------
%
dkepath.pll543(1).research1.local_root = '/shared/storage/plasma/STEP/LUKE/LUKE-CEA/';
%
dkepath.pll543(1).research1.mex914 = [dkepath.pll543(1).luke_root,'Project_DKE/MEX/Bin/MATLAB914/'];
%
dkepath.pll543(1).research1.compiler_opt.copts = '';
dkepath.pll543(1).research1.compiler_opt.copts.cpp.mex914 = '';
dkepath.pll543(1).research1.compiler_opt.fopts.mex914 = 'FC=''gfortran''';
%
dkepath.pll543(1).research1.MUMPS.mex914 = [dkepath.pll543(1).research1.local_root,'Packages/Bin/MUMPS/MUMPS_5.7.3_S_gfortran/MATLAB914'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.pll543(1).research1.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.pll543(1).research1.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.pll543(1).research1.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- other machine of zone partenaires -------------------------------
%
%dkepath.pll543(1).research2 = dkepath.pll543(1).research1;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.pll543(1).remote(1).remoteid = 'UYORK';
dkepath.pll543(1).remote(1).schedulername = 'direct';
dkepath.pll543(1).remote(1).profilename = 'pll543';
dkepath.pll543(1).remote(1).luke_root = dkepath.pll543(1).luke_root;% local cluster
%
%------------------------------------ Other LUKE users ------------------------------
%
%dkepath = add_path_cea_users(dkepath,'PARTENAIRES');
%
