function [dkepath] = path_CRPP_LAC
%
% path definitions for CRPP (EPFL, Suisse) lac1, lac2, lac4, lac5, lac6, lac7, lac8 computers 
% Note : at present lac5 is the one that is different from the others
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'lac','lac2','lac4','lac5','lac6','lac7','lac8'};
dkepath.hostname = {'crpppc172.epfl.ch','crpppc70.epfl.ch','crpppc296','crpppc401.epfl.ch','crpppc94','crpppc289','crpppc203'};% should match the output of hostname_jd on the machine
%
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'decker';
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.decker(1).luke_root = luke_root;
dkepath.decker(1).temppathroot = '/home/decker/NoTivoli/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% lac
%
dkepath.decker(1).lac.local_root = '/home/decker/NoTivoli/Packages/lac8/';
%
dkepath.decker(1).lac.mex800 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/lac/MATLAB800'];
dkepath.decker(1).lac.mex801 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/lac/MATLAB801'];
dkepath.decker(1).lac.mex803 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/lac/MATLAB803'];
dkepath.decker(1).lac.mex804 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/lac/MATLAB804'];
dkepath.decker(1).lac.mex805 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/lac/MATLAB805'];
dkepath.decker(1).lac.mex900 = [dkepath.decker(1).luke_root,'Project_DKE/MEX/Bin/lac/MATLAB900'];
dkepath.decker(1).lac.compiler_opt.helmex.mex800 = NaN;
dkepath.decker(1).lac.compiler_opt.helmex.mex801 = NaN;
dkepath.decker(1).lac.compiler_opt.helmex.mex803 = NaN;
dkepath.decker(1).lac.compiler_opt.helmex.mex804 = NaN;
dkepath.decker(1).lac.compiler_opt.helmex.mex805 = NaN;
dkepath.decker(1).lac.compiler_opt.helmex.mex900 = NaN;
dkepath.decker(1).lac.compiler_opt.fopts.mex800 = '';%'-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
dkepath.decker(1).lac.compiler_opt.fopts.mex801 = '';%'-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
dkepath.decker(1).lac.compiler_opt.fopts.mex803 = '';%'-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
dkepath.decker(1).lac.compiler_opt.fopts.mex804 = '';%'-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
dkepath.decker(1).lac.compiler_opt.fopts.mex805 = '';%'-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
dkepath.decker(1).lac.compiler_opt.fopts.mex900 = '';%'-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132''';
%
dkepath.decker(1).lac.MUMPS.mex800 = [dkepath.decker(1).lac.local_root,'MUMPS_4.10.0_ifort/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.decker(1).lac.MUMPS.mex801 = [dkepath.decker(1).lac.local_root,'MUMPS_4.10.0_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.decker(1).lac.MUMPS.mex803 = [dkepath.decker(1).lac.local_root,'MUMPS_4.10.0_ifort/MATLAB803'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.decker(1).lac.MUMPS.mex804 = [dkepath.decker(1).lac.local_root,'MUMPS_4.10.0_ifort/MATLAB804'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.decker(1).lac.MUMPS.mex805 = [dkepath.decker(1).lac.local_root,'MUMPS_4.10.0_ifort/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.decker(1).lac.MUMPS.mex900 = [dkepath.decker(1).lac.local_root,'MUMPS_4.10.0_ifort/MATLAB900'];%Where MUMPS matrix solver is stored (MEX function)
%
% lac2
%
dkepath.decker(1).lac2 = dkepath.decker(1).lac;% LAC2 and LAC have equivalent settings
%
% lac4
%
dkepath.decker(1).lac4 = dkepath.decker(1).lac;% LAC4 and LAC have equivalent settings
%
% lac5
%
dkepath.decker(1).lac5 = dkepath.decker(1).lac;% LAC5 and LAC have different settings, to be tested
%
% lac6
%
dkepath.decker(1).lac6 = dkepath.decker(1).lac;% LAC6 and LAC have equivalent settings
%
% lac7
%
dkepath.decker(1).lac7 = dkepath.decker(1).lac;% LAC7 and LAC have equivalent settings
%
% lac8
%
dkepath.decker(1).lac8 = dkepath.decker(1).lac;% LAC8 and LAC have equivalent settings
%
% LUKE documentation
%
dkepath.decker(1).graphviz.env = '';% Graphviz environment variable
dkepath.decker(1).latex.env = '';% Latex environment variable
dkepath.decker(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
remote_selection = [1,4,6,7,8];
%
remote(1).remoteid = 'CRPP_PPB110';
remote(1).schedulername = 'slurm';
remote(1).profilename = 'local';
remote(1).luke_root = '/home/decker/LUKE/';
%
remote(2).remoteid = 'CRPP_BELLATRIX';
remote(2).schedulername = 'pbs';
remote(2).profilename = 'kamleitn';
remote(2).luke_root = '/home/kamleitn/LUKE/';
%
remote(3).remoteid = 'CEA_ANDROMEDE';
remote(3).schedulername = 'pbs';
remote(3).profilename = 'local';
remote(3).luke_root = '/home/JD211098/LUKE/';
%
remote(4).remoteid = 'CRPP_LAC';
remote(4).schedulername = 'direct';
remote(4).profilename = 'local';
remote(4).luke_root = luke_root;% local cluster
%
remote(5).remoteid = 'CRPP_PC82';
remote(5).schedulername = 'direct';
remote(5).profilename = 'local';
remote(5).luke_root = '/home/decker/LUKE/';
%
remote(6) = remote(4);
remote(6).remoteid = 'CRPP_LAC5';
%
remote(7) = remote(4);
remote(7).remoteid = 'CRPP_LAC6';
%
remote(8) = remote(1);
remote(8).schedulername = 'direct';
%
% -------------- profiles selection ------------
%
dkepath.decker(1).remote = remote(remote_selection);
%