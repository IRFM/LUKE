function dkepath = path_EUROFUSION_ITM
%
% path definitions for EUROFUSION ITM cluster in Italy
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
dkepath.machine = 'r';%itm : ITM marconi servers; tok : AUG servers
dkepath.hostname = 'r';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
dkepath.computer = computer;%machine type and supported OS
%
%
% Selected user profile for unlisted users
%
dkepath.default = 'g2yvesp';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.g2yvesp(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.g2yvesp(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
%dkepath.g2yvesp(1).itm.local_root = '/afs/eufus.eu/g2itmdev/user/g2yvesp/public/';
dkepath.g2yvesp(1).local_root = '/marconi/eufus_gw/home/g2yvesp/public/';

dkepath.g2yvesp(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%dkepath.g2yvesp(1).speclibpath.xml_io_tools = [dkepath.g2yvesp(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
dkepath.g2yvesp(1).speclibpath.ual = getenv('UAL');%UAL path in the ITM gateway. See the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
dkepath.g2yvesp(1).mex713 = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Bin/eurofusion/MATLAB713/'];
dkepath.g2yvesp(1).mex902 = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Bin/eurofusion/MATLAB902/'];
dkepath.g2yvesp(1).mex905 = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Bin/eurofusion/MATLAB905/'];
%
dkepath.g2yvesp(1).compiler_opt.libs.gfortran = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.7.0','/',dkepath.machine,'/'];%extra libraries
dkepath.g2yvesp(1).compiler_opt.copts = '';
dkepath.g2yvesp(1).compiler_opt.fopts.mex713 = 'FC=''ifort''';%
dkepath.g2yvesp(1).compiler_opt.fopts.mex713 = ' -largeArrayDims';
dkepath.g2yvesp(1).compiler_opt.fopts.mex902 = 'FC=''gfortran''';%
dkepath.g2yvesp(1).compiler_opt.fopts.mex902 = ' ';%-largeArrayDims
dkepath.g2yvesp(1).compiler_opt.fopts.mex905 = 'FC=''gfortran''';%
dkepath.g2yvesp(1).compiler_opt.fopts.mex905 = ' ';%-largeArrayDims
%
dkepath.g2yvesp(1).MUMPS.mex902 = [dkepath.g2yvesp(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2/MATLAB902/'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.g2yvesp(1).MUMPS.mex905 = [dkepath.g2yvesp(1).local_root,'Packages/Bin/MUMPS/MUMPS_5.1.2/MATLAB905/'];%Where MUMPS matrix solver is stored (MEX function)
%
% Extra paths to add
%
dkepath.g2yvesp(1).extrapaths.LUKE_ITM = [dkepath.g2yvesp(1).local_root,'LUKE_ITM/trunk'];% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.g2yvesp(1).graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.g2yvesp(1).latex.env = '/usr/bin/';% Latex environment variable
dkepath.g2yvesp(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.g2yvesp(1).remote(1).remoteid = 'EUROFUSION_ITM';
dkepath.g2yvesp(1).remote(1).schedulername = 'slurm';
dkepath.g2yvesp(1).remote(1).profilename = 'g2yvesp';
dkepath.g2yvesp(1).remote(1).luke_root = dkepath.g2yvesp(1).luke_root;
%
dkepath.g2yvesp(1).remote(2) = dkepath.g2yvesp(1).remote(1);
dkepath.g2yvesp(1).remote(2).schedulername = 'direct';
