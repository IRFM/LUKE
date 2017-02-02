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
dkepath.machine = {'@s'};
dkepath.hostname = {'login.fuseu.eu','bdwn0529.marconi.cineca.it','bdwn0530.marconi.cineca.it','bdwn0531.marconi.cineca.it',...
    'bdwn0532.marconi.cineca.it','bdwn0533.marconi.cineca.it','bdwn0534.marconi.cineca.it','bdwn0535.marconi.cineca.it',...
    'bdwn0536.marconi.cineca.it','bdwn0537.marconi.cineca.it','bdwn0538.marconi.cineca.it','bdwn0539.marconi.cineca.it',...
    'bdwn0540.marconi.cineca.it','r040c03s06','r040c03s07','r040c03s08','r040c03s09','r040c03s10','r040c03s11','r040c03s12',...
    'r041c03s06','r041c03s07','r041c03s08','r041c03s09','r041c03s10','r041c03s11','r041c03s12','r040c03s01','r040c03s02',...
    'r040c03s03','r040c03s04','r040c03s05','r041c03s01','r041c03s02','r041c03s03','r041c03s04','r041c03s05'};%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
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
dkepath.g2yvesp(1).luke_root = '/gh/g2yvesp/public/LUKE/';
dkepath.g2yvesp(1).local_root = '/gh/g2yvesp/public/';
dkepath.g2yvesp(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%dkepath.g2yvesp(1).speclibpath.xml_io_tools = [dkepath.g2yvesp(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
dkepath.g2yvesp(1).speclibpath.ual = getenv('UAL');%UAL path in the ITM gateway. See the .bashrc file on the gateway to have the correct UAL version (must be consistent)
%
dkepath.g2yvesp(1).mex713 = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Bin/eurofusion/MATLAB713/'];
%
dkepath.g2yvesp(1).compiler_opt.libs.gfortran = [dkepath.g2yvesp(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.7.0','/',dkepath.machine,'/'];%extra libraries
dkepath.g2yvesp(1).compiler_opt.copts = '';
dkepath.g2yvesp(1).compiler_opt.fopts.mex713 = 'FC=''ifort''';%
dkepath.g2yvesp(1).compiler_opt.separatrice.mex713 = [' -largeArrayDims -L/afs/ipp-garching.mpg.de/common/soft/intel/ics/2011.0.013/composer_xe_2011_sp1.13.367/compiler/lib/intel64/ -lifcore -lirc -lsvml -L/afs/ipp/itm/switm/lib/lapack/3.4.2/lib/amd64_intel_12 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.g2yvesp(1).compiler_opt.helmex.mex713 = [' -compatibleArrayDims -L/afs/ipp-garching.mpg.de/common/soft/intel/ics/2011.0.013/composer_xe_2011_sp1.13.367/compiler/lib/intel64/ -lifcore -lirc -lsvml -L/afs/ipp/itm/switm/lib/lapack/3.4.2/lib/amd64_intel_12 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.g2yvesp(1).compiler_opt.fopts.mex713 = ' -largeArrayDims';
%
%dkepath.g2yvesp(1).MUMPS.mex800 = '/afs/ipp/itm/switm/lib/mumps/4.10.0_serial/matlab/R2012b/amd64_intel_12/';%Where MUMPS matrix solver is stored (MEX function)
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













