function [itm] = path_EFDA_ITM(luke_ref)
%
% path definitions for EFDA ITM cluster
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
itm.hostname = 'itm.rzg.mpg.de';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
itm.machine = 'itm';
itm.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
itm.path_profile = 1;
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
itm.yvesp(1).luke_root = '/pfs/home/yvesp/public/LUKE_ITM/trunk/LUKE/';
itm.yvesp(1).local_root = ['/pfs/home/yvesp/public/'];
itm.yvesp(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
itm.yvesp(1).startup{1} = sprintf('%s\n','[lukeversion,matlabversion,matlabrelease] = LUKEversion_jd;');
%
%itm.yvesp(1).speclibpath.xml_io_tools = [itm.yvesp(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
itm.yvesp(1).speclibpath.ual = getenv('UAL');%UAL path in the ITM gateway. See the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
itm.yvesp(1).mex800 = [itm.yvesp(1).luke_root,'Project_DKE/MEX/Bin/efda/MATLAB800/'];
%
itm.yvesp(1).compiler_opt.copts = '';
itm.yvesp(1).compiler_opt.helmex = NaN;%'  -llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
itm.yvesp(1).compiler_opt.fopts = ' -largeArrayDims';
%
%itm.yvesp(1).MUMPS.mex800 = ['/afs/ipp/itm/switm/lib/mumps/4.10.0_serial/matlab/R2012b/amd64_intel_12/'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Distributed computing -----------------------------
%
%
%--------------------------- Remote computing -----------------------------
%
itm.yvesp(1).remote(1) = remote_macpro_YVES_PEYSSON('condor','yves','yvesp');
itm.yvesp(1).remote(2) = remote_macpro_YVES_PEYSSON('xgrid','yves','yvesp');
















