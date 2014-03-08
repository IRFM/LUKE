function dkepath = path_EFDA_ITM
%
% path definitions for EFDA ITM cluster
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'itm';
dkepath.hostname = 'itm.rzg.mpg.de';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
dkepath.computer = computer;%machine type and supported OS
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.yvesp(1).luke_root = [pwd,filesep];
dkepath.yvesp(1).local_root = '/pfs/home/yvesp/public/';
dkepath.yvesp(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%dkepath.yvesp(1).speclibpath.xml_io_tools = [dkepath.yvesp(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
dkepath.yvesp(1).speclibpath.ual = getenv('UAL');%UAL path in the ITM gateway. See the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
dkepath.yvesp(1).mex800 = [dkepath.yvesp(1).luke_root,'Project_DKE/MEX/Bin/efda/MATLAB800/'];
%
dkepath.yvesp(1).compiler_opt.copts = '';
dkepath.yvesp(1).compiler_opt.helmex = NaN;%'  -llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.yvesp(1).compiler_opt.fopts = ' -largeArrayDims';
%
dkepath.yvesp(1).MUMPS.mex800 = '/afs/ipp/itm/switm/lib/mumps/4.10.0_serial/matlab/R2012b/amd64_intel_12/';%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.yvesp(1).graphviz.env = '/afs/@cell/common/soft/doxygen/@sys/graphviz-2.28/bin/';% Graphviz environment variable
dkepath.yvesp(1).latex.env = '/afs/ipp/tok/soft/texlive/2012/@sys/bin/x86_64-linux/';% Latex environment variable
dkepath.yvesp(1).imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.yvesp(1).remote(1).remoteid = 'EFDA_ITM';
dkepath.yvesp(1).remote(1).schedulername = 'condor';
dkepath.yvesp(1).remote(1).profilename = 'yves';
dkepath.yvesp(1).remote(1).luke_root = dkepath.yvesp(1).luke_root;
%
dkepath.yvesp(1).remote(2).remoteid = 'macpro_YVES_PEYSSON';
dkepath.yvesp(1).remote(2).schedulername = 'condor';
dkepath.yvesp(1).remote(2).profilename = 'yves';
dkepath.yvesp(1).remote(2).luke_root = '/Users/yvespeysson/Projets/LUKE/';
%
dkepath.yvesp(1).remote(3) = dkepath.yvesp(1).remote(2);
dkepath.yvesp(1).remote(3).schedulername = 'xgrid';
%
dkepath.yvesp(1).remote(4) = dkepath.yvesp(1).remote(2);
dkepath.yvesp(1).remote(4).schedulername = 'direct';
%
dkepath.yvesp(1).remote(5).remoteid = 'CEA_ANDROMEDE';
dkepath.yvesp(1).remote(5).schedulername = 'pbs';
dkepath.yvesp(1).remote(5).profilename = 'YP105119';
dkepath.yvesp(1).remote(5).luke_root = '/home/YP105119/LUKE/';
%
dkepath.yvesp(1).remote(6).remoteid = 'ASIPP_SHENMA';
dkepath.yvesp(1).remote(6).schedulername = 'torque';
dkepath.yvesp(1).remote(6).profilename = 'yves';
dkepath.yvesp(1).remote(6).luke_root = '/home/PEYSSON/LUKE/';
%













