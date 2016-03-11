function dkepath = path_laptop_GUILLAUME_BROCHARD
%
% path definitions for macbook pro 2014 (Core i5 Intel) of Guillaume Brochard 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'macbookguillaume';
dkepath.hostname = 'macbookguillaume';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'guillaumebrochard';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Guillaume Brochard ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.guillaumebrochard(1).luke_root = [pwd,filesep];
dkepath.guillaumebrochard(1).local_root = [getenv('HOME'),'/Projets/'];
dkepath.guillaumebrochard(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.guillaumebrochard(1).mex805 = [dkepath.guillaumebrochard(1).luke_root,'Project_DKE/MEX/Bin/macbookguillaume/MATLAB805','/'];
dkepath.guillaumebrochard(1).mex806 = [dkepath.guillaumebrochard(1).luke_root,'Project_DKE/MEX/Bin/macbookguillaume/MATLAB806','/'];
%
dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran = [dkepath.guillaumebrochard(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.9.0','/',dkepath.machine,'/'];%extra libraries
dkepath.guillaumebrochard(1).compiler_opt.copts = '';
dkepath.guillaumebrochard(1).compiler_opt.fopts.mex805 = ' ';%-largeArrayDims';
dkepath.guillaumebrochard(1).compiler_opt.separatrice.mex805 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.guillaumebrochard(1).compiler_opt.helmex.mex805 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.guillaumebrochard(1).compiler_opt.fopts.mex806 = ' ';%-largeArrayDims';
dkepath.guillaumebrochard(1).compiler_opt.separatrice.mex806 = [' -largeArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.guillaumebrochard(1).compiler_opt.helmex.mex806 = [' -compatibleArrayDims /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libBLAS.dylib /System/Library/Frameworks/Accelerate.framework/Frameworks/vecLib.framework/Versions/Current/libLAPACK.dylib  ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortran.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgcc_s_1.dylib ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libgfortranbegin.a ',dkepath.guillaumebrochard(1).compiler_opt.libs.gfortran,'libquadmath.a '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
dkepath.guillaumebrochard(1).MUMPS.mex805 = [dkepath.guillaumebrochard(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.guillaumebrochard(1).MUMPS.mex806 = [dkepath.guillaumebrochard(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_gfortran/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
dkepath.guillaumebrochard(1).TSBASE.mex = [dkepath.guillaumebrochard(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
% LUKE documentation
%
dkepath.guillaumebrochard(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.guillaumebrochard(1).latex.env = '/usr/texbin/';% Latex environment variable ('which latex' and 'latex -v')
dkepath.guillaumebrochard(1).imagemagick.env = '/usr/local/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.guillaumebrochard(1).remote(1).remoteid = 'laptop_GUILLAUME_BROCHARD';
dkepath.guillaumebrochard(1).remote(1).schedulername = 'condor';
dkepath.guillaumebrochard(1).remote(1).profilename = 'guillaumebrochard';
dkepath.guillaumebrochard(1).remote(1).luke_root = dkepath.guillaumebrochard(1).luke_root;% local cluster
dkepath.guillaumebrochard(1).remote(1).link_mode = [];
dkepath.guillaumebrochard(1).remote(1).cvsupdate = false;% update done in 'direct' mode
%
dkepath.guillaumebrochard(1).remote(2) = dkepath.guillaumebrochard(1).remote(1);
dkepath.guillaumebrochard(1).remote(2).schedulername = 'direct';
dkepath.guillaumebrochard(1).remote(2).cvsupdate = true;
dkepath.guillaumebrochard(1).remote(2).cvsrights = 'chmod -R a+rx ./';
%
%dkepath.guillaumebrochard(1).remote(5).remoteid = 'CEA_ANDROMEDE';
%dkepath.guillaumebrochard(1).remote(5).schedulername = 'pbs';
%dkepath.guillaumebrochard(1).remote(5).profilename = 'YP105119';
%dkepath.guillaumebrochard(1).remote(5).luke_root = '/home/YP105119/LUKE/';
%dkepath.guillaumebrochard(1).remote(5).link_mode = [];
%dkepath.guillaumebrochard(1).remote(5).cvsupdate = false;% update done in 'direct' mode
%
%dkepath.guillaumebrochard(1).remote(6) = dkepath.guillaumebrochard(1).remote(5);
%dkepath.guillaumebrochard(1).remote(6).schedulername = 'direct';
%dkepath.guillaumebrochard(1).remote(6).cvsupdate = true;% update done in 'direct' mode
%dkepath.guillaumebrochard(1).remote(6).cvsrights = 'chmod -R a+rx ./';
%
