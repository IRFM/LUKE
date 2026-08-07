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
function dkepath = path_SWIP_CLUSTER02
%
% path definitions for SWIP cluster CLUSTER02 (Chengdu, China) 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'cluster02';
dkepath.hostname = 'mgmt.chess';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'Yves';
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.Yves(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.Yves(1).luke_project = luke_root(sep(end-1)+1:sep(end)-1);
dkepath.Yves(1).luke_gitbranch = '';%default local luke git branch. Empty no specific git branch is enforced. 
%
dkepath.Yves(1).local_root = '/opt/TOKAMAK_CODE/luke/Packages/';
dkepath.Yves(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.Yves(1).localdatapath = dkepath.Yves(1).temppathroot;
%
dkepath.Yves(1).mex801 = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Bin/cluster02/MATLAB801/'];
%
dkepath.Yves(1).compiler_opt.libs.gfortran = [dkepath.Yves(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.6','/',dkepath.machine,'/'];%extra libraries
dkepath.Yves(1).compiler_opt.copts = '';
dkepath.Yves(1).compiler_opt.fopts.mex801 = 'FC=''gfortran''';%
%
%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.Yves(1).MUMPS.mex801 = [dkepath.Yves(1).local_root,'MUMPS_5.1.2/MATLAB801'];
%
% LUKE documentation
%
dkepath.Yves(1).graphviz.env = '/usr/bin/';%Graphviz environment variable
dkepath.Yves(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.Yves(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.Yves(1).remote(1).remoteid = 'SWIP_CLUSTER02';
dkepath.Yves(1).remote(1).schedulername = 'torque';
dkepath.Yves(1).remote(1).profilename = 'local';
dkepath.Yves(1).remote(1).luke_root = dkepath.Yves(1).luke_root;% local cluster
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 2, Pony Ma  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.mazy(1) = dkepath.Yves(1);
dkepath.mazy(1).remote(1).profilename = 'mazy';
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 3, Lei Xue ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.xuelei(1) = dkepath.Yves(1);
dkepath.xuelei(1).remote(1).profilename = 'xuelei';
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 4, Yipo Zhang  ---------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.zhangyp(1) = dkepath.Yves(1);
dkepath.zhangyp(1).remote(1).profilename = 'zhangyp';
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 5, Jie Zhang  ----------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.zhangjie(1) = dkepath.Yves(1);
dkepath.zhangjie(1).remote(1).profilename = 'zhangjie';
%
%--------------------------------------------------------------------------------------------------------
%---------------------------------------- Profile number 6, Xingyu Bai ----------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.baixy(1) = dkepath.Yves(1);
dkepath.baixy(1).remote(1).profilename = 'baixy';

