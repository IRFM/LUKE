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
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@epfl.ch)
%
dkepath.machine = {'itm','tok'};%itm : ITM marconi servers; tok : AUG servers
dkepath.hostname = {{'eufus','marconi'},{'toks','toki'}};%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
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
dkepath.g2yvesp(1).luke_root = '/afs/eufus.eu/g2itmdev/user/g2yvesp/public/LUKE/';
%
dkepath.g2yvesp(1).itm.local_root = '/afs/eufus.eu/g2itmdev/user/g2yvesp/public/';
dkepath.g2yvesp(1).itm.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%dkepath.g2yvesp(1).itm.speclibpath.xml_io_tools = [dkepath.g2yvesp(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
dkepath.g2yvesp(1).itm.speclibpath.ual = getenv('UAL');%UAL path in the ITM gateway. See the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
dkepath.g2yvesp(1).itm.mex713 = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Bin/eurofusion/MATLAB713/'];
dkepath.g2yvesp(1).itm.mex902 = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Bin/eurofusion/MATLAB902/'];
%
dkepath.g2yvesp(1).itm.compiler_opt.libs.gfortran = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.7.0','/',dkepath.machine,'/'];%extra libraries
dkepath.g2yvesp(1).itm.compiler_opt.copts = '';
dkepath.g2yvesp(1).itm.compiler_opt.fopts.mex713 = 'FC=''ifort''';%
dkepath.g2yvesp(1).itm.compiler_opt.separatrice.mex713 = [' -largeArrayDims -L/afs/ipp-garching.mpg.de/common/soft/intel/ics/2011.0.013/composer_xe_2011_sp1.13.367/compiler/lib/intel64/ -lifcore -lirc -lsvml -L/afs/ipp/itm/switm/lib/lapack/3.4.2/lib/amd64_intel_12 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.g2yvesp(1).itm.compiler_opt.helmex.mex713 = [' -compatibleArrayDims -L/afs/ipp-garching.mpg.de/common/soft/intel/ics/2011.0.013/composer_xe_2011_sp1.13.367/compiler/lib/intel64/ -lifcore -lirc -lsvml -L/afs/ipp/itm/switm/lib/lapack/3.4.2/lib/amd64_intel_12 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.g2yvesp(1).itm.compiler_opt.fopts.mex713 = ' -largeArrayDims';
dkepath.g2yvesp(1).itm.compiler_opt.fopts.mex902 = 'FC=''ifort''';%
dkepath.g2yvesp(1).itm.compiler_opt.separatrice.mex902 = [' -largeArrayDims -L/afs/ipp-garching.mpg.de/common/soft/intel/ics/2011.0.013/composer_xe_2011_sp1.13.367/compiler/lib/intel64/ -lifcore -lirc -lsvml -L/afs/ipp/itm/switm/lib/lapack/3.4.2/lib/amd64_intel_12 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.g2yvesp(1).itm.compiler_opt.helmex.mex902 = [' -compatibleArrayDims -L/afs/ipp-garching.mpg.de/common/soft/intel/ics/2011.0.013/composer_xe_2011_sp1.13.367/compiler/lib/intel64/ -lifcore -lirc -lsvml -L/afs/ipp/itm/switm/lib/lapack/3.4.2/lib/amd64_intel_12 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.g2yvesp(1).itm.compiler_opt.fopts.mex902 = ' -largeArrayDims';
%
dkepath.g2yvesp(1).itm.MUMPS.mex902 = '/afs/eufus.eu/g2itmdev/user/g2yvesp/public/Packages/Bin/MUMPS/MUMPS_5.1.2/MATLAB902';%Where MUMPS matrix solver is stored (MEX function)
%
% Extra paths to add
%
dkepath.g2yvesp(1).itm.extrapaths.LUKE_ITM = [dkepath.g2yvesp(1).itm.local_root,'LUKE_ITM/trunk'];% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.g2yvesp(1).itm.graphviz.env = '/usr/bin/';% Graphviz environment variable
dkepath.g2yvesp(1).itm.latex.env = '/usr/bin/';% Latex environment variable
dkepath.g2yvesp(1).itm.imagemagick.env = '/usr/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.g2yvesp(1).remote(1).remoteid = 'EUROFUSION_ITM';
dkepath.g2yvesp(1).remote(1).schedulername = 'pbs';
dkepath.g2yvesp(1).remote(1).profilename = 'yves';
dkepath.g2yvesp(1).remote(1).luke_root = dkepath.g2yvesp(1).luke_root;
%
dkepath.g2yvesp(1).remote(2).remoteid = 'macpro_YVES_PEYSSON';
dkepath.g2yvesp(1).remote(2).schedulername = 'condor';
dkepath.g2yvesp(1).remote(2).profilename = 'yves';
dkepath.g2yvesp(1).remote(2).luke_root = '/Users/yvespeysson/Projets/LUKE/';
%
dkepath.g2yvesp(1).remote(3) = dkepath.g2yvesp(1).remote(2);
dkepath.g2yvesp(1).remote(3).schedulername = 'direct';
%
dkepath.g2yvesp(1).remote(4).remoteid = 'CEA_ANDROMEDE';
dkepath.g2yvesp(1).remote(4).schedulername = 'pbs';
dkepath.g2yvesp(1).remote(4).profilename = 'YP105119';
dkepath.g2yvesp(1).remote(4).luke_root = '/home/YP105119/LUKE/';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Joan Decker  ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.g2jodec(1).luke_root = '/afs/ipp-garching.mpg.de/home/j/jodec/LUKE/';
%
% host 1 : toks
%
dkepath.g2jodec(1).tok.local_root = '/afs/ipp-garching.mpg.de/home/j/jodec/Packages/';
dkepath.g2jodec(1).tok.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.g2jodec(1).tok.mex803 = [dkepath.g2jodec(1).luke_root,'Project_DKE/MEX/Bin/toks/MATLAB803']; 
%
dkepath.g2jodec(1).tok.compiler_opt.helmex = NaN;
dkepath.g2jodec(1).tok.compiler_opt.fopts = '';
dkepath.g2jodec(1).tok.compiler_opt.copts = '';
%
dkepath.g2jodec(1).tok.MUMPS.mex803 = [dkepath.g2jodec(1).tok.local_root,'MUMPS_4.10.0/MATLAB803'];%Where MUMPS matrix solver is stored (MEX function)
%
% host 1 : itm
%
dkepath.g2jodec(1).itm.local_root = '/afs/ipp-garching.mpg.de/home/j/jodec/Packages/';
dkepath.g2jodec(1).itm.temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.g2jodec(1).itm.mex713 = [dkepath.g2jodec(1).luke_root,'Project_DKE/MEX/Bin/itm/MATLAB713']; 
%
dkepath.g2jodec(1).itm.compiler_opt.helmex = NaN;
dkepath.g2jodec(1).itm.compiler_opt.fopts = '';
dkepath.g2jodec(1).itm.compiler_opt.copts = '';
%
dkepath.g2jodec(1).itm.MUMPS.mex713 = [dkepath.g2jodec(1).tok.local_root,'MUMPS_4.10.0/MATLAB713'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.g2jodec(1).remote(1).remoteid = 'IPP_TOKS';
dkepath.g2jodec(1).remote(1).schedulername = 'direct';
dkepath.g2jodec(1).remote(1).profilename = 'joan';
dkepath.g2jodec(1).remote(1).luke_root = dkepath.g2jodec(1).luke_root;% local cluster
dkepath.g2jodec(1).remote(1).link_mode = [];
dkepath.g2jodec(1).remote(1).cvsupdate = true;
dkepath.g2jodec(1).remote(1).cvsrights = '';
%
dkepath.g2jodec(1).remote(2).remoteid = 'EFDA_ITM';
dkepath.g2jodec(1).remote(2).schedulername = 'direct';
dkepath.g2jodec(1).remote(2).profilename = 'joan';
dkepath.g2jodec(1).remote(2).luke_root = dkepath.g2jodec(1).luke_root;% local cluster
dkepath.g2jodec(1).remote(2).link_mode = [];
dkepath.g2jodec(1).remote(2).cvsupdate = false;
dkepath.g2jodec(1).remote(2).cvsrights = '';
%
dkepath.g2jodec(1).remote(3).remoteid = 'EFDA_ITM';
dkepath.g2jodec(1).remote(3).schedulername = 'sge';
dkepath.g2jodec(1).remote(3).profilename = 'joan';
dkepath.g2jodec(1).remote(3).luke_root = dkepath.g2jodec(1).luke_root;% local cluster
dkepath.g2jodec(1).remote(3).link_mode = [];
dkepath.g2jodec(1).remote(3).cvsupdate = false;
dkepath.g2jodec(1).remote(3).cvsrights = '';
%
dkepath.jodec = dkepath.g2jodec(1);% AUG profile
%












